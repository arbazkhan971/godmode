---
name: upload
description: >
  File upload handling, image optimization, media
  processing, signed URLs, multipart, virus scanning.
---

# Upload -- File Upload & Media Processing

## Activate When
- `/godmode:upload`, "file upload", "presigned URL"
- "multipart upload", "chunked", "resumable", "tus"
- "image optimization", "Sharp", "video processing"
- "virus scanning", "ClamAV", "MIME type check"

## Workflow

### Step 1: Requirements
```
File types: Images | Video | Docs | Audio | Archives
Max sizes: Images <10MB, Video <500MB, Docs <50MB
Processing: variants, transcoding, virus scan, EXIF
Storage: S3 | GCS | Azure Blob | R2 | local
CDN: CloudFront | Cloud CDN | Cloudflare
Scale: <uploads/day, peak concurrent>
```

### Step 2: Strategy Selection
```
IF < 10MB (images, docs): presigned PUT (default)
IF 10MB - 5GB (video): multipart (parallel chunks)
IF > 5GB or mobile: resumable (tus protocol)
WHEN server processing first: direct upload

PRESIGNED FLOW:
  Client requests URL {filename, type, size}
  -> Server validates type+size, creates DB record
  -> Generates presigned PUT (1hr expiry)
  -> Client PUTs directly to S3
  -> S3 event triggers worker
  -> Worker validates, scans, processes
```

### Step 3: Validation & Security
```
4 LAYERS:
1. Client-side (UX only): extension, MIME, size
   NEVER trust client validation.
2. Presign request (server gate): type allowlist,
   size limits per type, extension-type match,
   user quota, permissions
3. Post-upload (worker):
   Magic bytes (file-type lib) to verify true MIME
   ClamAV virus scan
   Check dimensions, verify not corrupted
   Strip EXIF metadata
4. Content moderation (optional): NSFW detection
```
```bash
# Detect existing upload libraries
grep -r "multer\|busboy\|sharp\|@aws-sdk/s3" \
  package.json 2>/dev/null
grep -r "clamav\|clamscan\|virus" \
  --include="*.ts" --include="*.yaml" -l 2>/dev/null
```
```
IF magic bytes mismatch declared type: reject
IF virus detected: delete immediately
IF scanner unavailable: quarantine (never serve)
IF EXIF present: strip with Sharp
  sharp(buf).rotate().withMetadata({
    orientation: undefined }).toBuffer()
```

### Step 4: Image Optimization
```
VARIANTS:
  placeholder: 20x20, 20% quality, base64 LQIP
  thumbnail: 200x200 crop, 80% quality
  small: 400w, 80%, medium: 800w, 85%
  large: 1600w, 90%, original: preserved
  Generate WebP + AVIF for each variant
  JPEG as fallback

TOOLS:
  Sharp/libvips (Node.js, fastest, low memory)
  Cloudinary (SaaS, URL-based transforms)
  imgproxy (self-hosted, Go, fast)
  FFmpeg (video + GIF)

Cache headers: max-age=31536000, immutable
```

### Step 5: Video Processing
```
Validate with ffprobe: container, codec, duration.
Transcode presets:
  360p: 800Kbps H.264
  720p: 2.5Mbps H.264
  1080p: 5Mbps H.264
  4K: 15Mbps H.265 (optional)
HLS adaptive streaming: 6s segments, multi-quality.
Thumbnails at 10%, 50%, 90% of duration.
```

### Step 6: Database Schema
```
uploads table:
  id, user_id, original_filename, content_type,
  detected_type (magic bytes), file_size,
  checksum_sha256, storage_key (unique),
  status (pending|processing|ready|failed|quarantined),
  width, height, duration_seconds,
  placeholder (base64), variants (JSONB),
  virus_scan_status, exif_stripped,
  created_at, updated_at

Indexes: user_id, status, content_type,
  created_at DESC, expires_at
```

### Step 7: CDN & Serving
```
Client -> CDN (edge, <10ms hit) -> Origin -> S3

Private files:
  API checks permissions -> signed CDN URL
  (5-15min expiry) -> client fetches from CDN

IF public: CDN with immutable caching
IF private: signed URLs with short expiry
```

### Step 8: Orphan Cleanup
```
5 types: incomplete (pending >24h),
  incomplete S3 multipart (lifecycle rule),
  unreferenced (weekly reconciliation),
  soft-deleted past 30d retention,
  expired temporary uploads
Cron: hourly, 100 files per run, log every deletion.
```

### Step 9: Commit
Commit: `"upload: <desc> -- <components>"`

## Key Behaviors
1. **Never proxy uploads through API.** Presigned URLs.
2. **Validate server-side.** Magic bytes + virus scan.
3. **Strip EXIF from every image.** Privacy.
4. **Strategy by size.** <10MB/10-5GB/>5GB.
5. **Process at upload, not request time.**
6. **Always generate blur placeholder (LQIP).**
7. **Scan every upload.** Never serve unscanned.
8. **Cleanup from day one.** Stale uploads accumulate.
9. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER proxy uploads when presigned URLs available.
2. NEVER trust Content-Type or extension. Magic bytes.
3. ALWAYS scan for viruses before serving.
4. ALWAYS strip EXIF metadata from images.
5. NEVER serve uploads from same domain as app.
6. ALWAYS enforce size limits client + server.
7. NEVER use predictable filenames. UUID or hash.
8. ALWAYS implement orphan cleanup.

## TSV Logging
Log to `.godmode/upload-results.tsv`:
`step\tcomponent\tprovider\tstatus\tdetails`

## Output Format
Print: `Upload: pipeline {complete|partial}. Validation: {magic_bytes|ext}. Virus: {active|none}. CDN: {active|none}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
KEEP if: CDN accessible AND headers correct
  AND validation rejects bad files AND metadata in DB
DISCARD if: processing fails silently
  OR malicious file passes OR EXIF leaks
```

## Stop Conditions
```
STOP when:
  - End-to-end upload works
  - Validation by magic bytes active
  - Virus scanning active
  - User requests stop
```
