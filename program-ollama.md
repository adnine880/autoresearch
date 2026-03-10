# autoresearch (Local Ollama Agent)

YOU ARE AN AUTONOMOUS AGENT. DO NOT THINK. DO NOT ANALYZE. JUST EXECUTE COMMANDS.

## RULES

- NEVER ask questions. NEVER list steps. NEVER explain your reasoning. Just run commands.
- ONLY edit `train.py`. No other files.
- Do NOT install packages. Do NOT reformat code. Do NOT fix warnings.
- When editing, change ONLY the one line specified. Nothing else.
- Do NOT stop between experiments. Keep looping forever.

## SETUP — Run these commands now

Command 1:
```bash
git checkout -b autoresearch/mar10
```

Command 2: Read the file `train.py` (use your read tool).

Command 3:
```bash
ls ~/.cache/autoresearch/
```

Command 4 — Run baseline (do NOT edit train.py first):
```bash
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Command 5 — Log baseline (replace VALUES with numbers from grep output, memory_gb = peak_vram_mb / 1024):
```bash
./log_result.sh <val_bpb> <memory_gb> keep "baseline"
```

The val_bpb from this baseline is your BEST score. Remember it.

## EXPERIMENT LOOP — Repeat forever

Each experiment has 4 commands. Run them all, then start the next experiment.

### Experiment 1: DEPTH = 10

Edit train.py: find `DEPTH = 8` and replace with `DEPTH = 10`. Change nothing else.

```bash
git add train.py && git commit -m "try: depth 10"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

If grep returned nothing = CRASH. Run: `./log_result.sh 0.000000 0.0 crash "depth 10"` then `git reset --hard HEAD~1`
If val_bpb < best = IMPROVED. Run: `./log_result.sh <val_bpb> <memory_gb> keep "depth 10"` — update best.
If val_bpb >= best = WORSE. Run: `./log_result.sh <val_bpb> <memory_gb> discard "depth 10"` then `git reset --hard HEAD~1`

### Experiment 2: DEPTH = 6

Edit train.py: find the current DEPTH line and replace with `DEPTH = 6`. Change nothing else.

```bash
git add train.py && git commit -m "try: depth 6"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic: CRASH → log crash + reset. IMPROVED → log keep. WORSE → log discard + reset.

### Experiment 3: MATRIX_LR = 0.06

Edit train.py: find `MATRIX_LR = 0.04` and replace with `MATRIX_LR = 0.06`. Change nothing else.

```bash
git add train.py && git commit -m "try: matrix_lr 0.06"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic: CRASH → log crash + reset. IMPROVED → log keep. WORSE → log discard + reset.

### Experiment 4: MATRIX_LR = 0.02

Edit: `MATRIX_LR = 0.04` → `MATRIX_LR = 0.02`

```bash
git add train.py && git commit -m "try: matrix_lr 0.02"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 5: TOTAL_BATCH_SIZE = 2**18

Edit: `TOTAL_BATCH_SIZE = 2**19` → `TOTAL_BATCH_SIZE = 2**18`

```bash
git add train.py && git commit -m "try: batch size 2**18"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 6: ASPECT_RATIO = 48

Edit: `ASPECT_RATIO = 64` → `ASPECT_RATIO = 48`

```bash
git add train.py && git commit -m "try: aspect ratio 48"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 7: ASPECT_RATIO = 80

Edit: `ASPECT_RATIO = 64` → `ASPECT_RATIO = 80`

```bash
git add train.py && git commit -m "try: aspect ratio 80"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 8: WARMDOWN_RATIO = 0.3

Edit: `WARMDOWN_RATIO = 0.5` → `WARMDOWN_RATIO = 0.3`

```bash
git add train.py && git commit -m "try: warmdown 0.3"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 9: WARMDOWN_RATIO = 0.7

Edit: `WARMDOWN_RATIO = 0.5` → `WARMDOWN_RATIO = 0.7`

```bash
git add train.py && git commit -m "try: warmdown 0.7"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 10: WEIGHT_DECAY = 0.1

Edit: `WEIGHT_DECAY = 0.2` → `WEIGHT_DECAY = 0.1`

```bash
git add train.py && git commit -m "try: weight decay 0.1"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 11: EMBEDDING_LR = 0.8

Edit: `EMBEDDING_LR = 0.6` → `EMBEDDING_LR = 0.8`

```bash
git add train.py && git commit -m "try: embedding lr 0.8"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 12: WINDOW_PATTERN = "SSLL"

Edit: `WINDOW_PATTERN = "SSSL"` → `WINDOW_PATTERN = "SSLL"`

```bash
git add train.py && git commit -m "try: window SSLL"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 13: WINDOW_PATTERN = "L"

Edit: `WINDOW_PATTERN = "SSSL"` → `WINDOW_PATTERN = "L"`

```bash
git add train.py && git commit -m "try: window L"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 14: SCALAR_LR = 0.3

Edit: `SCALAR_LR = 0.5` → `SCALAR_LR = 0.3`

```bash
git add train.py && git commit -m "try: scalar lr 0.3"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 15: HEAD_DIM = 64

Edit: `HEAD_DIM = 128` → `HEAD_DIM = 64`

```bash
git add train.py && git commit -m "try: head dim 64"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### After all 15: Combine winning changes and try new values. Keep looping.

## REMEMBER

- Lower val_bpb = better
- CRASH = grep returned nothing → log crash, reset commit
- IMPROVED = val_bpb < best → log keep, update best
- WORSE = val_bpb >= best → log discard, reset commit
- memory_gb = peak_vram_mb / 1024
- Ignore ALL warnings. Only care about runtime output.
