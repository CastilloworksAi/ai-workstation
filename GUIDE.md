================================================================================
  COMPLETE BEGINNER GUIDE — IMAGE GENERATION, VIDEO, LORA TRAINING
  Your personal AI workstation — written for you, by your setup
================================================================================

Last updated: May 2026 (revised)
Your system: RTX 5080 (16GB) | 96GB RAM | All models local, nothing cloud

--------------------------------------------------------------------------------
  TABLE OF CONTENTS
--------------------------------------------------------------------------------

  PART 1 — What is all of this?
  PART 2 — How to open everything
  PART 3 — ComfyUI basics (read this before touching any workflow)
  PART 4 — Your workflows, one by one
              A. X1                  — SDXL image generation (starter / scratch pad)
              B. flux_portrait_v1    — Flux portraits with detail boost
              C. Image_capybara_v0_1 — Image-to-image edit (keep face, change scene)
              D. video_ltx2_i2v      — Image-to-video (turn a photo into a video clip)
              E. flux_lora_train     — Train your own LoRA on Flux
  PART 5 — The full 0-to-trained-LoRA pipeline (step by step)
  PART 6 — Using your LoRA after training
  PART 7 — Open WebUI (AI chat)
  PART 8 — Quick reference / cheat sheet

================================================================================
  PART 1 — WHAT IS ALL OF THIS?
================================================================================

Think of your setup like a photo studio + darkroom + printing lab, all local:

  COMFYUI
  Your visual AI workbench. It lives at: http://localhost:8188
  It generates images and videos using AI models. You control it by connecting
  "nodes" together like a flowchart — each node does one job (load model, write
  prompt, generate image, save file, etc.)

  MODELS (the big files in ComfyUI/models/)
  These are the AI "brains." Different models are good at different things:
    - Flux Dev          — highly detailed, photorealistic, follows prompts closely
    - JuggernautXL      — versatile SDXL model, great all-rounder
    - Capybara          — image-to-image editing (edit a photo with a prompt)
    - LTX-2             — image-to-video (turn a photo into a short clip with audio)
    - Realistic Vision  — SD1.5, fast and good for faces/photos

  LORA (Low-Rank Adaptation)
  A small add-on file (50-300MB) you train on top of a base model.
  Think of it like this: the base model knows what "a person" looks like in
  general. A LoRA teaches it what YOUR specific person, style, or object looks
  like. You use a trigger word (like "ohwx") to activate it.

  OLLAMA + OPEN WEBUI
  Your local AI chat. Lives at: http://localhost:3000
  Like ChatGPT but running 100% on your machine. Uses your GPU when free,
  falls back to CPU automatically when ComfyUI is working.

--------------------------------------------------------------------------------

================================================================================
  PART 2 — HOW TO OPEN EVERYTHING
================================================================================

  COMFYUI (image / video generation)
  ----------------------------------
  ComfyUI is ALREADY running in the background. Just open your browser:

      http://localhost:8188

  If it ever gets closed or you restart your computer, open a terminal and run:

      ~/start_comfyui.sh

  Wait about 10-15 seconds for it to fully load, then open the browser.

  OPEN WEBUI (AI chat)
  --------------------
  Also already running. Open your browser and go to:

      http://localhost:3000

  This is your personal ChatGPT. Pick a model from the dropdown at the top.

  NOTE: Open WebUI needs Ollama running to actually answer.
  If chat doesn't work, open a terminal and run:

      ollama serve &

--------------------------------------------------------------------------------

================================================================================
  PART 3 — COMFYUI BASICS
================================================================================

  THE CANVAS
  ----------
  When you open ComfyUI you see a dark canvas with boxes connected by lines.
  Each box is a NODE. Each node does one specific job. The lines between them
  pass data from one node to the next, left to right.

  You don't need to understand every node. You only need to find and edit
  the ones with text/settings you want to change.

  LOADING A WORKFLOW
  ------------------
  Top-right of the screen → click the menu icon (three lines) → Workflows
  OR just press Ctrl+O to open a workflow file.
  Your workflows are saved inside ComfyUI automatically — look in the
  Workflows panel on the right side of the screen.

  HOW TO EDIT A NODE
  ------------------
  Click on any box (node) to select it. You'll see text fields, dropdowns,
  and sliders. Just click and type to change values.

  The most important nodes you'll edit are usually:
    - Prompt nodes (text boxes where you type what you want)
    - Checkpoint/Model loader nodes (which model to use)
    - LoRA loader nodes (which LoRA to use)
    - Image size nodes (width and height)
    - LoadImage nodes (upload your reference photo)

  HOW TO GENERATE
  ---------------
  Once you have a workflow loaded and your prompt typed:
  Press the big "Queue" button at the bottom right (or press Ctrl+Enter).
  The result appears in the preview node on the right side of the canvas.
  Output is automatically saved to: ComfyUI/output/

  CHANGING THE SEED
  -----------------
  The seed is a number that controls randomness. Same seed = same image.
  Different seed = different result with same prompt.
  Most workflows have a "seed" field — set it to -1 for random every time,
  or lock a specific number to reproduce a result you liked.

  THINGS THAT LOOK BROKEN
  -----------------------
  Red lines = a connection between nodes is broken. Usually means a model
  file is missing. Check that the model name in the loader node matches
  a file you actually have in your models folder.

  "Value not in list" dropdown = the model file it's looking for doesn't
  exist. Click the dropdown and pick the correct file you have.

