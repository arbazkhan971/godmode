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
  File Types:
  Images: <jpg, png, webp, svg>
  Documents: <pdf, docx, xlsx>
  Video: <mp4, webm>
  Audio: <mp3, wav>
  Other: <csv, json, zip>
  Upload Constraints:
  Max file size: <size>
  Max files per request: <N>
  Allowed MIME types: <list>
  Authentication: <required | public>
```

### Step 2: Object Storage Configuration
Set up the storage backend:

#### S3 Bucket Design
```
S3 BUCKET ARCHITECTURE:
  Bucket: <app-name>-<env>-uploads
  Region: <region>
  Versioning: Enabled
  Encryption: AES-256 (SSE-S3) or KMS
  Folder Structure:
  /<tenant-id>/
  /originals/<uuid>.<ext>     — Original uploads
  /processed/<uuid>/
  /thumb_200x200.<ext>      — Thumbnails
  /medium_800x600.<ext>     — Medium size
  /large_1920x1080.<ext>    — Large size
  /documents/<uuid>.<ext>     — Documents
```

#### Cross-Provider Comparison
```
OBJECT STORAGE COMPARISON:
| Feature | S3 | GCS | Azure Blob |
|---|---|---|---|
| Max object size | 5 TB | 5 TB | 190.7 TB |
| Multipart min | 5 MB | 5 MB | N/A (blocks) |
| Consistency | Strong | Strong | Strong |
| Versioning | Yes | Yes | Yes |
| Lifecycle rules | Yes | Yes | Yes |
| Replication | CRR/SRR | Dual/Multi | GRS/RA-GRS |
| CDN integration | CloudFront | Cloud CDN | Azure CDN |
| Presigned URLs | Yes | Yes | SAS tokens |
| Event triggers | Lambda | Functions | Functions |
| Storage classes | 6 tiers | 4 tiers | 4 tiers |
### Step 3: File Upload Architecture
Design secure, scalable upload flows:

#### Presigned URL Upload (Recommended for Direct-to-Storage)
```
PRESIGNED URL FLOW:
┌────────┐     ┌──────────┐     ┌────────┐
| Client |  | API |  | S3/GCS |
└───┬────┘     └────┬─────┘     └───┬────┘
| 1. Request |  |
|---|---|
| upload URL |  |
    ├──────────────>│               │
|  | 2. Generate |
|  | presigned |
|  | URL |
| 3. Return |  |
|---|---|
| presigned |  |
  <──────────────┤
| 4. Upload |  |
|---|---|
| directly |  |
| to storage |  |
    ├───────────────────────────────>
|  | 5. S3 Event |
|  | notification |
    │               │<──────────────┤
|  | 6. Process |
|  | (validate, |
|  | resize, |
|  | scan) |
| 7. Confirm |  |
|---|---|
| upload done |  |
  <──────────────┤
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
```

#### Multipart Upload (Large Files)
```
MULTIPART UPLOAD FLOW:
  Phase 1: INITIATE
  - Client requests multipart upload
  - Server creates upload session, returns upload ID
  - Server generates presigned URLs for each part
  Phase 2: UPLOAD PARTS
  - Client splits file into 5-100 MB chunks
  - Client uploads each chunk in parallel (3-5 concurrent)
  - Client retries failed chunks individually
  - Client reports progress per chunk
  Phase 3: COMPLETE
  - Client sends list of part ETags to server
```

#### Resumable Upload (Unstable Connections)
```
RESUMABLE UPLOAD (tus protocol):
  Protocol: tus v1.0.0 (https://tus.io)
  1. POST /uploads
  Upload-Length: <total-size>
  Upload-Metadata: filename <base64>, type <base64>
  -> 201 Created, Location: /uploads/<id>
  2. PATCH /uploads/<id>
  Upload-Offset: <current-offset>
  Content-Type: application/offset+octet-stream
  [binary chunk data]
  -> 204 No Content, Upload-Offset: <new-offset>
```

### Step 4: Image and Video Processing Pipeline
Design media processing workflows:

