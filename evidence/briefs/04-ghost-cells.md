# Brief 04 (lane anim, tag ghost-cells): Ohm's cast wind-up, Dent/Ohm hit-from-behind, Kerf's run feet

## Machine law (every Godot run, every gate)
- Before ANY Godot run or gate in a shell: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/anim` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Anything that renders: `--rendering-driver d3d12`. Windowed runs: `--position 0,1440` (secondary monitor, never the main display).
- Only ONE Godot process at a time from this worktree. Free your own processes by PID; never kill by name.
- Never touch `main`, other worktrees, `C:\Users\kazda\kiro\pof`. Never push.
- Repo law: AGENTS.md + STANDARDS.md. Typed GDScript, files <= ~200 lines (hard 300), functions <= 40 lines, <= 5 params,
  `Log` not `print`. Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`.
  Commit `.uid`/`.import` with new files. Run `node tools/gate/quick.mjs` before each commit.
- Ownership: lane anim owns the ghosts' drawn art and its render code (`project/features/souls/art/**`,
  `project/features/souls/ghost_drawn.gd`, `ghost_sheet.gd`, `ghost_recoil.gd`, `ghost_stride.gd` and the other
  render-only ghost view files), `project/features/characters/**`, and `tools/art/**`. NOT yours:
  `project/features/combat/**` (lane ai), `features/player/**` (lane move), sim/replay/parity digests.
  **Render only**: no change to any sim timing, damage, hitbox or attack phase. If a visual needs a sim change,
  it ships behind a launch flag that is OFF (append one line to `KNOWN_FLAGS` in `project/boot/launch_args.gd`).
- Owner's law, do not re-open: the hit lean by blow is kept as built (`GhostRecoil.LEAN_BY_FORM`: Tonnage 4 deg,
  others 12); GhostLunge at its built strength; the soul line on all four ghosts.
- Images are never edited by hand: pack with `tools/art/ghost_pack.py` (or a script under `tools/art/`).
  **Reproduce each committed sheet pixel-exactly with the packer first** (n15 knew the flags: Ohm act
  `--match=180` at 70, `--match=193` at 55; Tonnage act 55 `--match=195.5 --despeck=150`; see
  `docs/day/2026-11-11/hero/JOURNAL.md` lines 16-33) before you add or swap any cell, and assert the untouched
  cells stay byte-identical.

## Delivered art (assets lane, `C:/Users/kazda/kiro/gtai-assets/replies/n15-hero.md` lines 313-365; read them)
- **Ohm cast WIND-UP**, all eight facings, all A:
  p70 right `C:/Users/kazda/kiro/gtai-art/library/keyed/ghosts/ohm_act_70_cells_windup/{1..5}_1.png`,
  p70 left `.../ohm_act_70_left_cells_windup/{1..3}_1.png`; p55 `.../ohm_act_55_cells_windup/{1..5}_1.png`,
  `.../ohm_act_55_left_cells_windup/{1..3}_1.png`. Drop-ins for act column 1 (index 0, `WINDUP_COL`). Packing note
  (reply line ~328): some cells are taller than the cell box (p70 R2 265x208; p55 R1 232 vs cell 219): PAD, never
  scale a wind-up down. Boards: `C:/Users/kazda/kiro/gtai-art/library/evidence/it383/`.
- **Hit FROM BEHIND**, an alternate HIT column (act column 4), five right facings, p70 and p55, all A:
  `.../keyed/ghosts/dent_act_70_cells_hitback/{1..5}_4.png`, `.../ohm_act_70_cells_hitback/{1..5}_4.png`,
  `.../dent_act_55_cells_hitback/{1..5}_4.png`, `.../ohm_act_55_cells_hitback/{1..5}_4.png`. The left octants mirror
  the right (a symmetric stagger: the mirror keeps the blow on the back). p70 Dent R2 is 237 tall (cell 233): pad.
  Boards: `.../library/evidence/it384/`.

## Part A: Ohm's wind-up (p70 + p55)
1. Find out whether Ohm's act column 0 is ever drawn today (`GhostDrawn` says the wind-up column shows "only a form
   whose sim has one, Tonnage's slam"; check `ghost_acts.gd`, `ghost_lunge.gd`, Ohm's cast in the sim/fighter code,
   READ-only for combat/). Write what you find in your report.
