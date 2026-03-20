---
name: upload
description: File upload handling, image optimization, media processing, signed URLs, multipart uploads. Use when user mentions file upload, image upload, media processing, image optimization, Sharp, Cloudinary, S3 presigned URLs, multipart.
---

# Upload — File Upload & Media Processing

## When to Activate
- User invokes `/godmode:upload`
- User says "file upload", "image upload", "media upload", "upload files"
- User says "image optimization", "Sharp", "ImageMagick", "Cloudinary", "imgproxy"
- User says "presigned URL", "signed URL", "direct upload"
- User says "multipart upload", "chunked upload", "resumable upload", "tus"
- User says "video processing", "FFmpeg", "transcoding", "video encoding"
- User says "file validation", "virus scanning", "ClamAV", "MIME type check"
- User says "thumbnail generation", "image resize", "image variants"
- User says "progressive image loading", "blur placeholder", "LQIP"
- Application needs to accept user-uploaded files and serve them efficiently

## Workflow

### Step 1: Upload Requirements Discovery
Identify what the application needs from file uploads:

```
UPLOAD REQUIREMENTS:
┌──────────────────────────────────────────────────────────┐
│  File Categories:                                         │
│    Images: <jpg, png, webp, gif, svg, heic>               │
│    Video: <mp4, webm, mov>                                │
│    Documents: <pdf, docx, xlsx, csv>                      │
│    Audio: <mp3, wav, aac, ogg>                            │
│    Archives: <zip, tar.gz>                                │
│                                                           │
│  Upload Context:                                          │
│    User-facing: <profile photos | gallery | attachments>  │
│    Admin/internal: <bulk import | CMS media library>      │
│    API: <programmatic uploads from integrations>          │
│                                                           │
│  Constraints:                                             │
│    Max file size per type:                                │
│      Images: <10 MB>                                      │
│      Video: <500 MB>                                      │
│      Documents: <50 MB>                                   │
│    Max files per request: <N>                             │
│    Rate limit: <N uploads/min per user>                   │
│    Auth required: <yes | no | mixed>                      │
│                                                           │
│  Processing Needs:                                        │
│    Image variants: <thumbnail, medium, large, original>   │
│    Video transcoding: <yes | no>                          │
│    Document preview: <yes | no>                           │
│    Virus scanning: <yes | no>                             │
│    EXIF stripping: <yes | no>                             │
│                                                           │
│  Storage Backend:                                         │
│    Provider: <S3 | GCS | Azure Blob | local | R2>        │
│    CDN: <CloudFront | Cloud CDN | Fastly | Cloudflare>    │
│    Region: <primary region>                               │
│                                                           │
│  Scale:                                                   │
│    Uploads per day: <N>                                   │
│    Total storage projected: <N TB/year>                   │
│    Peak concurrent uploads: <N>                           │
└──────────────────────────────────────────────────────────┘
```

### Step 2: Upload Strategy Selection
Choose the right upload strategy for each use case:

#### Strategy Comparison
```
UPLOAD STRATEGY DECISION:
┌──────────────────────────────────────────────────────────┐
│  Strategy          │ When to Use         │ Max Size      │
│  ─────────────────────────────────────────────────────── │
│  Direct (server)   │ Small files < 5 MB, │ ~10 MB        │
│                    │ need server-side     │               │
│                    │ processing first     │               │
│                    │                      │               │
│  Presigned URL     │ Most uploads. Client │ 5 GB (single) │
│  (direct-to-S3)   │ uploads directly to  │               │
│                    │ storage, bypasses    │               │
│                    │ server bottleneck    │               │
│                    │                      │               │
│  Multipart/Chunked │ Large files > 100 MB │ 5 TB          │
│                    │ Parallel chunk upload│               │
│                    │ per-chunk retry      │               │
│                    │                      │               │
│  Resumable (tus)   │ Unreliable networks, │ Unlimited     │
│                    │ mobile uploads,      │               │
│                    │ very large files     │               │
│                    │                      │               │
│  Signed URL +      │ Large files with     │ 5 TB          │
│  Multipart combo   │ direct-to-storage    │               │
│                    │ and reliability      │               │
└──────────────────────────────────────────────────────────┘

RECOMMENDATION:
  < 10 MB (images, docs)  -> Presigned URL (single PUT)
  10 MB - 5 GB (video)    -> Presigned URL + Multipart
  > 5 GB or mobile/flaky  -> Resumable (tus protocol)
  Server processing first -> Direct upload to server
```

#### Presigned URL Upload Flow
```
PRESIGNED URL FLOW:
┌────────┐     ┌──────────┐     ┌────────┐     ┌─────────┐
│ Client │     │ API      │     │ S3/GCS │     │ Worker  │
└───┬────┘     └────┬─────┘     └───┬────┘     └────┬────┘
    │               │               │               │
    │ 1. Request    │               │               │
    │   upload URL  │               │               │
    │   {filename,  │               │               │
    │    type, size}│               │               │
    ├──────────────>│               │               │
    │               │               │               │
    │               │ 2. Validate   │               │
    │               │   type + size │               │
    │               │   Create DB   │               │
    │               │   record      │               │
    │               │               │               │
    │               │ 3. Generate   │               │
    │               │   presigned   │               │
    │               │   PUT URL     │               │
    │               ├──────────────>│               │
    │               │               │               │
    │ 4. Return     │               │               │
    │   {url, id,   │               │               │
    │    fields}    │               │               │
    │<──────────────┤               │               │
    │               │               │               │
    │ 5. PUT file   │               │               │
    │   directly    │               │               │
    │   to storage  │               │               │
    ├───────────────────────────────>│               │
    │               │               │               │
    │               │               │ 6. Event      │
    │               │               │  notification │
    │               │               ├──────────────>│
    │               │               │               │
    │               │               │  7. Validate  │
    │               │               │     Scan      │
    │               │               │     Process   │
    │               │               │     Resize    │
    │               │               │<──────────────┤
    │               │               │               │
    │ 8. Webhook /  │               │               │
    │   poll status │               │               │
    │<──────────────┤               │               │
    │               │               │               │
```

```typescript
// Server: Presigned URL generation
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import crypto from 'crypto';

const ALLOWED_TYPES: Record<string, { maxSize: number; extensions: string[] }> = {
  'image/jpeg': { maxSize: 10 * 1024 * 1024, extensions: ['.jpg', '.jpeg'] },
  'image/png':  { maxSize: 10 * 1024 * 1024, extensions: ['.png'] },
  'image/webp': { maxSize: 10 * 1024 * 1024, extensions: ['.webp'] },
  'image/gif':  { maxSize: 5 * 1024 * 1024,  extensions: ['.gif'] },
  'video/mp4':  { maxSize: 500 * 1024 * 1024, extensions: ['.mp4'] },
  'video/webm': { maxSize: 500 * 1024 * 1024, extensions: ['.webm'] },
  'application/pdf': { maxSize: 50 * 1024 * 1024, extensions: ['.pdf'] },
};

async function createUploadUrl(req: AuthenticatedRequest) {
  const { filename, contentType, fileSize } = req.body;

  // 1. Validate content type
  const typeConfig = ALLOWED_TYPES[contentType];
  if (!typeConfig) {
    throw new BadRequestError(`File type "${contentType}" is not allowed`);
  }

  // 2. Validate file size
  if (fileSize > typeConfig.maxSize) {
    throw new BadRequestError(
      `File size ${fileSize} exceeds limit of ${typeConfig.maxSize} bytes`
    );
  }

  // 3. Validate extension matches content type
  const ext = path.extname(filename).toLowerCase();
  if (!typeConfig.extensions.includes(ext)) {
    throw new BadRequestError(`Extension "${ext}" does not match type "${contentType}"`);
  }

  // 4. Generate storage key
  const fileId = crypto.randomUUID();
  const sanitized = filename.replace(/[^a-zA-Z0-9._-]/g, '_');
  const key = `uploads/${req.userId}/${fileId}/${sanitized}`;

  // 5. Generate presigned URL
  const command = new PutObjectCommand({
    Bucket: process.env.UPLOAD_BUCKET,
    Key: key,
    ContentType: contentType,
    ContentLength: fileSize,
    Metadata: {
      'user-id': req.userId,
      'original-filename': filename,
    },
  });

  const uploadUrl = await getSignedUrl(s3Client, command, { expiresIn: 3600 });

  // 6. Create DB record with status "pending"
  const upload = await db.upload.create({
    data: {
      id: fileId,
      userId: req.userId,
      filename: sanitized,
      originalFilename: filename,
      contentType,
      fileSize,
      storageKey: key,
      status: 'pending',       // pending -> processing -> ready | failed
      expiresAt: new Date(Date.now() + 3600 * 1000),
    },
  });

  return { uploadUrl, fileId, key };
}
```

