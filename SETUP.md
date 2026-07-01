# Container Setup

## What You're Training

The experiments train a **small GPT model** to predict the next token in text. The goal is to find the best model configuration (architecture + hyperparameters) that achieves the lowest `val_bpb` (bits per byte) — a compression metric. Better compression = better language modeling.

**Baselines:** ~0.998 val_bpb on default config (~300M params)

## Hardware: RTX 6000 Pro Blackwell (96GB)

Your GPU is well-suited for this:
- **96GB VRAM** — way more than needed (baseline uses ~45GB)
- **Blackwell** — newer than Hopper; uses `kernels-community/flash-attn3` kernel

With this GPU you could even increase model size from default and see results.

## Quick Start

```bash
# 1. Build image
docker build -t autoresearch:latest -f Dockerfile .

# 2. Apply k8s resources
kubectl apply -f k8s/autoresearch.yaml

# 3. Run data prep (one-time, downloads ~few GB + trains tokenizer)
kubectl exec autoresearch-0 -- uv run prepare.py

# 4. Run baseline experiment (~5 min)
kubectl exec autoresearch-0 -- uv run train.py

# 5. Follow logs
kubectl logs autoresearch-0 -f
```

## Running the Agent

Once the baseline works, point your coding agent (Claude, Codex, Cursor) at the repo and have it follow `program.md`. The agent:

1. Reads `program.md` for instructions
2. Edits `train.py`
3. Runs `uv run train.py` (5 min)
4. Checks `val_bpb`
5. Keeps improvement or reverts
6. Repeats

For k8s, you'd run the agent locally (it just edits files) and execute experiments in the pod:

```bash
# Agent edits train.py locally, then syncs to pod
kubectl cp train.py autoresearch-0:/app/train.py

# Run experiment
kubectl exec autoresearch-0 -- uv run train.py > run.log 2>&1

# Check results
kubectl exec autoresearch-0 -- grep "^val_bpb:" run.log
```

## Scaling to Multiple GPUs

With 96GB VRAM you could potentially:
- Run **multiple pods** on the same node (if you have more GPUs)
- Increase `DEVICE_BATCH_SIZE` in `train.py` to use more VRAM
- Increase model `DEPTH` from 8 to 12+ for bigger experiments

## Data

- First run downloads ~few GB of text data (climbmix-400b shards)
- Tokenizer trained from that data
- Cached in `/root/.cache/autoresearch/` (mounted as PVC)

## Useful k8s Commands

```bash
# Watch pod
kubectl get pod -w

# Exec into container
kubectl exec -it autoresearch-0 -- bash

# Copy results back
kubectl cp autoresearch-0:/app/results.tsv ./results.tsv

# Check GPU inside pod
kubectl exec autoresearch-0 -- nvidia-smi

# Delete and restart
kubectl delete statefulset autoresearch
kubectl apply -f k8s/autoresearch.yaml
```