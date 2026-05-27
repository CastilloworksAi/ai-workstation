# ai-workstation

Scripts I use to run ComfyUI, Ollama, and a nightly backup on a Ubuntu 24.04
machine with an RTX 5080. Specific to that hardware in places — the launch
flags target Blackwell.

For the ComfyUI workflows themselves, see
[comfyui-workflows](https://github.com/CastilloworksAi/comfyui-workflows).
For the LoRA training pipeline, see
[lora-training-guide](https://github.com/CastilloworksAi/lora-training-guide).
This repo is the *operations* layer underneath those.

## My hardware

| Component | Spec |
|---|---|
| GPU | NVIDIA RTX 5080 (16 GB VRAM, Blackwell — sm_120) |
| CPU | AMD Ryzen 9 9900X (12c / 24t) |
| RAM | 96 GB DDR5 |
| Storage | 3.7 TB NVMe primary, 1.8 TB NVMe secondary |
| OS | Ubuntu 24.04 LTS, kernel 6.17 |
| NVIDIA driver | 580.x (CUDA 13 runtime) |
| PyTorch | 2.11 + cu128 |

On other hardware:
- Ampere (3090) or Ada (4090): drop the `--fast` flag. Keep
  `--use-sage-attention`.
- 12 GB VRAM cards: skip LTX-2 video entirely. Capybara image editing still
  works with offload.
- Non-NVIDIA: none of this applies; reference only.

## Scripts

### `scripts/start_comfyui.sh`

Launches ComfyUI with the flags that matter on Blackwell:

```bash
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
python main.py --listen 127.0.0.1 --port 8188 --use-sage-attention --fast
```

What each flag does:

| Flag | Effect |
|---|---|
| `--use-sage-attention` | INT8 quantized attention. ~20% faster Flux/SDXL inference on Blackwell. Requires the `sageattention` Python package installed in the ComfyUI venv. |
| `--fast` | Enables fp8 matmul + fp16 accumulation. Blackwell-only. Another ~10–15% speedup on Flux Dev fp8 checkpoints. |
| `expandable_segments:True` | Prevents the PyTorch caching allocator from fragmenting VRAM into unusable chunks during long sessions. Eliminates a class of OOM errors when generating Flux at 1024+. |

Override the install dir / host / port with environment variables:

```bash
COMFY_DIR=/opt/ComfyUI COMFY_PORT=8000 ./scripts/start_comfyui.sh
```

### `scripts/backup.sh`

`rsync`-based nightly backup to a destination directory. Designed to run from
cron. **Do not also redirect cron output to the log file** — the script writes
to the log directly, and double-redirecting will duplicate every line (I had
this bug for a while; fixed in this version).

Default sources are `$HOME/Documents` and `$HOME/Projects`. Edit the
`SOURCES=( ... )` array to match your layout. Each source is mirrored into
`$BACKUP_DEST/` preserving its basename.

Exclusions: `*.pyc`, `__pycache__`, `.git`, `venv`, `node_modules`.

Cron line:

```cron
0 2 * * * /home/youruser/ai-workstation/scripts/backup.sh
```

Override the destination or log:

```bash
BACKUP_DEST=/mnt/external/backups BACKUP_LOG=/var/log/backup.log ./scripts/backup.sh
```

The script reports per-source status and a final size summary into the log.
Exit is always 0; failures are logged with `WARNING:` lines.

### `scripts/chat.sh`

A 60-line bash chat client for a local Ollama model. No Python, no web UI,
no Electron. Just `curl` + `jq`. Maintains conversation history in memory
for the session.

```bash
./scripts/chat.sh                          # default model: llama3.1:8b
MODEL=qwen3:8b ./scripts/chat.sh           # use a different model
OLLAMA_URL=http://other-host:11434/api/chat ./scripts/chat.sh   # remote host
```

The script will start `ollama serve` in the background if it isn't already
running, and `ollama pull` the model on first use.

Dependencies: `curl`, `jq`, `ollama`. Type `exit` or `quit` to leave.

### `scripts/download_capybara_models.sh`

Downloads all five files needed for ComfyUI's Capybara v0.1 image editing
workflow. Total: ~30 GB. No HuggingFace token required (public repos).

| File | Size | Destination |
|---|---|---|
| `capybara_v0.1.safetensors` | ~14 GB | `models/diffusion_models/` |
| `qwen_2.5_vl_7b.safetensors` | ~14 GB | `models/text_encoders/` |
| `byt5_small_glyphxl_fp16.safetensors` | ~420 MB | `models/text_encoders/` |
| `hunyuanvideo15_vae_fp16.safetensors` | ~2.4 GB | `models/vae/` |
| `sigclip_vision_patch14_384.safetensors` | ~10 MB | `models/clip_vision/` |

Override the destination with `COMFY_MODELS`:

```bash
COMFY_MODELS=/data/comfy_models ./scripts/download_capybara_models.sh
```

The script uses `wget -c` so interrupted downloads can be resumed by re-running it.

### `scripts/download_ltx2_models.sh`

Downloads all four files needed for the LTX-2 image-to-video workflow.
Total: ~36 GB. **Requires a HuggingFace token** because Lightricks gates
their models.

Setup:

1. Visit <https://huggingface.co/Lightricks/LTX-2> and click **Agree** to
   accept the model license.
2. Create a read token at <https://huggingface.co/settings/tokens>.
3. Export it and run the script:

```bash
export HF_TOKEN=hf_yourTokenHere
./scripts/download_ltx2_models.sh
```

| File | Size | Destination |
|---|---|---|
| `ltx-2-19b-dev-fp8.safetensors` | ~26 GB | `models/checkpoints/` |
| `gemma_3_12B_it_fp4_mixed.safetensors` | ~8.8 GB | `models/text_encoders/` |
| `ltx-2-19b-distilled-lora-384.safetensors` | ~7.2 GB | `models/loras/` |
| `ltx-2-spatial-upscaler-x2-1.0.safetensors` | ~950 MB | `models/latent_upscale_models/` |

On a 16 GB card the main model won't fit in VRAM; ComfyUI will offload to
system RAM automatically. Expect 5–15 minutes per ~5 second clip.

## Fresh-machine install

Order matters.

```bash
# 1. NVIDIA driver (Ubuntu 24.04 — Blackwell needs 570+, 580+ recommended)
sudo apt install nvidia-driver-580
sudo reboot

# 2. Python venv + ComfyUI
git clone https://github.com/comfyanonymous/ComfyUI.git ~/ComfyUI
cd ~/ComfyUI && python3 -m venv venv && source venv/bin/activate
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu128
pip install -r requirements.txt
pip install sageattention   # required for --use-sage-attention

# 3. Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.1:8b
ollama pull llama3.2-vision:11b   # for LoRA Studio captioning

# 4. This repo
git clone https://github.com/CastilloworksAi/ai-workstation.git
chmod +x ai-workstation/scripts/*.sh

# 5. Cron the backup
crontab -e   # add: 0 2 * * * /home/$USER/ai-workstation/scripts/backup.sh

# 6. Download models
./ai-workstation/scripts/download_capybara_models.sh
export HF_TOKEN=hf_xxx
./ai-workstation/scripts/download_ltx2_models.sh

# 7. Launch
./ai-workstation/scripts/start_comfyui.sh
```

ComfyUI will be at <http://localhost:8188>.

## Disk space planning

Realistic disk usage with the full kit installed:

| Thing | Size |
|---|---|
| Ubuntu 24.04 install | ~15 GB |
| ComfyUI + venv | ~6 GB |
| Flux Dev model + clip + vae | ~30 GB |
| Capybara stack (this repo) | ~30 GB |
| LTX-2 stack (this repo) | ~43 GB |
| Other base models (SDXL, SD1.5, z-image, etc.) | ~40 GB |
| LoRAs you collect | varies, mine is ~10 GB |
| Ollama models (llama3.1, qwen3, vision, etc.) | ~25 GB |
| Generated output (images, videos) | grows fast — mine is 150+ GB |

A 2 TB drive is the realistic minimum. A 4 TB drive gives you breathing room.

## Troubleshooting

**ComfyUI starts but generation hangs on first run**
First Flux generation compiles fp8 kernels. Can take 60–90 seconds. Subsequent
generations are fast.

**`CUDA error: no kernel image is available for execution on the device`**
You installed a PyTorch build that doesn't support sm_120 (Blackwell).
Reinstall with the `cu128` wheels:
```bash
pip install --force-reinstall torch torchvision --index-url https://download.pytorch.org/whl/cu128
```

**`--use-sage-attention` errors at startup**
`pip install sageattention` in the ComfyUI venv. If wheels aren't available
for your Python version, you'll need to build from source.

**Backup runs but log is empty / not running**
Cron uses a minimal `PATH` and `HOME`. Use absolute paths in the cron line.
Check `/var/log/syslog | grep CRON` for errors.

**Chat says "Ollama not running" but it is**
You probably have it bound on a non-default port. Set `OLLAMA_URL`:
```bash
OLLAMA_URL=http://127.0.0.1:11435/api/chat ./scripts/chat.sh
```

## What this repo is NOT

- Not a one-click installer. You will run commands.
- Not Docker / Compose. Plain shell scripts on the host.
- Not Windows or macOS tested. Probably needs adjustments on both.
- Not a maintained product. These are my working scripts, lightly cleaned for
  publication. Issues and PRs welcome but no SLA.

## Related repos

- [comfyui-workflows](https://github.com/CastilloworksAi/comfyui-workflows) —
  the ComfyUI workflow JSONs (Flux, SDXL, LoRA training, captioning)
- [lora-training-guide](https://github.com/CastilloworksAi/lora-training-guide) —
  end-to-end LoRA training walkthrough
- [lora-studio](https://github.com/CastilloworksAi/lora-studio) — local
  captioning + dataset prep web app

## License

MIT.
