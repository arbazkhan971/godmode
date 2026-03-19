# /godmode:ml

ML development and experimentation management. Tracks experiments with full reproducibility, manages hyperparameters, validates datasets for quality and bias, evaluates models with rigorous metrics, and compares experiments to select the best model.

## Usage

```
/godmode:ml                                # Interactive experiment setup and tracking
/godmode:ml --track                        # Track a running experiment
/godmode:ml --compare EXP-001,EXP-002     # Compare experiments side by side
/godmode:ml --validate <dataset>           # Run dataset validation checks
/godmode:ml --bias <dataset>               # Run bias detection
/godmode:ml --evaluate <checkpoint>        # Evaluate model on test set
/godmode:ml --search <config>              # Run hyperparameter search
/godmode:ml --registry                     # Show experiment registry
/godmode:ml --export <id>                  # Export experiment artifacts
```

## What It Does

1. Defines experiments with hypothesis, objective, and full reproducibility metadata
2. Manages hyperparameters via structured YAML configs with search strategies (grid, random, Bayesian, Hyperband)
3. Validates datasets (schema, missing values, duplicates, outliers, class imbalance, data leakage)
4. Detects bias across protected attributes with fairness metrics (demographic parity, equalized odds)
5. Tracks training runs with live metrics, checkpoints, and early stopping
6. Evaluates models with comprehensive metrics (per-class, calibration, error analysis)
7. Compares experiments with statistical significance testing

## Output
- Experiment results at `docs/ml/EXP-<ID>-results.md`
- Hyperparameters at `configs/ml/EXP-<ID>-params.yaml`
- Commit: `"ml: EXP-<ID> — <model> — <metric>=<value> (<vs baseline>)"`

## Key Principles

1. **Reproducibility** — every experiment records code version, data version, hyperparameters, random seeds
2. **Baselines first** — always compare against a baseline, even a naive one
3. **Statistical rigor** — test significance before claiming improvement
4. **Bias is a blocker** — check fairness metrics before shipping any model
5. **Track negative results** — failed experiments prevent duplicate wasted effort

## Next Step
If best model found: `/godmode:mlops` to deploy.
If bias detected: address before deployment.
If more experiments needed: iterate with `/godmode:ml`.

## Examples

```
/godmode:ml                                # Set up a new experiment
/godmode:ml --compare EXP-001,EXP-002,EXP-003  # Compare three runs
/godmode:ml --validate customer-data-v2    # Validate dataset quality
/godmode:ml --bias predictions.csv         # Check model predictions for bias
```
