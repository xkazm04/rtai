# n31 ghost 03 - Tonnage's deploy drawn in four readable beats (arrival, charge, dump, aftermath)

Builder tag: `g03-beats`. **Commit each finished part by 25 minutes into the call; hard stop 60 minutes after launch: commit what passes, report, END.** Never end with a commit sitting in the pre-commit hook.
Worktree (your cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Read `AGENTS.md` first, then `evidence/briefs/n31-ghost-02-drop.md` (the mechanics this draws) and `git log --oneline -15` (its commits).

## Why (owner, verbatim)
"The animation of ghost deployment and effect needs more detailed worked." Today the deploy is under a second: one held pose, one ink ring, a crack. After item 2 the deploy is: one press -> Tonnage present -> a `charge_s` (0.45 s) wind-up in which foes can walk out -> the dump on a full circle of `radius_m` -> aftermath. A player at 32 px/m must be able to read each beat without a UI marker.

## The four beats (each needs its own drawing on screen)
1. **Arrival** (press tick, ~6-8 ticks): he lands with weight: a drop shadow that grows from small to full under him before he touches, a landing squash cell, dust kicked outward on the ground (world dust colours: soot grey / tan, NOT teal).
2. **Charge** (the whole charge): the press rises / the body winds up across the charge (at least two distinct cells or a continuous rig pose ramp), and the **circle's edge is announced on the ground by the effect itself**: cracks crawling outward from his feet reaching the true radius at the dump tick, or a dust ring creeping out; this is the telegraph (counterplay: foes walk out). No dashed UI ring, no marker.
3. **Dump** (dump tick): the slam cell, a shock ring that reaches the TRUE damage radius, ground cracking to the radius, debris, a screen kick through the existing hit-feel table (`camera.json` shake / hit-stop ids already used by the stomp; add none outside souls without a NEED).
4. **Aftermath**: a crater decal that stays a few seconds (2-4 s) and fades; Tonnage fades or lifts away.
Teal stays for the ghost body only; dust, cracks, debris, crater are world colours (ink, soot grey, tan, concrete). Colour law: red blood only, vermilion only danger/collar, amber heat/fire/current.

## Where things are (verify)
- Body: `features/souls/ghost_deploy_body.gd` composites the rig (`TonnageRig`) in a 768 px viewport at the spot; `ghost_drawn_acts.gd` (act grid: cols windup/cut/follow/hit, 5 facing rows, `deploy_age`); sheets `features/souls/art/view/{p55,p70}/tonnage_act*.png` (+ `tonnage_spectral_*` if the spectral look is on in play: find which sheet the GAUNTLET actually shows at 32 px/m tilt 70 before drawing anything; say which, with a still). Sheet loader `ghost_sheet.gd` (five rows of cells; the log on main warns `p70/ohm_spec_hover.png needs five rows of square pose cells`, not yours here).
- Effect: `ghost_deploy_effects.gd` -> `HaulerMarks.draw` (`hauler_marks.gd`: ink shock ring over 0.4 s, `stomp_crack.png` at `CRACK_SCALE` 1.3 sized for 4 m, `SlamDebris`). The crack art spans +-3.1 m at scale 1: it must be re-scaled or re-made to reach the deploy's `radius_m` (the Q-form stomp keeps its 4 m marks: do not change its look; give the deploy its own path or a radius-driven scale).
- Past packing: commit `6b9b6de42` (Tonnage p70 HIT column replaced from new cells, "Packed --match"): read how it was done (`git show --stat 6b9b6de42`) and reuse that tool.

## Art (Codex image tool only, via `C:\Users\kazda\kiro\gtai-art\gen.mjs <roundDir>`)
- Round dir: `C:\Users\kazda\kiro\gtai-art\ghost-n31\tonnage-beats\` (`jobs.json`: `{style, jobs:[{name, track, refs:[file in refs/], prompt}]}`; out to `out/<name>.png`). Known fault: a job can stall copying to `./out` after the image exists under `~/.codex/generated_images/` — copy it by hand at once.
- **Edits of the shipped sheets, one row or cell per job, a reference each** (crop the row of the sheet the gauntlet shows into `refs/`). Cap for this call: **16 images**; the lane total cap is 60 (write the count in your report). If the tool answers with a usage limit: stop generating, report `BLOCKED images`, and finish the beats with what exists (rig pose ramps, drawn-in-code effects from the existing crack art).
- Keep a resumable state file `ghost-n31/tonnage-beats/state.md` (which jobs done, which packed, which rejected and why).
- Every new cell gets a **64 px/m in-game still BEFORE its commit** (the print path can change a colour: check it reaches the screen).
- Record every generated image in `steam/ai-provenance/2026-11.jsonl` (append-only, one line each, copy an existing line's format).

## Measure in the delivered frames
- The drawn shock ring / crack reach equals the damage `radius_m` to +-0.25 m, measured in a 64 px/m frame of the dump tick (state the pixel radius and the metres).
- Name the tick window in which each beat is live (press tick + n) before filming it; stills at those ticks.

## Evidence (in this call)
- A still strip of the four beats at 32 px/m tilt 70 and at 64 px/m (one image each, labelled), to `C:\Users\kazda\kiro\gtai-masters\n31\ghost\`.
- A 64 px/m clip of the whole deploy at half speed (15-40 s with lead-in; ffprobe the length).
- Use `tools/film/*` or a probe scene under `project/dev/ghost_n31/` through `node tools/dev/run.mjs` (all Godot through runGodot; windowed runs `--position 0,1440`, `--rendering-driver d3d12`).

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every Godot command. **Lane Godot lock** `build/n31/godot.lock` (wait for it, write `g03-beats <pid>`, delete yours after; never delete another's).
- Allowlist: `project/features/souls/**`, `project/dev/ghost_n31/**`, `project/tests/unit/test_ghost_deploy*.gd`, `project/tests/unit/test_tonnage_*.gd`, `steam/ai-provenance/2026-11.jsonl` (append), `docs/decisions.md` (append one line per decision), `C:\Users\kazda\kiro\gtai-art\ghost-n31\**`, `C:\Users\kazda\kiro\gtai-masters\n31\ghost\**` (films/stills only, no scripts), `build/n31/**`. Anything else (kills folder, `kill_styles`, `camera.json`, `combat.json`, other lanes' files, `tools/**`): STOP and write a NEED in your report.
- Typed GDScript, ~200 lines/file (hard 300), <= 40 lines/function, <= 5 params, `Log` not `print`, no global rand, ticks not delta. New `.gd` -> `--import` via runGodot, commit the `.uid`; new png -> commit its `.import`.
- Fix lint and format findings in your own edit and go on. Stage per path, `git commit -- <paths>`; no add -A/./-u, no stash, amend, rebase, reset --hard; never skip the hook (~12 min budget; a fail on `kill_reel_*.break.test.mjs` = stale class cache: `--import` and commit again). Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Mutate on the main changed effect file: `node tools/mutate/mutate.mjs --file=<file> --max=20 --lines=<changed> --tests=<basenames>` only if time remains; else "not run".

## Report (final message)
Which sheet the gauntlet shows, images generated (n, names, accepted/rejected), cells packed, files and commits, the beat tick windows, the radius check (px, m), still/clip paths, ffprobe length, NEED lines, what you would do next.

## Added 22:05 after the prep call (`g03a-prep`) - read `C:\Users\kazda\kiro\gtai-art\ghost-n31\tonnage-beats\state.md` FIRST
- The deployed Tonnage in the gauntlet shows the p70 SPECTRAL sheets (`view/p70/tonnage_spectral_pose.png` in the charge, `tonnage_spectral_act.png` from the dump), 4 x 5 cells of 384 x 320, feet at y 315; chain with file:line in state.md. Today the charge holds CARRY (no wind-up), there is no telegraph, the effects stop at P+81 (crack cut short), and the ground ring has teal.
- Director decisions: lock the deployed body to row 0 (toward camera); a new 5-cell strip `view/p70/tonnage_spectral_drop.png` (land squash, charge gather, charge peak, slam, lift-away) with the shipped cells as fallbacks; feed charge progress into the pose's wind-up first (works with shipped cells, no art); the deploy's effects get their own record (spot, dump tick, radius) so the crater outlives the ghost (2 s hold + 1 s fade); ground art world colours only (no teal ring for the deploy; the Q stomp keeps its marks); a single-cell packer script under `tools/ghost/` (not tools/art).
- The image round (8 jobs: b1-b5 body, fx-crack-radial, fx-crater, fx-dust-ring) was started at 22:03 by the director; outputs land in `ghost-n31/tonnage-beats/out/`. Check `gen.log`; do NOT re-run jobs that exist; review each output against its ref before packing; regenerate at most 6 (one per rejected job, a reason in state.md). The cap of 16 for this call includes the 8 already run.
- Beat windows to implement (P = press, D = P+27): drop P..P+5, squash P+6..9, gather P+10..18, peak P+19..26, telegraph cracks P+6..D reaching radius_m exactly at D, slam D..D+4, shock ring D..D+24, lift D+5..14, lift-away D+15..P+81, crater D..D+180.
- The radius is 6.5 m (g02 changes the row); read it from the row, never a constant.
