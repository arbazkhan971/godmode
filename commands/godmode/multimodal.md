# /godmode:multimodal

Multimodal AI workflow. Guides building AI systems that process multiple data types -- images, audio, video, and documents -- together. Covers vision model integration, audio processing, document understanding, and multi-modal RAG systems.

## Usage

```
/godmode:multimodal                        # Full multimodal pipeline design
/godmode:multimodal --vision               # Vision model selection and integration
/godmode:multimodal --audio                # Audio processing (STT + TTS) setup
/godmode:multimodal --documents            # Document understanding pipeline
/godmode:multimodal --ocr                  # OCR optimization
/godmode:multimodal --tables               # Table extraction optimization
/godmode:multimodal --rag                  # Multi-modal RAG system design
/godmode:multimodal --eval                 # Run multimodal evaluation suite
/godmode:multimodal --benchmark <modality> # Benchmark models for a modality
/godmode:multimodal --cost                 # Cost analysis across modalities
/godmode:multimodal --stream               # Design streaming multimodal pipeline
```

## What It Does

1. Discovers multimodal requirements (modalities, processing types, volume, latency, budget)
2. Selects and integrates vision models (Claude, GPT-4o, CLIP, YOLO, specialized OCR)
3. Configures audio processing (STT with Whisper/Deepgram, TTS with OpenAI/ElevenLabs)
4. Designs document understanding pipelines (PDF parsing, table extraction, form processing)
5. Builds multi-modal RAG systems (unified embeddings, cross-modal search, context assembly)
6. Evaluates per-modality and end-to-end (OCR accuracy, WER, table extraction, cross-modal retrieval)

## Output
- Pipeline config at `configs/multimodal/<pipeline>-config.yaml`
- Model card at `docs/multimodal/<pipeline>-models.md`
- Commit: `"multimodal: <pipeline> -- <modalities>, <vision_model>, OCR=<val>%, STT_WER=<val>%"`

## Key Principles

1. **Match model to task** -- vision LLMs are overkill for simple OCR; use specialized tools when they suffice
2. **Caption first, embed second** -- text descriptions of images/audio work better for RAG than raw embeddings
3. **Tables are hardest** -- PDF table extraction is brittle; test thoroughly with real documents
4. **Audio needs preprocessing** -- noise reduction, VAD, and segmentation improve STT accuracy
5. **Cost scales with modality** -- image analysis costs 10-100x more than text; cache aggressively
6. **Evaluate each modality** -- a multimodal system can fail in one modality while succeeding in others

## Next Step
If pipeline ready: `/godmode:rag` to integrate into full RAG system.
If quality insufficient: `/godmode:multimodal --benchmark` to compare models.
If cost too high: `/godmode:aiops --cost` to optimize spending.

## Examples

```
/godmode:multimodal                        # Build a multimodal pipeline
/godmode:multimodal --documents            # Parse and understand PDFs
/godmode:multimodal --audio                # Add voice input/output
/godmode:multimodal --rag                  # Build multimodal RAG
/godmode:multimodal --vision               # Integrate image analysis
```