2. Pack the eight wind-up cells into column 0 of `ohm_act.png` / `ohm_act_left.png` at both pitches.
3. Make the wind-up SHOW, render-only: if Ohm's cast has a sim lead-in (any ticks between the decision and the bolt),
   draw column 0 over those ticks. If the bolt leaves on the decision tick with no lead-in, then the visual-only
   option is to show the wind-up over the existing GhostLunge ease-in or for the first N ticks of the cut phase
   without moving the bolt tick; pick the one that reads best at 32 px/m and keep the alternative one const away.
   Do NOT delay the bolt (that is a gameplay change; if you believe it is needed, build it behind an OFF flag only).
4. Film before/after (`stride_film --film-form=ohm ...` or `cursor_sweep --sweep-form=ohm`, or `tools/film`): 8
   directions at 64 px/m (a sheet), and a 32 px/m tick strip of one cast. Look and describe.

## Part B: hit from behind (Dent + Ohm, p70 + p55)
1. Add the hitback cells as data (a separate `<name>_act_hitback.png` 1x5 sheet per pitch, or extra act columns:
   your call, explain why). Rule in `GhostDrawn`: when `blow` is known and the blow travels ALONG the facing (the shot
   came from behind; dot(blow_dir, facing) > some threshold you choose and justify), draw the hitback cell instead of
   the HIT cell; left octants mirror the right hitback cell. A form without hitback art keeps today's HIT cell.
   One const (e.g. `GhostDrawn.HIT_FROM_BEHIND: bool = true`) switches it off. `GhostRecoil` stays as built.
2. Unit tests (first-author): the cell chosen for a front blow, a side blow, a back blow, for each facing class;
   a form without hitback art; the const off = before.
3. Film before/after: the existing `stride_film --film-form=<dent|ohm> --film-hurt [--film-blow=...]` (n15 built
   these flags) with a blow from behind, at 64 px/m, profile + toward + away facings. Look and describe: the body
   should lurch FORWARD with the lean, no longer a front recoil pose fighting the lean.

## Part C: Kerf's run feet in all octants (measure only, unless a fix is cheap)
- LEVEL.md "Planted feet" Kerf cell: n15 filmed three octants of his run16 at 32 px/m; worst 2-tick holds 9.0-9.2 px
  (bar: worst hold < 9 px@32), drift 3.0. Film the remaining octants the way Dent's were filmed
  (`docs/day/2026-11-11/hero/JOURNAL.md` lines 228-237: stride_film `--film-turn` 45/90/135/-90/-135, leg 2, the form
  on screen first and last tick; `evidence/s15/tools/run32_films.sh`, `hold_ride.py`). Write
  `evidence/ghost-cells/kerf_run_hold_ride_32ppm.txt` with all 8 octants.
- The assets lane delivered two Kerf run16 alternates (`.../keyed/ghosts/kerf_run16_70_cells_alt/4_8.png`, `4_10.png`,
  reply lines ~300-312, "front foot planted ahead ... 43 % between f5 and f6; v1 was at 77 %"). If the worst holds
  sit in that row/frames, swap them in (script, byte-identical elsewhere) and re-measure.

## For every part
- Frames to `C:/Users/kazda/kiro/gtai-masters/n19/anim/ghost-cells/` (64 px/m before/after stills; 32 px/m strips;
  a 10-40 s 32 px/m clip for A and B). Look at each one and describe it in your report.
- `node tools/tests/run_unit.mjs --changed`, quick gate, one commit per part (art + code + tests together).
- After each code commit: `node tools/mutate/mutate.mjs --file=features/souls/ghost_drawn.gd --lines=<changed lines>`
  and quote killed/(killed+survived).
- If a look golden really contains the changed frame and moves, re-bless only that golden and name it.
- Provenance: add one line per changed shipped PNG to `steam/ai-provenance/2026-11.jsonl` if the earlier ghost
  sheet swaps did (check the file for `ohm_act` / `dent_act` lines and follow that form).

End your report with: files changed, commits (sha + subject), commands run and their result lines, frame paths,
the numbers (Kerf 8-octant table), and anything left undone with the reason.

## Notes added 23:35 (director)
- Known tool limit, verified by the director: `node tools/gate/quick.mjs` FAILS its Godot parse step on many
  files under `features/characters/` and `features/souls/` even when untouched (e.g. `rig_clips.gd`), because a
  standalone `--check-only -s` cannot see the `Log`/`LaunchArgs` autoloads. Do not chase it. Run quick with its
  lint half (`--no-godot` is fine for those files), and prove the parse with `node tools/tests/run_unit.mjs --changed`
  (which imports the whole project) before each commit. A real parse error shows there.
- Time: this session is capped at 75 min. Work A, then B, then C, and COMMIT each part when it is done, so a
  stop mid-way keeps the finished parts. If C does not fit, say so; do not rush A or B.
