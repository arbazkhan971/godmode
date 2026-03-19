---
name: multimodal
description: |
  Multimodal AI skill. Activates when users need to build AI systems that process multiple data types -- images, audio, video, documents, and text together. Covers vision model integration (image analysis, OCR), audio processing (speech-to-text, text-to-speech), document understanding (PDF parsing, table extraction), and multi-modal RAG systems. Every multimodal pipeline gets a structured design, model selection guide, processing pipeline, evaluation suite, and integration plan. Triggers on: /godmode:multimodal, "analyze images", "process audio", "extract from PDF", "multi-modal", or when the orchestrator detects multimodal AI work.
---

# Multimodal — Multimodal AI

## When to Activate
- User invokes `/godmode:multimodal`
- User says "analyze images", "process audio", "extract from PDF", "video analysis"
- User says "OCR", "speech-to-text", "text-to-speech", "image captioning"
- User says "multimodal RAG", "search across images and text", "document understanding"
- When building systems that process multiple input types (text + images, text + audio, etc.)
- When `/godmode:rag` needs to handle non-text documents (PDFs with tables/images, scanned docs)
- When `/godmode:agent` needs vision or audio capabilities as tools
- When the orchestrator detects multimodal libraries (Pillow, OpenCV, whisper, TTS, pdf parsers, vision APIs) in code

## Workflow

### Step 1: Multimodal Discovery & Requirements
Understand what modalities are needed and why:

```
MULTIMODAL DISCOVERY:
Use case: <what the multimodal system must accomplish>
Modalities required:
  - [ ] Text (natural language input/output)
  - [ ] Images (photos, screenshots, diagrams, charts)
  - [ ] Audio (speech, music, environmental sounds)
  - [ ] Video (clips, streams, recordings)
  - [ ] Documents (PDFs, scanned documents, forms)
  - [ ] Tables (spreadsheets, HTML tables, CSV)
  - [ ] Code (source code with syntax, notebooks)

Processing types:
  - [ ] Understanding: analyze and describe content (image captioning, transcription)
  - [ ] Extraction: pull structured data from unstructured media (OCR, table extraction)
  - [ ] Generation: create media from text (image generation, TTS)
  - [ ] Search: find content across modalities (image-text search, audio search)
  - [ ] Transformation: convert between modalities (speech-to-text, text-to-speech)

Volume and scale:
  Items to process: <N per day>
  Avg item size: <MB per item>
  Latency requirement: <real-time | near-real-time | batch>
  Accuracy requirement: <percentage>

Infrastructure:
  Cloud: <AWS | GCP | Azure | self-hosted>
  GPU available: <yes (type) | no (CPU/API only)>
  Budget: <monthly cost limit>
```

If the user hasn't specified, ask: "What types of media does your system need to process, and what should it do with them?"

### Step 2: Vision Model Selection & Integration
Choose and integrate vision capabilities:

