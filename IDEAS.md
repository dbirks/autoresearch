# AutoResearch Ideas & Experiment Directions

## Category 1: Learning the Pattern (Start Here)

### 1.1 Run the Baseline Manually
- Clone autoresearch, run `train.py` once without an agent
- Understand every line: GPTConfig, GPT model, MuonAdamW, training loop
- Identify what `program.md` tells the agent and what it doesn't

### 1.2 Make Your First Manual Edit
- Pick ONE hyperparameter in `train.py` (e.g., `MATRIX_LR`, `WARMUP_RATIO`)
- Change it, run training, see how `val_bpb` changes
- Build intuition for what moves the needle

### 1.3 Write a Custom `program.md`
- Take Karpathy's `program.md` and modify it for a specific goal
- Example: "Only modify attention patterns" or "Focus on optimizer changes"
- Test how the agent's behavior changes with different instructions

---

## Category 2: Hyperparameter & Training Experiments

### 2.1 Learning Rate Sweeps
- `MATRIX_LR`: Try multipliers (0.5x, 0.7x, 1.2x, 1.5x baseline)
- `EMBEDDING_LR`: Often gets less attention — worth exploring
- `SCALAR_LR`: Small params that might be under-optimized

### 2.2 Schedule Experiments
- `WARMUP_RATIO`: Karpathy found 0.5 → 0.3 was an early win
- `WARMDOWN_RATIO`: Try asymmetric warmup/warmdown
- Add cosine decay, triangular schedules, or warm restarts

### 2.3 Batch Size & Gradient Accumulation
- Smaller batches = more updates in 5 minutes
- Larger batches = more stable gradients
- The sweet spot depends on model size and GPU

### 2.4 Regularization
- `WEIGHT_DECAY`: Try scheduling it (decay over training)
- Dropout: Add to attention or MLP layers
- Label smoothing on the cross-entropy loss

---

## Category 3: Architecture Experiments

### 3.1 Activation Functions
- Current: `F.relu(x).square()` (ReLU-squared)
- Try: SiLU, GELU, SwiGLU, or custom activations
- Swap just the MLP activation first

### 3.2 Attention Patterns
- Current: `"SSSL"` (3 short, 1 long window)
- Try: `"SSSS"`, `"LLL"`, `"SLSL"`, or fully local/global
- Change the window size for short vs. long attention

### 3.3 Layer Normalization
- Pre-norm vs. post-norm
- Add RMSNorm to queries/keys/values
- Remove normalization from specific layers

### 3.4 Value Embeddings (ResFormer)
- The current model has alternating value embedding layers
- Try different ratios (every 2nd, every 3rd layer)
- Modify the gating mechanism

---

## Category 4: Optimizer Experiments

### 4.1 Muon Tweaks
- Modify the orthogonalization step
- Adjust Nesterov momentum coefficient
- Change how 2D params are detected

### 4.2 AdamW Variants
- Beta parameters: `(0.9, 0.999)` → `(0.85, 0.95)`
- Add lookahead wrapper
- Try different per-parameter learning rates

### 4.3 Gradient Processing
- Gradient clipping strategies
- Gradient accumulation with different step sizes
- Mixed precision tuning

---

## Category 5: Beyond LLM Training (Adapt the Pattern)

The autoresearch loop works for ANY domain with:
- A clear metric
- Safe action boundaries
- Fast feedback (< 10 minutes)

### 5.1 Code Optimization
- Metric: benchmark speed (milliseconds)
- Agent modifies: Python/C/Go code
- Boundary: must pass existing tests
- Example: Optimize a parser, serializer, or data structure

### 5.2 Algorithm Competitions
- Metric: accuracy on a benchmark (e.g., LeetCode, Advent of Code)
- Agent modifies: algorithm implementation
- Boundary: must be correct on all test cases
- Example: Find faster sorting, search, or graph algorithms

### 5.3 Data Processing Pipelines
- Metric: throughput (rows/second) or memory usage
- Agent modifies: Pandas/Polars/SQL queries
- Boundary: must produce identical results
- Example: Optimize ETL pipelines

### 5.4 Prompt Engineering
- Metric: LLM evaluation score (win rate, accuracy)
- Agent modifies: system prompt or few-shot examples
- Boundary: fixed budget per experiment
- Example: Optimize prompts for a specific task

### 5.5 Model Configuration
- Metric: inference latency or memory
- Agent modifies: quantization settings, KV cache config
- Boundary: accuracy must stay above threshold
- Example: Optimize serving configs for edge deployment

---

## Category 6: Meta-Experiments on AutoResearch Itself

### 6.1 Improve the Agent's Performance
- What `program.md` prompts produce the best results?
- Does giving the agent more context help or hurt?
- How does agent cost/quality tradeoff affect discovery rate?

### 6.2 Multi-Agent Research
- Run multiple agents in parallel with different `program.md` files
- Share results between agents
- One agent proposes, another evaluates

### 6.3 Dynamic Time Budgets
- Instead of fixed 5 minutes, use adaptive budgets
- Longer runs for big changes, shorter runs for small tweaks
- Auto-detect convergence

### 6.4 Better Search Strategies
- Add "exploration phases" (allow temporary regressions)
- Simulated annealing: accept some worse solutions early
- Genetic algorithms: combine successful changes

---

## Category 7: Specific Hypothesis-Driven Ideas

### 7.1 "The Small Batch Hypothesis"
- More gradient updates in 5 min > larger per-batch quality
- Halve batch size, double accumulation steps
- Expect: faster convergence on small models

### 7.2 "The Warmup Hypothesis"
- Longer warmup helps stabilize training
- Try 20% warmup (vs. default 5%)
- Expect: smoother loss curves, better final scores

### 7.3 "The Simple Attention Hypothesis"
- Sliding window attention is overkill for small models
- Switch to fully global or fully local
- Expect: speedup or quality improvement

### 7.4 "The LR Annealing Hypothesis"
- Cosine decay during the 5 min window matters
- Add a "cool down" phase in last 30 seconds
- Expect: better final val_bpb

### 7.5 "The Initialization Hypothesis"
- Different weight init strategies for small models
- Try Xavier, Kaiming, or orthogonal init
- Expect: faster early training

---

## Getting Started Checklist

- [ ] Read Karpathy's README and `program.md`
- [ ] Read `train.py` — understand the full training loop
- [ ] Read `prepare.py` — understand data & evaluation
- [ ] Run baseline experiment manually
- [ ] Identify your GPU setup (or cloud alternative)
- [ ] Pick ONE category above and start there
- [ ] Start small — one change at a time
- [ ] Track results in a spreadsheet or `results.tsv`

## Cloud GPU Alternatives (No Local GPU)

| Provider | Cost | Notes |
|----------|------|-------|
| **Lambda Labs** | ~$0.68/hr (A100) | Cheapest H100-class GPUs |
| **Vast.ai** | ~$0.30/hr (RTX 4090) | Rent by the hour, community hosts |
| **RunPod** | ~$0.40/hr (RTX 4090) | Similar to Vast, good UI |
| **Colab Pro** | ~$10/mo | Free tier has limits, Pro gets T4 |
| **Kaggle** | Free | 30h/week GPU, resets daily |