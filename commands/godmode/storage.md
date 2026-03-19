# /godmode:storage

Design and implement file storage systems with object storage, upload architecture, media processing, cost optimization, and backup strategies. Handles everything from presigned URL flows to video transcoding pipelines.

## Usage

```
/godmode:storage                        # Full storage architecture design and audit
/godmode:storage --upload               # File upload architecture design
/godmode:storage --process              # Media processing pipeline (images, video)
/godmode:storage --optimize             # Storage cost analysis and optimization
/godmode:storage --backup               # Backup and replication strategy
/godmode:storage --lifecycle            # Generate lifecycle policies
/godmode:storage --migrate              # Migrate between storage providers
/godmode:storage --provider aws         # Target provider (aws, gcp, azure)
/godmode:storage --audit                # Audit current storage for waste and risk
```

## What It Does

1. Discovers storage requirements (file types, volume, access patterns, compliance)
2. Configures object storage (S3, GCS, Azure Blob) with encryption and policies
3. Designs file upload architecture (presigned URLs, multipart, resumable/tus)
4. Builds image processing pipeline (validation, virus scan, resize, format conversion)
5. Builds video processing pipeline (transcode, HLS adaptive streaming, thumbnails)
6. Analyzes storage costs and recommends lifecycle policies and optimizations
7. Designs backup and cross-region replication for disaster recovery
8. Generates all configuration and infrastructure-as-code files

## Output
- Storage architecture design with bucket structure
- Upload service implementation with presigned URL flow
- Media processing pipeline with variant generation
- Lifecycle policies for cost optimization
- Backup and replication configuration
- Cost analysis with projected savings
- Commit: `"storage: <description> — <components configured>"`

## Next Step
After storage setup: `/godmode:network` to configure CDN for serving files, or `/godmode:secure` to audit storage security (bucket policies, encryption).

## Examples

```
/godmode:storage --upload                       # Design file upload for social app
/godmode:storage --optimize                     # Reduce S3 bill
/godmode:storage --process --provider aws       # Image pipeline with Lambda
/godmode:storage --backup                       # Cross-region replication setup
```
