# n14 wind-up follow-ups - builder brief (2026-11-10)

Branch `n14-windup-more`, worktree `C:\Users\kazda\kiro\gtai-wt\n14-windup-more`, cut from main
`63088ade9` (n13-weapon-art merged). Native DLLs in `project/native/bin/` are the newer build copied
from n13 (the main checkout's are stale): do not rebuild or replace them.

The owner's verdicts on the n13 report (all director's picks): keep everything n13 shipped, and
build these three follow-ups. Background: `docs/night/2026-11-10/weapon-art/JOURNAL.md` (item 4 and
`## Report`), `docs/art/requests/windup-cells.md`, `docs/night/2026-11-10/weapon-art/ASSETS-REPLIES.md`
(the asset lane's delivery: every path is under `C:\Users\kazda\kiro\gtai-art\library\`; read its
`deliveries/blade_windup_it309.md` incl. "it313 + it317 additions"). The n13 code: `RivetWindup`
(`project/features/characters/rivet_windup.gd`), `tools/art/rivet_windup_cells.py`,
`rivet_windup_cells.json`. On main, `RivetFrames.step` now also chains `RivetStrike` (n11 bare-claw
strike grid, weapon == "" only) after `RivetWindup`; they never overlap. `rivet_frames.gd` is at
exactly 200 lines: do not grow it (debt ratchet); put new logic in RivetWindup.

Films and stills: `C:\Users\kazda\kiro\gtai-masters\n14\windup-more\` with a `frames.json` of n13's shape.

## Repo law (AGENTS.md / STANDARDS.md - read both first)
- Stage per path. No `git add -A`/`.`/`-u`, no stash, no `reset --hard`. Commit each item as it lands.
- Typed GDScript, files about 200 LOC (hard 300), functions 40 lines or fewer, 5 params max. `Log`, not `print`.
- Data is JSON with a schema; commit `.import`/`.uid` with every new asset; every new PNG gets a
  line in `steam/ai-provenance/2026-11.jsonl` (a unit test checks weapon art; do it for all).
- No global RNG, no frame delta outside `World._process`. View only: the sim and parity untouched.
- Godot windows open on the secondary screen: `--position 0,1440`.
- Planted-fault runs (`tools/mutate/mutate.mjs` or hand plants) must leave the checkout clean; if a run
  is interrupted, restore the file by path before anything else.

## Lane rules (as n13)
Audit on film first; every change keeps a before (flag or data row); look goldens stay at 0.00 unless
an item intentionally changes a frame they show (name it, show it, re-bless only that one); new art is
warmed behind the load screen (RivetStripWarm) and checked with `tools/perf/fight_gate.mjs` against its
A/A twin (the machine is contended: judge by the paired CI); a blade wind-up ships on only if its
anticipation (melee.md 1-5) rises by at least 1 with no pop or flicker, else it ships off with the film
that shows why. Return questions instead of guessing.

## Items
1. **Boss-view (p55) wind-ups** for the plasma sword, katana and electro baton: lay the delivered p55
   pairs (`keyed/rivet/rivet_eq_{weapon}_55_windup.png`, side + cam) into p55 wind-up strips through
   `rivet_windup_cells.py` (re-tone to Rivet's plates as n13 did), fit scale and anchor per cell by
   eye against the p55 facings and strikes, and film each blade in a boss fight (the 55-degree view)
   before / after.
2. **The baton's left-side wind-up**: the delivered `rivet_eq_electro_baton_70_left_windup_v2.png`
   (p70; and p55 if the lane drew one). Add the second slot in RivetWindup (a left wind-up strip used
   where `RivetFrames.LEFT[oct]` picks the left strip for a one-hand weapon), film the baton facing
   left before / after.
3. **Chainsaw wind-up** (the owner took this offer; the sword spin-coil was declined): wire the
   delivered chainsaw p70 cells (`rivet_windup_70_cells/chainsaw_{side,cam}.png`) and p55
   (`rivet_eq_chainsaw_55_windup.png`) the same way, film both views, score anticipation (n12 audit:
   chainsaw 3).

## Gates before the final report
lint, full unit, `node tools/tests/run_scenarios.mjs`, parity bit-exact, look goldens, debt, the fight
gate. Unit tests for new logic; planted-fault scores on changed .gd files, quoted with what they covered.

## Report
Keep `docs/night/2026-11-10/windup-more/JOURNAL.md` as you go; end with `## Report`: per item on/off,
anticipation before -> after per blade and view, the before switch, stills and films, gates, perf,
planted-fault scores, owner calls. Do not merge, do not push.
