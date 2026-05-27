#!/bin/bash
# Downloads all model files for ComfyUI's LTX-2 image-to-video workflow.
#
# Lightricks/LTX-2 is a GATED repo — you must accept terms on HuggingFace first:
#   https://huggingface.co/Lightricks/LTX-2
# Then export your HuggingFace token before running:
#   export HF_TOKEN=hf_yourTokenHere
#   ./download_ltx2_models.sh

if [ -z "${HF_TOKEN:-}" ]; then
  echo "ERROR: Set HF_TOKEN env var first."
  echo "  1. Accept terms at https://huggingface.co/Lightricks/LTX-2"
  echo "  2. Create token at https://huggingface.co/settings/tokens"
  echo "  3. export HF_TOKEN=hf_yourTokenHere"
  exit 1
fi

COMFY="${COMFY_MODELS:-$HOME/ComfyUI/models}"
H="Authorization: Bearer $HF_TOKEN"

mkdir -p "$COMFY/checkpoints" "$COMFY/text_encoders" "$COMFY/loras" "$COMFY/latent_upscale_models"

echo "==> Downloading main LTX-2 model (~19GB, will take a while)..."
wget -c --header="$H" \
  "https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-dev-fp8.safetensors" \
  -O "$COMFY/checkpoints/ltx-2-19b-dev-fp8.safetensors"

echo "==> Downloading text encoder (Gemma 3 12B fp4)..."
wget -c \
  "https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors" \
  -O "$COMFY/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors"

echo "==> Downloading distilled LoRA..."
wget -c --header="$H" \
  "https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled-lora-384.safetensors" \
  -O "$COMFY/loras/ltx-2-19b-distilled-lora-384.safetensors"

echo "==> Downloading spatial upscaler..."
wget -c --header="$H" \
  "https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-spatial-upscaler-x2-1.0.safetensors" \
  -O "$COMFY/latent_upscale_models/ltx-2-spatial-upscaler-x2-1.0.safetensors"

echo ""
echo "All done! Open ComfyUI and load the video_ltx2_i2v workflow."
