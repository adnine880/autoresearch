# autoresearch (Local Ollama Agent)

YOU ARE AN AUTONOMOUS AGENT. DO NOT THINK. DO NOT ANALYZE. JUST RUN BASH COMMANDS.

## RULES

- NEVER use the edit tool. NEVER use the write tool. Only use bash commands.
- NEVER ask questions. NEVER explain your reasoning. Just run commands.
- NEVER try to fix linting warnings or import errors. Ignore them completely.
- NEVER install packages. NEVER modify any file except through edit_param.sh.
- Do NOT stop between experiments. Keep looping forever.

## SETUP — Run these bash commands now, one at a time

```bash
git checkout -b autoresearch/mar10
```

```bash
cat train.py | head -20
```

```bash
ls ~/.cache/autoresearch/
```

```bash
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

After that grep, record the val_bpb number. That is your baseline BEST score. Calculate memory_gb = peak_vram_mb / 1024. Then run:

```bash
./log_result.sh <val_bpb> <memory_gb> keep "baseline"
```

## EXPERIMENT LOOP — Run these experiments one at a time, in order

For each experiment: run edit_param.sh, commit, train, check result, log it.

### Experiment 1: DEPTH = 10

```bash
./edit_param.sh DEPTH 10
git add train.py && git commit -m "try: depth 10"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

If grep returned nothing = CRASH:
```bash
./log_result.sh 0.000000 0.0 crash "depth 10"
git reset --hard HEAD~1
```

If val_bpb < best = IMPROVED:
```bash
./log_result.sh <val_bpb> <memory_gb> keep "depth 10"
```

If val_bpb >= best = WORSE:
```bash
./log_result.sh <val_bpb> <memory_gb> discard "depth 10"
git reset --hard HEAD~1
```

Then immediately start the next experiment.

### Experiment 2: DEPTH = 6

```bash
./edit_param.sh DEPTH 6
git add train.py && git commit -m "try: depth 6"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic: CRASH → log crash + reset. IMPROVED → log keep. WORSE → log discard + reset.

### Experiment 3: MATRIX_LR = 0.06

```bash
./edit_param.sh MATRIX_LR 0.06
git add train.py && git commit -m "try: matrix_lr 0.06"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 4: MATRIX_LR = 0.02

```bash
./edit_param.sh MATRIX_LR 0.02
git add train.py && git commit -m "try: matrix_lr 0.02"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 5: TOTAL_BATCH_SIZE = 2**18

```bash
./edit_param.sh TOTAL_BATCH_SIZE '2**18'
git add train.py && git commit -m "try: batch size 2**18"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 6: ASPECT_RATIO = 48

```bash
./edit_param.sh ASPECT_RATIO 48
git add train.py && git commit -m "try: aspect ratio 48"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 7: ASPECT_RATIO = 80

```bash
./edit_param.sh ASPECT_RATIO 80
git add train.py && git commit -m "try: aspect ratio 80"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 8: WARMDOWN_RATIO = 0.3

```bash
./edit_param.sh WARMDOWN_RATIO 0.3
git add train.py && git commit -m "try: warmdown 0.3"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 9: WARMDOWN_RATIO = 0.7

```bash
./edit_param.sh WARMDOWN_RATIO 0.7
git add train.py && git commit -m "try: warmdown 0.7"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 10: WEIGHT_DECAY = 0.1

```bash
./edit_param.sh WEIGHT_DECAY 0.1
git add train.py && git commit -m "try: weight decay 0.1"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 11: EMBEDDING_LR = 0.8

```bash
./edit_param.sh EMBEDDING_LR 0.8
git add train.py && git commit -m "try: embedding lr 0.8"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 12: WINDOW_PATTERN = "SSLL"

```bash
./edit_param.sh WINDOW_PATTERN '"SSLL"'
git add train.py && git commit -m "try: window SSLL"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 13: WINDOW_PATTERN = "L"

```bash
./edit_param.sh WINDOW_PATTERN '"L"'
git add train.py && git commit -m "try: window L"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 14: SCALAR_LR = 0.3

```bash
./edit_param.sh SCALAR_LR 0.3
git add train.py && git commit -m "try: scalar lr 0.3"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### Experiment 15: HEAD_DIM = 64

```bash
./edit_param.sh HEAD_DIM 64
git add train.py && git commit -m "try: head dim 64"
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Same logic.

### After all 15: Combine winning changes and try new values. Keep looping forever.

## REMEMBER

- Lower val_bpb = better
- memory_gb = peak_vram_mb / 1024
- CRASH = grep returned nothing → log crash, git reset
- IMPROVED = val_bpb < best → log keep, update best
- WORSE = val_bpb >= best → log discard, git reset
