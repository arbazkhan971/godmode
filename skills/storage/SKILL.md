---
name: storage
description: |
  File storage and CDN skill. Activates when user needs to design or implement file storage systems. Covers object storage (S3, GCS, Azure Blob), file upload architecture (presigned URLs, multipart, resumable), image and video processing pipelines, storage cost optimization, and backup and replication strategies. Triggers on: /godmode:storage, "file upload", "S3 bucket", "image processing", "storage optimization", "backup strategy", or when building features that handle user-generated content.
---

# Storage — File Storage & CDN

## When to Activate
- User invokes `/godmode:storage`
- User says "file upload", "S3 bucket", "object storage", "presigned URL"
- User says "image processing", "video transcoding", "thumbnail generation"
- User says "storage costs too high", "optimize storage", "lifecycle policy"
- User says "backup strategy", "replication", "disaster recovery for files"
- Application needs to accept, store, or serve user-uploaded files
- Media processing pipeline needs design or optimization

## Workflow

### Step 1: Storage Requirements Discovery
Identify file storage needs and constraints:

```
STORAGE REQUIREMENTS:
┌──────────────────────────────────────────────────────────┐
│  File Types:                                              │
│    Images: <jpg, png, webp, svg>                          │
│    Documents: <pdf, docx, xlsx>                           │
│    Video: <mp4, webm>                                     │
│    Audio: <mp3, wav>                                      │
│    Other: <csv, json, zip>                                │
│                                                           │
│  Upload Constraints:                                      │
│    Max file size: <size>                                   │
│    Max files per request: <N>                              │
│    Allowed MIME types: <list>                              │
│    Authentication: <required | public>                     │
│                                                           │
│  Access Patterns:                                         │
│    Write frequency: <N uploads/day>                        │
│    Read frequency: <N downloads/day>                       │
│    Read/Write ratio: <N:1>                                 │
│    Geographic distribution: <regions>                      │
│    Latency requirements: <ms for first byte>               │
│                                                           │
│  Retention:                                               │
│    Hot storage: <duration> (frequently accessed)           │
│    Warm storage: <duration> (occasionally accessed)        │
│    Cold/archive: <duration> (rarely accessed)              │
│    Deletion policy: <soft delete | hard delete | retain>   │
│                                                           │
│  Compliance:                                              │
│    Data residency: <regions where data must stay>          │
│    Encryption: <at-rest | in-transit | both>               │
│    Audit logging: <required | optional>                    │
│    GDPR deletion: <required>                               │
└──────────────────────────────────────────────────────────┘
```

### Step 2: Object Storage Configuration
Set up the storage backend:

#### S3 Bucket Design
```
S3 BUCKET ARCHITECTURE:
┌──────────────────────────────────────────────────────────┐
│  Bucket: <app-name>-<env>-uploads                         │
│  Region: <region>                                         │
│  Versioning: Enabled                                      │
│  Encryption: AES-256 (SSE-S3) or KMS                      │
│                                                           │
│  Folder Structure:                                        │
│  /<tenant-id>/                                            │
│    /originals/<uuid>.<ext>     — Original uploads          │
│    /processed/<uuid>/                                     │
│      /thumb_200x200.<ext>      — Thumbnails                │
│      /medium_800x600.<ext>     — Medium size               │
│      /large_1920x1080.<ext>    — Large size                │
│    /documents/<uuid>.<ext>     — Documents                 │
│    /temp/<upload-id>/          — Multipart temp chunks      │
│                                                           │
│  Bucket Policy:                                           │
│  - Deny public access (all 4 block public access settings)│
│  - Allow CloudFront OAC for read access                   │
│  - Allow application IAM role for read/write              │
│  - Enforce SSL (deny non-HTTPS requests)                  │
│  - Enforce encryption (deny unencrypted uploads)          │
└──────────────────────────────────────────────────────────┘
```

