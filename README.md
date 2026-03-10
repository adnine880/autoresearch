# autoresearch — Local Ollama Fork

A fork of [karpathy/autoresearch](https://github.com/karpathy/autoresearch) that runs with **free local models** via [Ollama](https://ollama.com) + [OpenCode](https://github.com/opencode-ai/opencode), instead of requiring paid API access to Claude or Codex.

The upstream idea: give an AI agent a small but real LLM training setup and let it experiment autonomously overnight. It modifies `train.py`, trains for 5 minutes, checks if the result improved, keeps or discards, and repeats. You wake up to a log of experiments and (hopefully) a better model.

**This fork's contribution:** a `program-ollama.md` — agent instructions specifically written for small local models (tested with Qwen3 8B). Small models struggle with abstract instructions, so the prompt is written as an explicit step-by-step script with every experiment spelled out as concrete commands.

## What's different from upstream

| | Upstream | This fork |
|---|---|---|
| Agent backend | Claude Code, Codex, etc. | Ollama (local, free) |
| Agent interface | Claude CLI / Codex CLI | [OpenCode](https://github.com/opencode-ai/opencode) |
| Agent instructions | `program.md` (abstract) | `program-ollama.md` (explicit step-by-step) |
| Model tested with | Claude Sonnet/Opus | Qwen3 8B |
| Cost | API credits | Free (your GPU) |

## Quick start

**Requirements:** NVIDIA GPU (for training), Python 3.10+, [uv](https://docs.astral.sh/uv/), [Ollama](https://ollama.com), [OpenCode](https://github.com/opencode-ai/opencode).

### 1. Set up training

```bash
# Install uv (if needed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install dependencies
uv sync

# Download data and train tokenizer (one-time, ~2 min)
uv run prepare.py

# Verify it works (~5 min)
uv run train.py
```

### 2. Set up the local agent

```bash
# Install Ollama and pull a model
ollama pull qwen3:8b

# Install OpenCode
# See https://github.com/opencode-ai/opencode for instructions
```

Configure OpenCode to use Ollama as its backend (see OpenCode docs for provider setup).

### 3. Run the agent

Launch OpenCode in this repo and prompt:

```
Look at program-ollama.md and kick off a new experiment.
```

The agent will create a branch, run a baseline, then loop through hyperparameter experiments autonomously. Each run takes ~5 minutes, so expect ~12 experiments/hour.

## Project structure

```
prepare.py          — constants, data prep, tokenizer, evaluation (do not modify)
train.py            — model, optimizer, training loop (agent modifies this)
program.md          — agent instructions for Claude/Codex (upstream)
program-ollama.md   — agent instructions for local Ollama models (this fork)
log_result.sh       — helper script to append experiment results
pyproject.toml      — dependencies
```

## How program-ollama.md works

Small local models (8B params) can't reliably follow abstract research instructions the way Claude Opus can. They get stuck in analysis loops, reformat entire files instead of making surgical edits, and chase linting warnings.

`program-ollama.md` solves this by being extremely prescriptive:

- Every experiment is its own numbered section with exact find/replace edits
- Commit messages are pre-written
- Decision logic (keep/discard/crash) is repeated inline, not referenced abstractly
- Explicit "ignore all warnings" rules prevent the model from getting distracted
- The tone is "execute commands" not "reason about what to do"

This is essentially treating the local model as a script executor rather than a researcher. The "research" is front-loaded into the prompt design.

## Designing your own experiments

Edit `program-ollama.md` to change the experiment queue. The key hyperparameters in `train.py`:

| Variable | Default | What it controls |
|----------|---------|-----------------|
| `DEPTH` | 8 | Number of transformer layers |
| `ASPECT_RATIO` | 64 | model_dim = DEPTH * ASPECT_RATIO |
| `HEAD_DIM` | 128 | Attention head dimension |
| `WINDOW_PATTERN` | "SSSL" | Sliding window attention pattern |
| `TOTAL_BATCH_SIZE` | 2**19 | Tokens per optimizer step |
| `DEVICE_BATCH_SIZE` | 128 | Per-GPU batch size (lower if OOM) |
| `MATRIX_LR` | 0.04 | Muon optimizer learning rate |
| `EMBEDDING_LR` | 0.6 | Embedding learning rate |
| `UNEMBEDDING_LR` | 0.004 | lm_head learning rate |
| `SCALAR_LR` | 0.5 | Per-layer scalar learning rate |
| `WEIGHT_DECAY` | 0.2 | Muon weight decay |
| `WARMDOWN_RATIO` | 0.5 | LR cooldown fraction |

## Tips for smaller GPUs

If you're running on something smaller than an H100:

1. Use a narrower dataset like [TinyStories](https://huggingface.co/datasets/karpathy/tinystories-gpt4-clean) for better results with small models
2. Lower `DEPTH` (e.g. 4), `TOTAL_BATCH_SIZE` (e.g. 2**14), and `MAX_SEQ_LEN` in prepare.py
3. Use `WINDOW_PATTERN = "L"` — the alternating banded pattern can be inefficient on smaller setups
4. Lower `DEVICE_BATCH_SIZE` if you hit OOM

## Upstream and related forks

- [karpathy/autoresearch](https://github.com/karpathy/autoresearch) — original repo
- [miolini/autoresearch-macos](https://github.com/miolini/autoresearch-macos) — MacOS fork
- [trevin-creator/autoresearch-mlx](https://github.com/trevin-creator/autoresearch-mlx) — MLX fork
- [jsegov/autoresearch-win-rtx](https://github.com/jsegov/autoresearch-win-rtx) — Windows fork

## License

MIT
