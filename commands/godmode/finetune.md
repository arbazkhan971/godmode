# /godmode:finetune

Model fine-tuning workflow. Guides the full lifecycle of fine-tuning LLMs and ML models on custom data -- from method selection (LoRA, QLoRA, full fine-tuning) through dataset preparation, training configuration, evaluation, model merging, and deployment.

## Usage

```
/godmode:finetune                          # Full fine-tuning workflow
/godmode:finetune --method lora            # Force LoRA fine-tuning method
/godmode:finetune --dataset <path>         # Validate and prepare a dataset
/godmode:finetune --eval <checkpoint>      # Evaluate a fine-tuned checkpoint
/godmode:finetune --merge <adapter>        # Merge LoRA adapter with base model
/godmode:finetune --export gguf            # Export model to GGUF format
/godmode:finetune --compare                # Compare fine-tuning methods or checkpoints
/godmode:finetune --resume <checkpoint>    # Resume training from a checkpoint
/godmode:finetune --cost                   # Estimate training cost before starting
/godmode:finetune --card                   # Generate model card
```

## What It Does

1. Discovers fine-tuning requirements (goal, base model, hardware, budget)
2. Selects fine-tuning method (full FT, LoRA, QLoRA, DoRA) based on model size and VRAM
3. Prepares and validates dataset (format, quality, dedup, PII, edge cases)
4. Configures training (learning rate, batch size, epochs, scheduler, precision)
5. Monitors training quality (val loss, perplexity, sample generation, catastrophic forgetting)
6. Evaluates post-training (task metrics, vs alternatives, safety, forgetting check)
7. Merges adapter weights and exports to deployment formats (safetensors, GGUF, ONNX, AWQ)
8. Deploys to serving infrastructure (vLLM, Ollama, TGI, SageMaker)

## Output
- Training config at `configs/finetune/<model>-config.yaml`
- Dataset spec at `docs/finetune/<model>-dataset.md`
- Model card at `docs/finetune/<model>-card.md`
- Commit: `"finetune: <model> -- <method>, <N> examples, <task_metric>=<val>, <platform>"`

## Key Principles

1. **Prompting before fine-tuning** -- exhaust prompt engineering first
2. **Quality over quantity** -- 1,000 excellent examples beat 100,000 noisy ones
3. **Start small** -- validate on smallest viable model before scaling up
4. **Evaluate against alternatives** -- fine-tuned model must beat base + prompting, larger model + prompting, and RAG + base model
5. **Watch for catastrophic forgetting** -- test general capabilities after fine-tuning
6. **Safety persists** -- test safety and alignment after every fine-tuning run

## Next Step
If model meets quality bar: `/godmode:mlops` to deploy.
If quality insufficient: iterate on dataset or training config.
If catastrophic forgetting detected: reduce learning rate, epochs, or use LoRA with lower rank.

## Examples

```
/godmode:finetune                          # Fine-tune a model end-to-end
/godmode:finetune --method qlora           # Force QLoRA for limited VRAM
/godmode:finetune --dataset ./data/train.jsonl  # Validate a training dataset
/godmode:finetune --compare                # Compare LoRA vs QLoRA vs full FT
/godmode:finetune --export gguf            # Export for Ollama deployment
```
