---
name: finetune
description: |
  Model fine-tuning skill. Activates when users need to fine-tune LLMs or ML models on custom data. Covers fine-tuning method selection (LoRA, QLoRA, full fine-tuning), dataset preparation and curation, training configuration (learning rate, batch size, epochs, warmup), evaluation during training (validation loss, perplexity, downstream metrics), model merging, and deployment. Every fine-tuning run gets a structured plan, training config, evaluation report, and deployment checklist. Triggers on: /godmode:finetune, "fine-tune a model", "train on my data", "adapt the model", or when the orchestrator detects fine-tuning-related work.
---

# Fine-Tune — Model Fine-Tuning

## When to Activate
- User invokes `/godmode:finetune`
- User says "fine-tune a model", "train on my data", "adapt the base model"
- User says "LoRA", "QLoRA", "PEFT", "full fine-tuning"
- When customizing a pre-trained model for a specific domain or task
- When `/godmode:ml` identifies that a pre-trained model needs task-specific adaptation
- When `/godmode:prompt` has been exhausted and prompting alone cannot achieve the required quality
- When the orchestrator detects fine-tuning frameworks (PEFT, Unsloth, Axolotl, TRL, transformers Trainer) in code

## Workflow

### Step 1: Fine-Tuning Discovery & Requirements
Understand what must be fine-tuned and why:

```
FINE-TUNING DISCOVERY:
Goal: <what behavior the fine-tuned model must exhibit>
Base model: <model name and size — e.g., Llama 3.1 8B, Mistral 7B, Gemma 2 9B>
Why fine-tune (vs prompting):
  - [ ] Task requires consistent output format that prompting cannot reliably produce
  - [ ] Domain-specific knowledge not in the base model
  - [ ] Latency or cost constraints require a smaller, specialized model
  - [ ] Behavioral alignment (tone, style, persona) beyond prompt engineering
  - [ ] Proprietary data that cannot be sent to external APIs

Task type:
  - Instruction following: <general instruction tuning>
  - Classification: <categorize inputs into N classes>
  - Extraction: <pull structured data from unstructured text>
  - Summarization: <condense text with domain-specific understanding>
  - Conversation: <chat with domain persona or knowledge>
  - Code generation: <generate code in specific frameworks or patterns>
  - Custom: <describe task>

Hardware available:
  - GPU type: <A100 80GB | H100 | RTX 4090 24GB | T4 16GB | cloud instance>
  - GPU count: <N>
  - VRAM per GPU: <N GB>
  - RAM: <N GB>
  - Storage: <N GB available>

Budget:
  - Compute cost limit: $<N>
  - Time budget: <hours>
  - Ongoing training cadence: <one-time | weekly | monthly | on-demand>
```

If the user hasn't specified, ask: "What model do you want to fine-tune, and what task should it learn?"

### Step 2: Fine-Tuning Method Selection
Choose the method based on model size, hardware, and quality requirements:

