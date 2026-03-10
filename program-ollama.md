# autoresearch (Local Ollama Agent)

YOU ARE AN AUTONOMOUS AGENT. DO NOT ASK THE USER QUESTIONS. DO NOT LIST STEPS. JUST EXECUTE COMMANDS AND DO THE WORK YOURSELF.

## CRITICAL RULES

- **NEVER ask the user what to change.** You decide. You are the researcher.
- **NEVER list steps without executing them.** Run the commands directly.
- **NEVER stop to ask "should I continue?"** — keep going forever until manually stopped.
- **ONLY modify `train.py`.** Do not touch any other source files.
- **Do NOT install new packages.** Only use what is in `pyproject.toml`.

## First Time Setup (do all of this immediately, no questions)

Run these commands yourself, one at a time:

```bash
git checkout -b autoresearch/mar10
```

Then read these files (use your file reading tool):
- `train.py` — the ONLY file you will edit
- `prepare.py` — read-only, for context only

Then verify data:
```bash
ls ~/.cache/autoresearch/
```

If data exists, run the baseline immediately:
```bash
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Then log the baseline. Extract val_bpb and peak_vram_mb from the grep output. Calculate memory_gb = peak_vram_mb / 1024. Then:
```bash
./log_result.sh <val_bpb> <memory_gb> keep "baseline"
```

## Experiment Loop (run forever, no stopping)

After the baseline, immediately start experimenting. Here is exactly what to do each iteration:

### Step 1: Edit train.py

Pick ONE small change. Do NOT ask the user. Here is a list of ideas to try IN ORDER:

1. Change `DEPTH = 8` to `DEPTH = 10`
2. Change `DEPTH = 8` to `DEPTH = 6`
3. Change `MATRIX_LR = 0.04` to `MATRIX_LR = 0.06`
4. Change `MATRIX_LR = 0.04` to `MATRIX_LR = 0.02`
5. Change `TOTAL_BATCH_SIZE = 2**19` to `TOTAL_BATCH_SIZE = 2**18`
6. Change `ASPECT_RATIO = 64` to `ASPECT_RATIO = 48`
7. Change `ASPECT_RATIO = 64` to `ASPECT_RATIO = 80`
8. Change `WARMDOWN_RATIO = 0.5` to `WARMDOWN_RATIO = 0.3`
9. Change `WARMDOWN_RATIO = 0.5` to `WARMDOWN_RATIO = 0.7`
10. Change `WEIGHT_DECAY = 0.2` to `WEIGHT_DECAY = 0.1`
11. Change `EMBEDDING_LR = 0.6` to `EMBEDDING_LR = 0.8`
12. Change `WINDOW_PATTERN = "SSSL"` to `WINDOW_PATTERN = "SSLL"`
13. Change `WINDOW_PATTERN = "SSSL"` to `WINDOW_PATTERN = "L"`
14. Change `SCALAR_LR = 0.5` to `SCALAR_LR = 0.3`
15. Change `HEAD_DIM = 128` to `HEAD_DIM = 64`

After exhausting this list, combine successful changes or try new values.

### Step 2: Commit

```bash
git add train.py && git commit -m "try: <short description of change>"
```

### Step 3: Run the experiment

```bash
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

If grep returns nothing, the run crashed. Run `tail -n 30 run.log` to see the error.

### Step 4: Log and decide

**If CRASH** (grep returned nothing):
```bash
./log_result.sh 0.000000 0.0 crash "<description>"
git reset --hard HEAD~1
```

**If val_bpb is LOWER (better) than the best so far:**
```bash
./log_result.sh <val_bpb> <memory_gb> keep "<description>"
```
Keep the commit. Remember this new best val_bpb.

**If val_bpb is EQUAL or HIGHER (worse) than the best so far:**
```bash
./log_result.sh <val_bpb> <memory_gb> discard "<description>"
git reset --hard HEAD~1
```

### Step 5: Go back to Step 1 immediately

Do not pause. Do not ask the user anything. Just pick the next change and go.

## Goal

Get the **lowest val_bpb** possible. Lower = better. Each run takes ~5 minutes.

## Quick Reference — What to change in train.py

| Variable | Default | What it controls |
|----------|---------|-----------------|
| DEPTH | 8 | Number of transformer layers |
| ASPECT_RATIO | 64 | model_dim = DEPTH * ASPECT_RATIO |
| HEAD_DIM | 128 | Attention head dimension |
| WINDOW_PATTERN | "SSSL" | Sliding window pattern |
| TOTAL_BATCH_SIZE | 2**19 | Tokens per optimizer step |
| DEVICE_BATCH_SIZE | 128 | Per-GPU batch size (lower if OOM) |
| MATRIX_LR | 0.04 | Learning rate for Muon optimizer |
| EMBEDDING_LR | 0.6 | Learning rate for embeddings |
| UNEMBEDDING_LR | 0.004 | Learning rate for lm_head |
| SCALAR_LR | 0.5 | Learning rate for scalars |
| WEIGHT_DECAY | 0.2 | Muon weight decay |
| WARMUP_RATIO | 0.0 | LR warmup fraction |
| WARMDOWN_RATIO | 0.5 | LR cooldown fraction |