```
VISION MODEL SELECTION:

Use case to model mapping:
+-----------------------------+-------------------------+---------------------------+
| Use Case                    | Recommended Model       | Notes                     |
+-----------------------------+-------------------------+---------------------------+
| General image understanding | Claude 3.5 Sonnet       | Best overall vision +     |
| (describe, analyze, reason) | GPT-4o                  | language reasoning        |
|                             | Gemini 1.5 Pro          |                           |
|                             |                         |                           |
| OCR (printed text)          | Claude 3.5 Sonnet       | Excellent OCR built-in,   |
|                             | GPT-4o                  | handles complex layouts   |
|                             | Tesseract (free)        | Free but lower quality    |
|                             | Google Vision API       | Production-grade OCR      |
|                             |                         |                           |
| OCR (handwritten)           | Google Vision API       | Best handwriting recog.   |
|                             | Azure AI Vision         | Strong handwriting        |
|                             | Claude 3.5 Sonnet       | Good, improving           |
|                             |                         |                           |
| Object detection            | YOLO v8/v9              | Real-time, self-hosted    |
|                             | Florence-2              | Open-source, versatile    |
|                             | Google Vision API       | Managed, production       |
|                             |                         |                           |
| Image classification        | CLIP / SigLIP           | Zero-shot, self-hosted    |
|                             | Fine-tuned ViT          | Custom classes            |
|                             | Cloud Vision APIs       | Managed, pre-trained      |
|                             |                         |                           |
| Image generation            | DALL-E 3                | Text-to-image, API       |
|                             | Stable Diffusion XL     | Self-hosted, customizable |
|                             | Midjourney              | Highest aesthetic quality |
|                             | Flux                    | Open-source, high quality |
|                             |                         |                           |
| Chart/diagram understanding | Claude 3.5 Sonnet       | Excellent chart reading   |
|                             | GPT-4o                  | Strong diagram analysis   |
|                             | Gemini 1.5 Pro          | Good with tables/charts   |
|                             |                         |                           |
| Image embedding             | CLIP ViT-L/14           | Standard, well-supported  |
| (for similarity search)     | SigLIP                  | Better quality than CLIP  |
|                             | OpenAI CLIP             | API-based                 |
+-----------------------------+-------------------------+---------------------------+

SELECTED: <Model(s)> -- <justification>

Vision pipeline design:
  Input handling:
    Supported formats: <JPEG, PNG, WebP, GIF, TIFF, BMP, SVG>
    Max resolution: <N x N pixels>
    Preprocessing:
      - Resize to max dimension: <N pixels> (preserve aspect ratio)
      - Format conversion: <normalize to JPEG/PNG>
      - EXIF orientation correction
      - Color space normalization (sRGB)

  API integration:
    Provider: <Anthropic | OpenAI | Google | self-hosted>
    Image encoding: <base64 | URL reference>
    Max images per request: <N>
    Token cost per image: <N tokens equivalent>
    Rate limits: <N requests/min>

  Batch processing (if needed):
    Batch size: <N images>
    Parallelism: <N concurrent requests>
    Error handling: <retry with backoff | skip and log>
    Throughput: <N images/minute>

Example vision prompt:
  "Analyze this image and provide:
   1. A detailed description of what you see
   2. Any text visible in the image (OCR)
   3. Key objects and their spatial relationships
   4. Any notable patterns or anomalies

   Output as structured JSON."
```

### Step 3: Audio Processing
Choose and integrate audio capabilities:

```
AUDIO PROCESSING:

Speech-to-Text (STT):
+-----------------------------+------------------+------------------+------------------------+
| Model/Service               | Quality (WER)    | Latency          | Cost                   |
+-----------------------------+------------------+------------------+------------------------+
| OpenAI Whisper (API)        | ~5% WER          | ~1x realtime     | $0.006/min             |
| OpenAI Whisper (local)      | ~5% WER          | GPU: 0.3x RT     | Free (GPU required)    |
|                             |                  | CPU: 2-5x RT     |                        |
| Whisper large-v3-turbo      | ~6% WER          | GPU: 0.15x RT    | Free (GPU required)    |
| Google Speech-to-Text v2    | ~4% WER          | Streaming OK      | $0.016/min             |
| Azure Speech Services       | ~5% WER          | Streaming OK      | $0.016/min             |
| Deepgram Nova-2             | ~4% WER          | Streaming, fast   | $0.0043/min            |
| AssemblyAI                  | ~4% WER          | Streaming OK      | $0.01/min              |
+-----------------------------+------------------+------------------+------------------------+

STT features needed:
  - [ ] Real-time / streaming transcription
  - [ ] Speaker diarization (who said what)
  - [ ] Timestamps (word-level or segment-level)
  - [ ] Punctuation and formatting
  - [ ] Language detection
  - [ ] Multi-language support
  - [ ] Custom vocabulary (domain terms, names)
  - [ ] Noise robustness

SELECTED STT: <Model/Service> -- <justification>

Text-to-Speech (TTS):
+-----------------------------+------------------+------------------+------------------------+
| Model/Service               | Quality          | Latency          | Cost                   |
+-----------------------------+------------------+------------------+------------------------+
| OpenAI TTS (tts-1-hd)      | Very high        | ~0.5s TTFB       | $0.030/1K chars        |
| OpenAI TTS (tts-1)          | High             | ~0.3s TTFB       | $0.015/1K chars        |
| ElevenLabs                  | Highest          | ~0.3s TTFB       | $0.018/1K chars        |
| Google Cloud TTS            | High             | ~0.2s TTFB       | $0.016/1M chars        |
| Azure Neural TTS            | High             | ~0.2s TTFB       | $0.016/1M chars        |
| Coqui XTTS (self-hosted)    | High             | GPU-dependent     | Free (GPU required)    |
| Bark (self-hosted)          | Medium-High      | Slow              | Free (GPU required)    |
+-----------------------------+------------------+------------------+------------------------+

TTS features needed:
  - [ ] Voice cloning / custom voices
  - [ ] Streaming output
  - [ ] SSML support (emphasis, pauses, pronunciation)
  - [ ] Multi-language
  - [ ] Emotion/tone control
  - [ ] Low latency (conversational)

SELECTED TTS: <Model/Service> -- <justification>

Audio pipeline design:
  Input handling:
    Supported formats: <WAV, MP3, M4A, FLAC, OGG, WebM>
    Max duration: <N minutes>
    Sample rate: <16kHz minimum for speech>
    Preprocessing:
      - Convert to WAV/FLAC (lossless for STT)
      - Resample to target rate
      - Normalize volume
      - Noise reduction (optional: SpeechBrain, noisereduce)
      - VAD (Voice Activity Detection) for silence removal
      - Chunking for long audio (30s-60s segments)

  Streaming architecture (if real-time):
    Input: <WebSocket | WebRTC>
    Buffer: <N ms chunks>
    STT: streaming recognition
    Processing: incremental
    TTS: streaming synthesis
    Output: <WebSocket | audio stream>
```

### Step 4: Document Understanding
Extract structured information from documents:

```
DOCUMENT UNDERSTANDING:

PDF Processing:
+-----------------------------+------------------+------------------+------------------------+
| Tool/Library                | Strengths        | Weaknesses       | Best For               |
+-----------------------------+------------------+------------------+------------------------+
| PyMuPDF (fitz)              | Fast, reliable   | No table extract | Text-heavy PDFs        |
|                             | text extraction  | built-in         |                        |
|                             |                  |                  |                        |
| pdfplumber                  | Good table       | Slower than      | PDFs with tables       |
|                             | extraction       | PyMuPDF          |                        |
|                             |                  |                  |                        |
| Unstructured                | Multi-format,    | Heavy dependency | Complex docs,          |
|                             | layout analysis  | large install    | mixed content          |
|                             |                  |                  |                        |
| LlamaParse                  | LLM-powered      | API cost         | Complex layouts,       |
|                             | parsing          |                  | high accuracy needed   |
|                             |                  |                  |                        |
| Docling (IBM)               | Layout-aware,    | Newer project    | Research papers,       |
|                             | table extraction |                  | structured docs        |
|                             |                  |                  |                        |
| marker                      | High quality     | GPU recommended  | Converting PDFs to     |
|                             | PDF to markdown  |                  | clean markdown         |
|                             |                  |                  |                        |
| Vision LLM (Claude/GPT-4o) | Handles any      | Expensive at     | Scanned docs, complex  |
|                             | layout, OCR      | scale            | layouts, forms         |
+-----------------------------+------------------+------------------+------------------------+

SELECTED: <Tool(s)> -- <justification>

Table extraction:
  Method: <pdfplumber | Camelot | Tabula | vision LLM | Unstructured>
  Output format: <CSV | JSON | pandas DataFrame | markdown>
  Accuracy target: <percentage of cells correctly extracted>
  Handling complex tables: <merged cells, nested headers, multi-page tables>

Document processing pipeline:
  +----------+    +----------+    +----------+    +----------+    +----------+
  | Document | -> | Classify | -> | Extract  | -> | Structure| -> | Store /  |
  | Input    |    | & Route  |    | Content  |    | & Enrich |    | Index    |
  +----------+    +----------+    +----------+    +----------+    +----------+

  Stage 1 -- Classification:
    Determine document type: <PDF | scanned PDF | image | form | spreadsheet>
    Route to appropriate extractor

  Stage 2 -- Content extraction:
    Text: <PDF text layer | OCR for scanned docs>
    Tables: <table extraction tool>
    Images: <extract embedded images, caption with vision model>
    Metadata: <title, author, date, page count, language>

  Stage 3 -- Structuring:
    Convert to unified format: <markdown | JSON | structured text>
    Preserve hierarchy: <headings, sections, subsections>
    Link tables to surrounding context
    Add page numbers and source references

  Stage 4 -- Enrichment:
    Generate summaries per section
    Extract key entities (names, dates, amounts, terms)
    Generate embeddings for each section/chunk
    Add to vector store for retrieval

Form processing (if applicable):
  Method: <template-based extraction | vision LLM | specialized form OCR>
  Fields to extract: <list of field names and types>
  Confidence scoring: <per-field confidence>
  Human review threshold: confidence < <val>
```

