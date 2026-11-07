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
- **On a handheld-class iGPU (the handheld lane's E10, answering my REQUEST, 13:27, CONTENDED 1-3, their LEDGER E10):**
  the city's private RAM 1386 -> 898 MB and GPU shared memory 1007 -> 489 MB (about 1 GB back on a shared-memory
  device), render GPU 8.33 -> 7.37 ms (-12 %, unlike the 4090); the King fight saves memory but not GPU time. It pairs
  with their REPORT Call 6 (lossless / BC7 everywhere / BC7 in a handheld build only): one answer can cover both.
- **Costs:** pixels move. At 64 px/m: the drive's mean difference is 0.9/255 (PSNR 29.8 dB), the riot's 3.9/255
  (PSNR 24.8 dB). Per region (measured with option (b), 13:35): the figures' ink outlines carry most of it, not the
  asphalt as I first thought; figures and ink lines read the same to me at x2 and x4.
  The install grows ~160 MB (BC blocks are not compressed in the pck). Look goldens would need a re-bless.
- **Look at:** `gtai-masters\d9\perf\l4-riot64-lossless-vs-bc7-x2.png` and `l4-drive64-lossless-vs-bc7-x2.png`
  (left lossless, right BC7, centre crop x2).
- **Options:** (a) keep lossless (default); (b) BC7 for characters + vehicles only, keeping the city's ground
  and facades lossless: measured 13:16 (LEDGER L4b), riot peak VRAM 867 -> 686 MB (-21 %, about half of (c)'s
  saving), frame times unchanged. Its pixels: the ground and facades exact, the difference only on the figures'
  ink outlines (riot PSNR 26.0 dB vs (c)'s 24.8; by eye at x4 the same: `l4b-riot64-lossless-vs-bc7cv-ink-x4.png`,
  where it sits: `l4b-riot64-frame-and-diff.png`). (b) is not much cleaner than (c) on the figures, so if BC7 at all,
  (c) buys the most; (c) BC7 for all three.
- **Measured on the way:** BC7 does not remove the first-death hitch by itself (worst frame 23 ms without the
  worker-thread strip prefetch, 18-19 ms with it), so the prefetch (kept lever L3) stays whichever option you pick.

## Kept so far (pixel-free, on the branch; numbers in LEDGER)

- L2 CircleFan fan build (riot p99 22.2 -> 11.9 ms), L3 strip prefetch (riot worst 27.2 -> 18.0 ms), L5 snapshot passes
  (-40 % of that pass's CPU, no frame claim), **L8 lossless WebP effort** (14:05): the pck 227.7 -> 215.2 MB
  (-12.5 MB) with every mip of every texture decoding bit-identical; costs ~1.7x texture encode at import.
- Dropped with numbers: L1 renderer/driver, L6 render thread, **L7 a stripped export template** (exe 109 -> 67-74 MB and
  ~-10 MB RAM, but the MSVC build is ~10 % slower a frame than the official MinGW-GCC template, LTO or not).
