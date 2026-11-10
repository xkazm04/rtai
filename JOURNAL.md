# n15-combat JOURNAL

Lane combat, night n15 (2026-11-10 22:00 to 2026-11-11 08:00). Branch `n15-combat`, cut from main `5c5c03611`.
APPDATA for every Godot run: `C:/Users/kazda/kiro/gtai-n15/appdata/combat`.

## Session 1 (iteration 1, 21:58-23:28)

- 21:58 read: brief, common rules, AGENTS.md, tools/README.md, n11 combat REPORT "What does not work",
  last 30 decisions lines. Reply file `gtai-assets/replies/n15-combat.md` is empty (c-2 redraw not yet in).
  No other lane's journal names combat yet.
- FRICTION 22:05: ran the look goldens through `tools/dev/run.mjs` (headless): wrong, headless renders
  nothing. Killed my tree by PID (94744). Re-ran as `node tools/selftest/run.mjs` (windowed, the evidence
  path) for the baseline.
- Registry rules applied: (filled per decision below)
- BASELINE 22:30 (look goldens on the fresh worktree, main 5c5c03611 code with int-day's DLLs, `node tools/selftest/run.mjs`,
  log `build/selftest-baseline.log`): look goldens 11/11 within mean 4 (worst 0.00); block goldens 5/5 (worst 0.69);
  world lock holds; accents on doctrine. So the n14 "worst 0.69" is the BLOCK site and is present on main's code here.
- MILESTONE 22:40 `13a74d4dd` item 2: SWAT hit v4 + elder hit v3 packed (`street_hit.py VERSIONS`, one scale per kind,
  boot-bottom alignment, shift-in instead of bleed). FILL re-measured (swat 1.36, elder 1.20). Both filmed
  before/after at t341-348, 64 px/m: SWAT's carbine now continuous into the fall; elder thrown hard. Shipped.
- FRICTION: re-running `street_hit.py` re-packs 4 shipped burn sheets differently (hood, punk, swat, thug): the
  library's `burn/1_*` cells were re-keyed at 07:02, after n11's 06:58 pack. Restored them with `git checkout`; the
  flail item (next) has to pack frame 1 and 1b from the same (07:02) cells anyway.
- FRICTION / REQUEST tools: `node tools/film/compare.mjs` refuses `--victim=<kind>` ("bad argument"), and
  `film.mjs` refuses it after `--` ("give --victim before the --"), so a lone-victim before/after cannot go through
  compare. I filmed the before by putting the parent's sheet (via `git lfs smudge`) and FILL back for one film, then
  `git checkout --`. REQUEST tools: compare.mjs passes `--victim` through to both sides.
- Registry: no design fork taken yet beyond "ship only what reads better" (brief); judged on film.
- MILESTONE 23:18 `709321330` item 2 (burn flail): `street_hit.py FLAILS` packs `burn/1b` for the 8 BURNS kinds as
  `p70/<kind>_flail_burn_hit.png` (each facing at its `burn/1` cell's scale); `StreetWalkerHit.flail_frame` swaps
  on odd half shakes when `FLAIL_FRAMES` is true. Shipped OFF: not filmed yet. Unit test_street_walker_burn +
  test_street_walker_hit 22/22. CAVEAT: the shipped frame-1 burn sheets for hood, punk, swat and thug were packed
  from the pre-07:02 library cells; the 1b frames are scaled to the 07:02 frame-1 cells. Film both (and the
  repacked frame 1, `python tools/art/street_hit.py` re-makes them) before turning the flag on.
- Gates this session: quick + pre-commit lint on every commit; unit select only. Full unit / scenarios / evidence /
  reels NOT run yet on this branch.

NEXT: (1) film a burning patrol cop and SWAT with FLAIL_FRAMES true vs false (flamethrower or molotov victim,
`film.mjs weapon:flamethrower --victim=...`, 32 + 64 px/m, a 10-40 s clip); keep frame 1 as shipped or repack it
from the 07:02 cells, decide, record DECISION. (2) check `gtai-assets/replies/n15-combat.md` for the c-2 redraw
(item 1, first priority when it lands). (3) item 2 rest: drawn charred cells for a fire death, contractor/cultist
cells (`street_reactions_it321.md`), `dropped_weapons_it325.md`. (4) item 3 baton strike re-cut, etc.
(5) DEFECTS.md #3 (dark streak across the victim t345-348) and #4. (6) run the full gates
(`node tools/gate/run.mjs --rev=HEAD --reels`) once there is a batch. Keep REQUEST tools (compare --victim) open.

## Session 2 (iteration 2, 22:13-)

- 22:13 read JOURNAL, git log. (Session 1's clock stamps ran ahead of the wall clock; commits say 22:02-22:12.)
  Reply file `gtai-assets/replies/n15-combat.md` still empty: no c-2 redraw yet.
- MILESTONE 22:22 `261669f02` item 2: FLAIL_FRAMES ON. Filmed flamethrower lone kill, cop/head_cap and cop/head_swat,
  64 px/m t380-420 (fire 341, kill 542; victim is fighter id 1, not the probe's first "hostile"): arms alternate on the
  odd half shakes (394-398, 414-418), no size seam vs frame 1, also on SWAT (older frame-1 pack). Frame 1 kept as
  packed. Clip 32 px/m in masters. DECISION combat/burn-flail-2.
- MILESTONE 22:40 `b8da0a47f` items 2+3: the navy cop pistol (it325 cell 1, `dropped_gun.py --cop`, part
  `dropped_cop`) drawn by ShockArcsView; `--dropped-gun=pale` the before. Filmed electro_gun stun 64 + 32 px/m.
  DECISION combat/dropped-cop-pistol. Owner Call (it was an open n14 call).
- FRICTION: `GODOT_BIN` is not set in a fresh Bash; export it before a raw `--import`.
- MILESTONE 22:28 `42c826289` + `108ec888c` item 3: p55 baton strike cells re-cut (act_k 1.0; wind-up sheet_k 0.2632).
  compare HEAD~1 vs HEAD, chapter electro_baton --view=tilt t54-70: no more shrink into the swing. DECISION
  rivet/baton-p55-strike-size. (Registry not consulted: a size-match fix, no design fork.)
- MILESTONE 22:42 `a76c26f9a` + `6486e5e59` item 3: the baton's drawn left strike (it334) at p70/p55, one cell past the
  left wind-up; `--rivet-left-strike=off` the before. First cut hid the held part and a stale RivetSwipe wedge lingered
  t90-104: fixed by counting the strike as "left" in hides_held. DECISION rivet/baton-left-strike.
- Films of a director extra chapter: `film.mjs chapter:electro_baton -- --chapter=electro_baton_left` (ArenaArgs: last
  value wins; the log line `director chapter electro_baton_left` proves it). REQUEST tools: film.mjs/compare.mjs
  should list ReelChapters.extras() (`<blade>_left`, `<blade>_cam`) as chapters.
- DEFECTS.md: session-2 films added; top open = the game melee smear's flat white hexagon slab.