#### Cross-Provider Comparison
```
OBJECT STORAGE COMPARISON:
┌──────────────────────────────────────────────────────────┐
│  Feature          │ S3        │ GCS       │ Azure Blob  │
│  ─────────────────────────────────────────────────────── │
│  Max object size  │ 5 TB      │ 5 TB      │ 190.7 TB    │
│  Multipart min    │ 5 MB      │ 5 MB      │ N/A (blocks)│
│  Consistency      │ Strong    │ Strong    │ Strong      │
│  Versioning       │ Yes       │ Yes       │ Yes         │
│  Lifecycle rules  │ Yes       │ Yes       │ Yes         │
│  Replication      │ CRR/SRR   │ Dual/Multi│ GRS/RA-GRS  │
│  CDN integration  │ CloudFront│ Cloud CDN │ Azure CDN   │
│  Presigned URLs   │ Yes       │ Yes       │ SAS tokens  │
│  Event triggers   │ Lambda    │ Functions │ Functions   │
│  Storage classes  │ 6 tiers   │ 4 tiers   │ 4 tiers     │
### Step 3: File Upload Architecture
Design secure, scalable upload flows:

#### Presigned URL Upload (Recommended for Direct-to-Storage)
```
PRESIGNED URL FLOW:
┌────────┐     ┌──────────┐     ┌────────┐
│ Client │     │ API      │     │ S3/GCS │
└───┬────┘     └────┬─────┘     └───┬────┘
    │               │               │
    │ 1. Request    │               │
    │   upload URL  │               │
    ├──────────────>│               │
    │               │               │
    │               │ 2. Generate   │
    │               │   presigned   │
    │               │   URL         │
    │               │               │
    │ 3. Return     │               │
    │   presigned   │               │
    │<──────────────┤               │
    │               │               │
    │ 4. Upload     │               │
    │   directly    │               │
    │   to storage  │               │
    ├───────────────────────────────>
    │               │               │
    │               │ 5. S3 Event   │
    │               │   notification│
    │               │<──────────────┤
    │               │               │
    │               │ 6. Process    │
    │               │   (validate,  │
    │               │    resize,    │
    │               │    scan)      │
    │               │               │
    │ 7. Confirm    │               │
    │   upload done │               │
    │<──────────────┤               │
    └───────────────┘               │
