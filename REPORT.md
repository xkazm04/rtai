# perf lane - day run d9 (2026-11-07) - REPORT (in progress; final at 18:40)

Branch `d9-perf` (cut from main `3982af1a`). Full numbers, method and every lever: `docs/perf/LEDGER.md`.
Journal: `JOURNAL.md`. Clips and stills: `C:\Users\kazda\kiro\gtai-masters\d9\perf\` (`frames.json`).

## Calls for the owner

(filled as the levers that move a pixel are measured; each has a default that is already built)

### Call P-1: compress the drawn art as BC7 (a third of the VRAM, no frame cost) - default built: lossless (no change)
- **What:** the 712 textures under `features/{characters,city,vehicles}/art` imported as VRAM-compressed BC7
  (`compress/mode=2`, `high_quality=true`) instead of lossless. One import param per file; 73 s reimport.
- **Buys (measured, bench.lock, `evidence/perf/l4-bc7/ab.json`):** peak VRAM drive 902 -> 573 MB, riot 883 -> 554 MB
  (-37 %); texture memory -65 %; textures load as GPU blocks with no PNG decode (Godot docs rate it "fast" to load vs "slow" for
  lossless; its effect on the first-death hitch is NOT measured yet: NEXT).
  Frame times, GPU ms, draws, CPU and RAM unchanged on this PC (a WASH). On a shared-memory handheld that is
  ~330 MB of RAM back (REQUEST to the handheld lane).
- **Costs:** pixels move. At 64 px/m: the drive's mean difference is 0.9/255 (PSNR 29.8 dB), the riot's 3.9/255
  (PSNR 24.8 dB); by eye the difference sits in the asphalt's print grain (not measured per region); figures and ink lines read the same to me.
  The install grows ~160 MB (BC blocks are not compressed in the pck). Look goldens would need a re-bless.
- **Look at:** `gtai-masters\d9\perf\l4-riot64-lossless-vs-bc7-x2.png` and `l4-drive64-lossless-vs-bc7-x2.png`
  (left lossless, right BC7, centre crop x2).
- **Options:** (a) keep lossless (default); (b) BC7 for characters + vehicles only, keeping the city's ground
  grain lossless (most of the riot's pixel difference; not yet measured on its own); (c) BC7 for all three.