```typescript
// Client: Upload with progress tracking
async function uploadFile(file: File, onProgress?: (pct: number) => void) {
  // 1. Request presigned URL
  const { uploadUrl, fileId } = await api.post('/uploads/presign', {
    filename: file.name,
    contentType: file.type,
    fileSize: file.size,
  });

  // 2. Upload directly to S3
  await new Promise<void>((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open('PUT', uploadUrl);
    xhr.setRequestHeader('Content-Type', file.type);

    xhr.upload.onprogress = (e) => {
      if (e.lengthComputable && onProgress) {
        onProgress(Math.round((e.loaded / e.total) * 100));
      }
    };

    xhr.onload = () => (xhr.status === 200 ? resolve() : reject(new Error(`Upload failed: ${xhr.status}`)));
    xhr.onerror = () => reject(new Error('Upload failed: network error'));
    xhr.send(file);
  });

  // 3. Confirm upload and wait for processing
  const result = await api.post(`/uploads/${fileId}/confirm`);
  return result;
}
```

#### Chunked Multipart Upload (Large Files)
```
MULTIPART UPLOAD FLOW:
┌──────────────────────────────────────────────────────────┐
│  Phase 1: INITIATE                                        │
│  POST /uploads/multipart                                  │
│  - Server creates upload session                          │
│  - Server calls CreateMultipartUpload on S3               │
│  - Returns uploadId + presigned URLs for N parts          │
│                                                           │
│  Phase 2: UPLOAD PARTS (parallel)                         │
│  PUT <presigned-part-url>                                 │
│  - Client splits file: chunk size = 10 MB (configurable)  │
│  - Upload up to 5 chunks concurrently                     │
│  - Each chunk returns an ETag                             │
│  - Failed chunks retry individually (3x, exp backoff)     │
│  - Track progress: (completed bytes / total bytes) * 100  │
│                                                           │
│  Phase 3: COMPLETE                                        │
│  POST /uploads/multipart/:uploadId/complete               │
│  - Client sends { parts: [{partNumber, etag}] }           │
│  - Server calls CompleteMultipartUpload                    │
│  - Server validates assembled file checksum               │
│  - Server triggers post-processing pipeline               │
│                                                           │
│  ABORT (on cancel or timeout):                            │
│  DELETE /uploads/multipart/:uploadId                      │
│  - Server calls AbortMultipartUpload                      │
│  - S3 lifecycle rule auto-aborts incomplete > 24h         │
├──────────────────────────────────────────────────────────┤
│  Chunk sizing:                                            │
│    Default: 10 MB (good balance of retry cost vs speed)   │
│    Minimum: 5 MB (S3 minimum for multipart)               │
│    Maximum: 100 MB (for very fast connections)             │
│    Adaptive: increase chunk size on fast networks          │
│  Concurrency: 3-5 parallel (browser connection limits)    │
│  Retry: 3 attempts, exponential backoff (1s, 2s, 4s)     │
└──────────────────────────────────────────────────────────┘
```

```typescript
// Server: Multipart upload management
async function initiateMultipart(req: AuthenticatedRequest) {
  const { filename, contentType, fileSize } = req.body;

  // Validate
  validateFileType(contentType);
  validateFileSize(contentType, fileSize);

  const fileId = crypto.randomUUID();
  const key = `uploads/${req.userId}/${fileId}/${sanitize(filename)}`;
  const chunkSize = 10 * 1024 * 1024; // 10 MB
  const totalParts = Math.ceil(fileSize / chunkSize);

  // Create S3 multipart upload
  const { UploadId } = await s3.createMultipartUpload({
    Bucket: process.env.UPLOAD_BUCKET,
    Key: key,
    ContentType: contentType,
  });

  // Generate presigned URLs for each part
  const partUrls = await Promise.all(
    Array.from({ length: totalParts }, (_, i) =>
      getSignedUrl(s3, new UploadPartCommand({
        Bucket: process.env.UPLOAD_BUCKET,
        Key: key,
        UploadId,
        PartNumber: i + 1,
      }), { expiresIn: 7200 })
    )
  );

  // Persist upload session
  await db.upload.create({
    data: {
      id: fileId, userId: req.userId, filename: sanitize(filename),
      contentType, fileSize, storageKey: key,
      s3UploadId: UploadId, status: 'uploading',
      totalParts, completedParts: 0,
      expiresAt: new Date(Date.now() + 24 * 3600 * 1000),
    },
  });

  return { fileId, uploadId: UploadId, partUrls, chunkSize, totalParts };
}

async function completeMultipart(req: AuthenticatedRequest) {
  const { uploadId } = req.params;
  const { parts } = req.body; // [{ partNumber, etag }]

  const upload = await db.upload.findUniqueOrThrow({ where: { id: uploadId } });

  await s3.completeMultipartUpload({
    Bucket: process.env.UPLOAD_BUCKET,
    Key: upload.storageKey,
    UploadId: upload.s3UploadId,
    MultipartUpload: {
      Parts: parts.map((p: any) => ({ PartNumber: p.partNumber, ETag: p.etag })),
    },
  });

  await db.upload.update({
    where: { id: uploadId },
    data: { status: 'processing' },
  });

  // Trigger processing pipeline
  await queue.publish('upload.process', { fileId: uploadId });

  return { status: 'processing', fileId: uploadId };
}
```

#### Resumable Upload (tus Protocol)
```
RESUMABLE UPLOAD — tus v1.0.0 (https://tus.io):
┌──────────────────────────────────────────────────────────┐
│  When to use:                                             │
│  - Mobile uploads on cellular networks                    │
│  - Very large files (> 1 GB)                              │
│  - Users in regions with unstable connectivity            │
│  - When upload must survive app backgrounding / tab close │
│                                                           │
│  Protocol flow:                                           │
│                                                           │
│  1. CREATE                                                │
│     POST /files                                           │
│     Tus-Resumable: 1.0.0                                  │
│     Upload-Length: 1073741824                              │
│     Upload-Metadata: filename d29ya2Zsb3cucG5n,           │
│                      filetype aW1hZ2UvcG5n                │
│     -> 201 Created                                        │
│     -> Location: /files/abc123                            │
│                                                           │
│  2. UPLOAD (repeat until complete)                        │
│     PATCH /files/abc123                                   │
│     Tus-Resumable: 1.0.0                                  │
│     Upload-Offset: 0                                      │
│     Content-Type: application/offset+octet-stream         │
│     [binary data...]                                      │
│     -> 204 No Content                                     │
│     -> Upload-Offset: 52428800                            │
│                                                           │
│  3. RESUME (after disconnect)                             │
│     HEAD /files/abc123                                    │
│     -> 200 OK                                             │
│     -> Upload-Offset: 52428800   <- resume from here      │
│     -> Upload-Length: 1073741824                           │
│                                                           │
│  Server implementations:                                  │
│    Node.js:  @tus/server (official)                       │
│    Go:       tusd (reference server)                      │
│    Python:   django-tus, flask-tus                        │
│    Ruby:     tus-ruby-server                              │
│                                                           │
│  Client libraries:                                        │
│    Browser:  tus-js-client                                │
│    iOS:      TUSKit                                       │
│    Android:  tus-android-client                           │
│    React Native: tus-js-client (works with RN)            │
│                                                           │
│  Storage backends for tus server:                         │
│    S3 (via @tus/s3-store)                                 │
│    GCS (via @tus/gcs-store)                               │
│    Local filesystem (via @tus/file-store)                 │
└──────────────────────────────────────────────────────────┘
```