```
FINE-TUNING METHOD SELECTION:

Methods:
+-----------------------+------------------+------------------+------------------+-------------------+
| Method                | VRAM Required    | Training Speed   | Quality          | Best For          |
+-----------------------+------------------+------------------+------------------+-------------------+
| Full Fine-Tuning      | 4x model size    | Slow             | Highest          | Small models      |
|                       | (e.g., 28GB for  |                  | (all params      | (<3B), maximum    |
|                       | 7B in bf16)      |                  | updated)         | quality needed    |
|                       |                  |                  |                  |                   |
| LoRA                  | ~model size +    | Fast             | Near-full FT     | Most common.      |
| (Low-Rank Adaptation) | ~10-20% overhead |                  | quality at       | 7B-70B models,    |
|                       |                  |                  | fraction of cost | single GPU        |
|                       |                  |                  |                  |                   |
| QLoRA                 | ~25% of model    | Moderate         | Slightly below   | Large models on   |
| (Quantized LoRA)      | size (4-bit      | (quantization    | LoRA but very    | limited VRAM.     |
|                       | quantized)       | overhead)        | close            | 70B on single GPU |
|                       |                  |                  |                  |                   |
| DoRA                  | Similar to LoRA  | Similar to LoRA  | Slightly above   | When LoRA quality |
| (Weight-Decomposed    |                  |                  | LoRA in some     | is not sufficient |
| Low-Rank Adaptation)  |                  |                  | benchmarks       |                   |
|                       |                  |                  |                  |                   |
| Prefix Tuning /       | Minimal          | Very fast        | Lower than       | Few-shot adapt,   |
| Prompt Tuning         | (frozen model)   |                  | LoRA             | quick experiments |
+-----------------------+------------------+------------------+------------------+-------------------+

Decision guide:
  Model < 3B params AND have enough VRAM? -> Full fine-tuning
  Model 3B-13B, have 1x 80GB GPU?        -> LoRA (bf16)
  Model 3B-13B, have 1x 24GB GPU?        -> QLoRA (4-bit)
  Model 13B-70B, have 1x 80GB GPU?       -> QLoRA (4-bit)
  Model 13B-70B, have 4x 80GB GPUs?      -> LoRA with FSDP/DeepSpeed
  Model 70B+, limited hardware?           -> QLoRA with gradient checkpointing
  Quick experiment / prototype?           -> QLoRA on smallest viable model

SELECTED: <Method> -- <justification based on model size, VRAM, and quality requirements>

LoRA/QLoRA parameters:
  Rank (r): <4 | 8 | 16 | 32 | 64 | 128>
    - r=8-16: good default for most tasks
    - r=32-64: complex tasks, larger datasets
    - r=128+: approaching full fine-tuning quality
  Alpha: <typically 2x rank — e.g., r=16, alpha=32>
  Dropout: <0.05 - 0.1>
  Target modules: <which layers to adapt>
    - Attention only: q_proj, v_proj (minimal, fast)
    - Attention + MLP: q_proj, k_proj, v_proj, o_proj, gate_proj, up_proj, down_proj (recommended)
    - All linear layers (maximum quality, highest cost)
  Trainable parameters: <N> (<percentage of total>)
```

### Step 3: Dataset Preparation & Curation
Prepare and validate the fine-tuning dataset:

```
DATASET PREPARATION:

Data format:
  Instruction tuning:
    {"instruction": "<task description>", "input": "<context>", "output": "<expected response>"}

  Conversational:
    {"messages": [
      {"role": "system", "content": "<system prompt>"},
      {"role": "user", "content": "<user message>"},
      {"role": "assistant", "content": "<expected response>"}
    ]}

  Completion:
    {"text": "<full text for causal LM training>"}

  DPO / RLHF:
    {"prompt": "<input>", "chosen": "<preferred response>", "rejected": "<dispreferred response>"}

Dataset statistics:
  Total examples: <N>
  Train/validation split: <N train> / <N val> (<percentage>)
  Avg input tokens: <N>
  Avg output tokens: <N>
  Max sequence length: <N>
  Token distribution: <uniform | skewed -- describe>

Quality checks:
  [ ] No duplicate examples (exact or near-duplicate)
  [ ] No contradictory examples (same input, different outputs)
  [ ] Output quality is consistent (all examples meet target quality)
  [ ] Input diversity is sufficient (not all examples from one narrow pattern)
  [ ] No data leakage from evaluation set
  [ ] PII has been removed or anonymized
  [ ] Format is consistent across all examples
  [ ] Edge cases are represented (short inputs, long inputs, ambiguous inputs)

Dataset size guidance:
  Instruction tuning: 1,000-50,000 examples (quality > quantity)
  Classification: 100-1,000 per class
  Domain adaptation: 10,000-100,000 examples
  Style/tone tuning: 500-5,000 examples
  DPO/RLHF: 5,000-50,000 preference pairs

Curation recommendations:
  - Remove examples where the output is wrong or low quality
  - Deduplicate: exact match + semantic similarity > 0.95
  - Balance categories if classification task
  - Include "refusal" examples (model should decline inappropriate requests)
  - Review a random sample of 50-100 examples manually before training
```

### Step 4: Training Configuration
Configure the training run:

