# RTAI: Uprising logo (REL M04)

**`rtai_logo_master.jpg`** is the owner's pick, 2026-11-05 22:20. It is "prompt 4, the title lockup", from five logo prompts that the owner ran in Leonardo; the model was not recorded. The file is kept byte for byte as downloaded: 1024x1024, sha256 `9e5e14b0…aa9bd8`.

Everything else is derived from it by code, with no hand edits:
- `../icons/rtai_shortcut.ico` and `project/icon.ico` (the exe, desktop and taskbar icon):
  - 16, 24 and 32 px are the visor head, cropped at (300,30)-(724,454), because the letters blur at those sizes;
  - 48, 64, 128 and 256 px are the full logo.
- `../icons/rtai_shortcut_512.png`: the Steam shortcut icon.
- `../icons/rtai_app_184.jpg`: the Steam app icon (no alpha).
- `project/icon.png` (256 px): Godot's `config/icon`.

Still to do for M04: a transparent library logo (1280 wide), which needs the cream paper keyed out.

## Prompt (Leonardo)
```text
Original video game title lockup on plain warm cream paper. The exact text "RTAI" in massive blocky riveted-steel capitals printed in violet-black ink, the letters cracked and scorched as if welded together from scrap plate. Rising from behind the letters, the front-facing head and shoulders of a tall exhausted welding robot: welder-mask visor with two thin teal slit eyes, vermilion hazard-striped collar. Thin wisps of translucent teal ghost-smoke stream out of the holes inside the letters R and A, forming four small robot ghost faces. Below the letters, the exact word "UPRISING" stamped in vermilion like an office rubber stamp, slightly crooked. Two-ink risograph print: halftone dots, misregistered plates, paper grain, bold outlines, flat shapes, wide margins. Palette only: cream F2E8D5, vermilion E8502A, teal 1FB5A8, violet-black ink 17131B. Only the text "RTAI" and "UPRISING", nothing else written, no watermark.
```
Negative prompt: `photorealistic, photograph, 3D render, gradient, glossy, chrome bevel, drop shadow, extra letters, misspelled text, blurry text, real logos, watermark, signature, busy background, human face`.

The model left out "UPRISING", so the master shows only "RTAI".
