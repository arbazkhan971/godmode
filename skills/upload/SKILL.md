---
name: upload
description: File upload handling, image optimization, media processing, signed URLs, multipart uploads. Use when user mentions file upload, image upload, media processing, image optimization, Sharp, Cloudinary, S3 presigned URLs, multipart.
---

# Upload — File Upload & Media Processing

## When to Activate
- User invokes `/godmode:upload`
- User says "file upload", "image upload", "presigned URL", "direct upload"
- User says "multipart upload", "chunked upload", "resumable upload", "tus"
- User says "image optimization", "Sharp", "Cloudinary", "imgproxy"
- User says "video processing", "FFmpeg", "transcoding"
- User says "file validation", "virus scanning", "ClamAV", "MIME type check"
- User says "thumbnail generation", "blur placeholder", "LQIP"

## Workflow

### Step 1: Upload Requirements Discovery

```
UPLOAD REQUIREMENTS:
File types: Images (jpg/png/webp/gif/svg) | Video (mp4/webm) | Docs (pdf/docx) | Audio | Archives
Context: User-facing (profile/gallery/attachments) | Admin (bulk import/CMS) | API (programmatic)
Max sizes: Images <10MB, Video <500MB, Docs <50MB
Processing: Image variants, video transcoding, virus scanning, EXIF stripping
Storage: S3 | GCS | Azure Blob | R2 | local
CDN: CloudFront | Cloud CDN | Fastly | Cloudflare
Scale: uploads/day, total storage/year, peak concurrent
```

### Step 2: Upload Strategy Selection

- **< 10 MB (images, docs)**: Presigned URL (single PUT) — RECOMMENDED default
- **10 MB - 5 GB (video)**: Presigned URL + Multipart (parallel chunks, per-chunk retry)
- **> 5 GB or mobile/flaky**: Resumable (tus protocol)
- **Server processing first**: Direct upload to server

**Presigned URL flow**: Client requests upload URL {filename, type, size} → Server validates type+size, creates DB record (status: pending), generates presigned PUT URL → Client PUTs directly to S3 → S3 event triggers worker → Worker validates, scans, processes, resizes → Client polls/webhook for status.

Server-side: validate content type against allowlist, validate file size per type, validate extension matches type, generate UUID-based storage key (`uploads/{userId}/{uuid}/{sanitized}`), sign with 1-hour expiry, create DB record.

Client-side: XHR PUT with `upload.onprogress` for progress tracking, then POST confirm.

**Multipart upload flow**: Initiate (create session, generate presigned URLs for N parts at 10MB chunks) → Upload parts (5 concurrent, per-chunk retry 3x with backoff) → Complete (send part ETags, server calls CompleteMultipartUpload) → Abort on cancel/timeout. S3 lifecycle rule auto-aborts incomplete >24h.

**Resumable (tus protocol)**: Use `@tus/server` with S3Store on server, `tus-js-client` on client. CREATE (POST) → UPLOAD (PATCH, repeat) → RESUME (HEAD to get offset after disconnect). Client: `retryDelays: [0, 1000, 3000, 5000, 10000]`, `findPreviousUploads()` for resume.

### Step 3: File Validation & Security

4-layer validation pipeline:

1. **Client-side (UX only)**: Extension, MIME, size, dimension preview. Never trust.
2. **Presign request (server gate)**: Validate type allowlist, size limits, extension-type match, user quota, permissions.
3. **Post-upload (worker)**: Read magic bytes (`file-type` lib) to verify true MIME, compare against declared type, ClamAV virus scan, check image dimensions, verify not corrupted, strip EXIF/metadata.
4. **Content moderation (optional)**: NSFW detection (AWS Rekognition, Google Vision), OCR policy check.

**Magic byte validation**: Use `fileTypeFromBuffer()`, check detected type is allowed and matches declared type. Reject mismatches.

**Virus scanning**: ClamAV via `clamscan` — delete infected files immediately. If scanner fails, quarantine (never serve unscanned files).

**EXIF stripping**: `sharp(buffer).rotate().withMetadata({ orientation: undefined }).toBuffer()` — applies EXIF orientation then strips all metadata.

### Step 4: Image Optimization Pipeline

Variants: placeholder (20x20, 20% quality, base64 LQIP), thumbnail (200x200 crop, 80%), small (400w, 80%), medium (800w, 85%), large (1600w, 90%), original (preserved).