--------------------------------------------------------------------------------

================================================================================
  PART 4 — YOUR WORKFLOWS, ONE BY ONE
================================================================================

--------------------------------------------------------------------------------
  A. X1.json — SDXL image generation (starter / scratch pad)
--------------------------------------------------------------------------------

  WHAT IT DOES:
  Basic image generation using JuggernautXL. Great starting point.
  Good for landscapes, objects, scenes, and general art. Has educational
  sticky notes on the canvas explaining how prompting works.

  HOW TO USE IT:
  1. Load the workflow: Ctrl+O → X1
  2. Find the node labeled "CLIPTextEncode" with a big text box.
     There are TWO of them:
       - Top one = POSITIVE prompt (what you WANT)
       - Bottom one = NEGATIVE prompt (what you DON'T want)
  3. Click the positive prompt box and type what you want to generate.
     Example: "a red sports car on a mountain road at sunset, cinematic"
  4. Leave the negative prompt as-is or add things you don't want:
     Example: "blurry, low quality, extra limbs"
  5. Press Queue (or Ctrl+Enter).
  6. Your image appears in the preview and saves to ComfyUI/output/

  THINGS YOU CAN CHANGE:
    - Image size: find "EmptyLatentImage" node → change width/height
      (stick to multiples of 64. Good SDXL sizes: 1024x1024, 1024x768, 768x1024)
    - Steps: more steps = more detail but slower. 20-30 is fine for SDXL.
    - CFG Scale: how closely it follows your prompt. 7 is default.

--------------------------------------------------------------------------------
  B. flux_portrait_v1.json — Flux portraits with detail boost
--------------------------------------------------------------------------------

  WHAT IT DOES:
  Flux Dev image generation with two LoRAs pre-loaded:
    - add_details LoRA: sharpens and adds fine detail to faces/hair/skin
    - AntiBlur LoRA: reduces softness/blur in the output
  Best workflow for portraits, close-up face shots, and high quality work.

  HOW TO USE IT:
  1. Load the workflow.
  2. Find "CLIPTextEncodeFlux" — has TWO text boxes:
       - Top small box = short style/concept summary
       - Bottom big box = full detailed description
     TIP: Flux responds best to natural language, not keyword lists.
     Instead of: "woman, red hair, blue eyes, photorealistic"
     Write:       "A woman with long red hair and striking blue eyes,
                  standing in soft morning light, photorealistic portrait"
  3. The seed is set to FIXED by default — meaning it generates the same
     image each time. Change the seed number to get a different result,
     or switch the mode to "randomize."
  4. Queue it.

  FLUX TIPS:
  - Flux mostly ignores negative prompts (it doesn't use them like SDXL)
  - Be descriptive and specific — it follows instructions very well
  - Good sizes: 1024x1024, 896x1152, 1152x896

  TO ADD YOUR OWN LORA HERE:
  There are already two LoraLoader nodes. You can connect a third one, or
  temporarily swap one of the existing ones for your trained LoRA to test it.

--------------------------------------------------------------------------------
  C. Image_capybara_v0_1_image_edit.json — Edit a photo with a text prompt
--------------------------------------------------------------------------------

  WHAT IT DOES:
  Image-to-image editing. You give it a photo + an edit instruction, and it
  modifies the image while preserving the subject. Great for:
    - Keep the face, change the outfit
    - Keep the person, change the background
    - Keep the scene, change the time of day
    - Stylize the image (turn a photo into an oil painting, etc.)

  HOW TO USE IT:
  1. Load the workflow.
  2. Find the "LoadImage" node — click it and upload your starting photo.
  3. Find the green "CLIP Text Encode (Positive Prompt)" box.
     Write your edit instruction, e.g.:
       "Keep the person's face, change the outfit to a black tuxedo"
       "Same face, place them on a beach at sunset"
       "Keep the scene, make it nighttime with neon lights"
  4. Optionally edit the red NEGATIVE box (things to avoid).
  5. Queue it.

  SETTINGS YOU CAN ADJUST:
    - Steps: default is 20. Bump to 50 for higher quality (slower).
    - CFG: default is 6. Higher = follows prompt more strictly.
    - Resolution: see the resolution table on the workflow canvas — pick
      one that matches your input image's aspect ratio.

--------------------------------------------------------------------------------
  D. video_ltx2_i2v.json — Image-to-video (turn a photo into a clip with audio)
--------------------------------------------------------------------------------

  WHAT IT DOES:
  Takes a still photo + a text prompt and generates a short video clip
  (with audio). Uses Lightricks' LTX-2 model. Good for:
    - Animating a portrait (subtle facial motion, head turn)
    - Bringing a scene to life (water moving, leaves blowing)
    - Adding speech to a character

  HOW TO USE IT:
  1. Load the workflow.
  2. Find the "LoadImage" node — upload your starting photo.
  3. Find the GREEN positive prompt box. Describe the motion and audio
     you want in detail. Example:
       "A close-up of a young waitress in a retro 1950s diner. Camera
        slowly pushes in toward her face. She tilts her head, smiles,
        and says: 'Welcome to Rosie's. What can I get for you today?'
        Background sounds of clinking dishes and a distant jukebox."
  4. Queue it.

  HEADS UP — VRAM:
  The LTX-2 model is 19GB and your card is 16GB. ComfyUI will automatically
  offload parts to system RAM. It works, but each video takes longer than
  it would on a 24GB+ card. Be patient — 5-second clips can take 5-15 min.

  SIZE RULES:
    - Width & height must be divisible by 64
    - Frame count must be (multiple of 8) + 1 (e.g. 97, 121, 161)
    - Default: 720p (1280x720). Don't go higher unless you want to wait.

  CAMERA LORAS:
  The workflow has two LoRA nodes that are disabled by default. Press
  Ctrl+B on one of them to enable a camera control LoRA (dolly left, etc.)
  Set strength to 1.0 for camera LoRAs.

--------------------------------------------------------------------------------
  E. flux_lora_train.json — Train your LoRA (in ~/lora_training/)
--------------------------------------------------------------------------------

  WHAT IT DOES:
  This is the training workflow. It reads your dataset (images + captions),
  feeds them through Flux Dev thousands of times, and learns what makes
  your subject unique. Outputs a .safetensors LoRA file.

  LOCATION:
  This workflow lives at: $HOME/lora_training/flux_lora_train.json
  You can drag-drop it into ComfyUI to load it.

  HOW TO USE IT:
  (Full walkthrough in PART 5 below)

  TRAINING TIME ESTIMATE (your RTX 5080):
  - 1500 steps with 20 images: ~25-40 minutes
  - 3000 steps with 30 images: ~50-80 minutes
  - Do NOT close ComfyUI or your browser while training

--------------------------------------------------------------------------------

================================================================================
  PART 5 — THE FULL 0-TO-TRAINED-LORA PIPELINE
================================================================================

  Here is the complete process, in order, from nothing to a working LoRA.

  ─────────────────────────────────────────────────────────────────────────────
  STEP 1 — COLLECT YOUR IMAGES
  ─────────────────────────────────────────────────────────────────────────────

  Go find 20-50 photos of the person/style/object you want to train.

  For a PERSON LoRA (most common):
    - Photos of just them, ideally different outfits, locations, lighting
    - Mix of: close-up face, medium shot, full body
    - No group shots (the AI will get confused about who the subject is)
    - No heavy filters or stylized edits
    - .jpg or .png format is fine

  Put all your images in:
    $HOME/lora_training/datasets/my_subject/

  ─────────────────────────────────────────────────────────────────────────────
  STEP 2 — CAPTION YOUR IMAGES
  ─────────────────────────────────────────────────────────────────────────────

  Every image needs a text file describing what's in it.
  The caption must include your trigger word.

  CHOOSE YOUR TRIGGER WORD:
  Pick something unique that won't appear in normal prompts.
  Good choices: ohwx, TOK, sks, xyz123, yourname01
  Bad choices: woman, man, person (too generic — the model already knows these)

  EASIEST WAY: Use LoRA Studio (a small web app for captioning).
  Open a terminal and run:

      ~/lora_launch.sh

  It opens a browser at http://127.0.0.1:4173. Create a project, upload
  your photos, write captions for each, then click EXPORT. This saves:
    - The dataset (images + .txt captions) ready for training
    - A pre-configured training workflow

  After captioning, every image should have a matching .txt file:
    photo001.jpg  →  photo001.txt  (contains: "portrait of ohwx, brown hair...")
    photo002.jpg  →  photo002.txt  (contains: "ohwx standing outdoors, smiling...")

  MANUAL ALTERNATIVE:
  Open each image and write a .txt file by hand with the same filename.
  Tedious but works.

  ─────────────────────────────────────────────────────────────────────────────
  STEP 3 — TRAIN YOUR LORA
  ─────────────────────────────────────────────────────────────────────────────

  You have two options. Use whichever works best for you.

  ══ OPTION A — ComfyUI FluxTrainer (recommended, visual) ══════════════════

  If you used LoRA Studio to caption your images and clicked EXPORT, the
  training workflow was already saved for you. Just load and run it:

  1. Open ComfyUI at http://localhost:8188
  2. Click the Workflows panel (top-right menu icon)
  3. Find:  lora_studio_<yourproject>_train
  4. Click it to load the workflow
  5. Press Queue (Ctrl+Enter) — training begins immediately
  6. Watch the loss graph update. Validation images appear every ~750 steps.
  7. Output saves automatically to:
       $HOME/lora_training/output/<yourproject>/

  ══ OPTION B — Command line (ai-toolkit) ══════════════════════════════════

  Faster to start, no browser needed. Run from a terminal:

    cd $HOME/lora_training
    ./train.sh luna-reyes

  Configs live in:  $HOME/lora_training/configs/
  Currently set up: alix.yaml, persona_template.yaml

  To create a new character config:
    ./new_persona.sh <name> <TRIGGERWORD>
    e.g.:  ./new_persona.sh sarah SARAH01

  ══ MANUAL — Open flux_lora_train workflow directly ═══════════════════════

  Open ComfyUI → load $HOME/lora_training/flux_lora_train.json

  Find these nodes and change the following values:

  NODE: InitFluxLoRATraining
    lora_file_name → change "my_lora" to your subject name
                     e.g. "sarah_v1" or "cyberpunk_style"

  NODE: TrainDatasetAdd (there are 3 of these — change ALL of them)
    trigger_word   → change "TOK" to your trigger word, e.g. "ohwx"

  NODE: StringConstantMultiline (the validation prompts)
    Change to prompts that use your trigger word, e.g.:
    "portrait of ohwx | ohwx smiling outdoors | ohwx closeup"

  ─────────────────────────────────────────────────────────────────────────────
  STEP 4 — RUN THE TRAINING
  ─────────────────────────────────────────────────────────────────────────────

  1. Make sure ComfyUI has loaded normally (no errors on startup).
  2. Press Queue (Ctrl+Enter).
  3. Training begins. You will see:
       - A loss graph updating over time (lower/smoother = better)
       - Validation images appearing every ~750 steps showing what
         the LoRA currently "looks like" — these should gradually
         improve and look more like your subject
  4. DO NOT close the browser tab while training.
  5. When complete, your LoRA saves automatically to:
       $HOME/lora_training/output/sarah_v1.safetensors

  READING THE LOSS GRAPH:
  The loss number tells you how confused the model is. Lower = better.
  - Should steadily go down from ~0.1 toward ~0.01-0.05
  - If it never goes down → captions are wrong or dataset is bad
  - If it crashes to near-zero → overfit (trained too many steps)
  - Slightly bumpy line is normal. Very spiky = learning rate too high.

  ─────────────────────────────────────────────────────────────────────────────
  STEP 5 — COPY YOUR LORA TO THE MODELS FOLDER
  ─────────────────────────────────────────────────────────────────────────────

  After training, copy your LoRA to ComfyUI's LoRA folder:

    cp $HOME/lora_training/output/sarah_v1.safetensors \
       $HOME/ComfyUI/models/loras/flux/sarah_v1.safetensors

  (Or just drag it in a file manager — same thing.)

--------------------------------------------------------------------------------

================================================================================
  PART 6 — USING YOUR LORA AFTER TRAINING
================================================================================

  Once your .safetensors file is in ComfyUI/models/loras/flux/, you can use it.

  IN flux_portrait_v1:
  ─────────────────────
  1. Open flux_portrait_v1
  2. Find a LoraLoader node
  3. Click its dropdown → select your LoRA file (e.g. flux/sarah_v1)
  4. Set lora_strength to 0.7 (start here, adjust after seeing results)
  5. In your prompt, include your trigger word: "portrait of ohwx woman..."
  6. Queue it

  LORA STRENGTH GUIDE:
    0.4-0.6 = subtle, blends with model creativity
    0.7-0.8 = balanced — usually best for faces
    0.9-1.0 = strong likeness, less creative freedom
    Over 1.0 = usually too strong, artifacts appear

  STACKING MULTIPLE LORAS:
  You can use more than one LoRA at once.
  flux_portrait_v1 already has 2 loaded (add_details + AntiBlur).
  You can add your own as a third LoRA. Keep total combined strength under 1.5.

  NOTE: Flux LoRAs do NOT work on SDXL workflows (like X1), and vice versa.

--------------------------------------------------------------------------------

================================================================================
  PART 7 — OPEN WEBUI (AI CHAT)
================================================================================

  Open your browser → http://localhost:3000

  FIRST TIME SETUP:
  Create a local account (username/password — stays on your machine only).

  IF CHAT DOESN'T RESPOND:
  Ollama (the engine behind the chat) might not be running. Open a terminal:

      ollama serve &

  Then refresh the browser. Use `ollama list` to see installed models.

  HOW TO CHAT WITH AN IMAGE (vision models only):
  1. Select a vision-capable model from the dropdown (e.g. minicpm-v)
  2. Click the paperclip/attachment icon in the chat box
  3. Upload any image
  4. Ask questions about it: "What's in this image?" or
     "Write a detailed caption for this for AI training"

  NOTE: When ComfyUI is actively generating, Ollama automatically uses CPU
  instead of GPU. Responses will be slower — this is normal and expected.

--------------------------------------------------------------------------------

================================================================================
  PART 8 — QUICK REFERENCE / CHEAT SHEET
================================================================================

  OPEN COMFYUI .............. http://localhost:8188
  OPEN CHAT (OPEN WEBUI) .... http://localhost:3000
  START COMFYUI (if closed).. run ~/start_comfyui.sh in terminal
  START OLLAMA (if down) .... ollama serve &
  START LORA STUDIO ......... ~/lora_launch.sh
  TRAINING DATASETS ......... $HOME/lora_training/datasets/
  TRAINING OUTPUT ........... $HOME/lora_training/output/
  GENERATED IMAGES/VIDEOS ... $HOME/ComfyUI/output/
  LORAS FOLDER (FLUX) ....... $HOME/ComfyUI/models/loras/flux/
  LORAS FOLDER (SDXL) ....... $HOME/ComfyUI/models/loras/sdxl/

  ─────────────────────────────────────────
  WORKFLOW QUICK PICK
  ─────────────────────────────────────────
  "Generate a cool image fast"                 → X1 (SDXL)
  "Best quality portrait"                      → flux_portrait_v1
  "Edit a photo with a prompt"                 → Image_capybara_v0_1_image_edit
  "Turn a photo into a video"                  → video_ltx2_i2v
  "Use my trained LoRA"                        → flux_portrait_v1 (Flux LoRAs only)
  "Train a new LoRA"                           → flux_lora_train

  ─────────────────────────────────────────
  COMFYUI KEYBOARD SHORTCUTS
  ─────────────────────────────────────────
  Ctrl+Enter ............. Queue / generate
  Ctrl+Z ................. Undo
  Ctrl+O ................. Open workflow
  Ctrl+S ................. Save workflow
  Ctrl+Shift+S ........... Save workflow as new file
  Ctrl+B ................. Enable/disable a selected node (mute toggle)
  Space + drag ........... Pan the canvas
  Scroll wheel ........... Zoom in/out
  Double-click canvas .... Add a new node

  ─────────────────────────────────────────
  SOMETHING WENT WRONG?
  ─────────────────────────────────────────
  Red lines on canvas .... A model file is missing. Check the loader node
                           dropdown and pick a model that exists.
  "CUDA out of memory" ... Close other GPU apps and retry, or reduce
                           image/video size. For LTX-2 video, this is normal
                           on 16GB — ComfyUI will offload automatically.
  Generation is frozen ... Check the terminal where ComfyUI is running for
                           error messages. Usually a missing dependency.
  LoRA looks wrong ....... Strength too high — try reducing to 0.6-0.7.
                           Or overfit — retrain with fewer steps.
  Chat doesn't respond ... Ollama not running. In a terminal: ollama serve &

================================================================================
  END OF GUIDE
================================================================================