### Step 5: Multi-Modal RAG Systems
Build RAG systems that work across modalities:

```
MULTI-MODAL RAG DESIGN:

Architecture:
  +-------------+    +-------------+    +-------------+    +-------------+
  | Text        | -> | Text        | -> |             | -> |             |
  | Documents   |    | Embeddings  |    |             |    |             |
  +-------------+    +-------------+    |             |    |             |
                                        |   Unified   |    |   Multi-    |
  +-------------+    +-------------+    |   Vector    |    |   Modal     |
  | Images      | -> | Image       | -> |   Store     |    |   LLM      |
  |             |    | Embeddings  |    |             |    |   Generation|
  +-------------+    +-------------+    |             |    |             |
                                        |             |    |             |
  +-------------+    +-------------+    |             |    |             |
  | Audio       | -> | Transcribe  | -> |             |    |             |
  |             |    | + Embed     |    |             |    |             |
  +-------------+    +-------------+    +-------------+    +-------------+

Embedding strategies for multi-modal:
+-----------------------------+------------------+----------------------------------------+
| Strategy                    | Quality          | Description                            |
+-----------------------------+------------------+----------------------------------------+
| Unified embedding space     | Highest          | Use CLIP/SigLIP for images and text    |
| (same model for all)        |                  | in shared space. Direct cross-modal    |
|                             |                  | search (text query finds images).      |
|                             |                  |                                        |
| Caption + text embedding    | High             | Generate captions for images/audio,    |
| (describe then embed)       |                  | then embed captions with text model.   |
|                             |                  | Simpler, works with any text embedder. |
|                             |                  |                                        |
| Separate indexes            | Medium           | Separate vector stores per modality.   |
| (per modality)              |                  | Query each, merge results. Simple but  |
|                             |                  | no cross-modal search.                 |
|                             |                  |                                        |
| Late fusion                 | High             | Embed each modality separately, fuse   |
| (embed separately, fuse)    |                  | at retrieval time with learned weights.|
+-----------------------------+------------------+----------------------------------------+

SELECTED: <Strategy> -- <justification>

Multi-modal context assembly:
  When retrieved context includes images:
    Option A: Pass images directly to vision-capable LLM (Claude, GPT-4o)
    Option B: Convert images to text descriptions, pass text only
    Option C: Hybrid -- pass images for complex visuals, descriptions for simple ones
    SELECTED: <option>

  When retrieved context includes audio:
    Always: transcribe audio to text before passing to LLM
    Optionally: include audio metadata (duration, speaker, timestamp)

  Context budget allocation:
    Text chunks: <N tokens>
    Image descriptions: <N tokens per image>
    Direct images: <N images max> (each costs ~<N> tokens)
    Audio transcripts: <N tokens>
    Total context: <N tokens>

Document-level retrieval:
  For PDFs with mixed content (text + tables + images):
    1. Parse document into sections
    2. For each section, extract text, tables, and images
    3. Generate unified representation: text + table-as-text + image-caption
    4. Embed the unified representation
    5. At retrieval time, return the full section (text + table + image reference)
    6. Pass to vision LLM for generation (include original images when relevant)
```

