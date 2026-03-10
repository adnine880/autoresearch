# autoresearch (Local Ollama Agent)

YOU ARE AN AUTONOMOUS AGENT. EXECUTE COMMANDS DIRECTLY. NEVER ASK THE USER QUESTIONS.

## CRITICAL RULES — READ THESE FIRST

1. **NEVER ask the user what to change.** You decide.
2. **NEVER list steps without executing them.** Run commands immediately.
3. **NEVER stop or pause.** Keep running experiments forever.
4. **ONLY modify `train.py`.** No other files.
5. **Do NOT install new packages.**
6. **When editing train.py, ONLY change the ONE line you need to change.** Do NOT reformat, restyle, or rewrite other lines. Use a find-and-replace style edit that changes ONLY the target line.
7. **Ignore all linting warnings.** Warnings like "Import torch could not be resolved" are normal and harmless. Do NOT try to fix them.
8. **You MUST run the baseline BEFORE making any edits.** The very first experiment is always running the unmodified code.

## First Time Setup

Execute these steps IN ORDER. Do not skip any step.

### Step A: Create a git branch
```bash
git checkout -b autoresearch/mar10
```

### Step B: Read train.py
Read the file `train.py` to understand the code. Look at the "Hyperparameters" section near the bottom — that is the ONLY section you will edit.

### Step C: Verify data exists
```bash
ls ~/.cache/autoresearch/
```
If empty, tell the user to run `uv run prepare.py` and stop.

### Step D: Run the BASELINE (unmodified code)
Do NOT edit train.py yet. Run it as-is first:
```bash
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```
Record the val_bpb number — this is your baseline. Calculate memory_gb = peak_vram_mb / 1024.
```bash
./log_result.sh <val_bpb> <memory_gb> keep "baseline"
```

Now you have a baseline. Remember this val_bpb number — all future experiments compare against it.

## Experiment Loop

After the baseline, repeat this loop forever:

### Step 1: Make ONE small edit to train.py

**IMPORTANT: Only change ONE line. Do not reformat or rewrite the file.**

Use your edit tool to replace ONLY the specific line. For example, to change DEPTH:
- Find: `DEPTH = 8`
- Replace with: `DEPTH = 10`

That is it. One line. Nothing else changes.

Try these experiments IN ORDER (skip to next if current value already changed from a previous keep):

1. `DEPTH = 8` → `DEPTH = 10`
2. `DEPTH = 8` → `DEPTH = 6`
3. `MATRIX_LR = 0.04` → `MATRIX_LR = 0.06`
4. `MATRIX_LR = 0.04` → `MATRIX_LR = 0.02`
5. `TOTAL_BATCH_SIZE = 2**19` → `TOTAL_BATCH_SIZE = 2**18`
6. `ASPECT_RATIO = 64` → `ASPECT_RATIO = 48`
7. `ASPECT_RATIO = 64` → `ASPECT_RATIO = 80`
8. `WARMDOWN_RATIO = 0.5` → `WARMDOWN_RATIO = 0.3`
9. `WARMDOWN_RATIO = 0.5` → `WARMDOWN_RATIO = 0.7`
10. `WEIGHT_DECAY = 0.2` → `WEIGHT_DECAY = 0.1`
11. `EMBEDDING_LR = 0.6` → `EMBEDDING_LR = 0.8`
12. `WINDOW_PATTERN = "SSSL"` → `WINDOW_PATTERN = "SSLL"`
13. `WINDOW_PATTERN = "SSSL"` → `WINDOW_PATTERN = "L"`
14. `SCALAR_LR = 0.5` → `SCALAR_LR = 0.3`
15. `HEAD_DIM = 128` → `HEAD_DIM = 64`

After exhausting this list, combine successful changes or try new values.

### Step 2: Commit the change
```bash
git add train.py && git commit -m "try: <short description>"
```

### Step 3: Run the experiment
```bash
uv run train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
```
If grep returns nothing, the run crashed. Run `tail -n 30 run.log` to see error.

### Step 4: Log result and decide

Calculate memory_gb = peak_vram_mb / 1024.

**CRASH** (grep returned nothing):
```bash
./log_result.sh 0.000000 0.0 crash "<description>"
git reset --hard HEAD~1
```

**IMPROVED** (val_bpb is LOWER than best):
```bash
./log_result.sh <val_bpb> <memory_gb> keep "<description>"
```
Keep the commit. Update your best val_bpb.

**NOT IMPROVED** (val_bpb is EQUAL or HIGHER than best):
```bash
./log_result.sh <val_bpb> <memory_gb> discard "<description>"
git reset --hard HEAD~1
```

### Step 5: Go back to Step 1

Do NOT pause. Do NOT ask the user. Pick the next experiment and go immediately.

## Things to IGNORE

- Linting errors about missing imports (torch, kernels, etc.) — these are normal
- Type checker warnings — ignore them all
- Code formatting suggestions — do NOT reformat the file
- Any IDE warnings or suggestions — ignore everything except actual runtime errors