```typescript
// Server: tus integration with @tus/server
import { Server as TusServer } from '@tus/server';
import { S3Store } from '@tus/s3-store';

const tusServer = new TusServer({
  path: '/api/tus',
  datastore: new S3Store({
    partSize: 8 * 1024 * 1024, // 8 MB chunks
    s3ClientConfig: {
      bucket: process.env.UPLOAD_BUCKET,
      region: process.env.AWS_REGION,
    },
  }),
  maxSize: 5 * 1024 * 1024 * 1024, // 5 GB max
  generateUrl(req, { proto, host, path, id }) {
    return `${proto}://${host}${path}/${id}`;
  },
  namingFunction(req) {
    return `uploads/${req.userId}/${crypto.randomUUID()}`;
  },
  onUploadCreate: async (req, res, upload) => {
    // Validate metadata (file type, user permissions)
    const meta = upload.metadata;
    if (!ALLOWED_TYPES[meta?.filetype]) {
      throw { status_code: 400, body: 'File type not allowed' };
    }
    return res;
  },
  onUploadFinish: async (req, res, upload) => {
    // Trigger post-upload processing pipeline
    await queue.publish('upload.process', {
      key: upload.id,
      contentType: upload.metadata?.filetype,
      userId: req.userId,
    });
    return res;
  },
});

// Client: tus-js-client with resume
import * as tus from 'tus-js-client';

function uploadWithTus(file: File, onProgress: (pct: number) => void) {
  return new Promise<string>((resolve, reject) => {
    const upload = new tus.Upload(file, {
      endpoint: '/api/tus',
      retryDelays: [0, 1000, 3000, 5000, 10000],  // Auto-retry on failure
      chunkSize: 5 * 1024 * 1024,
      metadata: {
        filename: file.name,
        filetype: file.type,
      },
      onProgress(bytesUploaded, bytesTotal) {
        onProgress(Math.round((bytesUploaded / bytesTotal) * 100));
      },
      onSuccess() {
        resolve(upload.url!);
      },
      onError(error) {
        reject(error);
      },
    });

    // Resume from previous attempt if available
    upload.findPreviousUploads().then((prev) => {
      if (prev.length > 0) upload.resumeFromPreviousUpload(prev[0]);
      upload.start();
    });
  });
}
```

### Step 3: File Validation & Security
Validate uploads before making them available:

```
FILE VALIDATION PIPELINE:
┌──────────────────────────────────────────────────────────┐
│  Layer 1: CLIENT-SIDE (UX only — never trust)             │
│  - File extension check                                   │
│  - MIME type from file input                               │
│  - File size check                                        │
│  - Image dimension preview                                │
│  Purpose: Fast feedback, reduce unnecessary uploads       │
│                                                           │
│  Layer 2: PRESIGN REQUEST (server — gate before upload)    │
│  - Validate content type against allowlist                 │
│  - Validate file size against per-type limits              │
│  - Validate extension matches content type                 │
│  - Check user quota (storage used, upload rate limit)      │
│  - Check user permissions (authenticated, authorized)      │
│  Purpose: Prevent disallowed uploads before they start    │
│                                                           │
│  Layer 3: POST-UPLOAD (worker — validate actual file)      │
│  - Read file magic bytes to verify true MIME type          │
│  - Compare magic bytes against declared content type       │
│  - Scan for malware with ClamAV / commercial scanner      │
│  - Check image dimensions (reject extreme aspect ratios)   │
│  - Verify file is not corrupted (can be opened/parsed)     │
│  - Strip EXIF/metadata (GPS, camera info, timestamps)      │
│  Purpose: Catch spoofed types, malware, privacy leaks     │
│                                                           │
│  Layer 4: CONTENT MODERATION (optional)                    │
│  - NSFW detection (AWS Rekognition, Google Vision, etc.)   │
│  - Text extraction and policy check (OCR)                  │
│  - Custom classifiers for domain-specific rules            │
│  Purpose: Enforce community guidelines                    │
└──────────────────────────────────────────────────────────┘
```

```typescript
// Magic byte validation — do not trust Content-Type header
import { fileTypeFromBuffer } from 'file-type';

const MAGIC_BYTE_MAP: Record<string, string[]> = {
  'image/jpeg': ['image/jpeg'],
  'image/png':  ['image/png'],
  'image/webp': ['image/webp'],
  'image/gif':  ['image/gif'],
  'video/mp4':  ['video/mp4'],
  'video/webm': ['video/webm'],
  'application/pdf': ['application/pdf'],
};

async function validateFileContent(
  buffer: Buffer,
  declaredType: string
): Promise<{ valid: boolean; detectedType?: string; reason?: string }> {
  // 1. Detect real type from magic bytes
  const detected = await fileTypeFromBuffer(buffer);
  if (!detected) {
    return { valid: false, reason: 'Could not determine file type from content' };
  }

  // 2. Check detected type is allowed
  if (!MAGIC_BYTE_MAP[detected.mime]) {
    return { valid: false, detectedType: detected.mime, reason: `Detected type "${detected.mime}" is not allowed` };
  }

  // 3. Check detected type matches declared type
  const allowed = MAGIC_BYTE_MAP[declaredType];
  if (!allowed || !allowed.includes(detected.mime)) {
    return {
      valid: false,
      detectedType: detected.mime,
      reason: `Declared type "${declaredType}" does not match detected "${detected.mime}"`,
    };
  }

  return { valid: true, detectedType: detected.mime };
}
```

```typescript
// Virus scanning with ClamAV
import NodeClam from 'clamscan';

const clam = await new NodeClam().init({
  clamdscan: {
    socket: '/var/run/clamav/clamd.sock',  // Unix socket (faster)
    host: '127.0.0.1',                      // Or TCP
    port: 3310,
    timeout: 60000,
  },
});

async function scanForVirus(filePath: string): Promise<{ clean: boolean; virus?: string }> {
  try {
    const { isInfected, viruses } = await clam.scanFile(filePath);
    if (isInfected) {
      console.error(`VIRUS DETECTED in ${filePath}:`, viruses);
      // Delete infected file immediately
      await fs.unlink(filePath);
      return { clean: false, virus: viruses.join(', ') };
    }
    return { clean: true };
  } catch (error) {
    // If scanner fails, quarantine the file — do not serve it
    console.error('Virus scan failed:', error);
    throw new Error('Virus scanning unavailable — file quarantined');
  }
}
```

```typescript
// EXIF stripping — remove GPS, camera info, timestamps
import sharp from 'sharp';