### Step 6: Multi-Modal Evaluation
Evaluate multi-modal pipeline quality:

```
MULTI-MODAL EVALUATION:

Per-modality metrics:
+-----------------------------+------------------+------------------+
| Modality                    | Metric           | Score            |
+-----------------------------+------------------+------------------+
| Text extraction (OCR)       | Character accuracy| <val>%          |
|                             | Word accuracy     | <val>%          |
|                             | Layout preserved  | <val>%          |
|                             |                   |                 |
| Table extraction            | Cell accuracy     | <val>%          |
|                             | Structure correct | <val>%          |
|                             | Header detection  | <val>%          |
|                             |                   |                 |
| Image understanding         | Description quality| <val>/5 (judge)|
|                             | Object detection  | mAP=<val>       |
|                             | Classification    | accuracy=<val>  |
|                             |                   |                 |
| Speech-to-text              | WER               | <val>%          |
|                             | Speaker accuracy  | <val>%          |
|                             | Timestamp accuracy| <val>ms drift   |
|                             |                   |                 |
| Multi-modal RAG             | Hit rate @ K      | <val>%          |
|                             | Cross-modal recall| <val>%          |
|                             | Answer faithfulness| <val>          |
+-----------------------------+------------------+------------------+

End-to-end evaluation:
  Test set: <N multi-modal queries with ground truth>
  Query types:
    - Text-only queries: <N> (accuracy: <val>%)
    - Image-related queries: <N> (accuracy: <val>%)
    - Table/data queries: <N> (accuracy: <val>%)
    - Cross-modal queries: <N> (accuracy: <val>%)

  Latency by modality:
  +-----------------------------+----------+----------+
  | Pipeline                    | p50      | p95      |
  +-----------------------------+----------+----------+
  | Text query -> text answer   | <ms>     | <ms>     |
  | Image input -> text answer  | <ms>     | <ms>     |
  | Text query -> image result  | <ms>     | <ms>     |
  | Audio input -> text answer  | <ms>     | <ms>     |
  | Document -> structured data | <ms>     | <ms>     |
  +-----------------------------+----------+----------+

  Cost per modality:
  +-----------------------------+------------------+
  | Operation                   | Cost per item    |
  +-----------------------------+------------------+
  | Text embedding              | $<val>           |
  | Image analysis (LLM)       | $<val>           |
  | OCR processing              | $<val>           |
  | Audio transcription         | $<val>/minute    |
  | TTS generation              | $<val>/1K chars  |
  | Document parsing            | $<val>/page      |
  +-----------------------------+------------------+

VERDICT: <PASS | NEEDS IMPROVEMENT -- specify which modality>
```

### Step 7: Artifacts & Commit
Generate deliverables:

1. **Pipeline config**: `configs/multimodal/<pipeline>-config.yaml`
2. **Processing pipeline**: `src/multimodal/<pipeline>/process.py`
3. **Vision module**: `src/multimodal/<pipeline>/vision.py`
4. **Audio module**: `src/multimodal/<pipeline>/audio.py`
5. **Document module**: `src/multimodal/<pipeline>/documents.py`
6. **Evaluation suite**: `tests/multimodal/<pipeline>/eval.py`
7. **Model card**: `docs/multimodal/<pipeline>-models.md`

