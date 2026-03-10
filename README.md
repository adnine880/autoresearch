# autoresearch — Local Ollama Fork

A fork of [karpathy/autoresearch](https://github.com/karpathy/autoresearch) that runs with **free local models** via [Ollama](https://ollama.com) + [OpenCode](https://github.com/opencode-ai/opencode), instead of requiring paid API access to Claude or Codex.

The idea: give an AI agent a small but real LLM training setup and let it experiment autonomously. It modifies `train.py`, trains for 5 minutes, checks if the result improved, keeps or discards, and repeats. You come back to a log of experiments and (hopefully) a better model.

This fork adds `program-ollama.md` — agent instructions written for small local models (tested with Qwen3 8B). Small models struggle with abstract instructions, so the prompt is an explicit step-by-step script with every experiment spelled out as concrete bash commands.

## Quick start

**Requirements:**
- **Python 3.10+**
- **[uv](https://docs.astral.sh/uv/)** — Python project manager
- **[Ollama](https://ollama.com)** — runs the agent model locally
- **[OpenCode](https://github.com/opencode-ai/opencode)** — coding agent that connects to Ollama

### 1. Set up training

```bash
# Install uv (see https://docs.astral.sh/uv/getting-started/installation/)
# Windows: powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
# Linux/Mac: curl -LsSf https://astral.sh/uv/install.sh | sh

# Install dependencies
uv sync

# Download data and train tokenizer (one-time, ~2 min)
uv run prepare.py

# Verify it works (~5 min)
uv run train.py
```

### 2. Install Ollama

1. Go to [ollama.com](https://ollama.com) and download the installer for your OS
2. Run the installer — Ollama runs as a background service automatically
3. Verify it's working:

```bash
ollama --version
```

### 3. Download a model

For agentic use with OpenCode, you need a model that supports **tool calling** — this is what lets the AI actually read/write files and take actions. The best balance of capability and size is Qwen3 8B:

```bash
ollama pull qwen3:8b
```

**Recommended models by machine spec:**

| RAM available | Recommended model |
|---------------|-------------------|
| 8 GB | `qwen3:8b` |
| 16 GB | `qwen3:14b` or `qwen2.5-coder:14b` |
| 32 GB+ | `qwen3:30b` or `qwen2.5-coder:32b` |

The `qwen2.5-coder` series is particularly strong at writing code and data transformation if that's your primary use case.

### 4. Increase the context window (critical)

Ollama defaults to a 4096-token context window even when models support much larger contexts — this **must** be increased for agentic actions and tool use to work in OpenCode.

Run the model, set the context, then save it as a new variant:

```bash
ollama run qwen3:8b
>>> /set parameter num_ctx 32768
>>> /save qwen3:8b-32k
>>> /bye
```

You now have a model called `qwen3:8b-32k` with a proper context window.

### 5. Install Node.js

OpenCode requires Node.js 20 or higher. Download from [nodejs.org](https://nodejs.org) (choose the LTS version). Verify after installing:

```bash
node --version
```

### 6. Install OpenCode

```bash
npm install -g opencode-ai
```

Verify it installed:

```bash
opencode --version
```

### 7. Configure OpenCode to use your local Ollama model

Create or edit the config file at `~/.config/opencode/opencode.json` (on Windows: `C:\Users\YourName\.config\opencode\opencode.json`):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen3:8b-32k": {
          "name": "Qwen3 8B (local)",
          "tools": true
        }
      }
    }
  }
}
```

### 8. Run the agent

Navigate to this repo folder and launch OpenCode:

```bash
opencode
```

Inside OpenCode, use `/models` to select your Ollama model. Then prompt:

```
Look at program-ollama.md and kick off a new experiment.
```

The agent will create a branch, run a baseline, then loop through hyperparameter experiments autonomously. Each run takes ~5 minutes, so expect ~12 experiments/hour.

Everything stays on your machine — no API keys required, no cloud costs, complete privacy, and offline capability.

## GPU compatibility

`train.py` automatically detects your GPU and picks the best attention backend:

- **H100 (Hopper)**: Flash Attention 3 via `varunneal/flash-attention-3`
- **Other NVIDIA GPUs with FA3 support**: Flash Attention 3 via `kernels-community/flash-attn3`
- **All other CUDA GPUs**: PyTorch's built-in `scaled_dot_product_attention` (SDPA)

No code changes needed — the fallback is automatic. You'll see a message at startup telling you which backend is active. Similarly, `torch.compile` is used when available but the script runs fine in eager mode if compilation fails.

## Default configuration (8GB laptop GPU)

The defaults in `train.py` are tuned for an 8GB laptop GPU (e.g. RTX 5060/5070):

| Parameter | Default | Purpose |
|-----------|---------|---------|
| `DEPTH` | 6 | Number of transformer layers |
| `DEVICE_BATCH_SIZE` | 16 | Tokens per micro-batch (fits 8GB) |
| `TOTAL_BATCH_SIZE` | 2^16 (65K) | Tokens per optimizer step |
| `HEAD_DIM` | 64 | Attention head dimension |
| `WINDOW_PATTERN` | "L" | Full-context attention only |

If you have a larger GPU (16GB+), you can increase:
- `DEVICE_BATCH_SIZE` to 32-64 — faster training
- `DEPTH` to 8-10 — deeper model
- `TOTAL_BATCH_SIZE` to `2**18` — better gradient estimates
- `HEAD_DIM` to 128 — wider attention heads
- `WINDOW_PATTERN` to "SSSL" — alternating sliding window

For very small GPUs (4-6GB), lower `DEVICE_BATCH_SIZE` to 8 and `DEPTH` to 4.

## Project structure

```
prepare.py            — constants, data prep, tokenizer, evaluation (do not modify)
train.py              — model, optimizer, training loop (agent modifies this)
program-ollama.md     — agent instructions for local Ollama models
edit_param.sh         — change one hyperparameter in train.py via sed
run_experiment.sh     — train, compare to best score, log result (IMPROVED/WORSE/CRASH)
revert_experiment.sh  — revert last commit when experiment fails or regresses
log_result.sh         — append experiment results to results.tsv
opencode.json         — OpenCode provider config for local Ollama
pyproject.toml        — dependencies
```

## How program-ollama.md works

Small local models (8B params) can't reliably follow abstract research instructions the way large frontier models can. They get stuck in analysis loops, reformat entire files instead of making surgical edits, and chase linting warnings.

`program-ollama.md` and the helper scripts solve this together:

- **`edit_param.sh`** — the agent never touches the Edit tool (which small models can't use without reformatting the entire file). Instead it runs `./edit_param.sh DEPTH 10` to make surgical `sed` replacements
- **`run_experiment.sh`** — handles all the logic a small model would botch: trains, extracts metrics, compares to the best score (stored in `best_val_bpb.txt`), logs the result, and prints a single word: `IMPROVED`, `WORSE`, or `CRASH`
- **`revert_experiment.sh`** — one command to undo a failed experiment (`git reset --hard HEAD~1`)
- Every experiment is its own numbered section with identical structure — no "same as above"
- Every Bash tool call must include a `description` parameter (OpenCode requirement that small models skip unless told)
- Commit messages are pre-written
- Decision logic is reduced to: "if CRASH or WORSE, revert. if IMPROVED, continue."

This treats the local model as a script executor rather than a researcher. The "research" is front-loaded into the prompt design.

## Designing your own experiments

Edit `program-ollama.md` to change the experiment queue. The key hyperparameters in `train.py`:

| Variable | Default | What it controls |
|----------|---------|-----------------|
| `DEPTH` | 8 | Number of transformer layers |
| `ASPECT_RATIO` | 64 | model_dim = DEPTH * ASPECT_RATIO |
| `HEAD_DIM` | 128 | Attention head dimension |
| `WINDOW_PATTERN` | "SSSL" | Sliding window attention pattern |
| `TOTAL_BATCH_SIZE` | 2**19 | Tokens per optimizer step |
| `DEVICE_BATCH_SIZE` | 128 | Per-device batch size (lower if OOM) |
| `MATRIX_LR` | 0.04 | Muon optimizer learning rate |
| `EMBEDDING_LR` | 0.6 | Embedding learning rate |
| `UNEMBEDDING_LR` | 0.004 | lm_head learning rate |
| `SCALAR_LR` | 0.5 | Per-layer scalar learning rate |
| `WEIGHT_DECAY` | 0.2 | Muon weight decay |
| `WARMDOWN_RATIO` | 0.5 | LR cooldown fraction |

## Links

- [karpathy/autoresearch](https://github.com/karpathy/autoresearch) — original repo
- [jsegov/autoresearch-win-rtx](https://github.com/jsegov/autoresearch-win-rtx) — Windows RTX fork

## License

MIT