async function stripExifAndNormalize(buffer: Buffer): Promise<Buffer> {
  return sharp(buffer)
    .rotate()             // Auto-orient from EXIF before stripping
    .withMetadata({
      orientation: undefined,  // Remove orientation tag
    })
    .toBuffer();
  // sharp strips EXIF by default unless withMetadata() preserves it
  // .rotate() applies EXIF orientation, then the tag is no longer needed
}
```

### Step 4: Image Optimization Pipeline
Generate optimized variants for web delivery:

```
IMAGE OPTIMIZATION PIPELINE:
┌──────────────────────────────────────────────────────────┐
│  INPUT: Original uploaded image                           │
│                                                           │
│  Step 1: VALIDATE & NORMALIZE                             │
│  - Verify magic bytes match declared type                 │
│  - Virus scan                                             │
│  - Strip EXIF (GPS, camera info)                          │
│  - Auto-orient from EXIF rotation tag                     │
│  - Reject if width or height > 20000px                    │
│                                                           │
│  Step 2: GENERATE VARIANTS                                │
│  ┌────────────────────────────────────────────────────┐  │
│  │ Variant      │ Dimensions   │ Quality │ Use Case    │  │
│  │ ──────────────────────────────────────────────────  │  │
│  │ placeholder  │ 20x20        │ 20%     │ LQIP blur   │  │
│  │ thumbnail    │ 200x200 crop │ 80%     │ Lists, grid │  │
│  │ small        │ 400px wide   │ 80%     │ Cards       │  │
│  │ medium       │ 800px wide   │ 85%     │ Content     │  │
│  │ large        │ 1600px wide  │ 90%     │ Lightbox    │  │
│  │ original     │ (preserved)  │ 100%    │ Download    │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Step 3: FORMAT CONVERSION                                │
│  For each variant generate:                               │
│  - WebP  (30-50% smaller than JPEG, 95%+ browser share)  │
│  - AVIF  (additional 20% savings, 85%+ browser share)     │
│  - JPEG  (fallback for older browsers)                    │
│  Use Accept header / <picture> element for negotiation    │
│                                                           │
│  Step 4: BLUR PLACEHOLDER (LQIP)                          │
│  - 20x20 pixels, heavily blurred                          │
│  - Base64 encode (< 1 KB)                                 │
│  - Inline in HTML/JSON response                           │
│  - CSS blur(20px) + scale to full size                    │
│  - Swap to real image on load                             │
│                                                           │
│  OUTPUT: Stored in processed/ prefix with CDN headers     │
│  Cache-Control: public, max-age=31536000, immutable       │
└──────────────────────────────────────────────────────────┘
```

#### Tool Comparison
```
IMAGE PROCESSING TOOLS:
┌──────────────────────────────────────────────────────────┐
│  Tool         │ Best For           │ Notes               │
│  ─────────────────────────────────────────────────────── │
│  Sharp        │ Node.js apps.      │ Fastest Node lib.   │
│  (libvips)    │ Resize, convert,   │ Low memory. Use for │
│               │ crop, blur.        │ all server-side.    │
│               │                    │                     │
│  ImageMagick  │ Complex transforms.│ CLI or binding.     │
│               │ Batch processing.  │ Higher memory.      │
│               │ Legacy formats.    │ More format support.│
│               │                    │                     │
│  Cloudinary   │ SaaS. URL-based    │ On-the-fly via URL. │
│               │ transforms. No     │ Generous free tier. │
│               │ infrastructure.    │ CDN included.       │
│               │                    │                     │
│  imgproxy     │ Self-hosted URL    │ On-demand resize    │
│               │ transform proxy.   │ via URL params.     │
│               │ Go binary.         │ Very fast. Docker.  │
│               │                    │                     │
│  Pillow       │ Python apps.       │ PIL fork. Mature.   │
│               │ Django/Flask.      │ Not as fast as      │
│               │                    │ Sharp/libvips.      │
│               │                    │                     │
│  FFmpeg       │ Video + audio.     │ Transcode, thumb,   │
│  (images too) │ GIF optimization.  │ GIF->MP4, sprites.  │
└──────────────────────────────────────────────────────────┘
```

```typescript
// Full image processing pipeline with Sharp
import sharp from 'sharp';
import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';

interface ImageVariant {
  name: string;
  width: number | null;
  height: number | null;
  fit: keyof sharp.FitEnum;
  quality: number;
}

const VARIANTS: ImageVariant[] = [
  { name: 'placeholder', width: 20,   height: 20,   fit: 'inside', quality: 20 },
  { name: 'thumb',       width: 200,  height: 200,  fit: 'cover',  quality: 80 },
  { name: 'small',       width: 400,  height: null,  fit: 'inside', quality: 80 },
  { name: 'medium',      width: 800,  height: null,  fit: 'inside', quality: 85 },
  { name: 'large',       width: 1600, height: null,  fit: 'inside', quality: 90 },
];

async function processUploadedImage(storageKey: string): Promise<ProcessedImage> {
  // 1. Fetch original from S3
  const { Body } = await s3.send(new GetObjectCommand({
    Bucket: process.env.UPLOAD_BUCKET, Key: storageKey,
  }));
  const buffer = Buffer.from(await Body!.transformToByteArray());

  // 2. Validate and read metadata
  const image = sharp(buffer);
  const meta = await image.metadata();

  if (!meta.width || !meta.height) throw new Error('Invalid image: missing dimensions');
  if (meta.width > 20000 || meta.height > 20000) throw new Error('Image dimensions too large');

  // 3. Strip EXIF, auto-orient
  const normalized = sharp(buffer).rotate().withMetadata({ orientation: undefined });

  // 4. Generate all variants in parallel
  const results = await Promise.all(
    VARIANTS.map(async (v) => {
      const resized = normalized.clone().resize(v.width, v.height, {
        fit: v.fit,
        withoutEnlargement: true,
      });

      const [webp, avif] = await Promise.all([
        resized.clone().webp({ quality: v.quality }).toBuffer(),
        resized.clone().avif({ quality: v.quality }).toBuffer(),
      ]);

      return { variant: v.name, webp, avif };
    })
  );

  // 5. Upload variants to S3
  const baseKey = storageKey.replace('/uploads/', '/processed/').replace(/\.[^.]+$/, '');
  const uploads = results.flatMap((r) => [
    s3.send(new PutObjectCommand({
      Bucket: process.env.UPLOAD_BUCKET,
      Key: `${baseKey}/${r.variant}.webp`,
      Body: r.webp,
      ContentType: 'image/webp',
      CacheControl: 'public, max-age=31536000, immutable',
    })),
    s3.send(new PutObjectCommand({
      Bucket: process.env.UPLOAD_BUCKET,
      Key: `${baseKey}/${r.variant}.avif`,
      Body: r.avif,
      ContentType: 'image/avif',
      CacheControl: 'public, max-age=31536000, immutable',
    })),
  ]);
  await Promise.all(uploads);

  // 6. Generate base64 placeholder
  const placeholderBuf = results.find((r) => r.variant === 'placeholder')!.webp;
  const placeholder = `data:image/webp;base64,${placeholderBuf.toString('base64')}`;

  // 7. Update DB record
  await db.upload.update({
    where: { storageKey },
    data: {
      status: 'ready',
      width: meta.width,
      height: meta.height,
      placeholder,
      variants: {
        thumb:  `${baseKey}/thumb.webp`,
        small:  `${baseKey}/small.webp`,
        medium: `${baseKey}/medium.webp`,
        large:  `${baseKey}/large.webp`,
      },
      processedAt: new Date(),
    },
  });

  return { id: extractId(storageKey), placeholder, width: meta.width, height: meta.height };
}
```

#### Cloudinary and imgproxy Alternatives
```typescript
// Cloudinary: URL-based transforms (no server-side processing needed)
// Upload once, transform via URL parameters
const cloudinaryUrl = (publicId: string, transforms: string) =>
  `https://res.cloudinary.com/${CLOUD_NAME}/image/upload/${transforms}/${publicId}`;

// Examples:
cloudinaryUrl('user/photo123', 'w_200,h_200,c_fill,f_auto,q_80');   // Thumbnail
cloudinaryUrl('user/photo123', 'w_800,f_auto,q_auto');              // Medium
cloudinaryUrl('user/photo123', 'e_blur:2000,w_20,q_10');            // Placeholder