```
TRAINING CONFIGURATION:

Framework: <Unsloth | Axolotl | HuggingFace TRL | HuggingFace Trainer | torchtune | LLaMA-Factory>

Training hyperparameters:
  Learning rate: <1e-5 to 5e-4>
    - Full FT: 1e-5 to 5e-5 (conservative)
    - LoRA: 1e-4 to 3e-4 (standard)
    - QLoRA: 2e-4 to 5e-4 (slightly higher to compensate for quantization)
  LR scheduler: <cosine | linear | constant_with_warmup>
  Warmup ratio: <0.03 - 0.1> (3-10% of total steps)
  Batch size (per device): <1 | 2 | 4 | 8 | 16>
  Gradient accumulation steps: <N> (effective batch = per_device * accumulation * num_gpus)
  Effective batch size: <N>
  Epochs: <1-5>
    - Small dataset (<5K): 3-5 epochs
    - Medium dataset (5K-50K): 1-3 epochs
    - Large dataset (50K+): 1 epoch (often sufficient)
  Max sequence length: <N tokens> (must cover input + output)
  Weight decay: <0.01 - 0.1>
  Max gradient norm: <1.0>

Precision & optimization:
  Training precision: <bf16 | fp16 | fp32>
  Quantization (QLoRA): <4-bit NF4 | 4-bit FP4>
  Gradient checkpointing: <true | false> (saves VRAM, costs ~20% speed)
  Flash attention: <true | false> (2x speedup on supported hardware)
  Packing: <true | false> (pack short examples into single sequences for efficiency)

Estimated resources:
  VRAM per GPU: ~<N> GB
  Training time: ~<N> hours
  Total tokens processed: ~<N>
  Estimated cost: ~$<N>

Checkpointing:
  Save every: <N steps | N epochs>
  Keep best: <N checkpoints by validation loss>
  Total storage: ~<N> GB
```

### Step 5: Evaluation During Training
Monitor training quality and catch issues early:

```
TRAINING EVALUATION:

Metrics to monitor:
+-----------------------+------------------+------------------+-----------------------------------+
| Metric                | Good Signal      | Bad Signal       | Action                            |
+-----------------------+------------------+------------------+-----------------------------------+
| Training loss         | Steady decrease  | Flat or erratic  | Check LR, data quality            |
| Validation loss       | Decreasing       | Increasing       | Stop training (overfitting)       |
| Train/val gap         | Small (<0.1)     | Large (>0.3)     | Add regularization, reduce epochs |
| Perplexity            | Decreasing       | Increasing       | Check for data issues             |
| Learning rate         | Following sched  | --               | Verify scheduler is working       |
| Gradient norm         | Stable           | Spiking          | Reduce LR, check data outliers    |
| GPU utilization       | >80%             | <50%             | Increase batch size or seq length |
+-----------------------+------------------+------------------+-----------------------------------+

Evaluation checkpoints:
  Run evaluation every: <N steps>
  Evaluation dataset: <N examples from validation set>
  Evaluation metrics:
    - Validation loss and perplexity
    - Task-specific metrics (accuracy, F1, BLEU, ROUGE)
    - Generation quality (sample outputs at each checkpoint)
    - Instruction following rate (does model follow format?)

Sample generation at checkpoints:
  Generate responses for <N> fixed test prompts at each evaluation step.
  Compare: is the model learning the desired behavior?
  Watch for:
    - Catastrophic forgetting (base model capabilities degrading)
    - Mode collapse (all outputs look the same)
    - Format degradation (model stops following instructions)
    - Hallucination increase (model becomes more confident but less accurate)

Early stopping:
  Monitor: <validation loss | task metric>
  Patience: <N evaluation steps>
  Min delta: <minimum improvement to count as progress>
  Best checkpoint: <automatically saved>

TRAINING STATUS:
  Epoch: <current>/<total>
  Step: <current>/<total>
  Training loss: <value> (trend: <decreasing | plateauing | diverging>)
  Validation loss: <value> (trend: <decreasing | plateauing | increasing>)
  Best validation loss: <value> at step <N>
  Perplexity: <value>
  Sample output quality: <IMPROVING | STABLE | DEGRADING>
```

### Step 6: Post-Training Evaluation
Evaluate the fine-tuned model comprehensively:

