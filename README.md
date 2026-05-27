# AI Workstation (Ubuntu + RTX 5080)

A small bundle of scripts I use to run a fully local AI image / video /
chat workstation on Ubuntu 24.04 with an RTX 5080 (16GB VRAM, 96GB RAM).

Nothing here is novel on its own — but pulling the whole loop together
(ComfyUI launch flags for Blackwell, model downloads, Ollama CLI, nightly
backups, LoRA training launcher) saves a couple of hours when you set up a
new machine.

## What's in here

| File | What it does |
|---|---|
| `scripts/start_comfyui.sh` | Launches ComfyUI with `--use-sage-attention --fast` and the `expandable_segments` allocator (Blackwell GPUs — 5080/5090) |
| `scripts/backup.sh` | Nightly local-to-local `rsync` backup. Drop into cron. |
| `scripts/chat.sh` | Minimal terminal chat for a local Ollama model. `curl` + `jq`, no Python. |
| `scripts/download_capybara_models.sh` | Downloads all models for ComfyUI's Capybara v0.1 image-edit workflow (public files). |
| `scripts/download_ltx2_models.sh` | Downloads all models for LTX-2 image-to-video (gated — needs HF token). |
| `GUIDE.md` | A plain-English walkthrough of the workflows themselves: prompting tips, LoRA training, what each ComfyUI workflow does, troubleshooting. |

## Hardware assumptions

This setup is tuned for a **consumer Blackwell GPU (RTX 5080 / 5090)**.
On other GPUs:

- The `start_comfyui.sh` `--fast` flag wants Blackwell fp8 hardware. On
  Ampere/Ada (3090/4090), drop `--fast` and probably keep `--use-sage-attention`.
- The 19GB LTX-2 model assumes you have plenty of system RAM (32GB+) so
  ComfyUI can offload — on a 16GB card it won't fit in VRAM alone.

## ComfyUI launch flags explained

```bash
--use-sage-attention   # INT8 quantized attention — faster Flux/SDXL
--fast                 # Blackwell fp8 matmul + fp16 accumulation
PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True  # avoids VRAM fragmentation OOMs on big Flux workflows
```

## Setting up the nightly backup

1. Edit `scripts/backup.sh`'s `SOURCES=(...)` array to match what you want backed up.
2. `chmod +x scripts/backup.sh`
3. `crontab -e` and add:
   ```
   0 2 * * * /full/path/to/backup.sh
   ```
   **Do not** also add `>> backup.log 2>&1` to the cron line — the script
   already writes to `$BACKUP_LOG`. Double-logging will result in every line
   appearing twice (learned this the hard way).

## Setting up chat

```bash
# install Ollama from https://ollama.com
ollama serve &
ollama pull llama3.1:8b
./scripts/chat.sh
```

Use a different model:

```bash
MODEL=qwen3:8b ./scripts/chat.sh
```

## Setting up model downloads

```bash
# Public Comfy-Org models — no token needed
./scripts/download_capybara_models.sh

# Gated Lightricks LTX-2 models — needs HF token
# 1. Accept terms at https://huggingface.co/Lightricks/LTX-2
# 2. Create a read token at https://huggingface.co/settings/tokens
export HF_TOKEN=hf_yourTokenHere
./scripts/download_ltx2_models.sh
```

Customize the destination by setting `COMFY_MODELS` (defaults to
`$HOME/ComfyUI/models`).

## License

MIT.
