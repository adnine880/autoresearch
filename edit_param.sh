#!/bin/bash
# Edit a hyperparameter in train.py
# Usage: ./edit_param.sh <PARAM_NAME> <NEW_VALUE>
# Example: ./edit_param.sh DEPTH 10
# Example: ./edit_param.sh WINDOW_PATTERN '"SSLL"'
# Example: ./edit_param.sh TOTAL_BATCH_SIZE '2**18'

PARAM="${1:?Usage: ./edit_param.sh <PARAM_NAME> <NEW_VALUE>}"
VALUE="${2:?Missing new value}"

# Check that the parameter exists in train.py
if ! grep -q "^${PARAM} = " train.py; then
    echo "ERROR: Parameter ${PARAM} not found in train.py"
    exit 1
fi

# Show the old line
OLD=$(grep "^${PARAM} = " train.py)
echo "OLD: ${OLD}"

# Replace the line (everything after "PARAM = " up to the comment or end of line)
# sed -i behaves differently on macOS vs Linux, so use a temp file for portability
sed "s/^${PARAM} = .*/${PARAM} = ${VALUE}/" train.py > train.py.tmp && mv train.py.tmp train.py

# Show the new line
NEW=$(grep "^${PARAM} = " train.py)
echo "NEW: ${NEW}"