```
POST-TRAINING EVALUATION:

Model: <base model> + <fine-tuning method> (checkpoint: <step/epoch>)
Evaluation dataset: <N examples, held-out test set>

Task-specific metrics:
  Classification: accuracy=<val>, F1=<val>, precision=<val>, recall=<val>
  Generation: BLEU=<val>, ROUGE-L=<val>, BERTScore=<val>
  Instruction following: format_compliance=<val>%, refusal_accuracy=<val>%
  Custom metric: <name>=<val>

Comparison vs alternatives:
+---------------------------+------------------+------------------+------------------+
| Configuration             | Task Metric      | Latency          | Cost/1K tokens   |
+---------------------------+------------------+------------------+------------------+
| Base model + prompting    | <val>            | <ms>             | $<val>           |
| Fine-tuned model          | <val>            | <ms>             | $<val>           |
| Larger model + prompting  | <val>            | <ms>             | $<val>           |
| RAG + base model          | <val>            | <ms>             | $<val>           |
+---------------------------+------------------+------------------+------------------+

Catastrophic forgetting check:
  Test base model capabilities that should be preserved:
  - General knowledge: <PRESERVED | DEGRADED>
  - Reasoning: <PRESERVED | DEGRADED>
  - Instruction following: <PRESERVED | DEGRADED>
  - Language quality: <PRESERVED | DEGRADED>

Safety evaluation:
  - Refusal on harmful prompts: <pass rate>
  - Bias amplification: <measured | not detected>
  - Toxicity: <measured score vs base model>
  - Jailbreak resistance: <tested with N adversarial prompts>

VERDICT: <PASS -- model meets quality bar | NEEDS ITERATION -- specify what to change>
```

### Step 7: Model Merging & Export
Merge adapter weights and prepare for deployment:

```
MODEL MERGING & EXPORT:

Merging strategy:
  LoRA/QLoRA merge:
    Method: <standard merge | TIES merge | DARE merge | SLERP>
    Base model: <name>
    Adapter: <path to adapter weights>
    Merged model size: <N GB>

  Multi-adapter merging (if applicable):
    Adapters to merge: <list of adapters and their tasks>
    Method: <linear combination | task arithmetic | TIES-merging>
    Weights: <per-adapter weight>

Export formats:
  [ ] HuggingFace safetensors (standard)
  [ ] GGUF (for llama.cpp / Ollama inference)
  [ ] ONNX (for ONNX Runtime)
  [ ] AWQ / GPTQ quantized (for vLLM)

Quantization for deployment:
  Target: <fp16 | int8 | int4 | GGUF Q4_K_M | GGUF Q5_K_M | AWQ 4-bit>
  Quality check: run evaluation on quantized model to verify quality retention
  Quality retention: <percentage of full-precision metric retained>

Model card:
  Base model: <name and version>
  Fine-tuning method: <method>
  Dataset: <description, size, domain>
  Training config: <key hyperparameters>
  Evaluation results: <key metrics>
  Known limitations: <documented weaknesses>
  Intended use: <target use case>
  Out-of-scope use: <what not to use it for>
```

### Step 8: Deployment & Serving
Deploy the fine-tuned model:

```
DEPLOYMENT:

Serving options:
+---------------------+------------------+------------------+----------------------------+
| Platform            | Best For         | Scaling          | Cost                       |
+---------------------+------------------+------------------+----------------------------+
| vLLM                | Production       | Horizontal       | Self-hosted GPU            |
|                     | high-throughput  | (multi-GPU)      |                            |
| Ollama              | Local dev/test   | Single machine   | Free (local GPU)           |
| TGI (Text Gen       | Production       | Horizontal       | Self-hosted GPU            |
|   Inference)        | HuggingFace      |                  |                            |
| SageMaker           | AWS production   | Auto-scaling     | Per-instance + inference   |
| Together AI         | Managed API      | Serverless       | Per-token                  |
| Modal / RunPod      | Serverless GPU   | Auto-scaling     | Per-second GPU             |
| llama.cpp           | CPU inference    | Single machine   | Free (CPU)                 |
+---------------------+------------------+------------------+----------------------------+

SELECTED: <Platform> -- <justification>

Serving configuration:
  Model format: <safetensors | GGUF | AWQ>
  GPU type: <inference GPU>
  Batch size: <max concurrent requests>
  Max sequence length: <N tokens>
  Tensor parallelism: <N GPUs>

Performance benchmarks:
  Throughput: <tokens/sec>
  Latency (p50): <ms>
  Latency (p95): <ms>
  Concurrent users supported: <N>
  Cost per 1K tokens: $<val>
```