// imgproxy: Self-hosted URL-based transforms
// Deploy imgproxy (Docker) and transform via signed URLs
const imgproxyUrl = (sourceUrl: string, width: number, height: number) => {
  const encoded = Buffer.from(sourceUrl).toString('base64url');
  const path = `/resize:fit:${width}:${height}/plain/${encoded}@webp`;
  const signature = signImgproxyPath(path); // HMAC-SHA256
  return `${IMGPROXY_HOST}/${signature}${path}`;
};
```

#### Progressive Image Loading (Blur-Up Pattern)
```typescript
// React component: blur placeholder -> full image
function ProgressiveImage({ src, placeholder, alt, width, height }: Props) {
  const [loaded, setLoaded] = useState(false);

  return (
    <div style={{ position: 'relative', width, height, overflow: 'hidden' }}>
      {/* Blur placeholder — inline base64, loads instantly */}
      <img
        src={placeholder}
        alt=""
        aria-hidden
        style={{
          position: 'absolute', inset: 0, width: '100%', height: '100%',
          objectFit: 'cover', filter: 'blur(20px)', transform: 'scale(1.1)',
          transition: 'opacity 0.3s',
          opacity: loaded ? 0 : 1,
        }}
      />
      {/* Real image with responsive sources */}
      <picture>
        <source srcSet={src.replace('.webp', '.avif')} type="image/avif" />
        <source srcSet={src} type="image/webp" />
        <img
          src={src.replace('.webp', '.jpg')}
          alt={alt}
          width={width}
          height={height}
          loading="lazy"
          onLoad={() => setLoaded(true)}
          style={{
            position: 'absolute', inset: 0, width: '100%', height: '100%',
            objectFit: 'cover', opacity: loaded ? 1 : 0,
            transition: 'opacity 0.3s',
          }}
        />
      </picture>
    </div>
  );
}
```

### Step 5: Video Processing Pipeline
Transcode and prepare video for adaptive streaming:

```
VIDEO PROCESSING PIPELINE:
┌──────────────────────────────────────────────────────────┐
│  1. UPLOAD                                                │
│     Strategy: Multipart or tus (videos are large)         │
│     Max size: 500 MB (or 5 GB for premium)                │
│     Storage: S3 originals/ prefix                         │
│                                                           │
│  2. VALIDATE                                              │
│     - Verify container format via ffprobe                 │
│     - Check codec compatibility                           │
│     - Verify duration < max allowed (e.g., 10 min)        │
│     - Check video dimensions and framerate                │
│     - Virus scan the file                                 │
│                                                           │
│  3. TRANSCODE (FFmpeg or managed service)                 │
│  ┌────────────────────────────────────────────────────┐  │
│  │ Preset       │ Resolution  │ Bitrate  │ Codec      │  │
│  │ ──────────────────────────────────────────────────  │  │
│  │ 360p         │ 640x360     │ 800 Kbps │ H.264/AAC  │  │
│  │ 720p         │ 1280x720    │ 2.5 Mbps │ H.264/AAC  │  │
│  │ 1080p        │ 1920x1080   │ 5 Mbps   │ H.264/AAC  │  │
│  │ 4K (opt.)    │ 3840x2160   │ 15 Mbps  │ H.265/AAC  │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  4. GENERATE ASSETS                                       │
│     - Thumbnail at 10%, 50%, 90% of duration              │
│     - Preview: first 3 seconds as silent MP4 or GIF       │
│     - Poster image: best thumbnail as JPEG/WebP           │
│     - Waveform: audio visualization PNG                   │
│     - Subtitles: extract embedded SRT/VTT                 │
│                                                           │
│  5. ADAPTIVE STREAMING (HLS or DASH)                      │
│     - Segment duration: 4-6 seconds                       │
│     - Multiple quality levels for adaptive bitrate         │
│     - Master playlist (m3u8) referencing all qualities     │
│     - Optional: AES-128 encryption or DRM                 │
│                                                           │
│  6. SERVE                                                 │
│     - CDN for segment delivery                            │
│     - Range request support for progressive download      │
│     - Signed URLs for access control                      │
│     - Preload poster image, lazy-load video               │
│                                                           │
│  Managed alternatives:                                    │
│    AWS: MediaConvert (serverless transcode)                │
│    GCP: Transcoder API                                    │
│    Cloudflare: Stream (upload + encode + deliver)          │
│    Mux: Full video API (encode + stream + analytics)       │
│    Bunny: Stream (affordable, global CDN)                  │
└──────────────────────────────────────────────────────────┘
```

```typescript
// FFmpeg transcoding with fluent-ffmpeg
import ffmpeg from 'fluent-ffmpeg';
import ffprobe from 'ffprobe-static';

ffmpeg.setFfprobePath(ffprobe.path);

async function transcodeVideo(inputPath: string, outputDir: string) {
  const probe = await probeVideo(inputPath);
  const presets = getPresetsForResolution(probe.width, probe.height);

  // Generate each quality variant
  for (const preset of presets) {
    await new Promise<void>((resolve, reject) => {
      ffmpeg(inputPath)
        .videoCodec('libx264')
        .audioCodec('aac')
        .size(`${preset.width}x?`)       // Maintain aspect ratio
        .videoBitrate(preset.bitrate)
        .audioBitrate('128k')
        .outputOptions([
          '-preset', 'medium',
          '-crf', '23',
          '-movflags', '+faststart',      // Progressive download
          '-pix_fmt', 'yuv420p',          // Max compatibility
        ])
        .output(`${outputDir}/${preset.name}.mp4`)
        .on('end', resolve)
        .on('error', reject)
        .run();
    });
  }

  // Generate HLS adaptive streaming
  await new Promise<void>((resolve, reject) => {
    ffmpeg(inputPath)
      .outputOptions([
        '-preset', 'medium',
        '-g', '48', '-keyint_min', '48',  // Keyframe every 2s at 24fps
        '-sc_threshold', '0',
        '-hls_time', '6',                 // 6-second segments
        '-hls_playlist_type', 'vod',
        '-hls_segment_filename', `${outputDir}/hls/%v/segment_%03d.ts`,
        '-master_pl_name', 'master.m3u8',
        '-var_stream_map', presets.map((p, i) => `v:${i},a:${i}`).join(' '),
      ])
      .output(`${outputDir}/hls/%v/playlist.m3u8`)
      .on('end', resolve)
      .on('error', reject)
      .run();
  });

  // Generate thumbnails at different timestamps
  const duration = probe.duration;
  await generateThumbnails(inputPath, outputDir, [
    duration * 0.1, duration * 0.5, duration * 0.9,
  ]);
}

async function generateThumbnails(input: string, outputDir: string, timestamps: number[]) {
  for (const ts of timestamps) {
    await new Promise<void>((resolve, reject) => {
      ffmpeg(input)
        .screenshots({
          timestamps: [ts],
          filename: `thumb_${Math.round(ts)}s.jpg`,
          folder: outputDir,
          size: '640x?',
        })
        .on('end', resolve)
        .on('error', reject);
    });
  }
}
```

### Step 6: Database Schema for File Metadata
Track uploads and their processing state:

```sql
-- Upload metadata table
CREATE TABLE uploads (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tenant_id       UUID REFERENCES tenants(id),

  -- Original file info
  original_filename   TEXT NOT NULL,
  filename            TEXT NOT NULL,          -- Sanitized
  content_type        TEXT NOT NULL,
  detected_type       TEXT,                   -- From magic bytes
  file_size           BIGINT NOT NULL,
  checksum_sha256     TEXT,

  -- Storage
  storage_key         TEXT NOT NULL UNIQUE,   -- S3 key
  storage_bucket      TEXT NOT NULL,
  storage_provider    TEXT NOT NULL DEFAULT 's3',

  -- Processing status
  status              TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'uploading', 'processing', 'ready', 'failed', 'quarantined', 'deleted')),
  error_message       TEXT,

  -- Image/video metadata (populated after processing)
  width               INT,
  height              INT,
  duration_seconds    NUMERIC(10, 2),         -- Video/audio duration
  placeholder         TEXT,                    -- Base64 blur placeholder

  -- Variants (JSONB for flexible variant storage)
  variants            JSONB DEFAULT '{}',
  /*  Example:
      {
        "thumb":  { "key": "processed/abc/thumb.webp",  "width": 200,  "size": 8432 },
        "medium": { "key": "processed/abc/medium.webp", "width": 800,  "size": 45210 },
        "large":  { "key": "processed/abc/large.webp",  "width": 1600, "size": 128900 }
      }
  */

  -- Security
  virus_scan_status   TEXT DEFAULT 'pending'
    CHECK (virus_scan_status IN ('pending', 'clean', 'infected', 'error')),
  virus_scan_result   TEXT,
  exif_stripped       BOOLEAN DEFAULT FALSE,
  moderation_status   TEXT DEFAULT 'pending'
    CHECK (moderation_status IN ('pending', 'approved', 'rejected', 'manual_review')),

  -- Lifecycle
  is_public           BOOLEAN DEFAULT FALSE,
  access_count        INT DEFAULT 0,
  last_accessed_at    TIMESTAMPTZ,
  expires_at          TIMESTAMPTZ,            -- For temporary uploads
  deleted_at          TIMESTAMPTZ,            -- Soft delete

  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_uploads_user_id ON uploads(user_id);
