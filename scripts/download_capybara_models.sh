#!/bin/bash
# Downloads all models for ComfyUI's Capybara v0.1 image-edit workflow.
# All files are from public Comfy-Org / repackaged repos — no HuggingFace token needed.

COMFY="${COMFY_MODELS:-$HOME/ComfyUI/models}"

mkdir -p "$COMFY/diffusion_models" "$COMFY/text_encoders" "$COMFY/vae" "$COMFY/clip_vision"

echo "==> Downloading Capybara model (~14GB, this will take a while)..."
wget -c "https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/diffusion_models/capybara_v0.1.safetensors" \
  -O "$COMFY/diffusion_models/capybara_v0.1.safetensors"

echo "==> Downloading Qwen 2.5 VL text encoder (~14GB)..."
wget -c "https://huggingface.co/Comfy-Org/HunyuanImage_2.1_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b.safetensors" \
  -O "$COMFY/text_encoders/qwen_2.5_vl_7b.safetensors"

echo "==> Downloading ByT5 text encoder (small)..."
wget -c "https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/text_encoders/byt5_small_glyphxl_fp16.safetensors" \
  -O "$COMFY/text_encoders/byt5_small_glyphxl_fp16.safetensors"

echo "==> Downloading VAE..."
wget -c "https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/vae/hunyuanvideo15_vae_fp16.safetensors" \
  -O "$COMFY/vae/hunyuanvideo15_vae_fp16.safetensors"

echo "==> Downloading CLIP Vision..."
wget -c "https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/clip_vision/sigclip_vision_patch14_384.safetensors" \
  -O "$COMFY/clip_vision/sigclip_vision_patch14_384.safetensors"

echo ""
echo "All done! Open ComfyUI and load Image_capybara_v0_1_image_edit."