For each variant generate WebP + AVIF. Use `<picture>` element or Accept header for format negotiation. JPEG as fallback.

**Tools**: Sharp/libvips (Node.js, fastest, low memory — use for all server-side), Cloudinary (SaaS, URL-based transforms, no infra), imgproxy (self-hosted URL transform proxy, Go, fast), Pillow (Python), FFmpeg (video + GIF).

LQIP blur placeholder: 20x20 base64 image <1KB, inline in HTML/JSON, CSS `blur(20px) + scale`, swap to real image on load.

Cache headers: `Cache-Control: public, max-age=31536000, immutable`.

### Step 5: Video Processing Pipeline

Upload via multipart or tus. Validate with ffprobe (container, codec, duration, dimensions). Virus scan.

Transcode presets: 360p (800Kbps H.264), 720p (2.5Mbps), 1080p (5Mbps), optional 4K (15Mbps H.265). Generate HLS adaptive streaming (6s segments, multiple qualities, master playlist). Generate thumbnails at 10%, 50%, 90% of duration. Generate poster image and preview clip.

Managed alternatives: AWS MediaConvert, GCP Transcoder API, Cloudflare Stream, Mux, Bunny Stream.

### Step 6: Database Schema

`uploads` table: id, user_id, original_filename, filename (sanitized), content_type, detected_type (magic bytes), file_size, checksum_sha256, storage_key (unique), storage_bucket, status (pending/uploading/processing/ready/failed/quarantined/deleted), width, height, duration_seconds, placeholder (base64), variants (JSONB), virus_scan_status, exif_stripped, moderation_status, is_public, access_count, expires_at, deleted_at, created_at, updated_at.

Key indexes: user_id, status, content_type, created_at DESC, expires_at (WHERE NOT NULL), deleted_at (WHERE NULL).

### Step 7: Storage Backend & CDN

S3/R2/MinIO: `@aws-sdk/client-s3`, IAM auth, CloudFront with OAC. GCS: `@google-cloud/storage`, Cloud CDN. Azure: `@azure/storage-blob`, Azure CDN. Local: nginx with X-Accel-Redirect.

CDN serving: Client → CDN (edge, <10ms hit) → Origin (shield) → S3 (cold, +50-200ms miss).

Private files: API checks permissions → generates signed CDN URL (5-15min expiry) → client fetches from CDN.

### Step 8: Orphaned Upload Cleanup

5 types: incomplete uploads (pending >24h), incomplete S3 multipart (lifecycle rule + cron abort), unreferenced files (weekly S3-to-DB reconciliation), soft-deleted past retention (>30 days), expired temporary uploads.

Cron: hourly, 100 files per run, log every deletion, dry-run mode for new rules, alert if >threshold per run.

### Step 9: Commit
```
Commit: "upload: <description> — <components>"
Files: upload service, image processor worker, video processor worker, file validator, cleanup cron, DB migration
```

## Key Behaviors

1. **Never proxy uploads through your API server.** Use presigned URLs for direct-to-storage.
2. **Validate files server-side after upload.** Client checks are UX; post-upload validation (magic bytes, virus scan) is security.
3. **Strip EXIF from every image.** GPS coordinates, device serials, timestamps are privacy liabilities.
4. **Choose strategy by file size.** Single PUT <10MB. Multipart 10MB-5GB. Resumable (tus) for mobile/flaky.
5. **Process images at upload time, not request time.** Pre-generate all variants.
6. **Always generate blur placeholder (LQIP).** <1KB base64 that loads instantly.
7. **Scan every upload for malware.** ClamAV free. Never serve unscanned files.
8. **Run cleanup from day one.** Stale uploads accumulate silently.
9. **Serve through CDN with immutable caching.** Content-addressed, max-age=1year.
10. **Track every upload in the database.** DB is source of truth; S3 is just storage.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full upload architecture |
| `--presign` | Presigned URL flow only |
| `--multipart` | Multipart/chunked upload only |
| `--tus` | Resumable upload with tus |
| `--image` | Image optimization pipeline only |
| `--video` | Video processing pipeline only |
| `--validate` | File validation and security |
| `--cleanup` | Orphaned upload cleanup job |
| `--cdn` | CDN integration and serving |

## HARD RULES

