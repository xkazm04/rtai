# REPORT: night lane `brutality` (2026-11-04, 01:xx-08:40, updated for the 09:00-11:00 extension)

Branch `n-brutality`, head of record `88ff881d` (code; was `63cc3ce1` at 08:40) + docs commits. Evidence in two places:
`M` = `C:\Users\kazda\kiro\gtai-masters\n4\brutality\` (clips, frames, `frames.json`, 15 entries)
and `E` = `evidence/brutality/` in this worktree (logs, telemetry, sheets). What changed after
09:00 is collected under **After 09:00** at the end. All performance numbers
are **CONTENDED** (six lanes on one GPU); none was taken under `bench.lock`.

## What works

**Framework** (`project/features/combat/kills/**`, `data/tables/signature_kills.json` + schema, 11 rows)
- Kill event (`KillEvent`: weapon id, damage type, hit point, direction, victim rig) is taken from
  gunplay's `kill_landed`; `BrutalityHook` replaces the standard death on a matching row and vetoes
  the standard d5-combat death blood (`CombatBlood.veto`) under a signature kill.
- One data row per kill: parts, impulses, effects, kill-beat timing, plus optional columns (`cut_deg`,
  `spray`, `grind_ticks`, `hat_kick_mps`). Pooled gib parts (`GibSim`, `GibCut`). Corpses and leftovers
  persist with a budget, each kill gets its own ground print (`KillGround`).
- Determinism: gib physics run on the 60 Hz tick and use the RNG registry. Unit
  `project/tests/unit/test_signature_kills.gd` covers same seed giving the same gibs, a planted 1 %
  gib-speed fault being caught, reduced gore, robots and the budget. The scenario
  `project/tests/scenarios/scenario_brutality_kills.gd` covers rocket, hand cannon, flame, the
  charged electro gun, claw shock, the blades and the nuke: same seed, same state, the replay is
  identical, and the planted fault is caught. Results: `E/brutality-kills.json`,
  `E/scenario-brutality-it12.log`.
- `--gore=full|reduced`: with reduced gore there is no signature kill and the victim falls whole
  with the standard death (`M/clips/rocket-gore-reduced-arena-48ppm-10s.mp4`,
  `E/lab-rocket-gore-reduced-48-telemetry.json`). With `--reduced-motion`, ink flashes, the X-ray
  strobe, the ray echoes and the nuke flash are dropped or held under the screen-flash budget.
- Live paths: the hook runs in `CombatArena` (arena `--arena`, and the city proving block
  `--arena=city --rigs`). The dev lab `--sig-lab --sig-gun=<id> [--sig-solo=start:dx,dy]` only
  stages the victims. The arena station is `data/tables/arena_stations/brutality.json`.

**The eleven kills, all one-shot on the real cast cop rig, each with a clip on the city block:**

| # | Kill (row) | Best evidence |
|---|---|---|
| 1 | Rocket gib (`rocket_gib`): 4-6 rig parts with stumps, spin and bounce, red spray, ink splat, scorch | `M/clips/rocket-gib-solo-64ppm-slow-0.4x.mp4`, `M/clips/rocket-gib-city-block-48ppm-13s.mp4` |
| 2 | Hand cannon blowback: off his feet, flies back, smear slide, the cap spins off, stops at walls | `M/clips/hand-cannon-blowback-solo-64ppm-slow-0.4x.mp4`, `M/frames/hand-cannon-bodies-stop-at-wall-32ppm.png` |
| 3 | Flamethrower char: runs ablaze, charred silhouette, ash flakes onto a heap | `M/clips/flame-char-solo-64ppm-slow-0.4x-it8.mp4`, `M/frames/flame-char-ash-heaps-64ppm.png` |
| 4 | Electro (charged gun shot and claw shock): convulsion, X-ray skeleton held 4 ticks, collar smoke, stiff drop into the death plank (the rig's own death pose) | `M/clips/electro-plank-city-64ppm-slow-0.4x-it18.mp4`, `M/clips/electro-plank-city-48ppm-8s-it18.mp4`, `M/frames/electro-xray-held-flash-64ppm-60fps-strip.png` |
| 5 | Katana: diagonal cut, two halves clearly apart, blood fanning along the cut | `M/clips/katana-city-64ppm-slow-0.4x-it12.mp4` |
| 6 | Plasma rifle: ember-ringed hole, a look at the hole, a topple back along the shot, the bolt flies on | `M/clips/plasma-hole-city-32ppm-7s-it11.mp4`, `M/clips/plasma-hole-topple-solo-64ppm-slow-0.4x-it9.mp4` |
| 7 | Chainsaw: grind (held, shaking, continuous spray), then the split | `M/clips/chainsaw-city-64ppm-slow-0.4x-it12.mp4` |
| 8 | Plasma sword: katana split with cauterised glowing edges, no blood | `M/clips/plasma-sword-city-64ppm-slow-0.4x-it12.mp4` |
| 9 | Ray gun: rings dissolve him into a dust drift with the empty uniform, cap knocked aside | `M/clips/ray-dissolve-city-64ppm-slow-0.4x-it11.mp4` |
| 10 | Homing shard: a fan of crystals in red wounds, then a pop into parts, mist and spray | `M/clips/homing-shard-fan-solo-64ppm-slow-0.4x-it9.mp4` |
| 11 | Mini-nuke: everyone in the radius becomes a charcoal shadow in a scorch ring | `M/clips/mini-nuke-pack-city-48ppm-9s-it10.mp4`, `M/clips/mini-nuke-pack-city-64ppm-slow-0.4x-it10.mp4` |

- Reels: `M/clips/city-reel-all-11-kills-clean-48ppm-it18.mp4` (game-city, all eleven, no dev HUD,
  78 s, labelled; the electro chapter re-shot at 09:10; sheet `E/city-reel-all-11-clean-it18-sheet.png`), the melee kills at game zoom
  `M/clips/city-reel-melee-3-kills-32ppm-it12.mp4`, and the arena solo reel
  `M/clips/signature-kills-solo-reel-48ppm-39s.mp4`.
- The Director's 04:00 checkpoint is done: each kill was re-shot on one isolated victim, the blade
  kills show two clearly separated halves, the electro skeleton flash is visible, the rocket's
  first-frame spike is fixed (see below), and the homing shard and nuke were finished.

**Frame cost (kill-view CPU, CONTENDED, 60 fps fixed captures, city block 48 px/m)**
- Worst kill: mini-nuke, 4.3 ms on its kill tick (10 cuts at once). The rest: homing shard 2.5 ms,
  hand cannon 2.2, flame 1.9, then 1.1-1.4 ms each for the rocket, katana, chainsaw, plasma sword
  and ray gun (JOURNAL 06:09; telemetry `E/city-*-48-telemetry.json`).
- The first-burn and first-vaporise frame came down from 1.6-1.9 ms to 0.08-0.15 ms by warming the
  char shader (bbc674ee). The rocket's worst frame went from 67.7 ms (early, 26 kills) to 1.2 ms
  through per-kill ground layers and blot-by-blot smears (47e38261;
  `E/rocket-city-48-telemetry-before-it9.json` / `-after-it9.json`).

**Gates of record** (on `63cc3ce1`, private APPDATA, CONTENDED): lint 13/13, unit 787/787
(`E/unit-it13.log`), scenarios 35/35 with 0 script errors (`E/scenarios-it13.log`). Parity and the
bench were not re-run after the last changes (render only, no sim path touched). Look goldens 11/11
were last run on `59429978`.

## What does not work / open
- **Electro corpse pose:** fixed after 09:00 (see below): the drop lands in the rig's own death pose.
  Human-reactions' newer stiff plank (`c_plank`, legs together, arms at the sides) is on
  `n-human-reactions` only; the glue to switch to it after the merge is in `docs/decisions.md`.
- **The age-96 stall:** a 2-4 ms main-thread block shows up about 96 ticks into some kills (once even
  with no kill). It sits inside `KillView._draw`'s 72-slot gib-shadow loop, which cannot cost that
  much by itself. It is most likely contention or a render sync, but it is **unmeasured** under
  `bench.lock` and headless.
- **Nuke kill tick 4.3 ms** (CONTENDED): spreading the cuts of one tick over two frames is not done.
- **Claw-shock lab:** the lab drives its own `PlayerShock`, so Rivet's thrust clip does not play in
  that clip. In the real game the pilot path plays it.
- REQUESTs to gunplay: both answered on `n-gunplay` (REQUEST 30 stuck shards: `8ea3a2e5`; REQUEST 29
  molotov corpse: `0b2541a9` + `aa471560`). Re-check both on the merged main.
- Art: the gore stickers (REQUEST 3/4 from weapon-art, `art/gore/`) are front views over a top-down
  body. They read as a comic gag (call brutality-4). A top-down skeleton redraw was not made.

## What blocked, and for how long
- Nothing blocked the lane for long. About 01:00-01:30, the rocket gib waited on weapon-art's gore
  art, so it was built from procedural cuts of the rig parts first and the art was taken by path
  when it landed (n-weapon-art 295db1b3).
- Time lost: clips shot without `--rigs` (about 20 min over two sessions, re-shot); melee staging
  on the city block (iterations 11-12, about 40 min, fixed in 94ddeae6 / 8020d7f4); a wrong gun
  id (`mini_nuke_launcher`) that the lab silently ignored (about 10 min); gdformat's CRLF breaking
  scripted edits (switched to the Edit tool).
- Iterations 14-16 (08:23-08:40) were too short to build, capture and gate a change, so no code was
  touched in them.

## Calls for the owner (defaults are in the clips; each alternative is one data value)
- **brutality-1** Rocket gib from the victim's own cut rig parts (default) vs painted gore parts.
- **brutality-2** Ink flash: a cream starburst for 4 ticks (rocket) or 2 ticks (hand cannon), off
  under reduced motion (default), vs d5-combat's kill beat (`--kill-beat`).
- **brutality-3** Every fire death chars (default) vs only the flamethrower.
- **brutality-4** Electro X-ray as a front-view skeleton sticker (default) vs a top-down redraw.
- **brutality-5** A signature kill suppresses the standard death pool (default) vs keeps it.
- **brutality-6/8** Katana cut diagonal at 55 deg (default, `cut_deg`); chainsaw straight (default).
- **brutality-7** Plasma cauterised with no blood (default, `spray`) vs a red exit spray.
- **brutality-9** Chainsaw grind 54 ticks (default, `grind_ticks`) vs 30.
- **brutality-10** Blade halves part sideways and rest about 2 m apart (default) vs fly on along the blade.
- **brutality-11** X-ray held 4 frames (default, `KillShockFx.XRAY_HOLD`) vs a pure strobe.
- **brutality-12** Nuke victims as charcoal shadows (default) vs white ash outlines.
- **brutality-14** The plasma victim looks at the hole for 8 ticks before falling (default,
  `KillHoleFx.LOOK_TICKS`) vs dropping at once.
- **brutality-15** The electro gun one-shot needs the held charge (default, built by gunplay).
- **brutality-ray-cap** The ray gun's cap knocked aside (default, `hat_kick_mps: 1.8`) vs left on the
  heap (0): `M/clips/ray-dissolve-city-64ppm-slow-0.4x-it11.mp4` vs
  `M/clips/ray-gun-dissolve-solo-64ppm-slow-0.4x.mp4`.

## Next steps
1. After the merge: re-check the electro corpse on main (REQUEST 29), then apply the stiff-plank glue
   (`DeathPose.stiff_channels` + `plank_turn` in KillSprawlCut / KillShockFx, see `docs/decisions.md`).
2. Check gunplay REQUESTs 29 and 30 on the merged main.
3. Measure the age-96 stall and the nuke tick under `bench.lock` (windowed and headless). Spread the
   nuke's cuts over two frames if it holds.
4. Re-run the look goldens and parity on the merged main (the last look run was on `59429978`).
5. Decide the calls above, then flip the one-value alternatives in `signature_kills.json`.

## After 09:00 (extension, iteration 18, 08:45-09:45)
- **Electro corpse (showcase REQUEST 29, report next step 1), `88ff881d`:** the stiff drop now lands
  in a second whole-body cut of the victim's rig, posed by human-reactions' `DeathPose._shock` end
  channels (`c_sprawl` 1.05, hands down). It replaces the standing copy mid-drop and opens from 0.75x.
  `KillSprawlCut` puts every channel and node transform of the rig back (unit
  `test_kill_sprawl_cut.gd`, 3/3). It is render only: the kill sim, its RNG and the goldens are untouched.
  The corpse looks larger than the standing body because seen top-down, a standing cop shows only
  head and shoulders. It matches the live cops at the same zoom.
  Clips: `M/clips/electro-plank-city-64ppm-slow-0.4x-it18.mp4` and
  `M/clips/electro-plank-city-48ppm-8s-it18.mp4` (one isolated cop, open street, `--clean`);
  strip `E/electro-plank-64-strip-it18.png`. Cost (CONTENDED): 677 us on the cut tick, worst
  kill-view frame 748 us.
- **City reel** re-cut with the new electro chapter: `M/clips/city-reel-all-11-kills-clean-48ppm-it18.mp4`
  (frames.json entry 1).
- **Gates of record on `88ff881d`** (private APPDATA, CONTENDED): lint 13/13, unit 790/790
  (`E/unit-it18.log`; the first run hit the known `test_noir_shadows` flake, and the re-run passed), scenarios
  35/35 with 0 script errors (`E/scenarios-it18.log`), look goldens 11/11, worst mean 1.54 of 4.0
  (`E/look-golden-it18.json`), parity bit for bit over 1200 steps, with the planted mutation caught at
  step 629 (`E/parity-it18.log`). Next step 4 is done on this branch. Repeat it on the merged main.
- **Measured under `bench.lock`** (09:15-09:20, windowed, no movie writer, two runs each; `E/lock-it18/`):
  the nuke's five kill-tick cuts cost about 1.6 ms together (not 4.3 ms). Its worst frame is 4.45 ms at
  tick 123 (age 18) in both runs, so it is deterministic. A temporary probe puts 2.4 ms of it in
  `KillView._draw` (the marks' flash stars). The flame's age-96 stall showed up in one run of two, so
  it is contention, not the kill's code. The electro kill with the plank cut costs 0.8-1.2 ms. Every
  frame stays well inside 16.6 ms.
- Not done: merging `n-human-reactions` (110 commits, with conflicts in shared arena and rig files) for
  its stiff plank (see the DECISION and merge glue in `docs/decisions.md`). Also not done: the fix for the nuke's
  tick-123 frame (next probe: `KillMarkArt.flash` per mark).