```
MULTIMODAL PIPELINE COMPLETE:

Architecture:
- Modalities: <list of supported modalities>
- Vision: <model(s)>
- Audio: STT=<model>, TTS=<model>
- Documents: <parser(s)>
- Embeddings: <strategy> (<model(s)>)
- RAG: <multi-modal RAG design>

Evaluation:
- Text accuracy: <val>%
- Image understanding: <val>/5
- OCR accuracy: <val>%
- Table extraction: <val>%
- STT WER: <val>%
- Cross-modal retrieval: <val>%
- E2E latency p95: <ms>

Cost:
- Per image analysis: $<val>
- Per audio minute: $<val>
- Per document page: $<val>
- Monthly estimate: $<val>

Artifacts:
- Config: configs/multimodal/<pipeline>-config.yaml
- Pipeline: src/multimodal/<pipeline>/
- Tests: tests/multimodal/<pipeline>/eval.py (<N> test cases)
- Model card: docs/multimodal/<pipeline>-models.md

Next steps:
-> /godmode:rag -- Integrate multimodal into RAG pipeline
-> /godmode:embeddings -- Optimize multimodal embeddings
-> /godmode:aiops -- Add guardrails for image/audio content
-> /godmode:finetune -- Fine-tune vision model for domain
```

Commit: `"multimodal: <pipeline> -- <modalities>, <vision_model>, OCR=<val>%, STT_WER=<val>%"`

## Key Behaviors

1. **Choose the right model for each modality.** A vision LLM (Claude, GPT-4o) is excellent for understanding but overkill for simple OCR. Match model cost to task complexity.
2. **Caption first, embed second.** For multi-modal RAG, generating text descriptions of images/audio and embedding those descriptions is simpler and often more effective than unified embedding spaces.
3. **Tables are the hardest content type.** PDF table extraction is notoriously brittle. Test thoroughly with real documents. Vision LLMs handle complex tables better than traditional parsers.
4. **Audio requires preprocessing.** Raw audio with noise, silence, and multiple speakers degrades STT quality. Always preprocess: noise reduction, VAD, segmentation.
5. **Cost scales with modality.** Image analysis costs 10-100x more per item than text. Audio transcription costs per minute. Budget carefully and cache aggressively.
6. **Evaluate per modality and end-to-end.** A multimodal system can fail in one modality while succeeding in others. Measure each component independently and the full pipeline together.
7. **Document understanding is a pipeline, not a model.** Parsing, cleaning, structuring, and enriching documents requires multiple tools chained together. No single model handles everything.

## Example Usage

### Building a Document Q&A System
```
User: /godmode:multimodal Build a system to answer questions about our PDF reports

Multimodal: Starting discovery...

MULTIMODAL DISCOVERY:
Use case: Q&A over financial reports (PDFs with text, tables, charts)
Modalities: text, tables, charts/images
Volume: 500 PDFs, ~50 queries/day

DOCUMENT PROCESSING:
  Parser: marker (PDF -> markdown) + pdfplumber (tables)
  Charts: Claude 3.5 Sonnet vision (extract data from charts)
  Tables: pdfplumber extraction -> JSON -> markdown
  Pipeline: parse -> chunk -> embed -> index

MULTI-MODAL RAG:
  Strategy: Caption + text embedding
    Charts -> vision LLM caption -> text embedding
    Tables -> markdown text -> text embedding
    Text -> direct text embedding
  Embedding: OpenAI text-embedding-3-small (1536d)
  Retrieval: hybrid search + Cohere reranker
  Generation: Claude 3.5 Sonnet (pass original images for chart questions)

EVALUATION (100 test queries):
  Text questions: 94% accuracy
  Table questions: 87% accuracy
  Chart questions: 82% accuracy
  Cross-content: 79% accuracy
  E2E latency p95: 2.1s

Cost: $45/month (50 queries/day, 500 PDFs indexed)

Verdict: PASS for text and tables. Chart accuracy at 82% -- recommend
adding chart-specific extraction in next iteration.
```

