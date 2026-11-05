# JOURNAL: lane melee (branch `n7-melee`), night 2026-11-05/06

Masters: `C:\Users\kazda\kiro\gtai-masters\n7\melee\` (`M/`). Scratch: `C:\Users\kazda\kiro\gtai-n7p\scratch\melee\`.
Film: `evidence/n7-melee/film.sh <name> <ppm> <ticks> <arena args>`; A/B cuts with `evidence/cut_ab.sh`.

## Iteration 1 (19:20-20:20), BUILD

- 19:20 read: combat-notes REPORT + JOURNAL (the 18:15 DESIGN), ghost-powers REPORT (headings), AGENTS,
  `hit_feel.gd` + `hit_feel.json`, `react_link.gd`, `combat_arena.gd`, `player_melee.gd`, reel director.
  `n7-ranged` has no JOURNAL yet (no feel commits to merge). `n7-king` and `n7-servo` journals read:
  no REQUEST to this lane; king adds `Fighter.brain_owned` and small CombatArena edits (a merge to
  watch: my `wounded` signal is 4 lines in `combat_arena.gd`, now 286 lines, hard stop 300).
- Registry rules applied:
  - `realtime-combat-semantics`: a state change that changes the outcome must be perceivable (a jab
    that took half a riot cop's hp showed nothing; then my first pass showed a *block*), and an area
    effect must be telegraphed (the ghost audit scores the telegraph of the slam, ram and arc).
  - `motion-quality-gating`: craft, responsiveness and integrity are scored apart, never averaged;
    each dimension is a visible contrast (accelerates into the hit vs floats; the victim moves on the
    hit frame vs later); the score is absolute, not graded on the batch; the frame sampling is stated
    with each look; no number is made up to fill the table (unmeasured = blank).

### REQUEST 1 -> n7-ranged (the shared feel layer interface), 19:35
Melee and the ghosts will call the layer you own; proposed shape, your answer wins:
1. **Call:** keep `HitFeel.land(target_id, hit_class, dir, lethal, tick) -> int`, and add an optional
   `strength: float = 1.0` (0..2) that scales hit-stop ticks, shake amplitude and the camera kick.
   Melee passes 1.0 for a jab, about 1.5 for the combo finisher, 2.0 for a kill; ghosts pass their
   own (the slam 2.0 on its centre, the ram by speed).
2. **Classes I need** (rows in `hit_feel.json`, yours to add or let me add by REQUEST answer): `melee`
   (a jab: 2-3 ticks hit-stop, kick only, no shake), `melee_heavy` (finisher/katana: 4-5 ticks + a kick),
   `slam` (Tonnage press: hit-stop + a capped radial shake + debris hook), `ram`, `slice` (Kerf, per
   cut: 2 ticks, no shake, so the chain reads hit by hit), `chain` (Ohm arc: flash only past the first).
3. **Directional kick:** `CameraRig.kick_dir(dir: Vector2, strength)`, a few px along the hit, eased back.
4. **Cap per frame:** within one tick only the strongest hit-stop applies (not the sum), shake
   amplitude saturates (sum of strengths capped at e.g. 1.0 of the class max), and a per-second budget
   so a Gatling burst, an Ohm chain through 10 cops or a nuke on a crowd is one beat, not a blur.
5. **Off switch:** `--feel=off` (all new fields to 0; the before clips), plus a per-row `enabled`.
6. **View only:** if `land()`'s returned hit-stop holds `SimClock` (it says "the caller holds the clock
   for"), please state in your JOURNAL whether that hold is wall-clock only (ticks and replay unchanged);
   melee will only use the layer in a way that keeps parity.

- MILESTONE 19:26 `1e32a7fd` the non-lethal melee wound (brief item 2): `CombatArena.wounded` (view-only
  signal on the non-lethal branch, non-Rivet victims), `MeleeWound` beside `ReactLink` (queues the
  melee wound family along Rivet -> victim, once per strike: `GAP_TICKS` 12 so the chainsaw grind does
  not restart it every tick), `--soft-swing` = the night's (none). `test_melee_wound`. Dev flag
  `--riot-victims` (reel director: every chapter's victims are riot cops) for the film.
- FINDING 19:28 (looked at the first after, 48 px/m, frames 44-124 every 4th, 240x180 crops): all 4
  wounds played the **shield** family with the block sparks flying back at Rivet. That reads "blocked",
  while the sim took his hp (he dies on the next jab). Worse than no wound.
- DECISION 19:29 `a1716c1d`: a melee wound on a riot cop's front plays on the body
  (`MeleeWound.past_slab` true; false = the slab takes it). Rejected: the shield recoil (says
  "no damage"). Log: `4 wounds (0 on a shield)`. Tests 7/7 incl. both planted paths.
- LOOK 19:31 (zoom 120x100 crops x2, frames 76-108 every 4th, before over after): before = the riot cop
  stands untouched through two jabs; after = he twists away from the jab (shoulders and head turn,
  the shield swings off line) for about 0.4 s and recovers before the finisher kills him.
- CLIP `M/melee_wound_riot_ab_48ppm_64slow.mp4` (6.2 s, 370 frames: 48 px/m real time A/B, then
  64 px/m at 0.4x A/B; before = `--soft-swing` on the same head). Checked frames 52 and 250.
  Real time at 48 the twist is short but visible; at 0.4x it is plain.
- Lint 13/13 over 933 files; unit full suite 1115/1115 (19:25, before the past_slab fix; the wound
  test 7/7 after it).
- CHECK 19:36 (does a shield soak melee in the sim?): `EnemyPit.hurt` (the dev pit's AI) soaks front
  hits; `CombatArena.damage` (arena, city block, quest 1: where PlayerMelee lands) has only `damage_k`,
  no front soak, and the filmed riot cop died to his 2nd jab. past_slab stands for the live paths.

### REPLY to n7-ranged REQUEST 1 (19:37): accepted as written; my REQUEST 1 is superseded
- I take `view.feel_cam.hit(weapon, hit_class, dir * strength, lethal, tick)` as the one call, per-weapon
  looks as `hit_feel.json` `weapons` rows, the shared cap (1 kick/tick, 3 shakes and 12 stop ticks/s).
  No separate melee budget for now; I will ask by REQUEST if the audit after the merge shows a melee
  kill losing its stop to a gun.
- Melee lands through `CombatArena.damage` with no `struck`, so both of its paths call `cam.hit` from
  the view: kills from `kill_landed` (MELEE_IDS), non-lethal hits from my new `CombatArena.wounded`
  (view-only signal, `1e32a7fd`; no `struck`, so no double kick). Strength: jab 1.0, finisher 1.5.
- Point 6 of my REQUEST is answered by your FINDING 19:25: `SimClock.hold` withholds wall time only.
- I merge `n7-ranged` as soon as the feel commit is on the branch (not yet at 19:37: `git log n7-ranged`
  = main).
- GATES 19:48 `node tools/evidence/run.mjs --no-bench` on `402ed7db`: lint 13/13, unit 1117/1117, parity
  bit-exact (mutation caught at step 629), scenarios 51/52: `scenario_rig_stress` failed while my audit
  films rendered (CONTENDED); re-run alone 1/1 pass (rig p99 3.5 ms, CONTENDED). Known flake.
- FRICTION 19:40: the evidence run refused twice on a dirty tree (a journal line, then the new audit doc
  written while the commit hook's lint ran). Rule for this lane: draft docs in scratch during a gate run.
- AUDIT 19:45 `docs/polish/melee.md`: 9 attacks scored at 32 px/m (strips: melee frames 40-157 every 3rd,
  240x140 crops; ghosts 16-frame overviews + attack strips). Ranked weakest first: Kerf chain, plasma
  sword deflect, claw, Ohm bolt, chainsaw, Tonnage slam, Dent blast, baton, katana. Systemic: no camera
  feel in the live paths (ranged fixed the camera side), no attack in this lane has a sound cue of its own.
- MERGE 19:50 `445f0b5b`: n7-ranged 779cdd3d (FeelCam, FeelBudget, hit_feel kick/cap/weapons, --feel=off),
  0f8e4f5f (arena gun audio), e88ebcfe (a kill keeps the longer stop). Conflict only in the root
  JOURNAL.md (both lanes add one): kept ours.
- MILESTONE 19:52 `65dd07e1` MeleeFeel: kill_landed + wounded (MELEE_IDS) -> FeelCam.hit(weapon, &"melee",
  Rivet -> victim, lethal, tick), once per strike; attached in CollectCallView beside FeelCam. hit_feel.json
  weapons rows: claw (rivet_hit 3-tick stop, kick 2, no shake), katana/plasma_sword (melee_hit, kick 3),
  electro_baton (melee_hit, kick 2.5), chainsaw (no stop per bite, kick 1). Kills: kill stop + 1.5x kick.
  DECISION: no shake on any melee hit (restraint; the stop and the directional kick carry the weight;
  a shake is one `shake` value per row). test_melee_feel 5/5 incl. planted feel-off.
- MEASURE 19:54 (claw_combo at 32, 420 frames, actor crop 400x240 -> 100x60 grey, mean |diff| < 0.05 =
  still): after has new still runs at frame 75 (6 frames, the kill) and 109 (5 frames, the 2nd cop);
  before has none there; all later runs shift by 11-12 frames. LOOK at 48 (frames 66-89 every 2nd):
  the contact pose (claw in the cop, first drops out) holds, then the spray releases; the floor lines
  offset (the kick). CLIP `M/melee_feel_claw_ab_32ppm_48slow.mp4` (6.9 s, 415 frames).

### REQUEST 2 -> n7-ranged (20:00): an optional `class` on hit_feel.json `weapons` rows
The ghost attacks land like melee: through `CombatArena.damage`, no `struck` (`kerf_slice`, `dent_car`,
`dent_blast`, Ohm's bolt; the Hauler's stomp and `ram` keep HaulerKick). I want MeleeFeel to route any
`kill_landed`/`wounded` whose weapon has a row with a `class` to `FeelCam.hit(weapon, row.class, ...)`,
so the per-cut feel of Kerf's chain (a short stop, no shake: each cut its own beat) and Dent's blast are
rows, not a code map. Please add `"class": {"type": "string"}` (optional, a `classes` id) to the weapons
item schema and `HitFeel.weapon_class(weapon) -> StringName` (&"" when none). If you prefer I add it,
say so here and I will, in one commit touching only those two lines.
- CHECK 20:02 director reel on `432cb02d` (windowed, `--fixed-fps 60 --quit-after 8200`, 32 px/m):
  19/19 chapters down, 0 SCRIPT ERROR (scratch `director.log`).
- GATES 20:02 on `432cb02d`: lint 13/13, unit 1131/1131 but flagged FAIL "tree changed during run: M
  JOURNAL.md" (I appended REQUEST 2 mid-run: my error, not a test), scenarios 52/52, parity bit-exact
  (step 629), selftest pass (look goldens 11/11, block 5/5). Re-run below on the committed head.

NEXT (written 20:03, for iteration 2):
1. Read n7-ranged's JOURNAL for the answer to REQUEST 2 (`class` on weapons rows); merge any new feel
   commits (record each). Then Kerf's chain (rank 1): route `kerf_slice` through MeleeFeel -> FeelCam
   with a per-cut short stop and no shake, so each cut is its own beat; consider a cut-frame flash in
   KerfView (ink/white, not teal on the world). Film the chain at 32 real + 64 at 0.4x vs `--feel=off`.
2. Then: plasma sword deflect (rank 2: a bigger deflect spark, tie the return to the swing), Ohm's
   bolt tell (rank 4), chainsaw kill read at 32 (rank 5), Tonnage slam impact (debris + capped shake via
   a `stomp`/slam weapons row; check HaulerKick does not double it), Dent blast in frame.
3. Score the 48 px/m audit films (`scratch/melee/audit_*_48.avi`, kept for this), Tonnage plates/ram,
   Dent's blow, Ohm's mass arc; add to `docs/polish/melee.md`.
4. City block check: `--arena=city --bot=reel --reel=director` result (started 20:03, see below).
5. Quest 1 melee (brief item 5): quest 1 has no RivetCarry (claw only); a carried blade there changes
   quest 1's state hash -> decision line + deliberate re-bless. Do it after the ghost items.
6. Calls for the owner so far: none needing a verdict (past_slab and no-shake-on-melee are DECISIONs
   with one-value alternatives). Sound: no per-attack cues exist; needs sound assets (REPORT).
7. Never touch the worktree while `tools/evidence/run.mjs` runs (it checks cleanliness after unit).
- CHECK 20:05 city block director reel on `48fea0c2` (`--arena=city`, same flags): 19/19 chapters fully
  down, 0 SCRIPT ERROR (`evidence/n7-melee/director-city-48fea0c2.log`; the arena run's chapter lines
  are in `director-arena-432cb02d.log`, the head before was code-identical).
- GATES 20:08 on `48fea0c2` (nothing touched during the run): lint 13/13 over 938 files, unit 1131/1131,
  scenarios 52/52, parity bit-exact (mutation caught at step 629), selftest pass (look goldens 11/11,
  block 5/5). `evidence/n7-melee/gates-48fea0c2.log`. No bench: no performance claim.
- 20:09 REQUEST 2 not yet answered by n7-ranged. Masters: 2 clips + `frames.json` (copy in
  `evidence/n7-melee/`). Scratch cleaned (kept: the 48 px/m audit AVIs for NEXT 3).
- STOP 20:10 iteration 1. NEXT is the 20:03 entry above, unchanged.

## Iteration 2 (20:10-21:10), phase BUILD
- MERGE 20:15 `6d614652`: n7-ranged 5535aad2 (classes melee_heavy/slam/ram/slice/chain), eebc82f7
  (`class` on weapons rows + HitFeel.weapon_class: my REQUEST 2, answered 20:12), 2691917e/016966b2
  (fire kick), audit docs. Conflicts: JOURNAL.md (kept ours), hit_feel.json weapons (both sides' rows
  kept, sorted by id).
- FINDING 20:30: camera.json `hitstop_cooldown_ticks` 20 > Kerf `gap_s` 0.3 (18 ticks): at full
  player cadence the shared stop marks every other cut only. Not changing sim timing (gap_s) nor the
  shared cooldown (it governs every gun). So each cut carries a kick (no cooldown) and a view flare.
- DECISION 20:35: Kerf's cut flare prints in cream and ink (a world impact; teal stays the soul's own
  path, afterimages and hanging cut line). One value: `ghost_attacks.json kerf.cut_flare_s` (0 = none).
- MILESTONE 20:48 `cb3e5caa`: MeleeFeel routes any kill_landed/wounded whose weapons row has a
  `class` (ghost attacks) to FeelCam; ghost hits kick along `arena.hit_dir`. Rows kerf_slice (slice,
  kick 2.5) and dent_blast (blast, crash shake). KerfView cut flare 0.15 s. Tests: kerf cut felt by
  its row class, planted: a ghost weapon with no class row is not felt. Unit 1136/1136, lint 13/13.
  Not added: ohm_bolt (it already emits `struck`, so FeelCam feels it; a row class would double it).
- LOOK 20:45 (kerf, after 32, frames 94-105 full-res 480x270 crops): frames 96-102 hold still on the
  first cut; a cream slash edged in ink with ink sparks across the cop. 64 px/m A/B frames 320/345 of
  the clip: the flare plain beside the before's thin white cut line.
- CLIP `M/kerf_chain_ab_32ppm_64slow.mp4` (8.3 s).
- MEASURE 20:55 (dent, shift.py on a 600x300 floor crop, frames 160-200): before 0.0 px through the
  blast; after 17.9 px first-frame jolt, settling in 12 frames (165-177). LOOK (crops 520x320 frames
  162-180 every 2nd): the burst prints as before, the frame jolts; the blast still sits at the right
  edge (camera on Dent: owner call, untouched). CLIP `M/dent_blast_ab_32ppm.mp4` (3.5 s).
- Registry rules applied (realtime-combat-semantics, motion-quality-gating): the feel is keyed to the
  hit event frame (sync), strength-scaled and capped by the shared budget; every change judged A/B in
  motion vs `--feel=off` on the same head.