CREATE INDEX idx_uploads_tenant_id ON uploads(tenant_id);
CREATE INDEX idx_uploads_status ON uploads(status);
CREATE INDEX idx_uploads_content_type ON uploads(content_type);
CREATE INDEX idx_uploads_created_at ON uploads(created_at DESC);
CREATE INDEX idx_uploads_expires_at ON uploads(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX idx_uploads_deleted_at ON uploads(deleted_at) WHERE deleted_at IS NULL;

-- Trigger for updated_at
CREATE TRIGGER set_uploads_updated_at
  BEFORE UPDATE ON uploads
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- View: active uploads (not deleted, not expired)
CREATE VIEW active_uploads AS
  SELECT * FROM uploads
  WHERE deleted_at IS NULL
    AND (expires_at IS NULL OR expires_at > NOW())
    AND status NOT IN ('quarantined', 'deleted');
```

```typescript
// Prisma schema equivalent
model Upload {
  id               String   @id @default(uuid())
  userId           String   @map("user_id")
  tenantId         String?  @map("tenant_id")

  originalFilename String   @map("original_filename")
  filename         String
  contentType      String   @map("content_type")
  detectedType     String?  @map("detected_type")
  fileSize         BigInt   @map("file_size")
  checksumSha256   String?  @map("checksum_sha256")

  storageKey       String   @unique @map("storage_key")
  storageBucket    String   @map("storage_bucket")
  storageProvider  String   @default("s3") @map("storage_provider")

  status           UploadStatus @default(PENDING)
  errorMessage     String?  @map("error_message")

  width            Int?
  height           Int?
  durationSeconds  Decimal? @map("duration_seconds")
  placeholder      String?

  variants         Json     @default("{}")

  virusScanStatus  ScanStatus @default(PENDING) @map("virus_scan_status")
  virusScanResult  String?  @map("virus_scan_result")
  exifStripped     Boolean  @default(false) @map("exif_stripped")
  moderationStatus ModerationStatus @default(PENDING) @map("moderation_status")

  isPublic         Boolean  @default(false) @map("is_public")
  accessCount      Int      @default(0) @map("access_count")
  lastAccessedAt   DateTime? @map("last_accessed_at")
  expiresAt        DateTime? @map("expires_at")
  deletedAt        DateTime? @map("deleted_at")

  createdAt        DateTime @default(now()) @map("created_at")
  updatedAt        DateTime @updatedAt @map("updated_at")

  user             User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  tenant           Tenant?  @relation(fields: [tenantId], references: [id])

  @@index([userId])
  @@index([tenantId])
  @@index([status])
  @@index([createdAt(sort: Desc)])
  @@map("uploads")
}

enum UploadStatus {
  PENDING     @map("pending")
  UPLOADING   @map("uploading")
  PROCESSING  @map("processing")
  READY       @map("ready")
  FAILED      @map("failed")
  QUARANTINED @map("quarantined")
  DELETED     @map("deleted")
}
```

### Step 7: Storage Backend Integration & CDN
Configure storage providers and CDN for serving:

```
STORAGE BACKEND CONFIGURATION:
┌──────────────────────────────────────────────────────────┐
│  S3 / R2 / MinIO (S3-compatible):                         │
│    SDK: @aws-sdk/client-s3                                │
│    Auth: IAM role (EC2/ECS) or access key                 │
│    Upload: PutObject, CreateMultipartUpload               │
│    Download: GetObject or presigned GET URL               │
│    CDN: CloudFront with OAC (Origin Access Control)       │
│                                                           │
│  GCS (Google Cloud Storage):                              │
│    SDK: @google-cloud/storage                             │
│    Auth: Service account or Workload Identity              │
│    Upload: createWriteStream, createResumableUpload       │
│    Download: createReadStream or signed URL                │
│    CDN: Cloud CDN with backend bucket                     │
│                                                           │
│  Azure Blob Storage:                                      │
│    SDK: @azure/storage-blob                               │
│    Auth: Managed Identity or connection string             │
│    Upload: uploadBlockBlob, stageBlock + commitBlockList  │
│    Download: download or SAS token URL                    │
│    CDN: Azure CDN with blob origin                        │
│                                                           │
│  Local Filesystem (development / self-hosted):             │
│    Path: /var/data/uploads/<tenant>/<file>                 │
│    Serve: nginx with X-Accel-Redirect header              │
│    Backup: rsync to remote or sync to S3                  │
│    CDN: Cloudflare in front of origin                     │
└──────────────────────────────────────────────────────────┘

CDN SERVING PATTERN:
┌────────┐     ┌─────────┐     ┌─────────┐     ┌────────┐
│ Client │────>│ CDN     │────>│ Origin  │────>│ S3/GCS │
│        │     │ (edge)  │     │ (shield)│     │ (cold)  │
└────────┘     └─────────┘     └─────────┘     └────────┘
  Cache HIT:     < 10 ms
  Cache MISS:    + 50-200 ms (origin fetch, then cached)

CDN HEADERS:
  Cache-Control: public, max-age=31536000, immutable
  Content-Type: image/webp (or appropriate)
  Vary: Accept (for format negotiation — webp vs avif vs jpg)
  ETag: "<content-hash>"

SIGNED URL SERVING (private files):
  1. Client requests file via API
  2. API checks permissions
  3. API generates signed CDN URL (short expiry: 5-15 min)
  4. Client fetches from CDN with signed URL
  5. CDN validates signature, serves or fetches from origin
```

### Step 8: Orphaned Upload Cleanup
Remove uploads that were never completed or are no longer referenced:

```
ORPHANED UPLOAD CLEANUP:
┌──────────────────────────────────────────────────────────┐
│  Type 1: INCOMPLETE UPLOADS                               │
│  - Status: "pending" or "uploading" for > 24 hours        │
│  - Cause: User abandoned upload, browser crashed           │
│  - Fix: Cron job deletes DB record + S3 object            │
│                                                           │
│  Type 2: INCOMPLETE MULTIPART UPLOADS (S3)                │
│  - S3 retains partial chunks until explicitly aborted     │
│  - Cause: Client never called CompleteMultipartUpload     │
│  - Fix: S3 lifecycle rule aborts after 24 hours           │
│  - Also: Cron calls ListMultipartUploads and aborts stale │
│                                                           │
│  Type 3: UNREFERENCED FILES                               │
│  - Files in S3 not referenced by any DB record            │
│  - Cause: DB record deleted but S3 object remained        │
│  - Fix: Reconciliation job compares S3 listing vs DB      │
│  - Schedule: Weekly, with dry-run mode first              │
│                                                           │
│  Type 4: SOFT-DELETED PAST RETENTION                      │
│  - Status: "deleted", deleted_at > 30 days ago            │
│  - Cause: Intentional soft delete, retention period over  │
│  - Fix: Cron hard-deletes S3 objects + DB records          │
│                                                           │
│  Type 5: EXPIRED TEMPORARY UPLOADS                        │
│  - expires_at < NOW()                                     │
│  - Cause: One-time share links, preview uploads            │
│  - Fix: Cron deletes expired uploads                      │
│                                                           │
│  Implementation:                                          │
│  - Cron: Run cleanup every hour                           │
│  - Batch: Process 100 files per run (avoid timeout)       │
│  - Logging: Log every deletion with file ID and reason    │
│  - Safety: Dry-run mode for new cleanup rules             │
│  - Alerts: Alert if cleanup deletes > threshold per run   │
└──────────────────────────────────────────────────────────┘
```

```typescript
// Cleanup cron job
async function cleanupOrphanedUploads() {
  const now = new Date();
  const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
  const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

  // 1. Incomplete uploads (pending > 24h)
  const staleUploads = await db.upload.findMany({
    where: {
      status: { in: ['pending', 'uploading'] },
      createdAt: { lt: oneDayAgo },
    },
    take: 100,
  });

  for (const upload of staleUploads) {
    await deleteUploadFromStorage(upload.storageKey, upload.storageBucket);
    await db.upload.delete({ where: { id: upload.id } });
    logger.info('Cleaned up stale upload', { id: upload.id, status: upload.status });
  }

  // 2. Soft-deleted past retention
  const expiredDeleted = await db.upload.findMany({
    where: {
      deletedAt: { lt: thirtyDaysAgo, not: null },
    },
    take: 100,
  });

  for (const upload of expiredDeleted) {
    // Delete all variants + original from storage
    const keys = [upload.storageKey];
    if (upload.variants && typeof upload.variants === 'object') {
      for (const v of Object.values(upload.variants as Record<string, any>)) {
        if (v.key) keys.push(v.key);
      }
    }
    await deleteMultipleFromStorage(keys, upload.storageBucket);
    await db.upload.delete({ where: { id: upload.id } });
    logger.info('Hard-deleted expired upload', { id: upload.id });
  }

  // 3. Expired temporary uploads
  const expiredTemp = await db.upload.findMany({
    where: {
      expiresAt: { lt: now, not: null },
      deletedAt: null,
    },
    take: 100,
  });

  for (const upload of expiredTemp) {
    await deleteUploadFromStorage(upload.storageKey, upload.storageBucket);
    await db.upload.update({
      where: { id: upload.id },
      data: { status: 'deleted', deletedAt: now },
    });
    logger.info('Cleaned up expired upload', { id: upload.id });
  }

  // 4. Abort stale S3 multipart uploads
  const multipartUploads = await s3.send(new ListMultipartUploadsCommand({
    Bucket: process.env.UPLOAD_BUCKET,
  }));

  for (const mp of multipartUploads.Uploads ?? []) {
    if (mp.Initiated && mp.Initiated < oneDayAgo) {
      await s3.send(new AbortMultipartUploadCommand({
        Bucket: process.env.UPLOAD_BUCKET,
        Key: mp.Key,
        UploadId: mp.UploadId,
      }));
      logger.info('Aborted stale multipart upload', { key: mp.Key, uploadId: mp.UploadId });
    }
  }

  logger.info('Cleanup complete', {
    stale: staleUploads.length,
    expired: expiredDeleted.length,
    temporary: expiredTemp.length,
    multipart: multipartUploads.Uploads?.length ?? 0,
  });
}
```

### Step 9: Commit and Report
```
1. Save upload configuration in appropriate locations:
   - Upload service: src/services/upload/ or src/lib/upload/
   - Image processing: src/services/media/ or src/workers/image-processor/
   - Video processing: src/services/media/ or src/workers/video-processor/
   - Validation: src/lib/validation/file-validator
   - Cleanup cron: src/jobs/cleanup-uploads
   - DB migration: prisma/migrations/ or src/db/migrations/
2. Commit: "upload: <description> — <components implemented>"
3. If presigned URL flow: "upload: presigned URL flow with <N> image variants"
4. If video pipeline: "upload: video transcoding with HLS adaptive streaming"
5. If cleanup: "upload: orphaned upload cleanup cron job"
```

## Key Behaviors

1. **Never proxy file uploads through your API server.** Use presigned URLs for direct-to-storage uploads. Your server generates the URL; the client uploads directly. This eliminates the server as a bottleneck and saves compute.
2. **Validate files on the server side after upload, not just before.** Client-side checks are for UX. Post-upload validation (magic bytes, virus scan, dimension check) is for security. A file that passes presign validation can still be malicious.
3. **Strip EXIF data from every image.** EXIF contains GPS coordinates, device serial numbers, and timestamps. Serving user photos with intact EXIF is a privacy liability. Use Sharp's `.rotate()` to apply orientation before stripping.
4. **Choose the right upload strategy for the file size.** Single presigned PUT for files under 10 MB. Multipart for 10 MB to 5 GB. Resumable (tus) for mobile or unstable networks. Over-engineering small uploads wastes time; under-engineering large uploads wastes user patience.
5. **Process images at upload time, not at request time.** Pre-generate all variants (thumbnail, small, medium, large) and store them. On-demand resizing adds latency to every request and unpredictable compute costs.
6. **Always generate a blur placeholder (LQIP).** A 20x20 base64 image under 1 KB that loads instantly and blurs up while the real image loads. Users perceive the page as faster even when images are still loading.
7. **Scan every upload for malware.** ClamAV is free and catches the majority of threats. Never make an uploaded file available to other users before scanning it. Quarantine files that fail scanning.
8. **Run cleanup jobs from day one.** Incomplete uploads, orphaned files, and expired temporary files accumulate silently. A daily cron that deletes stale uploads and reconciles storage prevents runaway costs.
9. **Serve through CDN with immutable caching.** Processed images and video segments are content-addressed or versioned. Set `Cache-Control: public, max-age=31536000, immutable` and never worry about invalidation.
10. **Track every upload in the database.** Store status, variants, virus scan result, and access count. The database is the source of truth; S3 is just the storage backend. Without metadata, you cannot clean up, audit, or serve files reliably.

## Example Usage

### Setting up image uploads for a social app
```
User: /godmode:upload Set up image uploads for our social media app

Upload: Analyzing requirements...

Application: Social media app (profile photos + post images)
File types: JPEG, PNG, WebP, GIF
Max size: 10 MB per image
Scale: ~20K uploads/day

Architecture:
  1. Presigned URL flow (direct to S3, no server proxy)
  2. Post-upload Lambda processes images:
     - Magic byte validation
     - ClamAV virus scan
     - EXIF stripping
     - Generate 4 variants: thumb (200x200), small (400w), medium (800w), large (1600w)
     - Generate WebP + AVIF for each variant
     - Generate blur placeholder (base64, < 1 KB)
  3. Serve via CloudFront CDN with Accept header negotiation
  4. Database tracks upload status, variants, scan results

Variants per image: 4 sizes x 2 formats = 8 files + placeholder
Average processing time: 2-4 seconds
Storage: ~3 KB (thumb) to ~150 KB (large) per variant

Cleanup: Cron every hour deletes pending uploads > 24h old
```

### Adding video upload support
```
User: /godmode:upload Add video uploads with transcoding

Upload: Designing video pipeline...

Upload strategy: Multipart upload (videos typically 50-500 MB)
  - 10 MB chunks, 5 parallel, per-chunk retry
  - Resume on failure via stored part ETags

Validation: ffprobe checks container, codec, duration (max 10 min)
Virus scan: ClamAV on downloaded file before processing

Transcoding (FFmpeg):
  - 360p (800 Kbps) — mobile fallback
  - 720p (2.5 Mbps) — default quality
  - 1080p (5 Mbps) — high quality
  - HLS adaptive streaming (6s segments, all qualities)

Generated assets:
  - 3 thumbnails (at 10%, 50%, 90% duration)
  - Poster image (best thumbnail, WebP)
  - Preview clip (first 3s, muted, 320px wide)

Processing: SQS queue -> ECS Fargate task (FFmpeg container)
Estimated time: 30s per minute of video at 720p
Serving: CloudFront with signed URLs for premium content
```

### Cleaning up orphaned uploads
```
User: /godmode:upload Our S3 has 500 GB of orphaned files, help clean up

Upload: Analyzing upload hygiene...

Storage audit:
  Total S3 objects: 2.3M
  DB upload records: 1.8M
  Orphaned (in S3 but not in DB): 312K objects (142 GB)
  Stale pending uploads (> 24h): 45K records (28 GB)
  Incomplete multipart uploads: 890 (34 GB)
  Soft-deleted past retention: 22K records (18 GB)

Cleanup plan:
  1. Abort 890 incomplete multipart uploads: saves 34 GB (immediate)
  2. Delete 45K stale pending uploads: saves 28 GB (after verification)
  3. Hard-delete 22K expired soft-deletes: saves 18 GB
  4. Reconcile orphaned objects (dry-run first): saves 142 GB
  5. Add S3 lifecycle rule to auto-abort multipart after 24h

Total savings: 222 GB ($5.10/month storage + reduced request costs)
Add cron: hourly cleanup of stale + expired uploads
Add weekly: S3-to-DB reconciliation with dry-run logging
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full upload architecture design and implementation |
| `--presign` | Presigned URL upload flow only |
| `--multipart` | Multipart/chunked upload implementation only |
| `--tus` | Resumable upload with tus protocol |
| `--image` | Image optimization pipeline only |
| `--video` | Video processing pipeline only |
| `--validate` | File validation and security (MIME, virus, EXIF) |
| `--schema` | Database schema for upload metadata |
| `--cleanup` | Orphaned upload cleanup job |
| `--cdn` | CDN integration and serving configuration |
| `--provider <name>` | Target provider (aws, gcp, azure, cloudflare) |
| `--tool <name>` | Specific tool (sharp, cloudinary, imgproxy, ffmpeg) |

## HARD RULES

1. NEVER proxy file uploads through your application server when presigned URLs are available. Direct-to-storage uploads eliminate your server as a bottleneck and single point of failure.
2. NEVER trust the Content-Type header or file extension. Always validate file type by inspecting magic bytes. A file named `photo.jpg` containing PHP is an attack.
3. ALWAYS scan uploaded files for viruses before making them accessible. If the scanner is unavailable, quarantine the file. Never skip the scan.
4. ALWAYS strip EXIF metadata from images before storage. EXIF contains GPS coordinates, device info, and timestamps that leak user privacy.
5. NEVER serve user-uploaded files from the same domain as your application. Use a separate domain or CDN subdomain to prevent cookie theft and XSS via uploaded HTML/SVG.
6. ALWAYS enforce file size limits on both client and server. Client-side limits improve UX; server-side limits prevent abuse. They must match.
7. NEVER generate predictable or sequential file names for uploads. Use UUIDs or content hashes. Predictable names enable enumeration attacks.
8. ALWAYS implement orphan cleanup. Uploads that start but never complete, or files referenced by deleted records, accumulate silently. Run a periodic cleanup job.

## Auto-Detection

Before implementing, detect existing upload infrastructure:

```bash
# Detect upload libraries and SDKs
echo "=== Upload Libraries ==="
grep -r "multer\|busboy\|formidable\|sharp\|@aws-sdk/s3\|@google-cloud/storage\|@azure/storage-blob" package.json 2>/dev/null
grep -r "boto3\|google.cloud.storage\|azure.storage.blob\|django-storages\|carrierwave\|activestorage" requirements.txt Gemfile 2>/dev/null

# Detect existing upload handling
echo "=== Upload Handlers ==="
grep -r "multer\|upload\|presigned\|putObject\|getSignedUrl" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5

# Detect image processing
echo "=== Image Processing ==="
grep -r "sharp\|jimp\|imagemagick\|pillow\|cloudinary\|imgproxy" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5

# Detect virus scanning
echo "=== Virus Scanning ==="
grep -r "clamav\|clamscan\|virus\|malware" --include="*.ts" --include="*.js" --include="*.py" --include="*.yaml" -l 2>/dev/null | head -5

# Detect storage configuration
echo "=== Storage Config ==="
grep -r "S3_BUCKET\|STORAGE_BUCKET\|AZURE_CONTAINER\|UPLOAD_DIR\|CLOUDINARY" .env .env.example 2>/dev/null
```

## Iteration Protocol
```
WHILE upload implementation is incomplete:
  1. REVIEW — check current state: which components exist (presigned URLs, processing, validation, CDN), which are missing
  2. IMPLEMENT — pick next component from the plan, implement with tests
  3. TEST — upload test file end-to-end: presigned URL → upload → processing → CDN serving
  4. VERIFY — check: file accessible via CDN, EXIF stripped, variants generated, virus scan passed
  IF tests pass AND component works: commit, move to next component
  IF tests fail: check storage permissions, CORS config, processing pipeline. Fix and re-test (max 3 attempts)
STOP: all components implemented, end-to-end upload works, processing pipeline verified, cleanup automation active
```

## TSV Logging
After each workflow step, append a row to `.godmode/upload-results.tsv`:
```
STEP\tCOMPONENT\tPROVIDER\tSTATUS\tDETAILS
1\tpresigned-urls\ts3\tcreated\tPUT for upload, GET for download, 15min expiry
2\tvalidation\tcustom\tcreated\tmagic bytes check, size limits, allowed types whitelist
3\tvirus-scan\tclamav\tcreated\tclamscan on upload before public access
4\timage-processing\tsharp\tcreated\tthumbnail(150x150) + medium(800x600) + webp conversion + EXIF strip
5\tcdn-serving\tcloudfront\tconfigured\timmutable cache headers, custom domain, OAC
6\tcleanup\tcron\tcreated\tabort incomplete multipart uploads after 24h
```
Print final summary: `Uploads: {file_types}, max size: {size}. Storage: {provider}. Processing: {pipeline}. CDN: {cdn}. Virus scan: {yes/no}. Resumable: {yes/no}.`

## Success Criteria
All of these must be true before marking the task complete:
1. Presigned URL generation works for upload (PUT) and download (GET) with correct expiry.
2. File validation rejects invalid types (magic bytes check, not just extension/Content-Type).
3. Virus scanning runs on every upload before the file is accessible to other users.
4. Image processing generates all required variants and strips EXIF metadata.
5. CDN serves processed files with correct cache headers (`Cache-Control: public, max-age=31536000, immutable`).
6. Upload size limits enforced both client-side (early feedback) and server-side (authoritative).
7. Incomplete multipart uploads are cleaned up automatically (lifecycle rule or cron job).
8. Upload metadata stored in database (not just object storage tags) for querying and cleanup.

## Error Recovery
| Failure | Action |
|---------|--------|
| Presigned URL returns 403 | Check IAM permissions for `s3:PutObject` and `s3:GetObject`. Verify bucket policy. Check clock skew (<15min). Verify URL hasn't expired. Check that bucket region matches the signing region. |
| CORS error on browser upload | Verify bucket CORS allows: origin (your domain), method (PUT), headers (Content-Type, x-amz-*). Clear browser CORS cache (test in incognito). Check that preflight OPTIONS request succeeds. |
| Image processing fails | Check file is valid image (magic bytes, not just extension). For Sharp: check `sharp.versions` for libvips. For large files: process in background job with memory limits, not in request handler. |
| Virus scanner rejects clean file | Check ClamAV signature database is current (`freshclam`). Test with EICAR test file to verify scanner works. If false positive: quarantine file, log for manual review, do not auto-approve. |
| Upload timeout for large files | Switch to multipart upload (>100MB). Implement resumable uploads (tus protocol) for unreliable networks. Set client timeout to match expected upload duration at minimum bandwidth. |
| CDN serving stale content | Use content-hashed filenames (`{hash}.{ext}`) to make cache invalidation unnecessary. If using mutable URLs: create CloudFront invalidation. Check CDN TTL settings. |

## Multi-Agent Dispatch
```
Agent 1 (worktree: upload-core):
  - Configure storage bucket with IAM, CORS, lifecycle rules
  - Build presigned URL generation endpoints (upload + download)
  - Implement file validation (magic bytes, size limits, type whitelist)

Agent 2 (worktree: upload-processing):
  - Implement image processing pipeline (variants, EXIF strip, format conversion, blur placeholder)
  - Add virus scanning integration (ClamAV or cloud-native)
  - Build video processing if needed (thumbnails, transcoding, adaptive bitrate)

Agent 3 (worktree: upload-serving):
  - Configure CDN with origin access control and cache policies
  - Build upload confirmation and metadata tracking API
  - Implement cleanup automation (incomplete uploads, orphaned files)

MERGE ORDER: core -> processing -> serving
CONFLICT ZONES: storage client initialization, upload route handlers, file metadata schema
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run upload tasks sequentially: storage config, then presigned URLs, then processing pipeline, then CDN and cleanup.
- Use branch isolation per task: `git checkout -b godmode-upload-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.

## Anti-Patterns

- **Do NOT proxy file uploads through your API server.** Use presigned URLs. Your server should never be a data pipe between client and storage — it wastes compute, adds latency, and creates a single point of failure.
- **Do NOT trust the Content-Type header or file extension.** Always inspect magic bytes to determine the real file type. A file named `photo.jpg` with PHP inside it is an attack, not an image.
- **Do NOT serve uploaded files without virus scanning.** Even images can contain malware. Scan every file before making it accessible. If the scanner is down, quarantine the file — do not skip the scan.
- **Do NOT serve images with EXIF data intact.** GPS coordinates, device identifiers, and timestamps are embedded in photos. Strip EXIF before storing processed variants.
- **Do NOT resize images on every request.** Pre-generate variants at upload time and cache them with immutable headers. On-demand resizing has unpredictable latency and cost.
- **Do NOT skip the blur placeholder.** Without LQIP, users see a blank space or layout shift while images load. A 20x20 base64 image costs almost nothing and significantly improves perceived performance.
- **Do NOT let incomplete uploads accumulate.** S3 multipart uploads that are never completed still cost money. Add lifecycle rules to abort them after 24 hours. Run a cleanup cron for stale DB records.
- **Do NOT store upload metadata only in S3 tags or object metadata.** Use a database as the source of truth. S3 metadata is hard to query, and you need to filter, sort, and aggregate uploads for cleanup, analytics, and serving.
- **Do NOT generate video thumbnails only at the start of the video.** The first frame is often black or a logo. Generate thumbnails at 10%, 50%, and 90% of duration and pick the best one (highest contrast/entropy).
- **Do NOT skip adaptive bitrate streaming for video.** Serving a single quality forces mobile users to buffer or desktop users to watch low quality. HLS with multiple quality levels adapts automatically.