#### Image Processing Pipeline
```
IMAGE PROCESSING PIPELINE:
┌────────┐    ┌────────┐    ┌──────────┐    ┌─────────┐
| Upload | ───> | Validate | ───> | Process | ───> | Store |
|---|---|---|---|---|---|---|
| (S3) |  | & Scan |  | & Resize |  | Variants |
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
```

```typescript
// Image processing with Sharp
async function processImage(key: string): Promise<ProcessedImage> {
  const original = await s3.getObject({ Bucket: BUCKET, Key: key }).promise();
  const image = sharp(original.Body as Buffer);
  const metadata = await image.metadata();

```

#### Video Processing Pipeline
```
VIDEO PROCESSING PIPELINE:
  1. UPLOAD (multipart, resumable for large files)
  -> S3 originals bucket
  2. VALIDATE
  - Verify container format (MP4, WebM, MOV)
  - Check codec (H.264, H.265, VP9, AV1)
  - Verify duration < max allowed
  - Scan for malware
  3. TRANSCODE (AWS MediaConvert / FFmpeg)
|  | Preset | Resolution | Bitrate | Format |  |
|  | ────────────────────────────────────────────── |  |
```
STORAGE COST ANALYSIS:
  Current Monthly Cost: $<amount>
  Breakdown:
  Storage:     $<amount> (<N> TB at $<rate>/GB)
  Requests:    $<amount> (<N>M GET, <M>K PUT)
  Egress:      $<amount> (<N> TB transferred)
  Processing:  $<amount> (Lambda/MediaConvert)
  Optimization Opportunities:
|  | Action | Savings | Risk | Effort |  |
|  | ────────────────────────────────────────────────── |  |
|  | Lifecycle to IA (90d) | 40% | Low | Low |  |
|  | Lifecycle to Glacier | 80% | Medium | Low |  |
|  | (365d) |  |  |  |  |
|  | Delete incomplete | 5% | None | Low |  |
|  | multipart uploads |  |  |  |  |
|  | Compress before store | 30% | Low | Med |  |
|  | Deduplicate files | 15% | Low | Med |  |
|  | Serve via CDN (reduce | 50% | None | Med |  |
|  | S3 egress) | (egress) |  |  |  |
|  | Delete orphaned files | 10% | Low | Med |  |
|  | WebP conversion | 30% | None | Med |  |
|  | (images) | (storage) |  |  |  |
  Projected monthly cost after optimization: $<amount>
  Projected savings: $<amount>/month (<N>% reduction)
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
```

### Step 6: Backup and Replication Strategies
Design data durability and disaster recovery:

```
BACKUP AND REPLICATION STRATEGY:
  Tier 1: SAME-REGION REDUNDANCY (automatic)
  S3: 11 nines durability across 3+ AZs
  GCS: Dual-region or multi-region
  Azure: LRS (3 copies) or ZRS (3 AZ copies)
  Tier 2: CROSS-REGION REPLICATION
  Primary: <region-1>
  Replica: <region-2>
  Mode: Async replication (seconds of lag)
  Scope: Entire bucket or prefix-filtered
  Purpose: Disaster recovery, regional compliance
  Tier 3: CROSS-ACCOUNT BACKUP
```

#### Replication Configuration
```yaml
# S3 Cross-Region Replication (Terraform)
resource "aws_s3_bucket_replication_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  role   = aws_iam_role.replication.arn

  rule {
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

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full storage architecture design and audit |
| `--upload` | File upload architecture design only |
| `--process` | Media processing pipeline design only |

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
Verify all of these before marking the task complete:
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
| Time Window | Objects Accessed | % of Total | Storage Class |
|---|---|---|---|
| Last 7 days | <N> | <pct>% | Use STD |
| 8-30 days | <N> | <pct>% | Use STD |
| 31-90 days | <N> | <pct>% | Use IA |
| 91-365 days | <N> | <pct>% | Use IA |
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
## Output Format
Print: `Storage: {provider} configured. Upload: {presigned|direct}. CDN: {active|none}. Direct access: {blocked|exposed}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
After EACH storage configuration change:
  KEEP if: end-to-end test passes AND no access regressions AND cost projection improved
  DISCARD if: upload fails OR direct bucket access possible OR CORS breaks
  On discard: revert. Never keep a storage change that exposes the bucket directly.
```
