# Domain Guide: Using Godmode Across Different Domains

Godmode's workflow adapts to different engineering domains. This guide shows how to configure and use Godmode for backend, frontend, ML, content, and DevOps work.

---

## Backend Development

### Setup
```
/godmode:setup
# Test: npm test / pytest / go test ./...
# Lint: eslint / ruff / golangci-lint
# Verify: curl timing or custom benchmark
```

### Recommended Workflow
```
think → predict → plan → build → optimize → secure → ship
```

All 16 skills are relevant. The full workflow is designed primarily for backend work.

### Optimization Targets
| Target | Verify Cmd |
|--|--|
| Response time | `curl -s -o /dev/null -w '%{time_total}' <url>` |
| Throughput | `wrk -t4 -c100 -d10s <url> \| grep 'Requests/sec'` |
| Memory usage | `ps -o rss= -p <pid>` |
| Query time | `psql -c "EXPLAIN ANALYZE <query>" \| grep 'Execution Time'` |
| Startup time | `time node dist/index.js --dry-run` |

### Security Focus
- Input validation on all endpoints
- SQL injection prevention
- Authentication/authorization on every route
- Rate limiting on public endpoints
- HTTPS enforcement

---

## Frontend Development

### Setup
```
/godmode:setup
# Test: npm test (vitest/jest)
# Lint: npm run lint (eslint + prettier)
# Build: npm run build
# Verify: du -b dist/assets/index-*.js (bundle size)
```

### Recommended Workflow
```
think → plan → build → optimize → ship
```

The predict and scenario skills are less common in frontend work but useful for architecture decisions (state management, rendering strategy).

### Optimization Targets
| Target | Verify Cmd |
|--|--|
| Bundle size | `npm run build && du -b dist/assets/*.js \| awk '{s+=$1}END{print s}'` |
| Lighthouse score | `npx lighthouse <url> --output=json \| jq '.categories.performance.score * 100'` |
| First contentful paint | `npx lighthouse <url> --output=json \| jq '.audits["first-contentful-paint"].numericValue'` |
| Component render time | `npm run bench -- --component <name>` |
| Test execution time | `time npm test` |

### Key Think Considerations
- Component architecture (how to split UI into components)
- State management approach (local state, context, Zustand, Redux)
- Data fetching strategy (REST, GraphQL, React Query, SWR)
- Accessibility requirements (WCAG level)
- Responsive design breakpoints

### Security Focus (Frontend-Specific)
- XSS prevention (dangerouslySetInnerHTML, user content rendering)
- CSRF tokens on form submissions
- Sensitive data not stored in localStorage
- Content Security Policy headers
- No API keys in client bundle

---

## Machine Learning

### Setup
```
/godmode:setup
# Test: pytest tests/
# Lint: ruff check .
# Verify: python -c "from evaluate import load_metric; ..."
```

### Recommended Workflow
```
think → predict → plan → build → optimize → ship
```

The optimize skill is especially powerful for ML — it naturally maps to hyperparameter tuning, feature engineering, and model architecture experiments.

### Optimization Targets
| Target | Verify Cmd |
|--|--|
| Accuracy | `python evaluate.py --metric accuracy` |
| F1 score | `python evaluate.py --metric f1` |
| Inference latency | `python benchmark.py --model <path>` |
| Model size | `du -b models/latest.pt` |
| Training time | `time python train.py --epochs 1` |
| Memory usage | `python -c "import torch; model = ...; print(torch.cuda.memory_allocated())"` |

### Think Phase Adaptations
- Data exploration before model design
- Feature engineering brainstorming
- Architecture choices (transformer vs. RNN vs. classical ML)
- Training strategy (from scratch vs. fine-tuning vs. transfer learning)

### Optimize Phase Adaptations
- Each iteration can be a hyperparameter change
- Guard rails: validation loss must not increase
- Track multiple metrics (accuracy AND latency)
- Longer iteration cycles (training takes time)

### Security Focus (ML-Specific)
- PII in training data
- Model inversion attacks
- Adversarial input robustness
- Data poisoning prevention
- Model output sanitization

---

## Content / Documentation

### Setup
```
/godmode:setup
# Test: npx markdownlint docs/  (or custom validation)
# Lint: npx markdownlint-cli2 "**/*.md"
# Build: npm run build:docs (static site generator)
```

### Recommended Workflow
```
think → plan → build → review → ship
```

Skip optimize and secure for pure content work. The think, plan, and review skills are the most valuable.

### Think Phase Adaptations
- Audience analysis (who is reading this?)
- Information architecture (how is content organized?)
- Content format (tutorial, reference, guide, how-to)
- Examples and code samples needed

### Review Adaptations
The code review dimensions adapt for content:
1. **Accuracy** — Is the content technically correct?
2. **Completeness** — Are all topics covered?
3. **Clarity** — Can the target audience understand it?
4. **Structure** — Is it well-organized with good headings?
5. **Examples** — Are examples relevant and working?
6. **Freshness** — Is the content up to date?

---

## DevOps / Infrastructure

### Setup
```
/godmode:setup
# Test: terraform validate && terraform plan
# Lint: tflint / hadolint (Dockerfile) / shellcheck
# Verify: terraform plan -json | jq '.resource_changes | length'
```

### Recommended Workflow
```
think → predict → plan → build → secure → ship
```

The predict skill is especially valuable for infrastructure decisions (cloud provider, architecture, scaling strategy). The secure skill catches misconfigurations.

### Think Phase Adaptations
- Architecture decisions (monolith vs. microservices, serverless vs. containers)
- Scaling strategy (horizontal vs. vertical, auto-scaling triggers)
- Cost analysis (per-request cost, idle cost, scaling cost)
- Disaster recovery requirements (RTO, RPO)

### Security Focus (Infrastructure-Specific)
- Network segmentation (security groups, NACLs)
- Secret management (no hardcoded credentials in Terraform/Helm)
- Least privilege IAM policies
- Encryption at rest and in transit
- Container image scanning
- Kubernetes RBAC and Pod Security Standards

### Optimization Targets
| Target | Verify Cmd |
|--|--|
| Deploy time | `time ./deploy.sh` |
| Container startup | `docker run ... --time` |
| Resource usage | `kubectl top pods -n <namespace>` |
| Infrastructure cost | `infracost breakdown --path .` |
| Image size | `docker images <image> --format '{{.Size}}'` |

---

## Cross-Domain Tips

### 1. Configure the verify command for YOUR domain
The optimization loop only works if the verify command accurately measures what you care about. Spend time getting this right.

### 2. Adjust the predict panel
Use `--panel` to select domain-appropriate expert personas:
```
/godmode:predict --panel ml       # ML-specific experts
/godmode:predict --panel frontend # Frontend-specific experts
/godmode:predict --panel devops   # Infrastructure-specific experts
```

### 3. Security is always relevant
Even frontend and content projects have security considerations. Don't skip `/godmode:secure` — just use `--quick` for lighter-weight audits.

### 4. The workflow is flexible
You don't have to run every skill every time. Use what makes sense for your domain and the specific task at hand.
