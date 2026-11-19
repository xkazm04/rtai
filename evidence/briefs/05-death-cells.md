# Brief 05 (lane anim, tag death-cells): wire the delivered death cells that never landed

## Machine law (every Godot run, every gate)
- Before ANY Godot run or gate in a shell: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/anim` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Anything that renders: `--rendering-driver d3d12`. Windowed runs: `--position 0,1440` (secondary monitor, never the main display).
- Only ONE Godot process at a time from this worktree. Free your own processes by PID; never kill by name.
- Never touch `main`, other worktrees, `C:\Users\kazda\kiro\pof`. Never push.
- Repo law: AGENTS.md + STANDARDS.md. Typed GDScript, files <= ~200 lines (hard 300), functions <= 40 lines, <= 5 params,
  `Log` not `print`. Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`.
  Commit `.uid`/`.import` with new files. Run `node tools/gate/quick.mjs` before each commit.
- Ownership: lane anim owns `project/features/characters/**` (the death/kill cell PNGs in `art/view/p70|p55/`, the
  kill-cell view code there) and `tools/art/**` (`kill_cells_pack.py`, `kill_cells_size.py`, `kill_cells_tone.py`).
  The `cells` entries in `project/data/tables/signature_kills.json` are the art wiring of these cells: you may add
  grid entries there (data only; no change to damage, timing, slide or any gameplay field). NOT yours:
  `features/combat/**` (lane ai), `features/combat/weapons/**` and weapon tables (lane guns), `features/player/**`.
  If wiring needs a code change outside anim's files, stop and describe it in the report.
- Render only: no sim/replay/parity digest moves. Owner's laws: red is blood only; cops are blue; the dropped rifle lies
  0.5 m from the body; do not invent new deaths.
- Never edit an image by hand; pack with `tools/art/kill_cells_pack.py`. Before packing a new grid, reproduce one
  committed grid with the packer byte- or pixel-exactly (e.g. `p70/cop_patrol_claw_throw.png`) so the flags are known.

## What is owed (from `docs/day/2026-11-11/kills-new/REPORT.md` lines 31-34 and 66-80, and
## `C:/Users/kazda/kiro/gtai-assets/replies/n16-kills-new.md` / `n16-kills-polish.md`; read them)
A. **claw_throw p55, patrol / riot / SWAT**: delivered (it438) and packed once, then removed from the tree; under the
   55-degree view the claw plays the p70 cells. Rebuild with `kill_cells_pack.py --death=claw_throw --art=p55`, add
   `cells.grids.p55` (cop/head_cap, cop/head_helmet, cop/head_swat), provenance lines (follow the p70 claw lines in
   `steam/ai-provenance/2026-11.jsonl`), a p55 assert in `test_kill_throw_art`, import the PNGs (commit `.import`),
   film `kill:claw_shock --view=tilt --ppm=32` (`tools/film/film.mjs`), and check the 4.2 m slide reads under 55.
   Sources: `C:/Users/kazda/kiro/gtai-art/library/keyed/street/cop_{patrol,riot}_claw_throw_55_cells/` (and the
   `_55_area_cells` variants: find which the earlier pack used, the n16 JOURNAL says), SWAT's equivalent.
B. **claw_throw p70 for 9 more kinds** (hood, cap, punk, jogger, worker, shopper, elder, hat, thug): delivered after
   the n16 freeze (it442/it446), not wired; today they play the placeholder. Pack and wire each kind that has a p70
   grid; the shopper draws no dropped bag (leave as drawn, note it).
C. **molotov_torch p55, patrol / riot / SWAT**: delivered 18:37-18:46 (n16), not wired (the 55 view plays p70).
D. The director's list also names "the lying, worker and gang burn cells that exist but are not wired". Find them:
   compare the library (`gtai-art/library/keyed/street/*burn*`, `*char*`, `*collapse*`, gang kinds) and
   `gtai-assets/replies/n16-kills-polish.md` against what `art/view/p70|p55/*burn*`/`*char*` and the tables wire.
   List each set: delivered / packed / wired, then wire what has a source and a grid.

Work A, then B, then C, then D; each one is finished (packed, wired, test, film, looked at, committed) before the next.

## Per set
- Byte-identical guarantee for every grid you do not mean to change (the packer or a check script asserts it).
- Unit: extend the kill-art tests (`test_kill_throw_art`, the molotov/burn art tests) so the new grid is required.
- Film before/after at the same tick: `node tools/film/film.mjs kill:<weapon> ...` (A and C with `--view=tilt`), 64 px/m
  and 32 px/m, plus a 10-40 s 32 px/m clip for A. Stills and clips to `C:/Users/kazda/kiro/gtai-masters/n19/anim/death-cells/`.
  Look at every still and describe it in your report (right kind, right colours, feet/body registered, no seam, no
  cell clipping, red only for blood).
- `node tools/tests/run_unit.mjs --changed`, quick gate, commit per set. If a look golden really contains the death and
  moves, re-bless only that golden and name it.
- After the last code commit (if any GDScript changed): `node tools/mutate/mutate.mjs --file=<that file> --lines=<changed>`.

End with: per set delivered/packed/wired before and after, commits, commands and result lines, frame paths, and what
remains owed with the reason.

## Notes added 23:45 (director)
- Known tool limit: `node tools/gate/quick.mjs` FAILS its Godot parse step on many untouched files under
  `features/characters/` (standalone `--check-only -s` cannot see the `Log`/`LaunchArgs` autoloads). Do not chase it:
  use quick's lint half (`--no-godot`) and prove the parse with `node tools/tests/run_unit.mjs --changed`.
- 75 min cap: commit each set (A, B, C, D) as it finishes. If D does not fit, list what you found and stop.