### Step 9: Artifacts & Commit
Generate deliverables:

1. **Training config**: `configs/finetune/<model>-config.yaml`
2. **Dataset spec**: `docs/finetune/<model>-dataset.md`
3. **Training script**: `src/finetune/<model>/train.py`
4. **Evaluation script**: `src/finetune/<model>/evaluate.py`
5. **Model card**: `docs/finetune/<model>-card.md`
6. **Deployment config**: `configs/finetune/<model>-serving.yaml`

```
FINE-TUNING COMPLETE:

Model:
- Base: <base model name>
- Method: <full FT | LoRA | QLoRA> (r=<rank>, alpha=<alpha>)
- Dataset: <N examples>, <domain>
- Training: <N epochs>, lr=<val>, effective_batch=<N>
- Duration: <hours>, cost: $<val>

Evaluation:
- Task metric: <val> (vs base model: <improvement>)
- Validation loss: <val>
- Perplexity: <val>
- Catastrophic forgetting: <NONE | MINIMAL | DETECTED>
- Safety: <PASS | REVIEW REQUIRED>

Deployment:
- Format: <export format>
- Platform: <serving platform>
- Throughput: <tokens/sec>
- Latency p95: <ms>

Artifacts:
- Config: configs/finetune/<model>-config.yaml
- Dataset: docs/finetune/<model>-dataset.md
- Training: src/finetune/<model>/train.py
- Model card: docs/finetune/<model>-card.md

Next steps:
-> /godmode:eval -- Run comprehensive evaluation suite
-> /godmode:mlops -- Set up production serving with monitoring
-> /godmode:aiops -- Add guardrails and safety monitoring
-> /godmode:embeddings -- Generate domain-specific embeddings
```

Commit: `"finetune: <model> -- <method>, <N> examples, <task_metric>=<val>, <deployment_platform>"`

## Key Behaviors

1. **Prompting before fine-tuning.** Fine-tuning is expensive. Exhaust prompt engineering and few-shot learning first. Fine-tune only when prompting demonstrably cannot achieve the quality bar.
2. **Quality over quantity in training data.** 1,000 excellent examples beat 100,000 noisy ones. Curate ruthlessly. Review samples manually. Remove contradictions and duplicates.
3. **Start small, then scale.** Train on the smallest viable model first (7B, not 70B). Validate the approach works before spending on larger models.
4. **Evaluate against alternatives.** Always compare fine-tuned model vs (a) base model + prompting, (b) larger model + prompting, (c) RAG + base model. Fine-tuning must beat all to justify the investment.
5. **Watch for catastrophic forgetting.** Fine-tuning can degrade base model capabilities. Test general abilities alongside task-specific metrics.
6. **Version everything.** Dataset version, base model version, adapter weights, training config, evaluation results. Fine-tuning is an experiment -- treat it like one.
7. **Safety does not disappear after fine-tuning.** Test safety and alignment after every fine-tuning run. Models can lose safety training during adaptation.

## Example Usage

