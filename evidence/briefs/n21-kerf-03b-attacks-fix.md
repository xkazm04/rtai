# n21-kerf brief 03b (--resume of attacks): what the director still sees in the 14:27 strips

Same rules and allowlist as brief 03. **Wall-clock hard stop: HARDSTOP. Commit deadline: COMMITBY.** Fix lint and
format findings in your own edits and go on. Never amend, never rebase. Stage per path. Mutate `--max=20` on
changed lines. `export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/kerf` before every Godot run. One Godot process
at a time; free your own by PID. Any path outside brief 03's allowlist: stop and write `NEED <owner>: <file> <why>`.

## Resolved since brief 03 (do not touch again)
Overhead charge count (re-shot board reads 3/2/1/0), the zigzag along the slot (86c6743ca), the cutting blade
past the helmet on the arrival frame (196e96d77), the echo at 35 percent (42c78b422), COCK over HIT (4174e2a73).

## Still wrong (seen in `slice_strip_top_32.png` and `slice_strip_70_32.png`, 14:27)
1. **The victim is hidden at +15.** Top view, frame 111/+15: the Ronin's curled ribbon lies across the fallen
   officer (strip x ~1190..1230, y ~110..150). Tilt 70, frame 111/+15: the Ronin's body and left crescent cover
   the officer almost completely; only an arm shows. The owner's rule: the victims stay visible. Fix it view-only
   for the slice's reaction window (from the press tick until the victim's reaction ends, or 30 ticks): either the
   victim draws above the Ronin, or the Ronin's parts that overlap the victim (ribbon, near crescent) draw at about
   45 percent alpha. Your call, inside your allowlist (`kerf_*`, KerfVictim's call sites); say which in the final
   message. No sim position, facing or digest may move. Prove it with a unit test (the overlap rule or the z order
   during the window, and back to normal after it).
2. **Two pale bars beside the victim at +15** (top strip, x ~1190..1230, y ~110..135; also a pale stub at the
   victim in tilt 70 +15, x ~1185, y ~125). Find what draws them. If they are your sparks: sparks are small motes
   ON the straight slot line only, never off it and never within the victim's radius + 0.3 m at any tick (the
   victim moves after the press: test against his drawn position, not the press-tick one). If they are not yours
   (a shared hit mark, a dropped weapon), say what they are and leave them.
3. Re-shoot `slice_strip_top_32.png`, `slice_strip_70_32.png`, `slice_before_after_top_32.png`,
   `kerf_attack_32.mp4` (+poster) and `kerf_close_64.mp4` (+poster) on the final code. Quote the legacy byte
   compare and the scenario digests before/after (unchanged).

## Final message
Commits, what 1 and 2 were and how each was fixed, test counts (`run_unit.mjs --changed`), digests, mutate
scores, evidence paths, anything undone.
