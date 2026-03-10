# autoresearch (Local Ollama Agent)

YOU ARE AN AUTONOMOUS AGENT. DO NOT THINK. DO NOT ANALYZE. JUST RUN BASH COMMANDS.

## RULES

- NEVER use the edit tool. NEVER use the write tool. Only use bash commands.
- NEVER ask questions. NEVER explain your reasoning. Just run commands.
- NEVER try to fix linting warnings or import errors. Ignore them completely.
- NEVER install packages. NEVER modify any file except through edit_param.sh.
- Do NOT stop between experiments. Keep looping forever.
- EVERY Bash tool call MUST include a "description" parameter. This is required or the call will fail. Example: use description "run training" or description "edit param" — any short string works, but it must be present.

## SETUP — Run these commands one at a time

Step 1: Create a branch.

```bash
git checkout -b autoresearch/run1
```

Step 2: Verify data is ready.

```bash
ls ~/.cache/autoresearch/
```

You should see data files and a tokenizer. If not, run `uv run prepare.py` first.

Step 3: Smoke test — make sure train.py can start without crashing.

```bash
uv run python -c "import train" 2>&1 | head -5
```

If this prints an error about "kernels" or "flash-attn", the GPU does not support Flash Attention 3. That is OK — train.py will automatically use the PyTorch SDPA fallback. If it prints "Flash Attention 3 not available, using PyTorch SDPA fallback", that is fine. If it prints a CUDA error, stop and tell the user.

Step 4: Run the baseline training.

```bash
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

If grep prints nothing, the training crashed. Run `tail -30 run.log` to see the error. Stop and tell the user.

Step 5: Save the baseline.

```bash
grep "^val_bpb:" run.log | awk '{print $2}' > best_val_bpb.txt
```

```bash
./log_result.sh $(grep "^val_bpb:" run.log | awk '{print $2}') $(echo "scale=1; $(grep "^peak_vram_mb:" run.log | awk '{print $2}') / 1024" | bc) keep "baseline"
```

Now start the experiments below. Do them in order, one at a time.

## EXPERIMENT LOOP

For EVERY experiment, the steps are always the same:
1. Run edit_param.sh to change a value
2. Commit the change
3. Run run_experiment.sh — it trains, compares to best, and logs the result
4. Check the output: if it says CRASH or WORSE, run revert_experiment.sh. If it says IMPROVED, do nothing.

### Experiment 1: DEPTH = 10

```bash
./edit_param.sh DEPTH 10
```

```bash
git add train.py && git commit -m "try: depth 10"
```

```bash
./run_experiment.sh "depth 10"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 2: DEPTH = 6

```bash
./edit_param.sh DEPTH 6
```

```bash
git add train.py && git commit -m "try: depth 6"
```

```bash
./run_experiment.sh "depth 6"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 3: MATRIX_LR = 0.06

```bash
./edit_param.sh MATRIX_LR 0.06
```

```bash
git add train.py && git commit -m "try: matrix_lr 0.06"
```

```bash
./run_experiment.sh "matrix_lr 0.06"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 4: MATRIX_LR = 0.02

```bash
./edit_param.sh MATRIX_LR 0.02
```

```bash
git add train.py && git commit -m "try: matrix_lr 0.02"
```

```bash
./run_experiment.sh "matrix_lr 0.02"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 5: TOTAL_BATCH_SIZE = 2**18

```bash
./edit_param.sh TOTAL_BATCH_SIZE '2**18'
```

```bash
git add train.py && git commit -m "try: batch size 2**18"
```

```bash
./run_experiment.sh "batch size 2**18"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 6: ASPECT_RATIO = 48

```bash
./edit_param.sh ASPECT_RATIO 48
```

```bash
git add train.py && git commit -m "try: aspect ratio 48"
```

```bash
./run_experiment.sh "aspect ratio 48"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 7: ASPECT_RATIO = 80

```bash
./edit_param.sh ASPECT_RATIO 80
```

```bash
git add train.py && git commit -m "try: aspect ratio 80"
```

```bash
./run_experiment.sh "aspect ratio 80"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 8: WARMDOWN_RATIO = 0.3

```bash
./edit_param.sh WARMDOWN_RATIO 0.3
```

```bash
git add train.py && git commit -m "try: warmdown 0.3"
```

```bash
./run_experiment.sh "warmdown 0.3"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 9: WARMDOWN_RATIO = 0.7

```bash
./edit_param.sh WARMDOWN_RATIO 0.7
```

```bash
git add train.py && git commit -m "try: warmdown 0.7"
```

```bash
./run_experiment.sh "warmdown 0.7"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 10: WEIGHT_DECAY = 0.1

```bash
./edit_param.sh WEIGHT_DECAY 0.1
```

```bash
git add train.py && git commit -m "try: weight decay 0.1"
```

```bash
./run_experiment.sh "weight decay 0.1"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 11: EMBEDDING_LR = 0.8

```bash
./edit_param.sh EMBEDDING_LR 0.8
```

```bash
git add train.py && git commit -m "try: embedding lr 0.8"
```

```bash
./run_experiment.sh "embedding lr 0.8"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 12: WINDOW_PATTERN = "SSLL"

```bash
./edit_param.sh WINDOW_PATTERN '"SSLL"'
```

```bash
git add train.py && git commit -m "try: window SSLL"
```

```bash
./run_experiment.sh "window SSLL"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 13: WINDOW_PATTERN = "L"

```bash
./edit_param.sh WINDOW_PATTERN '"L"'
```

```bash
git add train.py && git commit -m "try: window L"
```

```bash
./run_experiment.sh "window L"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 14: SCALAR_LR = 0.3

```bash
./edit_param.sh SCALAR_LR 0.3
```

```bash
git add train.py && git commit -m "try: scalar lr 0.3"
```

```bash
./run_experiment.sh "scalar lr 0.3"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert. Move to the next experiment.

### Experiment 15: HEAD_DIM = 64

```bash
./edit_param.sh HEAD_DIM 64
```

```bash
git add train.py && git commit -m "try: head dim 64"
```

```bash
./run_experiment.sh "head dim 64"
```

If the output says CRASH or WORSE, run this:

```bash
./revert_experiment.sh
```

If the output says IMPROVED, do NOT revert.

### After all 15: Go back to Experiment 1 and repeat with different values. Keep looping forever.

## REMEMBER

- CRASH or WORSE = run ./revert_experiment.sh
- IMPROVED = do NOT revert
- Do NOT stop. Start the next experiment immediately.
- EVERY Bash tool call MUST include a "description" parameter or it will fail.