### Adding Audio to an Existing Chatbot
```
User: /godmode:multimodal Add voice input/output to our support chatbot

Multimodal: Starting discovery...

AUDIO INTEGRATION:
  STT: Deepgram Nova-2 (streaming, low latency, $0.0043/min)
    Features: speaker diarization, punctuation, custom vocabulary
    Latency: 300ms streaming lag

  TTS: OpenAI tts-1 (good quality, low latency, $0.015/1K chars)
    Voice: "nova" (natural, friendly)
    Streaming: yes (TTFB ~300ms)

  Pipeline:
    User speaks -> Deepgram STT (streaming) -> text -> existing chatbot ->
    text response -> OpenAI TTS (streaming) -> audio to user

  End-to-end voice latency:
    STT: ~300ms
    Chatbot: ~800ms (existing)
    TTS: ~300ms TTFB
    Total TTFB: ~1.4s (acceptable for voice)

  Cost per voice conversation (avg 5 min):
    STT: $0.022
    TTS: $0.045
    Total: $0.067/conversation ($201/month at 100 conversations/day)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full multimodal pipeline design workflow |
| `--vision` | Vision model selection and integration |
| `--audio` | Audio processing (STT + TTS) setup |
| `--documents` | Document understanding pipeline |
| `--ocr` | OCR optimization |
| `--tables` | Table extraction optimization |
| `--rag` | Multi-modal RAG system design |
| `--eval` | Run multimodal evaluation suite |
| `--benchmark <modality>` | Benchmark models for a specific modality |
| `--cost` | Cost analysis across modalities |
| `--stream` | Design streaming multimodal pipeline |

## Auto-Detection

```
IF requirements.txt OR pyproject.toml contains:
  "pillow" OR "opencv" OR "torchvision" OR "transformers":
    SUGGEST "Vision/image processing libraries detected. Activate /godmode:multimodal?"

IF code imports "whisper" OR "speechrecognition" OR "pyaudio" OR "soundfile":
  SUGGEST "Audio processing libraries detected. Activate /godmode:multimodal?"

IF code imports "pymupdf" OR "pdfplumber" OR "unstructured" OR "docling":
  SUGGEST "Document processing libraries detected. Activate /godmode:multimodal?"

IF code calls vision API (Claude vision, GPT-4o with images, Google Vision):
  SUGGEST "Vision API usage detected. Activate /godmode:multimodal?"

IF directory contains data/ with mixed file types (*.pdf, *.jpg, *.mp3, *.wav):
  SUGGEST "Multi-format data directory detected. Activate /godmode:multimodal?"

IF vector store code references image embeddings OR CLIP OR SigLIP:
  SUGGEST "Multi-modal embedding usage detected. Activate /godmode:multimodal?"
```

## Iterative Pipeline Build Protocol

```
WHEN building a multi-modal processing pipeline:

modalities_to_build = [m for m in required_modalities]  # e.g., ["text", "images", "audio", "documents"]
current_modality = 0
total_modalities = len(modalities_to_build)
built_pipelines = []
evaluation_results = {}

WHILE current_modality < total_modalities:
  modality = modalities_to_build[current_modality]

  1. SELECT model/tool for this modality (see selection matrices)
  2. BUILD processing pipeline (input handling, preprocessing, inference)
  3. BUILD embedding pipeline (if multi-modal RAG)
  4. EVALUATE per-modality metrics:
     - Text: extraction accuracy
     - Images: description quality, OCR accuracy
     - Audio: WER for STT
     - Documents: table extraction accuracy, layout preservation
  5. MEASURE latency and cost per item

  evaluation_results[modality] = {accuracy: acc, latency: lat, cost: cost}

  IF accuracy < target_threshold:
    OPTIMIZE: try alternative model, adjust preprocessing
    CONTINUE  # retry same modality
  ELSE:
    built_pipelines.append(modality)
    current_modality += 1

  REPORT "{current_modality}/{total_modalities} modalities built"

# After all modalities built:
6. BUILD cross-modal integration (unified vector store, context assembly)
7. RUN end-to-end evaluation across all modalities
8. MEASURE total pipeline cost projection