```

```typescript
// Server: Generate presigned URL
async function generateUploadUrl(req: Request): Promise<UploadUrlResponse> {
  const { filename, contentType, fileSize } = req.body;

  // Validate file type and size
  if (!ALLOWED_MIME_TYPES.includes(contentType)) {
    throw new BadRequestError(`File type ${contentType} not allowed`);
  }
  if (fileSize > MAX_FILE_SIZE) {
    throw new BadRequestError(`File exceeds max size of ${MAX_FILE_SIZE}`);
  }

  const fileId = crypto.randomUUID();
  const key = `${req.tenantId}/originals/${fileId}/${sanitizeFilename(filename)}`;

  const presignedUrl = await s3.getSignedUrl('putObject', {
    Bucket: UPLOAD_BUCKET,
    Key: key,
    ContentType: contentType,
    ContentLength: fileSize,
    Expires: 3600,                          // 1 hour expiry
    Metadata: {
      'uploaded-by': req.userId,
      'tenant-id': req.tenantId,
      'original-filename': filename,
    },
    Conditions: [
      ['content-length-range', 1, MAX_FILE_SIZE],
    ],
  });

  // Store upload record in database
  await db.uploads.create({
    id: fileId,
    userId: req.userId,
    tenantId: req.tenantId,
    filename,
    contentType,
    fileSize,
    key,
    status: 'pending',
  });

  return { uploadUrl: presignedUrl, fileId, key };
}
```

#### Multipart Upload (Large Files)
```
MULTIPART UPLOAD FLOW:
┌──────────────────────────────────────────────────────────┐
│  Phase 1: INITIATE                                        │
│  - Client requests multipart upload                       │
│  - Server creates upload session, returns upload ID       │
│  - Server generates presigned URLs for each part          │
│                                                           │
│  Phase 2: UPLOAD PARTS                                    │
│  - Client splits file into 5-100 MB chunks                │
│  - Client uploads each chunk in parallel (3-5 concurrent) │
│  - Client retries failed chunks individually              │
│  - Client reports progress per chunk                      │
│                                                           │
│  Phase 3: COMPLETE                                        │
│  - Client sends list of part ETags to server              │
│  - Server calls CompleteMultipartUpload                    │
│  - Server validates assembled file (checksum, size)       │
│  - Server triggers post-upload processing                 │
│                                                           │
│  ABORT (on failure or timeout):                           │
│  - AbortMultipartUpload cleans up partial chunks          │
│  - Lifecycle rule auto-aborts incomplete uploads > 24h    │
├──────────────────────────────────────────────────────────┤
│  Chunk size: 10 MB (balance between retry cost and speed) │
│  Max concurrent: 5 (avoid browser connection limits)      │
│  Retry policy: 3 retries per chunk, exponential backoff   │
│  Progress: (completed chunks / total chunks) * 100        │
└──────────────────────────────────────────────────────────┘
```

#### Resumable Upload (Unstable Connections)
```
RESUMABLE UPLOAD (tus protocol):
┌──────────────────────────────────────────────────────────┐
│  Protocol: tus v1.0.0 (https://tus.io)                    │
│                                                           │
│  1. POST /uploads                                         │
│     Upload-Length: <total-size>                            │
│     Upload-Metadata: filename <base64>, type <base64>     │
│     -> 201 Created, Location: /uploads/<id>               │
│                                                           │
│  2. PATCH /uploads/<id>                                   │
│     Upload-Offset: <current-offset>                       │
│     Content-Type: application/offset+octet-stream         │
│     [binary chunk data]                                   │
│     -> 204 No Content, Upload-Offset: <new-offset>        │
│                                                           │
│  3. HEAD /uploads/<id>  (resume after disconnect)         │
│     -> 200 OK, Upload-Offset: <server-offset>            │
│     Client resumes from server offset                     │
│                                                           │
│  Benefits:                                                │
│  - Survives network disconnects                           │
│  - Client resumes from last byte received by server       │
│  - Works on mobile and unstable connections               │
│  - Open protocol with client libraries for all platforms  │
└──────────────────────────────────────────────────────────┘
```

### Step 4: Image and Video Processing Pipeline
Design media processing workflows:

#### Image Processing Pipeline
```
IMAGE PROCESSING PIPELINE:
┌────────┐    ┌────────┐    ┌──────────┐    ┌─────────┐
│ Upload │───>│ Validate│───>│ Process  │───>│ Store   │
│ (S3)   │    │ & Scan │    │ & Resize │    │ Variants│
└────────┘    └────────┘    └──────────┘    └─────────┘
     │              │              │               │
  S3 Event     Virus scan    Sharp/ImageMagick   S3 + CDN
  trigger      MIME check    Generate variants    serve

PROCESSING STEPS:
  1. VALIDATE
     - Verify MIME type matches file header (not just extension)
     - Scan for malware (ClamAV or commercial scanner)
     - Check dimensions and file size
     - Strip EXIF data (privacy — GPS coordinates, camera info)

  2. GENERATE VARIANTS
     ┌───────────────────────────────────────────────────┐
     │  Variant     │ Dimensions  │ Quality │ Format     │
     │  ─────────────────────────────────────────────── │
     │  thumbnail   │ 200x200     │ 80%     │ webp, jpg  │
     │  medium      │ 800x600     │ 85%     │ webp, jpg  │
     │  large       │ 1920x1080   │ 90%     │ webp, jpg  │
     │  original    │ (preserved) │ 100%    │ (original) │
     └───────────────────────────────────────────────────┘

  3. OPTIMIZATION
     - Convert to WebP (30-50% smaller than JPEG)
     - Generate AVIF for modern browsers (additional 20% savings)
     - Preserve original as fallback
     - Generate blur placeholder (< 1 KB, base64 inline)

  4. SERVE
     - CDN with Accept header content negotiation
     - <picture> element with srcset for responsive images
     - Lazy loading with blur-up placeholder
```

```typescript
// Image processing with Sharp
async function processImage(key: string): Promise<ProcessedImage> {
  const original = await s3.getObject({ Bucket: BUCKET, Key: key }).promise();
  const image = sharp(original.Body as Buffer);
  const metadata = await image.metadata();

  // Strip EXIF data
  image.rotate();  // Auto-orient from EXIF, then strip

  const variants = await Promise.all([
    // Thumbnail
    image.clone().resize(200, 200, { fit: 'cover' })
      .webp({ quality: 80 }).toBuffer(),
    // Medium
    image.clone().resize(800, 600, { fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 85 }).toBuffer(),
    // Large
    image.clone().resize(1920, 1080, { fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 90 }).toBuffer(),
    // Blur placeholder
    image.clone().resize(20, 20, { fit: 'inside' })
      .blur(10).webp({ quality: 20 }).toBuffer(),
  ]);

  // Upload all variants to S3
  const baseKey = key.replace('/originals/', '/processed/').replace(/\.[^.]+$/, '');
  await Promise.all([
    s3.putObject({ Bucket: BUCKET, Key: `${baseKey}/thumb.webp`, Body: variants[0], ContentType: 'image/webp', CacheControl: 'public, max-age=31536000' }).promise(),
    s3.putObject({ Bucket: BUCKET, Key: `${baseKey}/medium.webp`, Body: variants[1], ContentType: 'image/webp', CacheControl: 'public, max-age=31536000' }).promise(),
    s3.putObject({ Bucket: BUCKET, Key: `${baseKey}/large.webp`, Body: variants[2], ContentType: 'image/webp', CacheControl: 'public, max-age=31536000' }).promise(),
  ]);

  return {
    id: extractFileId(key),
    original: { key, width: metadata.width, height: metadata.height },
    variants: { thumb: `${baseKey}/thumb.webp`, medium: `${baseKey}/medium.webp`, large: `${baseKey}/large.webp` },
    placeholder: `data:image/webp;base64,${variants[3].toString('base64')}`,
  };
}
```

#### Video Processing Pipeline
```
VIDEO PROCESSING PIPELINE:
┌────────────────────────────────────────────────────────────┐
│  1. UPLOAD (multipart, resumable for large files)          │
│     -> S3 originals bucket                                 │
│                                                            │
│  2. VALIDATE                                               │
│     - Verify container format (MP4, WebM, MOV)             │
│     - Check codec (H.264, H.265, VP9, AV1)                │
│     - Verify duration < max allowed                        │
│     - Scan for malware                                     │
│                                                            │
│  3. TRANSCODE (AWS MediaConvert / FFmpeg)                  │
│     ┌──────────────────────────────────────────────────┐  │
│     │  Preset      │ Resolution │ Bitrate  │ Format    │  │
│     │  ──────────────────────────────────────────────  │  │
│     │  720p        │ 1280x720   │ 2.5 Mbps │ H.264/MP4│  │
│     │  1080p       │ 1920x1080  │ 5 Mbps   │ H.264/MP4│  │
│     │  4K          │ 3840x2160  │ 15 Mbps  │ H.265/MP4│  │
│     │  HLS playlist│ Adaptive   │ Variable │ HLS/fMP4 │  │
│     └──────────────────────────────────────────────────┘  │
│                                                            │
│  4. GENERATE ASSETS                                        │
│     - Thumbnail at 3 different timestamps                  │
│     - Preview GIF (first 3 seconds, 320px wide)            │

### Step 5: Storage Cost Optimization
Analyze and reduce storage costs:

```
STORAGE COST ANALYSIS:
┌──────────────────────────────────────────────────────────┐
│  Current Monthly Cost: $<amount>                          │
│                                                           │
│  Breakdown:                                               │
│  Storage:     $<amount> (<N> TB at $<rate>/GB)            │
│  Requests:    $<amount> (<N>M GET, <M>K PUT)              │
│  Egress:      $<amount> (<N> TB transferred)              │
│  Processing:  $<amount> (Lambda/MediaConvert)             │
│                                                           │
│  Optimization Opportunities:                              │
│  ┌────────────────────────────────────────────────────┐  │
│  │ Action                 │ Savings  │ Risk    │ Effort│  │
│  │ ────────────────────────────────────────────────── │  │
│  │ Lifecycle to IA (90d)  │ 40%      │ Low     │ Low   │  │
│  │ Lifecycle to Glacier   │ 80%      │ Medium  │ Low   │  │
│  │   (365d)               │          │         │       │  │
│  │ Delete incomplete      │ 5%       │ None    │ Low   │  │
│  │   multipart uploads    │          │         │       │  │
│  │ Compress before store  │ 30%      │ Low     │ Med   │  │
│  │ Deduplicate files      │ 15%      │ Low     │ Med   │  │
│  │ Serve via CDN (reduce  │ 50%      │ None    │ Med   │  │
│  │   S3 egress)           │ (egress) │         │       │  │
│  │ Delete orphaned files  │ 10%      │ Low     │ Med   │  │
│  │ WebP conversion        │ 30%      │ None    │ Med   │  │
│  │   (images)             │ (storage)│         │       │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Projected monthly cost after optimization: $<amount>     │
│  Projected savings: $<amount>/month (<N>% reduction)      │
└──────────────────────────────────────────────────────────┘
```

#### Lifecycle Policy
```json
{
  "Rules": [
    {
      "ID": "transition-to-ia",
      "Status": "Enabled",
      "Filter": { "Prefix": "" },
      "Transitions": [
        {
          "Days": 90,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 365,
          "StorageClass": "GLACIER_IR"
        },
        {
          "Days": 730,
          "StorageClass": "DEEP_ARCHIVE"
        }
      ]
    },
    {
      "ID": "cleanup-incomplete-uploads",
      "Status": "Enabled",
      "Filter": { "Prefix": "" },
      "AbortIncompleteMultipartUpload": {
        "DaysAfterInitiation": 1
      }
    },
    {
      "ID": "expire-temp-files",
      "Status": "Enabled",
      "Filter": { "Prefix": "temp/" },
      "Expiration": { "Days": 1 }
    },
    {
      "ID": "delete-old-versions",
      "Status": "Enabled",
      "Filter": { "Prefix": "" },
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 30
      }
    }
  ]
}
```

### Step 6: Backup and Replication Strategies
Design data durability and disaster recovery:

```
BACKUP AND REPLICATION STRATEGY:
┌──────────────────────────────────────────────────────────┐
│  Tier 1: SAME-REGION REDUNDANCY (automatic)               │
│  S3: 11 nines durability across 3+ AZs                    │
│  GCS: Dual-region or multi-region                          │
│  Azure: LRS (3 copies) or ZRS (3 AZ copies)               │
│                                                           │
│  Tier 2: CROSS-REGION REPLICATION                          │
│  Primary: <region-1>                                      │
│  Replica: <region-2>                                      │
│  Mode: Async replication (seconds of lag)                  │
│  Scope: Entire bucket or prefix-filtered                   │
│  Purpose: Disaster recovery, regional compliance           │
│                                                           │
│  Tier 3: CROSS-ACCOUNT BACKUP                              │
│  Backup account: <account-id> (separate AWS account)       │
│  S3 Object Lock: Compliance mode (immutable)               │
│  Retention: <N> days minimum                               │
│  Purpose: Protection against account compromise            │
│                                                           │
│  Recovery Targets:                                        │
│  RPO (Recovery Point Objective): <time>                    │
│  RTO (Recovery Time Objective): <time>                     │
│                                                           │
│  Backup Testing:                                          │
│  Frequency: Monthly restore test                          │
│  Scope: Random sample of <N> files                        │
│  Verification: Checksum comparison with originals         │
└──────────────────────────────────────────────────────────┘
```

#### Replication Configuration
```yaml
# S3 Cross-Region Replication (Terraform)
resource "aws_s3_bucket_replication_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    filter {}  # Replicate everything

    destination {
      bucket        = aws_s3_bucket.uploads_replica.arn
      storage_class = "STANDARD_IA"    # Save costs on replica

      encryption_configuration {
        replica_kms_key_id = aws_kms_key.replica.arn
      }

      metrics {
        status = "Enabled"
        event_threshold {
          minutes = 15
        }
      }

      replication_time {
        status = "Enabled"
        time {
          minutes = 15    # S3 Replication Time Control (RTC)
        }
      }
    }

    delete_marker_replication {
      status = "Enabled"
    }
  }
}
```

### Step 7: Commit and Report
```
1. Save storage configuration in appropriate locations:
   - Bucket config: `infra/storage/` or Terraform modules
   - Upload service: `src/services/upload/` or `src/lib/storage/`
   - Processing pipeline: `src/services/media/` or Lambda functions
   - Lifecycle policies: `infra/storage/lifecycle.json`
2. Commit: "storage: <description> — <components configured>"
3. If upload architecture: "storage: file upload — presigned URL flow with <N> variants"
4. If optimization: "storage: optimize — lifecycle policies, projected <N>% cost reduction"
```

## Key Behaviors

1. **Never accept uploads through your API server.** Use presigned URLs for direct-to-storage uploads. Your server should never be a proxy for file transfers — it creates a bottleneck and wastes compute.
2. **Validate on the server side, not the client.** Client-side validation is for UX. Server-side validation (MIME type sniffing, file header inspection, virus scanning) is for security.
3. **Strip EXIF data from images.** EXIF contains GPS coordinates, camera serial numbers, and timestamps. Serving user photos with EXIF data is a privacy violation.
4. **Use content-addressable storage when possible.** Hash the file content for the key. This gives you automatic deduplication and cache-friendly immutable URLs.
5. **Set lifecycle policies from day one.** Storage costs grow silently. Transition to IA after 90 days, Glacier after a year. Auto-delete incomplete multipart uploads after 24 hours.
6. **Serve through CDN, not directly from the bucket.** CDN reduces egress costs, improves latency, and adds a caching layer. Never expose your bucket URL publicly.
7. **Generate image variants at upload time, not at request time.** On-demand resizing adds latency and compute cost to every request. Pre-generate standard sizes and cache them.
8. **Test backup restores regularly.** A backup you have never tested restoring is not a backup. Run monthly restore tests on random file samples.

## Example Usage

### Designing a file upload system
```
User: /godmode:storage Design file upload for our social media app

Storage: Analyzing requirements...

Application: Social media app (images and short videos)
Upload types: JPEG, PNG, MP4 (max 60s video)
Scale: ~50K uploads/day, ~2M views/day

Architecture:
  1. Client requests presigned URL from API
  2. Client uploads directly to S3 (multipart for > 10 MB)
  3. S3 event triggers Lambda processing pipeline
  4. Lambda validates, scans, and generates variants
  5. Variants stored in processed/ prefix
  6. Served via CloudFront CDN

Image variants: thumb (200x200), feed (600x600), full (1200x1200)
Video variants: 480p, 720p, HLS adaptive streaming
Blur placeholders: Base64 inline (< 1 KB)

Storage design:
  Bucket: myapp-prod-media
  Encryption: SSE-S3
  Versioning: Enabled
  Lifecycle: IA after 90 days, Glacier IR after 365 days
  Replication: CRR to us-west-2

Estimated costs:
  Storage: $230/month (10 TB, lifecycle-optimized)
  Requests: $45/month (2M GETs, 50K PUTs)
  Processing: $60/month (Lambda + MediaConvert)
  CDN egress: $170/month (2 TB via CloudFront)
## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full storage architecture design and audit |
| `--upload` | File upload architecture design only |
| `--process` | Media processing pipeline design only |
| `--optimize` | Storage cost analysis and optimization |
| `--backup` | Backup and replication strategy only |
| `--lifecycle` | Generate lifecycle policies only |
| `--migrate` | Migrate between storage providers |
| `--provider <name>` | Target provider (aws, gcp, azure) |
| `--audit` | Audit current storage for waste and risk |

## HARD RULES

1. **NEVER proxy file uploads through the API server.** Use presigned URLs for direct-to-storage uploads. The server generates the URL; the client uploads directly.
2. **NEVER store files on the application server filesystem.** Local storage is not durable, not scalable, and lost on deploy. Use object storage (S3, GCS, Azure Blob).
3. **NEVER trust file extensions or Content-Type headers.** Inspect file headers (magic bytes) to determine actual file type. A `.jpg` with PHP file headers is an attack.
4. **NEVER serve files directly from the bucket URL.** Use a CDN. Direct bucket access is slower, more expensive (egress), and exposes your bucket name.
5. **NEVER skip virus scanning on user uploads.** Scan with ClamAV or a commercial scanner before making files available to other users.
6. **ALWAYS strip EXIF data from images.** EXIF contains GPS coordinates, camera serial numbers, and timestamps -- serving it is a privacy violation.
7. **ALWAYS set lifecycle policies from day one.** Transition to IA after 90 days, Glacier after a year. Auto-delete incomplete multipart uploads after 24 hours.
8. **ALWAYS generate image variants at upload time**, not at request time. On-demand resizing adds latency and unpredictable cost to every request.

## Auto-Detection

On activation, detect the storage context:

```bash
# Detect cloud provider
ls ~/.aws/credentials ~/.config/gcloud/application_default_credentials.json 2>/dev/null
grep -r "aws-sdk\|@aws-sdk\|@google-cloud/storage\|@azure/storage-blob" package.json 2>/dev/null

# Detect existing storage configuration
grep -rl "S3Client\|S3\|getSignedUrl\|presignedUrl\|Storage\|BlobServiceClient" src/ --include="*.ts" --include="*.js" 2>/dev/null | head -5

# Detect upload handling
grep -rl "multer\|busboy\|formidable\|multipart" src/ --include="*.ts" --include="*.js" 2>/dev/null | head -5

# Detect image processing
grep -r "sharp\|imagemagick\|jimp\|canvas" package.json 2>/dev/null

# Detect CDN configuration
ls cdn.* cloudfront.* 2>/dev/null
grep -r "CloudFront\|cloudflare\|cdn" infra/ terraform/ 2>/dev/null | head -5
```

## Iteration Protocol
```
WHILE storage implementation is incomplete:
  1. REVIEW — check current state: which components exist (client, presigned URLs, CDN, lifecycle), which are missing
  2. IMPLEMENT — pick next component from the plan, implement with tests
  3. TEST — upload a test file end-to-end: presigned URL generation → upload → CDN serving → cleanup
  4. VERIFY — check: file accessible via CDN, original not publicly accessible, lifecycle rules active
  IF tests pass AND component works: commit, move to next component
  IF tests fail: check IAM permissions, bucket policy, CORS config. Fix and re-test (max 3 attempts)
STOP: all components implemented, end-to-end upload works, CDN serving verified, lifecycle rules active
```
## TSV Logging
After each workflow step, append a row to `.godmode/storage-results.tsv`:
```
STEP\tCOMPONENT\tPROVIDER\tSTATUS\tDETAILS
1\tstorage-client\ts3\tcreated\tS3Client wrapper with upload, download, delete, presign
2\tpresigned-urls\ts3\tcreated\tPUT for upload, GET for download, 15min expiry
3\tcdn\tcloudfront\tconfigured\tdistribution with OAC, cache policy, custom domain
4\tlifecycle\ts3\tconfigured\tincomplete multipart cleanup 24h, transition to IA 90d
5\timage-processing\tsharp\tcreated\tthumbnail + medium + large variants on upload
```
Print final summary: `Storage: {provider}, bucket: {name}. CDN: {cdn_provider}. Presigned URLs: {yes/no}. Image processing: {yes/no}. Lifecycle: {rules}. Backup: {strategy}.`

## Success Criteria
All of these must be true before marking the task complete:
1. Storage client works: upload, download, delete, and presigned URL generation all succeed with test files.
2. Presigned URLs expire correctly (test: URL works before expiry, returns 403 after expiry).
3. CDN serves files with correct cache headers (`Cache-Control: public, max-age=31536000, immutable` for hashed filenames).
4. Direct bucket access is blocked (only CDN or presigned URLs can access files).
5. Lifecycle rules are active: incomplete multipart uploads cleaned up, old versions transitioned/expired.
6. Image processing (if applicable) generates all required variants and strips EXIF metadata.
7. CORS configuration allows uploads from the application's domain(s) only.
8. All credentials come from environment variables or IAM roles, not hardcoded.

## Error Recovery
| Failure | Action |
|---------|--------|
| Access denied (403) | Check IAM policy: does the role/user have `s3:PutObject`, `s3:GetObject` on the correct bucket ARN? Check bucket policy for explicit denies. Check VPC endpoint policy if applicable. |
| CORS error on upload | Verify bucket CORS config allows the origin, method (PUT), and headers (Content-Type, x-amz-*). CORS rules are cached by browsers — test in incognito. |
| Presigned URL fails | Check clock skew between server and AWS (<15min). Verify signing credentials match the bucket region. Check that the URL hasn't expired. |
| CDN returns stale content | Invalidate CDN cache: `aws cloudfront create-invalidation`. For future: use content-hashed filenames to avoid cache invalidation entirely. |
| Image processing OOM | Reduce Sharp concurrency: `sharp.concurrency(1)`. Process large images in a background job, not in the request handler. Set memory limits on the worker. |
| Upload timeout | For files >100MB, switch to multipart upload. Set appropriate timeout on the client. Implement resumable uploads (tus protocol) for unreliable networks. |
## Multi-Agent Dispatch
```
Agent 1 (worktree: storage-core):
  - Configure storage bucket with IAM, CORS, lifecycle rules
  - Build storage client wrapper with upload, download, delete, presign
  - Set up CDN with origin access control

Agent 2 (worktree: storage-processing):
  - Implement image processing pipeline (variants, EXIF strip, format conversion)
  - Add virus scanning integration (ClamAV or cloud-native)
  - Build video processing if needed (thumbnails, transcoding)

Agent 3 (worktree: storage-api):
  - Create upload API endpoints (presigned URL generation, upload confirmation)
  - Implement file metadata tracking in database
  - Add download endpoints with access control

## Storage Optimization Audit

Comprehensive audit of access patterns, compression effectiveness, and lifecycle policy coverage:

```
STORAGE OPTIMIZATION AUDIT:
Provider: <AWS S3 | GCS | Azure Blob>
Bucket: <bucket name>
Audit date: <date>
Total storage: <size>
Monthly cost: <amount>

ACCESS PATTERN ANALYSIS:
┌──────────────────────────────────────────────────────────────────┐
│  Time Window     │ Objects Accessed │ % of Total │ Storage Class  │
├──────────────────────────────────────────────────────────────────┤
│  Last 7 days     │ <N>              │ <pct>%     │ Should be STD  │
│  8-30 days       │ <N>              │ <pct>%     │ Should be STD  │
│  31-90 days      │ <N>              │ <pct>%     │ Should be IA   │
│  91-365 days     │ <N>              │ <pct>%     │ Should be IA   │
│  > 365 days      │ <N>              │ <pct>%     │ Should be Glac │
│  Never accessed  │ <N>              │ <pct>%     │ Delete or Glac │
└──────────────────────────────────────────────────────────────────┘

  Access pattern checks:
    1. QUERY S3 Storage Lens / GCS Insights for access frequency per prefix
    2. IDENTIFY hot prefixes (frequently accessed) vs cold prefixes (rarely accessed)
    3. IDENTIFY orphaned objects (no DB reference, no recent access)
    4. MEASURE read/write ratio per prefix
    5. MAP access patterns to optimal storage class:
       - Frequent access (daily): S3 Standard / GCS Standard
       - Infrequent access (monthly): S3 Standard-IA / GCS Nearline
       - Archive (yearly): S3 Glacier IR / GCS Coldline
       - Deep archive (compliance): S3 Glacier Deep / GCS Archive
    6. CALCULATE projected savings from reclassification

  Access pattern anomaly detection:
    - ALERT if write frequency increases > 50% week-over-week (possible runaway process)
    - ALERT if read frequency drops > 30% (possible broken CDN or stale cache)
    - ALERT if storage growth rate exceeds projected budget

## Platform Fallback
Run tasks sequentially with branch isolation if `Agent()` or `EnterWorktree` unavailable. See `adapters/shared/sequential-dispatch.md`.
## Keep/Discard Discipline
```
After EACH storage configuration change:
  1. TEST: Upload a file end-to-end — presigned URL, upload, CDN serving, cleanup.
  2. VERIFY: Direct bucket access blocked, lifecycle rules active, CORS correct.
  3. DECIDE:
     - KEEP if: end-to-end test passes AND no access regressions AND cost projection improved
     - DISCARD if: upload fails OR direct bucket access possible OR CORS breaks
  4. COMMIT kept changes. Revert discarded changes before next component.

Never keep a storage change that exposes the bucket directly or breaks uploads.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - End-to-end upload works (presigned URL -> upload -> CDN serving)
  - Direct bucket access blocked, lifecycle rules active
  - All credentials from environment variables or IAM roles
  - User explicitly requests stop

DO NOT STOP just because:
  - Cost optimization is incomplete (lifecycle rules are a start)
  - Video processing is not yet implemented (if not requested)
```