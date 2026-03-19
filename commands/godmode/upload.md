# /godmode:upload

Handle file uploads, image optimization, video processing, and media pipelines. Covers presigned URLs, multipart/chunked uploads, resumable uploads (tus), Sharp/Cloudinary/imgproxy image processing, FFmpeg video transcoding, file validation, virus scanning, and orphaned upload cleanup.

## Usage

```
/godmode:upload                        # Full upload architecture design
/godmode:upload --presign              # Presigned URL upload flow
/godmode:upload --multipart            # Multipart/chunked upload for large files
/godmode:upload --tus                  # Resumable upload with tus protocol
/godmode:upload --image                # Image optimization pipeline (Sharp, variants, LQIP)
/godmode:upload --video                # Video processing pipeline (FFmpeg, HLS)
/godmode:upload --validate             # File validation and security (MIME, virus, EXIF)
/godmode:upload --schema               # Database schema for upload metadata
/godmode:upload --cleanup              # Orphaned upload cleanup cron job
/godmode:upload --cdn                  # CDN integration and serving config
/godmode:upload --provider aws         # Target provider (aws, gcp, azure, cloudflare)
/godmode:upload --tool sharp           # Specific tool (sharp, cloudinary, imgproxy, ffmpeg)
```

## What It Does

1. Discovers upload requirements (file types, sizes, volume, processing needs)
2. Selects upload strategy (presigned URL, multipart, resumable/tus)
3. Implements presigned URL flow with direct-to-storage uploads
4. Builds file validation pipeline (magic bytes, virus scan with ClamAV, EXIF stripping)
5. Builds image optimization pipeline (Sharp variants, WebP/AVIF, blur placeholders)
6. Builds video processing pipeline (FFmpeg transcode, HLS adaptive streaming, thumbnails)
7. Designs database schema for tracking uploads, variants, and processing status
8. Configures storage backends (S3, GCS, Azure Blob, R2, local) and CDN serving
9. Implements orphaned upload cleanup (stale, expired, unreferenced files)
10. Generates all implementation code, migrations, and infrastructure config

## Output
- Upload architecture with strategy selection and flow diagrams
- Presigned URL service with client and server implementation
- Image processing pipeline with variant generation and LQIP
- Video transcoding pipeline with HLS adaptive streaming
- File validation with magic byte checking and virus scanning
- Database schema (SQL + Prisma) for upload metadata
- Cleanup cron job for orphaned and stale uploads
- CDN configuration with signed URLs for private files
- Commit: `"upload: <description> — <components implemented>"`

## Next Step
After upload setup: `/godmode:storage` to configure storage lifecycle and cost optimization, or `/godmode:secure` to audit upload security (file validation, access control).

## Examples

```
/godmode:upload --presign --image             # Image upload with presigned URLs and Sharp processing
/godmode:upload --video --provider aws        # Video pipeline with AWS MediaConvert
/godmode:upload --validate                    # File validation with ClamAV and MIME checking
/godmode:upload --cleanup                     # Orphaned upload cleanup job
/godmode:upload --tus --provider cloudflare   # Resumable uploads with R2 storage
```
