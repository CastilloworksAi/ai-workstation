#!/bin/bash
# Launches ComfyUI with Blackwell-class GPU optimizations.
# Adjust COMFY_DIR if your install lives elsewhere.

COMFY_DIR="${COMFY_DIR:-$HOME/ComfyUI}"
HOST="${COMFY_HOST:-127.0.0.1}"
PORT="${COMFY_PORT:-8188}"

cd "$COMFY_DIR" || exit 1
source venv/bin/activate

# Prevents VRAM fragmentation OOM on large Flux workflows.
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

# --use-sage-attention : INT8 quantized attention, faster Flux/SDXL on Blackwell (RTX 5080/5090)
# --fast               : Blackwell fp8 matmul + fp16 accumulation speedups
exec python main.py --listen "$HOST" --port "$PORT" --use-sage-attention --fast
