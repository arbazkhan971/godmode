---
name: storage
description: >
  File storage and CDN. Object storage, presigned
  URLs, image/video processing, lifecycle policies.
---

# Storage -- File Storage & CDN

## Activate When
- `/godmode:storage`, "file upload", "S3 bucket"
- "presigned URL", "image processing", "CDN"
- "storage costs", "lifecycle policy", "backup"

## Workflow

### Step 1: Requirements Discovery
```
File Types: images | docs | video | audio | archives
Max Upload Size: images <10MB, video <500MB
Storage Provider: S3 | GCS | Azure Blob | R2
CDN: CloudFront | Cloud CDN | Cloudflare
Scale: <uploads/day, total storage/year>
```

### Step 2: Object Storage Configuration
```bash
# Create S3 bucket with versioning
aws s3api create-bucket \
  --bucket myapp-prod-uploads \
  --region us-east-1
aws s3api put-bucket-versioning \
  --bucket myapp-prod-uploads \
  --versioning-configuration Status=Enabled

# Verify bucket policy
aws s3api get-bucket-policy --bucket myapp-prod-uploads
```
```
BUCKET STRUCTURE:
  /<tenant-id>/originals/<uuid>.<ext>
  /<tenant-id>/variants/<uuid>/<size>.<ext>
  /<tenant-id>/thumbnails/<uuid>.webp

PROVIDER COMPARISON:
| Feature      | S3    | GCS   | Azure Blob |
|-------------|-------|-------|-----------|
| Max object  | 5 TB  | 5 TB  | 190.7 TB  |
| Multipart   | 5 MB  | 5 MB  | N/A blocks|
| Consistency | Strong| Strong| Strong    |
```

### Step 3: Upload Architecture
```
PRESIGNED URL FLOW:
  Client -> API (request URL)
  -> API validates type+size, generates presigned PUT
  -> Client PUTs directly to S3
  -> S3 event -> Worker validates/scans/resizes
  -> Client gets confirmation

IF file < 10MB: single presigned PUT
IF file 10MB-5GB: multipart (5-100MB chunks,
  3-5 concurrent, per-chunk retry)
IF file > 5GB or mobile: resumable (tus protocol)
WHEN server processing needed first: direct upload
```

### Step 4: Image Processing Pipeline
```
PIPELINE:
  Upload -> Validate (magic bytes) -> Virus Scan
  -> Process (Sharp: resize, WebP/AVIF, strip EXIF)
  -> Store variants -> CDN

VARIANTS:
  thumbnail: 200x200 crop, 80% quality
  small: 400w, 80% quality
  medium: 800w, 85% quality
  large: 1600w, 90% quality
  placeholder: 20x20, 20% quality, base64 LQIP
```

### Step 5: Cost Optimization
```
LIFECYCLE POLICIES:
  Incomplete multipart: abort after 24h
  Transition to IA: after 90 days (40% savings)
  Transition to Glacier: after 365 days (80%)
  Delete old versions: after 30 days

OPTIMIZATION ACTIONS:
| Action              | Savings | Effort |
|--------------------|---------|--------|
| Lifecycle to IA    | 40%     | Low    |
| CDN (reduce egress)| 50%     | Medium |
| WebP conversion    | 30%     | Medium |
| Deduplicate files  | 15%     | Medium |
```

### Step 6: Backup & Replication
```
Tier 1: Same-region (automatic, 11 nines S3)
Tier 2: Cross-region replication
  Primary: us-east-1, Replica: eu-west-1
  IF compliance requires geo-redundancy: enable
  IF disaster recovery RTO < 1h: enable
```

### Step 7: Commit
```
Commit: "storage: <desc> -- <components>"
Files: bucket config, upload service, processing,
  lifecycle policies
```

## Key Behaviors
1. **Never proxy uploads through API server.**
2. **Validate server-side after upload.**
3. **Strip EXIF from images.** Privacy liability.
4. **Content-addressable storage for dedup.**
5. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER proxy uploads through API. Use presigned URLs.
2. NEVER store files on app server filesystem.
3. NEVER trust file extensions. Check magic bytes.
4. NEVER serve from bucket URL. Use CDN.
5. ALWAYS scan uploads for viruses (ClamAV).
6. ALWAYS strip EXIF metadata from images.
7. ALWAYS set lifecycle policies from day one.
8. ALWAYS generate image variants at upload time.

## Auto-Detection
```bash
grep -r "aws-sdk\|@aws-sdk\|@google-cloud/storage" \
  package.json 2>/dev/null
grep -r "S3Client\|getSignedUrl\|presignedUrl" \
  src/ --include="*.ts" --include="*.js" -l \
  2>/dev/null | head -5
```

## TSV Logging
Log to `.godmode/storage-results.tsv`:
`step\tcomponent\tprovider\tstatus\tdetails`

## Output Format
Print: `Storage: {provider}. Upload: {presigned|direct}. CDN: {active|none}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
KEEP if: end-to-end upload works AND direct bucket
  access blocked AND cost projection improved
DISCARD if: upload fails OR bucket exposed OR CORS
  breaks. Revert on discard.
```

## Stop Conditions
```
STOP when:
  - End-to-end upload works (presigned -> CDN)
  - Direct bucket access blocked
  - Lifecycle rules active
  - All credentials from env vars or IAM roles
```
