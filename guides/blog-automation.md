# Blog Automation Guide

This is a practical workflow for shipping content consistently with automation.

## 1) Daily content pitches via cron

Use a daily cron to generate 3-5 relevant content ideas.

Example:
- input: recent project updates, notes, and trends
- output: publishable pitch list with audience + CTA

See: `crons/daily-content-pitches.json`

## 2) Image generation via AI

For each article, generate:
- 1 hero image
- 2-3 inline images

Prompt pattern:
- topic + audience + visual style + composition + aspect ratio

Automate image generation as a cron step or pipeline stage.

## 3) Auto-publish pipeline

Typical pipeline:

1. Idea selected
2. Outline generated
3. Draft expanded
4. Images generated
5. Markdown packaged
6. Publish to CMS/API
7. Share to channels

You can run this fully automated or keep a manual approval gate before publishing.

## 4) Weekly build log setup

Run a weekly cron to summarize:
- what shipped
- what got blocked
- what changed in direction
- what’s next

See: `crons/weekly-build-log.json`

---

My recommendation:
- start with daily pitches + weekly build log
- add auto-drafting next
- add auto-publish only after your review loop is solid
