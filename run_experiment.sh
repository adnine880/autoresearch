#!/bin/bash
# Run a single autoresearch experiment, extract results, and compare to best.
# Usage: ./run_experiment.sh "<description>"
# Example: ./run_experiment.sh "depth 10"
#
# Outputs one of:
#   CRASH
#   IMPROVED <val_bpb> <memory_gb>
#   WORSE <val_bpb> <memory_gb>
#
# Side effects:
#   - Writes run.log
#   - Reads/writes best_val_bpb.txt (creates if missing)

DESC="${1:-experiment}"

echo "Running: $DESC"
uv run train.py > run.log 2>&1 || true

# Extract results
VAL_BPB=$(grep "^val_bpb:" run.log 2>/dev/null | awk '{print $2}')
PEAK_VRAM=$(grep "^peak_vram_mb:" run.log 2>/dev/null | awk '{print $2}')

if [ -z "$VAL_BPB" ]; then
    echo "CRASH"
    ./log_result.sh 0.000000 0.0 crash "$DESC"
    exit 1
fi

MEMORY_GB=$(echo "scale=1; $PEAK_VRAM / 1024" | bc)

# Load best score (default to 999 if no baseline yet)
if [ -f best_val_bpb.txt ]; then
    BEST=$(cat best_val_bpb.txt)
else
    BEST="999.0"
fi

# Compare: improved or worse?
IMPROVED=$(echo "$VAL_BPB < $BEST" | bc -l)

if [ "$IMPROVED" = "1" ]; then
    echo "$VAL_BPB" > best_val_bpb.txt
    ./log_result.sh "$VAL_BPB" "$MEMORY_GB" keep "$DESC"
    echo "IMPROVED $VAL_BPB $MEMORY_GB"
else
    ./log_result.sh "$VAL_BPB" "$MEMORY_GB" discard "$DESC"
    echo "WORSE $VAL_BPB $MEMORY_GB"
fi