### Fine-Tuning with LoRA
```
User: /godmode:finetune Fine-tune Llama 3.1 8B for medical Q&A

Finetune: Starting discovery...

FINE-TUNING DISCOVERY:
Goal: Answer medical questions with domain-accurate, sourced responses
Base model: Llama 3.1 8B Instruct
Why fine-tune: Domain knowledge gaps in base model, requires medical terminology precision

METHOD: QLoRA (4-bit NF4)
  Rationale: 8B model on single RTX 4090 (24GB VRAM)
  LoRA rank: 32, alpha: 64
  Target modules: all linear layers
  Trainable params: 67M (0.8% of total)

DATASET:
  12,500 medical Q&A pairs (curated from medical literature)
  Train: 11,250, Val: 1,250
  Avg input: 45 tokens, Avg output: 180 tokens
  Quality: manually reviewed 100 samples, 2 removed for inaccuracy

TRAINING:
  LR: 2e-4, cosine scheduler, warmup: 5%
  Batch size: 4, gradient accumulation: 4 (effective: 16)
  Epochs: 3, max seq length: 1024
  Duration: 2.5 hours on 1x RTX 4090

EVALUATION:
  Medical QA accuracy: 87.3% (base model: 71.2%, +16.1%)
  Faithfulness: 0.94
  Format compliance: 98%
  Catastrophic forgetting: NONE (general QA preserved)
  Safety: PASS (refusal rate on harmful medical advice: 100%)

DEPLOYMENT: vLLM on A10G
  Throughput: 450 tokens/sec
  Latency p95: 280ms
  Cost: $0.003/1K tokens

Verdict: PASS -- significant improvement over base model prompting.
```

### Comparing Fine-Tuning Methods
```
User: /godmode:finetune --compare LoRA vs QLoRA vs full FT on my 3B model

Finetune: Running comparison...

+---------------------+----------+---------+--------+-------+----------+
| Method              | Accuracy | Val Loss| Time   | VRAM  | Cost     |
+---------------------+----------+---------+--------+-------+----------+
| Full fine-tuning    | 92.1%    | 0.31    | 8h     | 24GB  | $12.00   |
| LoRA (r=16)         | 91.4%    | 0.33    | 2h     | 10GB  | $3.00    |
| QLoRA (r=16, 4-bit) | 90.8%    | 0.35    | 2.5h   | 6GB   | $3.75    |
| LoRA (r=64)         | 91.9%    | 0.32    | 3h     | 12GB  | $4.50    |
+---------------------+----------+---------+--------+-------+----------+

Recommendation: LoRA (r=16) -- 99.2% of full FT quality at 25% of the cost.
For maximum quality with budget: LoRA (r=64).
For minimal VRAM: QLoRA (r=16) -- 98.6% of full FT quality at 6GB VRAM.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full fine-tuning workflow from discovery to deployment |
| `--method <name>` | Force method: `full`, `lora`, `qlora`, `dora`, `prefix` |
| `--dataset <path>` | Validate and prepare a dataset for fine-tuning |
| `--config <path>` | Use an existing training config |
| `--eval <checkpoint>` | Evaluate a fine-tuned checkpoint |
| `--merge <adapter>` | Merge LoRA adapter with base model |
| `--export <format>` | Export model: `safetensors`, `gguf`, `onnx`, `awq` |
| `--compare` | Compare fine-tuning methods or checkpoints |
| `--resume <checkpoint>` | Resume training from a checkpoint |
| `--cost` | Estimate training cost before starting |
| `--card` | Generate model card for a fine-tuned model |

## Anti-Patterns

- **Do NOT fine-tune before trying prompting.** Fine-tuning is expensive and hard to iterate. Prompt engineering, few-shot learning, and RAG should be exhausted first.
- **Do NOT fine-tune on noisy data.** Garbage in, garbage out. Noisy training data teaches the model to produce noisy outputs. Curate ruthlessly.
- **Do NOT skip the validation set.** Without validation loss monitoring, you cannot detect overfitting. Always hold out at least 10% of data.
- **Do NOT use the largest model first.** Start with the smallest model that could plausibly work. Validate the approach before scaling up.
- **Do NOT ignore catastrophic forgetting.** Test general capabilities after fine-tuning. A model that aces your task but cannot follow basic instructions is broken.
- **Do NOT deploy without safety testing.** Fine-tuning can remove safety guardrails. Test with adversarial prompts and harmful inputs after every fine-tuning run.
- **Do NOT train for too many epochs on small datasets.** Small datasets overfit fast. 1-3 epochs is often optimal. More epochs does not mean better quality.
- **Do NOT set learning rate too high.** The most common fine-tuning failure is a learning rate that is too aggressive. Start conservative and increase only if training is too slow.