FINAL:
  REPORT per-modality and end-to-end metrics
  REPORT monthly cost estimate at expected volume
```

## Multi-Agent Dispatch

```
WHEN building a multi-modal system with multiple modalities:

DISPATCH parallel agents in worktrees:

  Agent 1 (vision-pipeline):
    - Implement image processing (resize, OCR, captioning)
    - Integrate vision model (Claude/GPT-4o/CLIP)
    - Build image embedding pipeline
    - Output: src/multimodal/vision.py + tests

  Agent 2 (audio-pipeline):
    - Implement audio processing (noise reduction, VAD, chunking)
    - Integrate STT (Whisper/Deepgram) and TTS
    - Build audio transcription pipeline
    - Output: src/multimodal/audio.py + tests

  Agent 3 (document-pipeline):
    - Implement PDF/document parsing (text, tables, images)
    - Integrate document understanding tools
    - Build document chunking and enrichment
    - Output: src/multimodal/documents.py + tests

  Agent 4 (rag-integration):
    - Design multi-modal RAG architecture
    - Build unified vector store with cross-modal search
    - Implement context assembly for generation
    - Output: src/multimodal/rag.py + configs

MERGE:
  - Verify all pipelines output compatible formats for RAG integration
  - Run end-to-end tests across all modalities
  - Measure combined latency and cost
  - Generate unified evaluation report
```

## HARD RULES

```
1. NEVER use a vision LLM for every image task. Use specialized tools
   (Tesseract for OCR, YOLO for detection) when they suffice.
   Reserve vision LLMs for complex understanding tasks.

2. ALWAYS preprocess audio before STT: noise reduction, VAD,
   segmentation into 30-60s chunks. Raw audio degrades accuracy.

3. NEVER embed images without text descriptions for RAG.
   Raw CLIP embeddings are useful for similarity but insufficient
   for question-answering. Generate captions first.

4. ALWAYS validate table extraction accuracy on real documents.
   Wrong numbers from extraction errors are worse than no answer.

5. NEVER build real-time audio without streaming every stage.
   Full transcription + full LLM + full TTS = unacceptable latency.
   Stream STT, LLM generation, and TTS synthesis.

6. ALWAYS track cost per modality at scale.
   Image analysis costs 10-100x more per item than text.
   Budget carefully and cache aggressively.

7. NEVER process all document pages equally.
   Classify pages first. Skip cover pages, TOC, and filler.
   Process only content-rich pages.

8. EVERY multi-modal pipeline MUST be evaluated per-modality AND
   end-to-end. A system can fail in one modality while succeeding in others.
```

## Anti-Patterns

- **Do NOT use vision LLMs for everything.** Sending every image to GPT-4o/Claude is expensive. Use specialized tools (Tesseract for OCR, YOLO for detection) when they suffice. Reserve vision LLMs for complex understanding.
- **Do NOT skip document preprocessing.** Raw PDF text extraction produces garbage for many documents. Clean, structure, and validate before embedding or feeding to LLMs.
- **Do NOT ignore table extraction quality.** Wrong numbers from a table extraction error can be worse than no answer. Validate table extraction accuracy on your actual documents.
- **Do NOT embed images without descriptions.** Raw image embeddings (CLIP) are useful for similarity search but insufficient for question-answering. Generate text descriptions for RAG.
- **Do NOT assume STT is good enough out of the box.** Domain terminology, accents, and background noise degrade STT accuracy. Test with realistic audio and add custom vocabulary.
- **Do NOT build real-time audio without streaming.** Waiting for full audio transcription + full LLM response + full TTS synthesis creates unacceptable latency. Stream every stage.
- **Do NOT forget about cost at scale.** Image and audio processing is expensive. A system that works at 10 queries/day may be unaffordable at 10,000 queries/day. Model routing and caching are essential.
- **Do NOT process all document pages equally.** Many PDFs have cover pages, table of contents, appendices, and filler. Classify pages and process only content-rich ones.