1. NEVER proxy uploads through app server when presigned URLs are available.
2. NEVER trust Content-Type header or file extension. Validate magic bytes.
3. ALWAYS scan for viruses before making files accessible. Quarantine if scanner unavailable.
4. ALWAYS strip EXIF metadata from images before storage.
5. NEVER serve user uploads from same domain as your application (prevent cookie theft/XSS).
6. ALWAYS enforce file size limits on both client and server.
7. NEVER generate predictable file names. Use UUIDs or content hashes.
8. ALWAYS implement orphan cleanup.

## Auto-Detection

```bash
grep -r "multer\|busboy\|sharp\|@aws-sdk/s3\|@google-cloud/storage" package.json 2>/dev/null
grep -r "presigned\|putObject\|getSignedUrl" --include="*.ts" --include="*.js" -l 2>/dev/null | head -5
grep -r "clamav\|clamscan\|virus" --include="*.ts" --include="*.js" --include="*.yaml" -l 2>/dev/null | head -5
```

## TSV Logging
```
STEP	COMPONENT	PROVIDER	STATUS	DETAILS
1	presigned-urls	s3	created	PUT for upload, GET for download, 15min expiry
2	validation	custom	created	magic bytes, size limits, type whitelist
3	virus-scan	clamav	created	scan before public access
4	image-processing	sharp	created	4 variants + webp + EXIF strip
5	cdn-serving	cloudfront	configured	immutable cache headers, OAC
6	cleanup	cron	created	abort incomplete multipart after 24h
```
Print: `Uploads: {types}, max: {size}. Storage: {provider}. Processing: {pipeline}. CDN: {cdn}. Virus scan: {yes/no}. Resumable: {yes/no}.`

## Success Criteria
1. Presigned URL generation works for upload and download with correct expiry.
2. File validation rejects invalid types by magic bytes.
3. Virus scanning runs before files are accessible.
4. Image processing generates variants and strips EXIF.
5. CDN serves with correct cache headers (immutable).
6. Size limits enforced client-side and server-side.
7. Incomplete multipart uploads cleaned up automatically.
8. Upload metadata stored in database.

## Error Recovery
- **Presigned URL 403**: Check IAM permissions, bucket policy, clock skew (<15min), URL expiry, region match.
- **CORS error**: Verify bucket CORS allows origin, PUT method, Content-Type + x-amz-* headers.
- **Image processing fails**: Verify valid image via magic bytes. Check Sharp/libvips. Process in background job with memory limits.
- **Virus scanner false positive**: Check ClamAV signatures current. Quarantine for manual review.
- **Upload timeout**: Switch to multipart (>100MB) or tus (unreliable networks).
- **CDN stale content**: Use content-hashed filenames. Create CloudFront invalidation if needed.

## Iteration Protocol
```
WHILE incomplete: REVIEW → IMPLEMENT next component → TEST end-to-end → VERIFY (CDN, EXIF, variants, scan)
IF pass: commit | IF fail: fix (max 3 attempts)
STOP: end-to-end works, validation rejects bad files, virus scanning blocks malware
```

## Keep/Discard Discipline
```
KEEP if: CDN accessible, correct headers, validation rejects bad files, metadata in DB
DISCARD if: processing fails silently OR malicious file passes OR EXIF leaks
```

## Stop Conditions
```
STOP when: end-to-end upload works, validation by magic bytes, virus scanning active, or user stops
DO NOT STOP just because: video transcoding not done or cleanup cron not running
```

## Anti-Patterns
- Do NOT skip blur placeholder — blank space/layout shift during image load degrades UX.
- Do NOT store metadata only in S3 tags — use a database for querying/cleanup/serving.
- Do NOT generate video thumbnails only at start — first frame is often black. Use 10%/50%/90%.
- Do NOT skip adaptive bitrate for video — single quality forces mobile buffering or desktop low quality.

## Multi-Agent Dispatch
```
Agent 1 (upload-core): S3 bucket config, presigned URLs, file validation
Agent 2 (upload-processing): Image pipeline (variants, EXIF, formats, LQIP), virus scanning, video processing
Agent 3 (upload-serving): CDN config, upload confirmation API, cleanup automation
MERGE: core → processing → serving
```

## Platform Fallback
Run sequentially: storage config → presigned URLs → processing → CDN/cleanup. Branch per task.

## Output Format
Print: `Upload: pipeline {complete|partial}. Validation: {magic_bytes|extension_only}. Virus scan: {active|none}. CDN: {active|none}. Status: {DONE|PARTIAL}.`
