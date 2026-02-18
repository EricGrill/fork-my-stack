# TOOLS.md (Template)

Local operational notes. Keep this file practical and updated.
Do NOT store secrets here.

## Machine / Server Notes

### MAIN_MACHINE
- Role: daily driver
- OS: macOS/Linux/Windows
- Notes: local dev and chat runtime

### GPU_MACHINE (optional)
- Role: Ollama inference
- GPU: YOUR_GPU
- Notes: keep models warm for faster response

## Platform Formatting Rules

- Discord: avoid markdown tables, use bullets
- WhatsApp: lightweight formatting, short blocks
- Slack: use concise summaries with actionable next steps

## Image Generation Setup

- Provider: YOUR_IMAGE_PROVIDER
- Model: YOUR_IMAGE_MODEL
- Defaults:
  - hero images: 16:9
  - inline images: 1:1 or 4:3
- Prompt style: clear subject + style + lighting + composition

## Blog Publishing Workflow

1. Generate daily post ideas
2. Draft outline
3. Create hero + inline images
4. Assemble markdown
5. Publish via your CMS/API
6. Post summary to your channels

Tip: automate steps 1, 3, and 6 with cron + tools.
