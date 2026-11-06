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
- MERGE 20:12 `6d614652`: n7-ranged 5535aad2 (classes melee_heavy/slam/ram/slice/chain), eebc82f7
  (`class` on weapons rows + HitFeel.weapon_class: my REQUEST 2, answered 20:12), 2691917e/016966b2
  (fire kick), audit docs. Conflicts: JOURNAL.md (kept ours), hit_feel.json weapons (both sides' rows
  kept, sorted by id).
- FINDING 20:14: camera.json `hitstop_cooldown_ticks` 20 > Kerf `gap_s` 0.3 (18 ticks): at full
  player cadence the shared stop marks every other cut only. Not changing sim timing (gap_s) nor the
  shared cooldown (it governs every gun). So each cut carries a kick (no cooldown) and a view flare.
- DECISION 20:15: Kerf's cut flare prints in cream and ink (a world impact; teal stays the soul's own
  path, afterimages and hanging cut line). One value: `ghost_attacks.json kerf.cut_flare_s` (0 = none).
- MILESTONE 20:18 `cb3e5caa`: MeleeFeel routes any kill_landed/wounded whose weapons row has a
  `class` (ghost attacks) to FeelCam; ghost hits kick along `arena.hit_dir`. Rows kerf_slice (slice,
  kick 2.5) and dent_blast (blast, crash shake). KerfView cut flare 0.15 s. Tests: kerf cut felt by
  its row class, planted: a ghost weapon with no class row is not felt. Unit 1136/1136, lint 13/13.
  Not added: ohm_bolt (it already emits `struck`, so FeelCam feels it; a row class would double it).
- LOOK 20:17 (kerf, after 32, frames 94-105 full-res 480x270 crops): frames 96-102 hold still on the
  first cut; a cream slash edged in ink with ink sparks across the cop. 64 px/m A/B frames 320/345 of
  the clip: the flare plain beside the before's thin white cut line.
- CLIP `M/kerf_chain_ab_32ppm_64slow.mp4` (8.3 s).
- MEASURE 20:21 (dent, shift.py on a 600x300 floor crop, frames 160-200): before 0.0 px through the
  blast; after 17.9 px first-frame jolt, settling in 12 frames (165-177). LOOK (crops 520x320 frames
  162-180 every 2nd): the burst prints as before, the frame jolts; the blast still sits at the right
  edge (camera on Dent: owner call, untouched). CLIP `M/dent_blast_ab_32ppm.mp4` (3.5 s).
- Registry rules applied (realtime-combat-semantics, motion-quality-gating): the feel is keyed to the
  hit event frame (sync), strength-scaled and capped by the shared budget; every change judged A/B in
  motion vs `--feel=off` on the same head.
- CHECK 20:22 director reel (arena) on the working tree = `cb3e5caa` code: 19/19 chapters fully down, 0 SCRIPT ERROR.
- CHECK 20:24 director reel (city block, `--arena=city`) on `cb3e5caa` code: 19/19 chapters fully down, 0 SCRIPT ERROR (`evidence/n7-melee/director-{arena,city}-cb3e5caa.log`).
- MEASURE 20:30 (Tonnage, `--bot=ghosts --ghost=tonnage` at 32, before `--feel=off` / after, shift.py
  on a 700x300 floor crop, frames 120-240): the two films are bit-identical (same numbers): the slam's
  camera is HaulerKick (powers.json stomp_shake `crash`, stomp_hitstop `boss_hit`), outside FeelCam, so
  `--feel=off` does not touch it. Both shake on the slam (frames 142-160, jolts to 15 px). CORRECTION
  to the audit: the slam has a shake and a stop; at 32 px/m with the camera already moving they do not
  read as a beat. What is missing is debris (and a landing mark). Not routing stomp through FeelCam
  (it would double the HaulerKick shake).
- FRICTION 20:28: a new class_name (SlamDebris) is unknown to films until `--import` refreshes the global
  class cache: 3 Tonnage films came out with 447 SCRIPT ERRORs (discarded). Rule: `--import` after
  adding a class, before any film.
- MILESTONE 20:30 `2502aaa7` plasma sword deflect (rank 2): `CombatArena.deflected(at, back)` (view
  only) from `PlayerDeflect.bat`; MeleeFeel parry beat (row `plasma_deflect`: melee_heavy, 4-tick stop,
  3 px kick toward the shooter, no shake); DeflectMarks (new table `melee_marks.json` `deflect`): cream
  starburst edged in ink on the bat frame (8 ticks) and a cream streak 2.5 m along the return (10 ticks);
  drawn in FxView. Off: flash_ticks 0 or `--feel=off`. test_deflect_marks 5/5 incl. planted; unit
  1141/1141.
- LOOK 20:29 (director `--chapter=plasma_sword_deflect` 48 px/m, frames 126-148 every 2nd, 520x220 crops,
  before over after): before = the small ink spark scribble at the blade tip; after = a cream star edged
  in ink at the tip plus the streak toward the cop, and the bat holds (the after runs ~5 frames behind;
  the cop drops later). The streak reads greyish once the ink fades (a tuning note, not fixed).
- CLIP `M/plasma_deflect_ab_32ppm_48slow.mp4` (5.8 s).
- MILESTONE 20:37 `4c6c6bf5` Tonnage slam debris (rank 6): SlamDebris inside HaulerMarks.draw (arena, city
  block, quest 1's CastView all get it): a cream landing flash edged in ink (slam_flash_s 0.08), 16 paper
  chips edged in ink in low arcs with shadows (slam_debris, slam_debris_s 0.55), paper-dust puffs. Seeded
  from the stomp tick. Off: slam_debris 0 or --feel=off.
- LOOK 20:33 first pass (frames 157-171, 420x320 full-res crops): the dust read, the ink chips vanished
  on the dark asphalt and the 1.1 m flash hid under the 3x press body. DECISION 20:34: chips in paper
  edged in ink, 0.16-0.32 m; flash 2.0 m. LOOK 20:36 second pass: the landing frame prints a cream disc
  round the press, dust rolls out, chips land at the edge. CLIP `M/tonnage_slam_ab_32ppm_48slow.mp4` (5.8 s).
- LOOK 20:38 Ohm tell pass 1 (NOT committed): after each bolt the fingertip glow (tell_glow_m 0.22) charges
  back over bolt_gap_s to a white ready glint, white flash at the tips on the fire frame. Looked at frames
  140-180 every 4th, 240x160 crops x1.5, before over after: at 32 px/m the Ohm form is ~20 px inside its
  own teal aura; the glow does not separate from it. No visible change = not done. Patch kept in
  `gtai-n7p/scratch/melee/ohm_tell_pass1.patch`; `tell_glow_m` stays in the data (inert: nothing reads it).

- GATES 20:44 `node tools/evidence/run.mjs --no-bench` on `f6dc5330` (tree untouched during the run):
  lint 13/13 over 942 files, unit 1143/1143, scenarios 52/52, parity bit-exact (planted caught at
  step 629), selftest pass (look goldens 11/11, block 5/5). `evidence/n7-melee/gates-f6dc5330.log`.
  No bench: no performance claim.
- CHECK 20:49 director reel on `f6dc5330` (deflect + debris in): arena 19/19 and city block 19/19, every chapter fully down, 0 SCRIPT ERROR (`evidence/n7-melee/director-{arena,city}-f6dc5330.log`). Kerf, deflect, Dent blast and Tonnage debris stand as done.
- MILESTONE 20:53 `0555878c` Ohm's bolt tell (rank 4), pass 2: pass 1's fingertip glow plus, outside the
  form's aura, a white spark edged in ink reaching from each tip toward the aim (0.25 -> 0.9 m) as the
  charge refills over bolt_gap_s; crackles when ready; the fire frame flashes the tips. LOOK 20:52
  (frames 140-180 every 4th, 240x160 crops x1.5, before over after): prongs out while ready, gone on the
  fire frame, growing back; the before has only the aura. CLIP `M/ohm_tell_ab_32ppm_crop.mp4` (6.9 s).
  No unit test (draw-only view); the ghosts reel ran with 0 SCRIPT ERROR. frames.json 7 entries.

NEXT (written 20:40, revised 20:56, for iteration 3):
1. Read the gate result appended below (evidence run on the head after this commit); if a known flake
   fails, re-run it alone.
2. Ohm: the tell landed (`0555878c`); judge it at 48 px/m and in the city block; the bolt's victim
   impact (white disc) and the mass arc at --tier=1 are next for Ohm.
3. Chainsaw kill read at 32 (rank 5): the kill is a red blob under Rivet; the grind gets no stop per
   bite by design; look at a spray direction / a kill-frame mark.
4. Deflect streak greys as its ink fades: try cream over a thinner ink, re-look at 48.
5. Score the unscored attacks from the 48 px/m audit films (Tonnage plates/ram, Dent's blow, Ohm's
   mass arc) in `docs/polish/melee.md`.
6. Quest 1 melee (brief 5): a carried blade on quest 1's path changes its state hash -> decision line
   + deliberate re-bless; do it once the ghost items stand.
7. Calls for the owner (REPORT): Kerf at full player cadence holds every other cut (camera.json
   `hitstop_cooldown_ticks` 20 > kerf `gap_s` 18 ticks); options: as built / cooldown 18 (shared with
   guns, n7-ranged's call) / gap_s 0.34 (sim). The Tonnage stomp's HaulerKick ignores `--feel=off`.
8. City-block combined clip of the polished set (30-90 s) before freeze; exe by 08:30.
- GATES 20:58 scenarios on `0555878c` (the Ohm tell): exit 0, 0 SCRIPT ERROR. Lint 13/13 at the commit hook. Unit last full run 1143/1143 on `f6dc5330` (the Ohm commit touches only ohm_view.gd).
- STOP 20:59 iteration 2. NEXT is the 20:40/20:56 entry above.

## Iteration 3 (21:00-22:00), phase BUILD
- MERGE 21:01 `20f2263d`: n7-ranged 0d4089f1 (camera.json hitstop_cooldown 20 -> 16: every Kerf cut now
  gets its stop; my call 7 is decided by ranged), e32720c4 (flamer ignition kick), da508e6b (blast cue),
  9c140ffb (react snap), spin-up tremor, docs. Conflicts: JOURNAL.md (kept ours), hit_feel.json weapons
  (both sides' rows, sorted by id: checked).
- NOTE from ranged's FINDING 20:46: the director reel without `--loadout=pistol` skips Rivet's own guns.
  My reel gates so far ran without it; from now on both reels run with `--loadout=pistol`.
- LOOK 21:03 chainsaw before (director `--chapter=chainsaw` 32 px/m, frames 80-195 every 4th, 200x120
  crops x2; close-ups of 82/100/130/160 x4): through the ~1 s grind the cop is buried under the saw bar,
  his own ink-rimmed drops and the floor splat; the halves parting (from ~frame 152) reads clearly.
- FINDING 21:07 pass 1: a cream slash along the cut on the parting tick did not show: the cut runs along
  the saw's push, so the slash lay on the saw bar (cream edged in ink too). Measured: after vs before
  identical from frame 160 on (mean |diff| 0.0).
- DECISION 21:08: the parting mark is a starburst (cream, ink rim, 1.2 m across, 12 ticks), not a slash.
  Alternative: `melee_marks.json saw.release_m` 0 (none).
- MILESTONE 21:12 `49cc45d1` chainsaw kill read (rank 5): SawMarks (`melee_marks.json saw`: clear_m 0.45
  drops hidden until clear of the held body, shake_m 0.06 judder (0.035 before), release_m 1.2 burst on
  the tick the halves part); `--feel=off` = the before values. test_saw_marks 4/4 incl. planted.
- LOOK 21:10 (32: frames 140-162 every 2nd, 110x80 crops x3, after over before; 48: frames 136-170 every
  3rd): the burst prints over the cop on frames 144-148 (48: 142), the halves part 6-8 frames later; fewer
  drops over the body during the grind. CLIP `M/chainsaw_kill_ab_32ppm_48slow.mp4` (5.5 s).
- GATES 21:16 `node tools/evidence/run.mjs --no-bench` on `19c92dd9` (chainsaw in): lint 13/13 over 947
  files, unit 1156/1156, scenarios 52/52, parity bit-exact (planted caught at step 629), selftest pass
  (look goldens 11/11, block 5/5). `evidence/n7-melee/gates-19c92dd9.log`. No bench: no performance claim.
- CHECK 21:16 director reels WITH `--loadout=pistol` on `19c92dd9`: arena 19/19 and city block 19/19,
  every chapter fully down, 0 SCRIPT ERROR, no "skipped" line
  (`evidence/n7-melee/director-{arena,city}-loadout-19c92dd9.log`).
- AUDIT 21:15 Tonnage ram at 48 px/m (audit film frames 180-420 every 10th, 760x460 crops): the press
  drives cops into a heap against the car; HaulerKick's `kill` stop and `hit` shake run per ram hit,
  but nothing prints where the press meets a body. Scores (32 px/m read): antic. 2, impact 2, read 2,
  victim sync 3, sound 1.
- FINDING 21:22: in the arena the ghost forms' TonnageView draws the Hauler marks (CastView only in
  quest 1's non-form path); my first ram draw sat in CastView only and never ran (log: 6 ram hits,
  0 draws). Both now call `RamMarks.draw_all` (the stomp's pattern: TonnageView when `marks`).
- FINDING 21:24: a burst between the press and the body hid under the press body (cream-pixel diff
  after vs `--feel=off`: ~30 px). DECISION 21:25: the burst sits 0.1 m past the body, 0.7 m across.
- MILESTONE 21:27 `0c4161d8` Tonnage ram contact (brief 4, "the ram needs weight"): RamMarks (cream
  burst edged in ink, 0.15 s, 5 paper chips along the shove); HaulerStage keeps the last 8 ram hits
  for the view (not in write_state); ghost_attacks.json tonnage ram_flash_s / ram_chips; --feel=off =
  none. No unit test (draw-only view, as the Ohm tell). LOOK (frames 133-147 every 2nd, 160x120 crops
  x2, after over before): a cream star by the cop from the contact frame through the ram stop, then
  chips. Honest limit: at 32 px/m it is a ~20 px star; the heap of bodies at the car is unchanged.
  CLIP `M/tonnage_ram_ab_32ppm_48slow.mp4` (4.2 s).
- GATES 21:32 scenarios on `0c4161d8` (the ram): 52 ran, 0 failed, 0 SCRIPT ERROR. Lint 13/13 at the commit hook.
- MILESTONE 21:35 `a7ed5d4c` deflect streak (NEXT 4 of it2): alpha 1-t² and the width thinning to 0.4
  (a linear alpha fade laid half-clear cream on half-clear ink = grey). LOOK (48 px/m director chapter,
  frames 125-134, 180x60 crops x2, after over the pre-commit head): before greys to a smudge on frames
  129-131; after stays a cream line edged in ink, thinning. CLIP `M/plasma_deflect_streak_ab_48ppm_slow.mp4`.
- DOC 21:36: hit_feel.json kerf_slice doc updated for ranged's cooldown 16 (every cut gets its stop now).
- PLAN quest 1 melee (brief 5; read-only survey 21:15, not started): quest 1's StagePilot has
  `carry = null` (stage_pilot.gd:19: "quest 1 keeps its own weapons"); the claw is PlayerMelee
  (stage_pilot.gd:12), `_pick_melee` (:149-156) switches to a MeleeTable weapon only when a carry
  wields one. Minimal path: in `Quest1Session._bind_pilot` (quest1_session.gd:83-87) build a RivetCarry
  as ArenaArsenal.arm does (arena_arsenal.gd:17-56, stream `gunplay` from the world's rng), add one
  blade, leave it on its slot key (do not select: Gloria arrives via `rivet.weapon`, stage_lines.gd:13,
  and is not in the carry). `pilot.write_state` adds carry state (stage_pilot.gd:107-109) -> quest 1's
  state hash changes; no test pins a literal quest 1 hash (only same-seed self-compares); precedent
  docs/decisions.md:555 (Dent ghost cars: a DECISION, no re-bless). Check: the HUD's slot keys in
  quest 1, PickupsView is arena-only, `--loadout` is not in KNOWN_FLAGS.
- CHECK 21:39 city block ghost reel (`--arena=city --bot=ghosts --ghost=tonnage --rigs`, 32 px/m, 600
  frames) on `a7ed5d4c`: 0 SCRIPT ERROR; LOOK (frames 126-250 every 4th, 480x300 crops): the ram's
  cream star prints by the cop at the parked car on frames 134-138, the slam's flash and debris on 158-166.
- Scratch cleaned (kept: the 48 px/m audit AVIs for the unscored attacks).

NEXT (written 21:40, for iteration 4):
1. Quest 1 melee (brief 5), per the PLAN entry above: a RivetCarry with one blade in
   `Quest1Session._bind_pilot`, on its slot key, Gloria untouched; DECISION line (quest 1 state hash
   changes, no literal pinned, precedent decisions.md:555); scenarios (quest1_*), a quest 1 film with
   the blade drawn on its path (`res://boot/quest1.tscn`, find the dev flags quest 1 films use).
2. Score Tonnage's plates, Dent's blow and Ohm's mass arc (`--tier=1`) from the 48 px/m audit AVIs
   in scratch; add to `docs/polish/melee.md`; work the weakest.
3. Tonnage ram: the heap of rammed bodies at the car still reads as one blob at 32 (the burst is
   ~20 px); options: a bigger burst only on a kill, or the ram kill's throw (signature row
   tonnage_ram) launching bodies clear instead of piling.
4. Ohm: the bolt's victim impact and the mass arc through a crowd (brief: "without drowning the screen").
5. Merge n7-ranged feel commits as they land (record each).
6. Before freeze: the combined city-block clip of the polished set (30-90 s), the exe (int-day recipe
   in docs/decisions.md), REPORT with calls for the owner: Tonnage stomp's HaulerKick ignores
   `--feel=off`; no per-attack sound cues exist (needs sound assets); Kerf's stop cadence decided by
   ranged (cooldown 16).
- STOP 21:40 iteration 3. Gates on `19c92dd9` full green; scenarios on `0c4161d8` 52/52; later commits
  are view-only (deflect streak alpha, a data doc line): lint 13/13 at each commit hook.

## Iteration 4 (21:38-22:38), phase BUILD
- MERGE 21:41 n7-ranged 48679f03 (quest 1 table guns: StageGuns in collect_call_stage/quest1_session,
  `--quest-guns=off`), 078e83ab (Gloria recoil kick row), docs. Conflict: JOURNAL.md only (kept ours);
  hit_feel.json auto-merged (gloria row, parses). Ranged's NOTE: my quest 1 blade moves the same quest 1
  hash; no committed golden.
- FINDING 21:45: the shipped quest 1 draws Rivet as a sprite (CastView); the held weapon, the swing
  and the smear exist only on the rig cast (dev `--rigs`, debug builds only; hosting the rigs in the
  default quest is rivet-arsenal Call 1, open). So a carried blade in the sim alone would be invisible
  in the shipped quest: the brief's "seen in the shipped quest" needs a sprite-path blade view.
- MILESTONE 21:47 `fbc5a982` quest 1 carries the katana (brief 5, sim): RivetCarry.sheathe (key 2 draws
  it over the story's gun, again puts it away; a story swap = put away), Quest1Session.blade (rng
  stream `quest_blade`), `--quest-blade=off|<id>` in LaunchArgs. test_quest_blade 4/4 (incl. the
  no-sheathe control); unit 1164/1164. DECISION line in docs/decisions.md (quest 1 hash moves, no golden).
- BUILD 21:50 (not committed yet): CastBladeView (boot/collect_call/view) = MeleeWeaponView on the
  sprite's hand point (track_at split out of track), attached in Quest1Game._casts on the sprite path;
  dev: CollectCallInputDriver.blade_ticks + quest1_clip `--blade=<from>-<to>` (the pad draws the
  blade, closes on the bot's target, the held trigger swings, key 2 puts it away).
- MILESTONE 21:54 `8237d411` CastBladeView (the shipped sprite cast draws the carried blade) +
  `3c19d6f8` dev pad `--blade=<from>-<to>`. GATES 21:52 scenarios on `fbc5a982`: 52 ran, 0 failed,
  0 SCRIPT ERROR; quest1 input: beats b1-b6, 49 kills, 65 shots, 0 deaths, 316.58 s, replay identical
  (unchanged); final hash 4aab804f.. -> 589fbbf6.. (the carry state). `evidence/n7-melee/scenarios-fbc5a982.log`.
- LOOK 21:56 quest 1 Dock 9, 32 px/m, ticks 13560-13900 (`--blade=13570-13880`), sheet every 14th
  frame + frames 92-110 every 2nd at x2: the blade is out from frame ~18, lifts (102), cuts down
  (104-106), settles (110); contractors split with blood on the cut. The steel smear (0.4 alpha) is
  invisible on the cream pavement. 48 px/m (frames 40-76 every 4th): the blade reads on the art-tier
  sprite; it starts at his shoulder side (the sprite does not turn with an arm: a guessed hand point).
  CLIP `M/quest1_katana_ab_32ppm.mp4` (before `--quest-blade=off` | after; the before's Rivet shoots
  from range, the after's pad walks him in).
- MILESTONE 21:58 `becfeb7f` the sprite cast's blade smear is cream edged in ink (MeleeWeaponView
  `smear_ink`, set by CastBladeView; the rig path keeps steel). LOOK 48 px/m (steel48 vs ink48, the
  frames that differ: 3, 26, 83; crops x2): steel is a faint grey wedge on asphalt, the cream wedge
  with its ink edge reads. CLIP `M/quest1_katana_smear_ab_48ppm_half.mp4`; the 32 px/m A/B re-rendered
  with the final smear.
- AUDIT 22:00 Dent's blow (NEXT 2): the strike had no feel (hit_feel.json had no `dent_car` row; the
  MeleeFeel class route skips a weapon with no class). Tonnage plates: no spark seen at 48 in the
  every-20th sheet (not measured frame by frame). Ohm mass arc: not in the reel's beat.
- MILESTONE 22:03 `4a522dfe` dent_car row (class ram). MEASURE (arena `--bot=ghosts --ghost=dent`,
  32 px/m, 420 frames; on vs `--feel=off` vs the pre-row data; phase correlation on a 900x600 crop
  against off frame 117): on: (-12, 5) px held frames 117-123 (the stop holds tick 117), then
  (1,-7) (-4,5) (-7,-5) (2,3) ... settling by 130; pre-row = feel-off exactly (0 px differ, frames
  114-130). LOOK (clip frame at the strike): the car, the thrown cop and blood in frame; cops blue.
  CLIP `M/dent_car_blow_ab_32ppm_04x.mp4`. Registry rule applied (realtime-combat-semantics: feel
  keyed to the contact tick and scaled by the hit's class; the cap via FeelBudget stays ranged's).
- DECISION 22:03: Dent's blow takes the `ram` class (a vehicle striking a body = a ram), not `blast`
  (that is the car's explosion, a separate, bigger beat). Alternative: delete the row (not felt).
- GATES 22:11 `node tools/evidence/run.mjs --no-bench` on `29d44643` (clean tree): lint 13/13 over
  952 files, unit 1164/1164, scenarios 52/52, parity bit-exact (planted caught at step 629), selftest
  pass (look goldens 11/11). `evidence/n7-melee/gates-29d44643.log`. No bench: no performance claim.
  FRICTION: the first try refused a dirty tree (JOURNAL edits); commit docs before the evidence run.
- MILESTONE 22:18 `806a657e` Dock 9's fight hint adds ", [2] for the blade" when quest 1 carries one
  (ObjectiveHint; `[slotN]` -> the bound key). test_quest_blade 5/5 (hint absent without a blade);
  unit 1165/1165. Hint key unchanged (SLICE__HINT_FIGHT), so the scenario's hint list does not move.
  Limit: a pad user reads "[2]" (the slot actions have no pad button; weapon_next draws it on a pad).
- Scratch cleaned (quest 1 frames, Dent films; frames.json references only the masters mp4s).
- CHECK 22:16 director reel WITH `--loadout=pistol` on `29d44643` (arena): 19/19 chapters fully down,
  0 SCRIPT ERROR, nothing skipped (`evidence/n7-melee/director-arena-loadout-29d44643.log`). The reel
  does not quit by itself: run it with `--quit-after 7400` (my run hit the 10-min background limit
  after the last chapter, so the city reel never started; re-run on `806a657e`, result below).

NEXT (written 22:20, for iteration 5):
1. Read the city reel + scenarios results appended below (on `806a657e`); re-run a known flake alone.
2. Quest 1 blade hand point (HAND_AHEAD_M 0.45 / HAND_SIDE_M 0.4) puts the grip at his shoulder side
   on the sprite; look at 64 px/m and try the sprite's claw side. quest1_clip `--blade=13570-13880`.
3. Tonnage plates: film a cop firing at Tonnage at 48 px/m every frame; measure whether a spark
   prints at the press (`armor_k`); if nothing reads, a small ink spark per deflected round.
4. Ohm's mass arc: find how to reach upgrade_tier 1 in the ghosts reel, film through a crowd at 32,
   judge "without drowning the screen". Then Ohm's bolt victim impact; Tonnage ram heap at the car.
5. Merge n7-ranged feel commits as they land (record each).
6. Before freeze: the combined city-block clip of the polished set (30-90 s), the exe (int-day recipe
   in docs/decisions.md), REPORT with calls for the owner: (a) quest 1 carries the katana on key 2
   (`--quest-blade=off` / `=electro_baton`; clip `M/quest1_katana_ab_32ppm.mp4`); (b) Tonnage stomp's
   HaulerKick ignores `--feel=off`; (c) no per-attack sound cues exist (needs sound assets); (d) Dent's
   blow feel (`dent_car` row, class ram; delete the row = the before; `M/dent_car_blow_ab_32ppm_04x.mp4`).
- CHECK 22:18 director reel city block (`--arena=city --bot=reel --reel=director --loadout=pistol
  --quit-after 7400`) on `806a657e`: 19/19 chapters fully down, 0 SCRIPT ERROR, exit 0
  (`evidence/n7-melee/director-city-loadout-806a657e.log`).
- MILESTONE 22:19 `5f80e67c` (NEXT 2 done early) quest 1 blade hand point on the sprite's claw side
  (HAND_SIDE_M sign). LOOK 48 px/m (quest1_clip ticks 13580-13780, every 7th frame, 320x240 crops):
  the sprite turns with his facing; the blade now leaves from the wrench-claw side (lower left while
  he faces west), where before (the 21:56 frames) it started over his far shoulder. No side-by-side
  (the old frames were cleaned); the 32 px/m A/B is re-rendered with it (22:20, below).
- GATES 22:21 scenarios on `806a657e` (run beside a quest clip render): 52 ran, 1 failed =
  `scenario_rig_stress` (200 people: rig p50 1.009 ms > 1.0 ms, the known contention flake); re-run
  alone on `5f80e67c`: 1 ran, 0 failed. 0 SCRIPT ERROR; quest1 input pass, final 589fbbf6 (unchanged
  by the hint). `evidence/n7-melee/scenarios-806a657e.log`, `scenario-rig-stress-alone-5f80e67c.log`.
- LOOK 22:23 re-rendered quest 1 A/B (32 px/m, frames 92-110 every 2nd at x2): the blade leaves from
  the sprite's claw side, cuts (104-108), the cream wedge edged in ink on frame 110; contractors split.
  `M/quest1_katana_ab_32ppm.mp4` replaced; frames.json 13 entries (+ the Dent blow clip).
- STOP 22:24 iteration 4. Head: gates full green on `29d44643`; since then a view constant, a hint
  (unit 1165/1165), docs; scenarios 52/52 with the rig flake re-run alone; director arena 19/19
  (`29d44643`) and city 19/19 (`806a657e`). NEXT is the 22:20 entry above (item 2 is done: `5f80e67c`).
- FINDING 22:28 (NEXT 3, measurement only): Tonnage under fire, arena `--bot=ghosts --ghost=tonnage
  --ppm=48`, 330 frames (`scratch/melee/plates_48.avi`), sheet frames 60-180 every 6th, 640x400
  crops: the cops' tracers (small vermilion dashes) reach the press on frames ~84-114 and nothing
  prints where they meet the plates; the press shows no reaction. Not yet checked frame by frame
  (a spark could fall between samples): next iteration, diff frames 80-120 one by one against
  `--feel=off`, then build an ink spark per deflected round if nothing is there.
- FINDING 22:27 (plates, frame by frame 84-113, 360x220 crops at the press's cop side): the cops'
  tracers fly onto the press and their dashes draw ON the press body (frames ~93-104) with no spark,
  no glance and no mark: at 48 px/m the rounds read as passing through Tonnage. Plates scores (48):
  antic. n/a, impact 1, read 1, victim sync n/a, sound 1. NEXT 3 is now a build item: an ink-and-
  cream spark at the plate edge per round that armor_k turns, the tracer cut at the plate (view
  only, data row in ghost_attacks.json tonnage with an off value), gated with a per-tick cap (a
  Gatling cop must not blur the press).
- STOP 22:28 iteration 4 (final). NEXT is the 22:20 entry, with item 3 updated by this finding.

## Iteration 5 (22:27-23:27), phase BUILD
- MERGE 22:28 none: n7-ranged's new commits since 48679f03 (1ce1b11e muzzle flash aim, ed60713e
  gun_fx aim, 41bb90e7 molotov rig_kick, docs/REPORT) touch no hit_feel module or table; not merged
  (their REPORT.md would land in this branch). Re-check before freeze.
- REGISTRY 22:30 applied: realtime-combat-semantics (the impact mark keyed to the contact, scaled by
  the hit: small arms = a small spark; a per-tick cap so a burst never stacks); depth-ordered-layered-
  art (the spark draws on the print layer over the press, the round clipped at the plate face so it
  never draws over the body).
- MILESTONE 22:39 `8375c763` Tonnage's plates stop the rounds (NEXT 3): PlateSparks (features/souls,
  view only, FxView `_shots`): an enemy round's tracer ends at plate_r_m 1.35 from Rivet's spot, its
  first contact prints a cream star edged in ink with a short bounce streak (plate_spark_ticks 6),
  at most plate_sparks_per_tick 2 new a tick; a stopped round stays hidden past the plates. The
  clipped tracer copies FxView's style in use (the plain vermilion dash in the arena, the ink tracer
  under a table gun). Data ghost_attacks.json tonnage + schema; `--feel=off` = the before.
  test_plate_sparks 6/6 (incl. a planted Rivet round and form-off: no spark; the cap); unit
  1171/1171; lint 13/13.
- LOOK 22:35 (arena `--bot=ghosts --ghost=tonnage --rigs`, 330 frames): 48 px/m frames 86-109 every
  2nd, after vs `--feel=off`: before, vermilion dashes draw inside the press; after, they stop at the
  plate and stars print. Pass 1 (plate_r_m 1.2) set the stars inside the hazard stripe (the plates
  are square); 1.35 puts them on it. Pass 1 also drew the clipped round as the 1.2 m ink tracer
  while the arena draws a 0.25 m vermilion dash: fixed to the branch in use before the commit.
  32 px/m x2 crops 90-105: the stars read on the stripe, small. CLIPS `M/tonnage_plates_ab_32ppm.mp4`
  (before | after), `M/tonnage_plates_48ppm_04x.mp4`. frames.json 15 entries.
- DECISION 22:39 plates are a view clip (docs/decisions.md): the sim lands the round at Rivet's radius
  as before; growing the sim hit radius was rejected (moves the hash for a read).
- GATES 22:43 scenarios on `8375c763` (run beside the Ohm films): 52 ran, 0 failed, 0 SCRIPT ERROR;
  quest1 input pass, replay identical, final 589fbbf6 (unchanged: the plates are view only).
  `evidence/n7-melee/scenarios-8375c763.log`.
- AUDIT 22:40 Ohm mass arc (NEXT 4): OhmBeat already takes `--tier=1`; arena `--bot=ghosts
  --ghost=ohm --tier=1 --rigs`, 32 px/m, 600 frames; sheet every 25th, then frames 94-117 every 2nd
  on the cluster. Scores: antic. 4, impact 3, read 2, sync 4 (every body stuns on the bolt tick),
  sound 1. The fan out of the first body drew five ropes as wide as the bolt over six bodies, each
  wearing cream stun squiggles: the cluster drowns.
- MILESTONE 22:44 `454490ce` ohm branch_k 0.55 (view only, OhmView): a hop from a struck body draws
  at 0.55 of the bolt's strokes and flash; 1 or `--feel=off` = the old look. Branches were NOT
  staggered in time (that would put the arc out of sync with the victims' stun on the hit tick).
  Lint 13/13, unit 1171/1171. LOOK: 48 px/m pair matched by tick (feel-off runs 6 ticks ahead with
  no hit-stop: before frame 92 vs after frame 98, both tick 92) and the 32 px/m A/B frame 40 (before
  = the feel-on film from before the change, so the timing matches): the bolt keeps its weight, the
  branches thin, the cops' blue shows through. Modest gain; the stun squiggles are most of the
  clutter and are the reaction view's. CLIPS `M/ohm_mass_arc_ab_32ppm_04x.mp4`,
  `M/ohm_mass_arc_48ppm_04x.mp4` (not in frames.json: the 15-entry cap keeps the wound and claw).
- FRICTION 22:31 films: `--bot=ghosts` given to the default scene is ignored (boot warns "unknown launch
  arg"); use `evidence/n7-melee/film.sh` (it loads res://dev/arena/arena.tscn). Cost one film pair.
### REQUEST 4 -> n7-ranged (22:52): the stun marks under a mass arc
Ohm's mass arc (`--bot=ghosts --ghost=ohm --tier=1`) stuns up to 6 bodies on one tick, and each one
draws ShockJolt.arcs (cream squiggles, ShockArcsView, shared with the electro gun): at 32 px/m the
cluster is a cream blob (`M/ohm_mass_arc_ab_32ppm_04x.mp4`, both halves). Ask: a cap on how many
bodies draw the full arcs at once (e.g. the newest 2 full, the rest a lighter or shorter crawl), as
data with an off value. I have not touched ShockJolt (yours via gunplay's electro). If you would
rather I build it, reply and I will, on the same row you name.

NEXT (written 22:55, for iteration 6):
1. Read the director arena + city reel results appended below (on `454490ce`); re-run a known flake alone.
2. Plates: done to d97a976d (below). Open: film quest 1 with Tonnage under fire (story_forms path).
3. Ohm: n7-ranged's reply to REQUEST 4 (stun marks under a mass arc); if they hand it back, build the
   cap as data. Then the bolt's single-victim impact at 32 px/m.
4. Tonnage ram heap at the car (bodies pile into one blob at 32): a bigger burst only on a kill, or
   the ram kill's throw clear of the heap (signature row tonnage_ram).
5. Merge n7-ranged feel commits as they land (none touched hit_feel since 078e83ab at 22:28).
6. Before freeze: the combined city-block clip of the polished set (30-90 s), the exe (int-day recipe
   in docs/decisions.md), REPORT with calls for the owner: (a) quest 1 carries the katana on key 2
   (`--quest-blade=off` / `=electro_baton`; `M/quest1_katana_ab_32ppm.mp4`); (b) Tonnage stomp's
   HaulerKick ignores `--feel=off`; (c) no per-attack sound cues exist (needs sound assets); (d) Dent's
   blow feel (`dent_car` row, class ram; `M/dent_car_blow_ab_32ppm_04x.mp4`); (e) plates stop rounds in
   the view only, the sim radius unchanged (`--feel=off` = before; `M/tonnage_plates_ab_32ppm.mp4`);
   (f) Ohm branch_k 0.55 (1 = before; `M/ohm_mass_arc_ab_32ppm_04x.mp4`).
- CHECK 22:50 director reel arena (`--bot=reel --reel=director --loadout=pistol --quit-after 7400`) on
  `454490ce`: 19/19 chapters fully down, 0 SCRIPT ERROR, exit 0
  (`evidence/n7-melee/director-arena-loadout-454490ce.log`).
- LOOK 22:50 plates in the city block (`--arena=city --bot=ghosts --ghost=tonnage --rigs`, 32 px/m, 600
  frames; sheets every 30th, 150-184 every 3rd, 270-336 every 6th, 286-309 every frame): no spark
  seen, and no clear enemy round meeting the plates in those windows either (the dashes near the
  press fly away from it). Not proven either way in the city: NEXT 2 stays open (a longer city film,
  or find the tick a cop round lands on Rivet from a log line).
- TRIED and REVERTED 22:52: ram_kill_k (a ram that kills prints the burst 1.6x bigger and holds it
  1.6x longer). Filmed the arena beat (32 px/m, frames 130-149 every 2nd, tick-matched against the
  8375c763 film): identical, because these rams do not kill (the cops survive and pile at the car).
  Not committed: it could not be seen in motion. Re-try only with a beat where a ram kills.
- CHECK 22:53 director reel city block (`--arena=city`, same flags) on `454490ce`: 19/19 chapters fully
  down, 0 SCRIPT ERROR, exit 0 (`evidence/n7-melee/director-city-loadout-454490ce.log`).
- FINDING 22:54 (city plates, temporary spark log, not committed): 49 sparks, the first at tick 40,
  while Rivet was still morphing in (the teal morph disc, no press drawn: frames 58-80 show sparks
  round the disc). HaulerForm.form.on goes true at the start of the morph.
- MILESTONE 22:57 `330779ff` the plates wait for the press: GhostPilot.settled_in(tonnage) and the
  tank's grow (morph_k >= 0.95). Temp log re-run: first spark tick 60 with the grow gate alone (still
  the disc), tick 93 with settled_in (city and arena, 13 sparks in 200 frames each); city frames
  88-110: the press is out, the glances print at its plate. Lint 13/13, unit 1172/1172
  (test_plate_sparks 7/7, planted: one tick into the grow). Trade-off: the press art shows ~7 ticks
  before settled, and there rounds still draw into it (seen in the re-rendered A/B, rows 1-2).
  `M/tonnage_plates_ab_32ppm.mp4` re-rendered on 330779ff.
- STOP 23:00 iteration 5. Head `330779ff` (+ docs): lint 13/13, unit 1172/1172; scenarios 52/52 on
  `8375c763` (later commits view only: Ohm branch_k, the plates gate); director arena 19/19 and city
  19/19 on `454490ce`. NEXT is the 22:55 entry (item 2 replaced above).
- MILESTONE 23:04 `d97a976d` (NEXT 2 done) the plates also spark while the transformation into
  Tonnage is PRESS_K 0.8 through (GhostForms.to_id tonnage, not exiting). Temp-log run (stripped
  before the commit): first spark tick 93 -> 83. LOOK arena 32 px/m frames 76-94 every 2nd: the press
  leaves the morph ring at ~80, the first star prints at 84; frames 80-82 still draw a dash into the
  half-formed press (2-3 ticks, accepted). Lint 13/13, unit 1172/1172. `M/tonnage_plates_ab_32ppm.mp4`
  re-rendered on d97a976d (clip frames 52-72: row 2 the star where the before's dashes enter).
- GATES 23:07 scenarios on `d97a976d`: 52 ran, 0 failed, 0 SCRIPT ERROR; quest 1 final 589fbbf6
  (unchanged all iteration: every change here is view only). `evidence/n7-melee/scenarios-d97a976d.log`.
- STOP 23:08 iteration 5 (final). Head: lint 13/13, unit 1172/1172, scenarios 52/52 on `d97a976d`;
  director arena 19/19 and city 19/19 on `454490ce` (later commits touch only PlateSparks' gate).
  Scratch cleaned (this iteration's films; the 48 px/m audit AVIs kept). NEXT is the 22:55 entry,
  item 2 done (`d97a976d`); open on it: quest 1 with Tonnage under fire.

## Iteration 6 (23:09-00:09), phase BUILD
- READ 23:10 JOURNAL NEXT, git log, n7-ranged JOURNAL: no reply to REQUEST 4 (stun marks under a
  mass arc); their new feel commit 5ef1c584 (the flamer flare, hit_feel.json ignite_flare_k).
- MERGE 23:11 cherry-picked n7-ranged `5ef1c584` (-x; a full merge would land their JOURNAL.md and
  REPORT.md here). One conflict in hit_feel.json `weapons`: kept my rows (chainsaw, claw,
  dent_blast, dent_car, electro_baton), took their flamethrower doc. e32720c4 was already in.
- DECISION 23:12 REQUEST 4 unanswered for 20 min: I build the stun cap myself on the reaction views
  (not the hit_feel module), as data with an off value (docs/decisions.md).
- REGISTRY applied: realtime-combat-semantics (the mark scales with what the player must read:
  the newest victims keep the full read, the rest stay readable as stunned); depth-ordered-layered-
  art (the marks no longer cover the blue uniform layer of a crowd).
- FINDING 23:15 first pass capped only ShockJolt's crawl: the 32 px/m crop showed that most of the
  cream in the cluster is WeaponFxElectro.stun's two head sparks per body (FightAreasArt), which the
  cap did not touch. Moved the ranking into StunCrowd so both views share it.
- MILESTONE 23:25 `7ce7b33d` human_reactions.json stun_crowd (StunCrowd, view only): the 2 newest
  stunned bodies draw the full marks; the rest 0 arcs, 1 spit, 1 head spark. full 0 or `--feel=off`
  = the before. test_stun_crowd 4/4 (planted: full 0 and few bodies give no cap). Unit 1178/1178
  (the one red in the first run was test_noir_shadows, the known flake: green alone and in the
  re-run); lint 13/13.
- LOOK 23:24 arena `--bot=ghosts --ghost=ohm --tier=1 --rigs`, 32 px/m, 3 films (full 0 | arcs 1 |
  arcs 0), cluster crops frames 96-131 every 7th side by side: arcs 1 still left a cream crawl on
  every body; arcs 0 lets the six cops and the riot shield read blue, each still stunned (a spark
  circling the head, a spit). Shipped arcs 0. CLIP `M/ohm_stun_crowd_ab_32ppm_04x.mp4`; frames.json
  top entry (the deflect streak dropped to keep 15).
- CHECK 23:30 director reels on `7ce7b33d` (`--bot=reel --reel=director --loadout=pistol
  --quit-after 7400`): arena 19/19 and city 19/19 fully down, 0 SCRIPT ERROR
  (`evidence/n7-melee/director-{arena,city}-loadout-7ce7b33d.log`). electro_chain 4/4 down.
- GATES 23:33 scenarios on `7ce7b33d`: 52 ran, 0 failed, 0 SCRIPT ERROR, exit 0
  (`evidence/n7-melee/scenarios-7ce7b33d.log`).
### NOTE -> n7-ranged (23:34): REQUEST 4 is closed, I built it
`7ce7b33d`: human_reactions.json `stun_crowd` + `StunCrowd` (features/combat/react). ShockArcsView
and FightAreasArt ask StunCrowd.light_of(arena); ShockJolt.arcs and WeaponFxElectro.stun take an
optional count (defaults unchanged, so a lone electro victim looks as before). If you touch those two
draws, keep the count parameter; `full` 0 turns it all off.
- LOOK 23:37 Ohm's single bolt in the arena (`--ghost=ohm`, no tier), 32 px/m, crops 84-121: the bolt
  is a thick teal stroke with a cream core held ~5 frames, then a cream burst and ink chips off the
  struck body. Reads; no build (the audit's "thin at 32" was before the tell and is not what I saw).
- MILESTONE 23:51 the combined city clip (brief evidence): `M/melee_polished_set_city_32ppm.mp4`, 53 s
  with the game audio cut in sync: the director reel's melee chapters in the city (claw, katana,
  chainsaw, plasma deflect, baton; cut by the HUD tick, since hit-stop runs frames 74-141 ahead of
  ticks by the end) and the four ghost reels in the city (frames 40-400). Head `7ce7b33d`. Top of
  frames.json (dent_blast dropped to keep 15; Dent's blow clip stays).
- FRICTION 23:46 an ffmpeg concat of the AVIs with `a=0` still carried the director AVI's whole audio
  track (110 s) into the mp4; cut the audio per segment instead (atrim at frame/60).
- REPORT.md draft committed (`caaaf26e`), finished at the freeze.

NEXT (written 23:55, for iteration 7):
1. Read n7-ranged's JOURNAL for a reply to the 23:34 NOTE (stun_crowd); cherry-pick any new
   hit_feel commit (-x, keep my `weapons` rows on a conflict) and record it here.
2. Tonnage ram heap (bodies pile into one blob at the car at 32 px/m): find a beat where a ram
   kills (signature row tonnage_ram) before building anything; otherwise make the heap read through
   the view only (e.g. a stagger or flinch per body on contact, already in sync with the shove).
3. Quest 1 with Tonnage under fire (story_forms path): confirm the plates spark in the shipped quest.
4. Sound: every attack scores 1. Check `audio_cues.json` for existing cues that the melee and ghost
   hits could fire on the hit frame (data only, no new assets); if none fit, it stays a call.
5. Raise the weakest re-scored row in docs/polish/melee.md (claw jab small at 32).
6. Before the freeze: re-cut `M/melee_polished_set_city_32ppm.mp4` on the final head if anything
   visible changed; export the exe (the int-day recipe in docs/decisions.md) to
   build/export/windows/RTAI.exe; finish REPORT.md (draft in place: add the exe line and command lines
   per call); gates on the final head.
- STOP 23:56 iteration 6. Head: lint 13/13, unit 1178/1178, scenarios 52/52 and director arena + city
  19/19 on `7ce7b33d` (later commits are docs only).

## Iteration 7 (23:58-00:58), phase BUILD
- READ 23:59 JOURNAL NEXT, git log, n7-ranged JOURNAL to its end: they closed REQUEST 4 on my
  `7ce7b33d` (theirs discarded) and keep off my stun files; one new feel commit `d79c5278`.
- MERGE 00:00 cherry-picked n7-ranged `d79c5278` (-x) as `648e6523` (pistol muzzle_k). One conflict in
  hit_feel.json `weapons`: their `pistol` row placed before my `plasma_deflect`/`plasma_sword` (id
  order). Lint 13/13, unit 1182/1182 after the merge.
- FINDING 00:01 (NEXT 4, sound): StageAudio is the arena's and quest 1's sound, and it hears only
  shots (a round appears / ends). A melee or ghost hit lands through CombatArena.damage, so a
  non-lethal claw jab, a cut, a stomp or a bolt played nothing; a kill only the generic kill punch.
  The shipped bank has impact_metal, impact_flesh, shock_crackle and crash (2 takes each): enough to
  give each attack family its own hit sound with no new asset.
- MILESTONE 00:07 `f593aac4` audio_cues.json `hits` (weapon id -> cue) + six cue rows built from the
  shipped sounds by pitch and gain: melee_claw (metal 0.85), melee_cut (flesh 1.3: katana, plasma
  sword, kerf_slice), melee_grind (metal 0.6, chainsaw), melee_zap (crackle 1.15: baton, claw_shock),
  ghost_slam (crash 0.75: stomp, stomp_wave, ram, dent_car), ghost_bolt (crackle 0.8: ohm_bolt);
  dent_blast -> the existing `blast`. HitCues listens to CombatArena.wounded + kill_landed and plays
  at the victim on the hit tick; the chainsaw grind once per MeleeWound gap. `--hit-cues=off` = the
  before (LaunchArgs). test_hit_cues 5/5; planted fault (the gap gate removed) -> exactly the
  chainsaw test fails (1186/1187); restored 1187/1187. Lint 13/13.
- DECISION 00:07 sound: hit cues reuse the shipped sounds pitched per family rather than wait for
  new assets (a call stays open for real recorded swings/cuts); a kill plays the weapon cue too,
  under the kill punch (the weapon is heard on the kill frame). Alternative = drop a `hits` row.
- LOOK/LISTEN 00:10 A/B films on `f593aac4` (claw_combo director chapter, Tonnage ghost reel, 32 px/m,
  `--hit-cues=off` = before), audio RMS per 1/60 s window, after minus before: the claw film gains
  energy at frames 76-84 and 109-112; sheets put the kills' first blood at 75 and 108 (sound within 1
  frame). Tonnage: onsets at 136, 200, 224, 232, 255, 288, 321, 395; the ram contact star prints at
  135 (sound at 136). The other onsets were not tied frame by frame (the stomp frame is buried in the
  press; not claimed). 0 SCRIPT ERROR in all four films.
- CLIP `M/hit_cues_ab_32ppm.mp4` (6.8 s, back to back off/on, game audio + cream waveform strip);
  frames.json top. Kept the melee wound clip (brief item 2) in frames.json, dropped the quest 1 katana
  smear close-up (quest 1 is covered by its 32 px/m A/B) to stay at 15.
- Audit: systemic finding 2 marked partly done; sound re-scored 1 -> 3 for every attack.
- STOP (iteration 7, written by iteration 8 at 00:25): iteration 7 ended without a NEXT; it left
  ClawMarks (NEXT 5, the claw jab) staged and uncommitted, and its scenarios run on `f593aac4` cut off
  (no summary line). Director arena + city on `f593aac4`: 19/19 + 19/19, 0 SCRIPT ERROR.

## Iteration 8 (00:23-01:23), phase BUILD
- READ 00:23 JOURNAL tail, git log, the staged diff (ClawMarks + test + melee_marks `claw` row).
- FRICTION 00:27 the staged work failed lint (a 107-char comment line; melee_marks.json not canonical
  after a hand edit): fixed, `node tools/art/canon_json.mjs` rewrites a table canonically.
- GATES 00:30 lint 13/13, unit 1191/1191 (`evidence/n7-melee/{lint,unit}-it8.log`). Planted fault
  (the claw weapon check widened to any weapon) -> exactly test_another_weapon_prints_none fails
  (3/4); restored.
- MILESTONE 00:38 `f45ad8e6` ClawMarks: the claw's jab prints three cream rakes edged in ink across
  the victim on the hit frame (melee_marks.json `claw`: rake_m 1, gap_m 0.22, flash_ticks 10).
  flash_ticks 0 or `--feel=off` = the before. A data-only "before" for the film (flash_ticks 0 on
  the same head) so the pair differs by the rakes alone, not by the whole feel layer.
- LOOK 00:36 director `--chapter=claw_combo` at 32 px/m, after vs before, 2x crops of frames 72-79
  and 104-111: the rakes print on frame 74 (first blood 75) and 106, square to Rivet -> cop, held by
  the hit-stop; at real 32 px/m (640x360 crop) the three stripes read over the cop. The rakes cover
  the cop's blue for ~10 frames: accepted (it is the claw's signature on the hit, short). 48 px/m
  close-up at 0.4x looked at (both kills). CLIPs `M/claw_rake_ab_32ppm.mp4` (3.9 s),
  `M/claw_rake_48ppm_04x.mp4`; frames.json top (dropped the older melee_feel_claw clip, superseded).
- Audit: claw row re-scored impact 2 -> 3, read 3 -> 4 (ranked item 3).
- CHECK 00:34 director reels on `f45ad8e6` (`evidence/n7-melee/reels.sh`): arena 19/19 and city
  19/19 fully down, 0 SCRIPT ERROR (`evidence/n7-melee/director-{arena,city}-loadout-f45ad8e6.log`).
- READ 00:31 n7-ranged JOURNAL to its end: two new feel commits, `50c0883b` (Gloria muzzle_k 1.8)
  and `193bc529` (machine pistol muzzle_k 1.3); no REQUEST to melee. Merge after the scenarios run.
- FINDING (NEXT 3, by code, not filmed): quest 1 draws through CollectCallView -> FxView, the same
  view that owns PlateSparks and ClawMarks, so the plates and the claw rakes are on the shipped
  quest path. Not filmed: the quest bot never takes Tonnage, so it stays "unseen in quest 1".
- TRIED and REVERTED 00:36 (NEXT 2, the ram heap): ink speed lines bridging each rammed body's
  shove (`ram_smear_s` 0.12; the sim moves a body stomp_knock_m 2.2 m in one tick). Filmed the
  arena Tonnage reel at 32 px/m, after vs `ram_smear_s` 0, 2x crops of frames 133-140 (contact at
  tick 135): on screen the cop does not jump 2.2 m (the car stops it and the press follows right
  behind), so the lines lie under the press body; a few grey ticks peek out at 135-137. Not
  visible in motion: not committed (files restored, test moved to scratch). The heap is the
  sim's shove into the car; a view-only fix has to draw *on* the bodies, not behind them.
- FINDING 00:38 (victim sync, the ram heap): the arena Tonnage film logs `react: 0 wounds`. A ghost hit
  lands through CombatArena.damage; `struck` carries rounds only and ReactLink heard `wounded` for the
  five melee ids, so a rammed or slam-thrown body that lives played no rig reaction at all.
- MILESTONE 00:48 `91700e01` human_reactions.json `ghost_wound` (ram, stomp, stomp_wave -> blast =
  knockdown) via ReactLink._on_wounded and MeleeWound's gate; a ghost blow passes a riot slab like
  melee (`_ghost_blow` set by apply(); `_wound`'s 5-arg shape kept so the other lanes' tests do not
  move: FRICTION, the first try changed it and load_all failed on test_melee_wound's old calls).
  test_ghost_wound 5/5; planted fault (ReactLink back to melee only) -> exactly the ram test fails.
  Lint 13/13, unit 1196/1196 (`evidence/n7-melee/{lint,unit}-it8b.log`).
- LOOK 00:46 arena Tonnage reel: 1 wound (first pass: 1 on a shield, the riot cop's block sparks;
  after the slab fix 0 on a shield), not visible: the slam kills him ~20 frames later. City reel
  (`--arena=city --bot=ghosts --ghost=tonnage --rigs`, 600 ticks, before = ghost_wound {}): react 2
  wounds vs 0; difference frames from 142 (the ram contact) at the press's right; 2.5x crops of
  145/155/165/175: before the riot cop stands braced behind his shield arc, after he is laid out along
  the shove; the slam kills him at ~175 in both. Read at real 32 px/m in the clip's frame. CLIP
  `M/ghost_wound_ram_ab_32ppm.mp4`; frames.json top (dropped ohm_tell's crop clip to keep 15).
- DECISION 00:49 (docs/decisions.md): ghost_wound is data; Dent's car and Ohm's bolt are left out (the
  car's direction is not Rivet -> victim; the bolt stuns through FightAreas). Alternative = add a row.
- Audit: ram victim sync 3 -> 4; read stays 2 (the heap is the sim's shove).
- MERGE 00:51 cherry-picked n7-ranged `50c0883b` (Gloria muzzle_k 1.8) as `f1e9c76e` (clean) and
  `193bc529` (machine pistol muzzle_k 1.3) as `f17890ef` (-x). One conflict in hit_feel.json
  `weapons`: kept my `katana` and `kerf_slice` rows, took their machine_pistol doc. Lint 13/13, unit
  1197/1197 on `f17890ef` (`evidence/n7-melee/{lint,unit}-f17890ef.log`).
- READ 00:57 n7-king / n7-servo journals: no REQUEST to melee.
- REPORT draft updated (`3e4ab417`): hit sounds, claw rakes, ghost wounds rows; call (g) (a ghost blow
  past the riot slab); "does not" rewritten (sounds reuse the bank; the heap tries; plates unfilmed in
  quest 1).
- Scratch: this iteration's AVIs deleted (747 MB); 13 older AVIs kept as possible re-cut sources.

NEXT (written 00:58, for iteration 9):
1. Read n7-ranged's JOURNAL to its end; cherry-pick any new hit_feel commit (-x; on a `weapons`
   conflict keep my melee/ghost rows, take theirs for guns) and record it here.
2. The ram heap is still read 2, the weakest craft score. A view-only fix has to draw *on* the
   bodies (the shove's speed lines lie under the press; reverted). Candidates: a per-body ink outline
   pop on the contact frame so each rammed cop separates from the pile, or the knockdown family's
   travel along the shove (human_reactions `knockdown` travel_m) if it is short at 32. Film the city
   reel (`--arena=city --bot=ghosts --ghost=tonnage --rigs`, contact ~142) before building.
3. Dent's seized-car blow on a body that lives: no ghost_wound row (the direction is the car's, not
   Rivet -> victim). If it matters on film, give MeleeWound.hit a dir from arena.hit_dir for that
   weapon, then add `dent_car` to ghost_wound.
4. Before the freeze (08:30): re-cut `M/melee_polished_set_city_32ppm.mp4` on the final head (claw
   rakes and the ghost wounds changed what is seen); export the exe (the int-day recipe in
   docs/decisions.md) to build/export/windows/RTAI.exe; finish REPORT.md (exe line, command lines
   per call a-g); gates on the final head (lint, unit, scenarios, director arena + city,
   `node tools/evidence/run.mjs`).
- CHECK 00:59 director reels on `f17890ef`: arena 19/19 and city 19/19 fully down (every chapter's
  `N/N down`), 0 SCRIPT ERROR (`evidence/n7-melee/director-{arena,city}-loadout-f17890ef.log`).
- TRIED and REVERTED 01:00 (NEXT 3 early): ghost wounds thrown along `arena.hit_dir` (every ghost
  hit sets it just before damage(): the stomp's press-head push, the ram's blend, Dent's car heading),
  plus `dent_car` and `dent_blast` -> blast in ghost_wound. test_ghost_wound 6/6, melee 7/7. Dent
  arena reel at 32 px/m, before = no Dent rows: react 1 wound vs 0; difference frames from 156 at a
  cop in the cluster by the car's nose; 2.5x crops of 154/162/172/185: a few pixels in a dense
  cluster, then the blast covers it. Not visible in motion: reverted. For iteration 9: the hit_dir
  part is still right for the stomp's direction; land it with a film where a slam survivor is thrown
  off to the side (city Tonnage reel), not on Dent.
- GATES 01:04 scenarios on `f17890ef`: 52 ran, 1 failed, 0 SCRIPT ERROR. The one red was
  scenario_city_chase's 2 ms nav budget (max 4536 us), the known flake, run while I filmed Dent beside
  it; re-run alone: 1 ran, 0 failed (`evidence/n7-melee/scenario-city-chase-alone-f17890ef.log`).
- STOP 01:05 iteration 8. Code commits: `f45ad8e6` (claw rakes), `91700e01` (ghost wounds), merges
  `f1e9c76e` + `f17890ef`. Head gates on `f17890ef`: lint 13/13, unit 1197/1197, scenarios 52/52
  (city_chase flake green alone), director arena + city 19/19, 0 SCRIPT ERROR. Later commits are docs
  only. NEXT is the 00:58 entry above (items 1-4).
- SCOUT 01:09 (for NEXT 2, no build): HitLink (CastView's cream impact star behind the victim via
  `hit_link.flash(f)`, and HitLink knockback) hears `struck` only; MeleeFeel lands melee and ghost
  hits on FeelCam (camera) only, never on HitFeel.land, so the victim flash rows (`ram` flash_ticks 8,
  `melee` 6...) never light a melee or ghost victim. Candidate for the ram heap: call HitFeel.land's
  flash part (no reaction signal: ReactLink already plays the wound) from MeleeFeel for ghost hits,
  so each rammed body gets its own star on the contact. Check first whether the arena rig path draws
  `_impact` at all (CastView is quest 1's sprite cast; the arena films use `--rigs`).
- GATES 01:17 `node tools/evidence/run.mjs --no-bench` on `470c8e33` (code = `f17890ef`): exit 0, lint
  13/13, unit 1197/1197, scenarios 52/52, parity bit-exact over 1200 steps (planted mutation caught at
  629), selftest look goldens 11/11, block 5/5 (`evidence/n7-melee/evidence-run-470c8e33.log`). The
  first run (01:11) marked unit FAIL only because I appended to JOURNAL during it ("tree changed
  during run"; 1197 passed); re-run with the tree untouched. Bench not run (contended; no lock taken).
- STOP 01:18 iteration 8 (final). NEXT = the 00:58 entry (1-4) plus the 01:00 hit_dir note and the
  01:09 scout.

## Iteration 9 (01:19-02:19), phase BUILD
- READ 01:19 JOURNAL tail (NEXT 00:58 + 01:00 hit_dir note + 01:09 scout), git log, n7-ranged JOURNAL
  to its end (FYI 00:49: three feel commits; `193bc529` already in as `f17890ef`), king/servo: no
  REQUEST to melee.
- MERGE 01:21 cherry-picked n7-ranged `d99106f4` (weapon_fx_spin, `spin_whirl_m`) as `7ec7ac46` and
  `ce923514` (gatling whirl 0.8) as `b915e863`, both clean (-x).
- FRICTION 01:27 unit on the merge went red (`evidence/n7-melee/unit-b915e863-red-missing-last_aim.log`:
  load_all parse error, weapon_fx_spin.gd reads `GunHand.last_aim`, added by n7-ranged `1ce1b11e`,
  which their FYI did not list). Redid the merge in order with `git reset --keep 70d12961` (tree
  clean bar JOURNAL) and cherry-picked `1ce1b11e d99106f4 ce923514` -x as `ac548347 c955172e
  ab8cf8d0`, so no broken commit sits on the branch. Lint 13/13, unit 1201/1201 on `ab8cf8d0`
  (`evidence/n7-melee/{lint,unit}-ab8cf8d0.log`).
- FINDING + FIX 01:36 (`c48b2806`): the city Tonnage reel logged 6 engine `ERROR: Invalid polygon
  data, triangulation failed` at `RamMarks._chip` (not SCRIPT ERROR, so the reels' count missed it).
  Cause: city positions ~500 m = ~16000 canvas px at 32 px/m; a 4-6 px quad in absolute coordinates
  is degenerate in float32 (Godot's Geometry2D failed 1 of 200 such quads in a probe; the renderer
  is pickier). SlamDebris.chip now draws the quad around the origin under a draw transform (the
  HaulerMarks pattern) and RamMarks uses it. City reel after: 0 such ERROR, react 2 wounds as before
  (`evidence/n7-melee/city-tonnage-{before,after}-chipfix.log`). LOOK: difference blend of the two
  600-frame films: only frames 250, 261, 268 differ, by single pixels (the outline drew before;
  only the fill dropped). Log hygiene, no visible change: not filmed as an A/B.
- LOOK 01:31 the ram in the city at 32 px/m (2x crops, frames 134-162 every 4th): 138 burst star
  past the riot cop; 142-146 he and a second cop at the car's bonnet slip under the press's turning
  arm; 150 the riot cop is thrown clear with the chips (the ghost wound, `91700e01`); 158 the slam.
  The bonnet cop stays under the press: that is the heap.
- FINDING 01:34 (why the heap): GhostFormView draws the form at rigs z + 60 (`Z_OVER_RIGS`, a
  ghost-forms decision: no human head or arm over a ghost body), and the sim lets a rammed body sit
  inside the press's footprint against the car. So any body the press overlaps is hidden, whatever
  marks the view prints. A view-only fix must either pop the struck body over the form for the
  shove (breaks the ghost-forms rule) or the sim must keep bodies out of the footprint (sim change,
  re-bless). Neither tonight: the riot cop's throw already reads in the city; recorded as a call.

### REQUEST 01:49 to n7-ranged (low priority): Kerf's cuts at player cadence
Kerf's chain cuts every `gap_s` 18 ticks at full player cadence, but the camera rig allows one stop
per `camera.json hitstop_cooldown_ticks` 20 (`core/render/camera_rig.gd:118`), so only every other
cut holds (the director reel presses every 20 ticks, so the films hold every cut). Options, yours to
pick since the cooldown gates every gun's stop too: (1) a per-weapon `stop_cooldown` override in
hit_feel.json `weapons` (kerf_slice 16) passed to `CameraRig.hitstop`; (2) camera.json cooldown 18
(stops at most 3.3 a second instead of 3.0, for every gun). I build neither; if you land (1) I add
the kerf_slice value and film it.
- MILESTONE 01:36 combined city clip re-cut on `bd36c37c` (NEXT 4's first part, early):
  `M/melee_polished_set_city_32ppm.mp4`, 44 s, game audio cut per segment, 0 SCRIPT ERROR in all
  9 films. New and re-runnable: `evidence/n7-melee/set_clip.sh <tag>` films each melee chapter
  alone (`--chapter=<id>`: frame 0 = the chapter start, so hit-stop drift never moves a cut; the old
  cut read HUD ticks off one long director film) and each ghost reel, then concats with atrim per
  segment; `RECUT=1` re-cuts the scratch AVIs without filming. LOOK: the first cut (chapters from
  frame 0, 59.5 s) spent ~4.5 s per melee chapter on the walk-up (in the city the cops come in
  first: claw kills ~330-360, katana ~330, chainsaw ~390-450, baton ~330, on 30-frame sheets); trimmed
  to the kill windows. Sheet every 2 s: every tile shows an attack. frames.json entry updated.
- CHECK 01:40 reels + scenarios on `bd36c37c` (code = `c48b2806`): director arena 19/19 and city
  19/19 fully down (14x 1/1, 2x 2/2, 3x 4/4), 0 SCRIPT ERROR; scenarios 52 ran, 0 failed
  (`evidence/n7-melee/{director-arena,director-city,scenarios}-*bd36c37c.log`).
- TRIED, not built 01:38 (the ram's anticipation, 2): an ink speed wake behind the press while
  HaulerForm.ramming(). The city beat has no charge to show it on: the press morphs over frames
  60-90, then creeps ~1 m in 35 frames into the cops (charge sheet). Needs a beat that charges first.
- TRIAL EXE 01:38 (NEXT 4 de-risk): bake_city + `--export-release windows-showcase
  ../build/export/windows/RTAI.exe` exit 0, 245 MB (`evidence/n7-melee/it9-{bake,export}.log`).
  Booted call (h)'s line `RTAI.exe --screen 0 --rendering-driver d3d12 -- --arena=city --bot=ghosts
  --ghost=tonnage --rigs --ppm=32` under Movie Maker: exit 0, no unknown flag, 0 SCRIPT ERROR, the ram
  star at 138 and the slam at 170 as in the editor (react 1 wound vs the editor's 2: not chased).
  `--quest-blade=off|electro_baton`, `--hit-cues=off --feel=off`: accepted, 0 SCRIPT ERROR. But the
  showcase exe boots the arena hub; quest 1 is the slice feature's main scene, and a release
  template refuses a scene path ("compiled without support for path overrides").
- BLOCKER FOUND + FIXED 01:44 (`87d7dc2b`): the windows-slice exe (the shipped quest 1) on this branch
  failed to compile quest1_game.gd: 5 SCRIPT ERROR, `Could not find type "ArenaRigs"` at
  plasma_scorch_view.gd:24, through collect_call_view -> melee_feel -> react_link. dev/ is not in
  the slice export. My `65dd07e1` (MeleeFeel in CollectCallView, iteration 2) put that chain on the
  quest path; ReactLink -> PlasmaScorchView -> ArenaRigs is combat-notes' (on main). MeleeFeel used
  ReactLink only for MELEE_IDS: the list moves to MeleeWound and ReactLink aliases it. Re-exported
  to `build/export/windows-slice/RTAI.exe`: the title card loads, 0 SCRIPT ERROR (no autostart flag
  to go past it; GDScript resolves class names at compile, so quest1_game's static closure compiled).
  Guard: `test_slice_closure.gd` walks quest 1's class-name closure (comments and strings stripped)
  and fails on any res://dev/ script; planted fault (MeleeFeel back on ReactLink) -> fails with
  exactly `ArenaRigs <- plasma_scorch_view.gd`. Lint 13/13, unit 1204/1204.
- FYI to the Director and every lane (01:46): the slice export drops dev/; a dev class name anywhere
  on quest 1's static path kills the shipped game at load, and no gate caught it (the gates run in
  the editor, where dev/ exists). `test_slice_closure.gd` now catches it in the unit gate; run it on
  each merge. corpse_fade.gd and brutality_hook.gd also name ArenaRigs but are off quest 1's path today.
- DECISION 01:46: two exes at the freeze. `build/export/windows/RTAI.exe` (windows-showcase: the arena
  and city calls b-h) and `build/export/windows-slice/RTAI.exe` (windows-slice: quest 1, call a).
  Both presets default to the same path; the slice one is redirected on the command line.

NEXT (written 01:53, for iteration 10):
1. Read n7-ranged's JOURNAL to its end: cherry-pick new feel commits -x **with their prerequisites**
   (check that each commit's new names exist on this branch: `1ce1b11e` was missed once, 01:27), run
   unit before committing the merge note. Look for a reply to the 01:49 REQUEST (Kerf cooldown).
2. Freeze (by 08:30), in this order: gates on the final head (lint, unit, scenarios, reels.sh,
   `node tools/evidence/run.mjs --no-bench`); `bash evidence/n7-melee/set_clip.sh <head>` (the
   combined city clip, ~7 min; look at a 2 s sheet); bake_city + both exes: `--export-release
   windows-showcase ../build/export/windows/RTAI.exe` and `--export-release windows-slice
   ../build/export/windows-slice/RTAI.exe`; boot each once (showcase: call (h)'s line; slice: the
   title card, 0 SCRIPT ERROR); finish REPORT.md (exe lines per call a-h, gates).
3. Build candidates (weakest first): the ram's anticipation (2) needs a charging beat: check
   whether the ghost reel can drive the press at top speed into a line (a dev beat change, not
   sim), then an ink speed wake behind the press while `ramming()`; Dent's blow on a survivor
   (01:00 note: ghost wounds along `arena.hit_dir` for the stomp, filmed on a slam survivor thrown
   sideways in the city reel).
4. If the Director merges other lanes onto quest 1's path, `test_slice_closure` is the check.
- LOOK 01:50 Tonnage wave 2 in the city (frames 230-340): the press turns and wades ~1-2 m in 110
  frames into the slam's pile at the car. Neither ram in the reel happens at speed, so a ram wake
  would show nothing on the live paths without a charging beat (NEXT 3).
- CHECK 01:56 reels + scenarios on `87d7dc2b` (the slice fix): director arena 19/19 and city 19/19
  fully down, 0 SCRIPT ERROR; scenarios 52 ran, 0 failed
  (`evidence/n7-melee/{director-arena,director-city,scenarios}-*87d7dc2b.log`).
- FRICTION 01:51 `tools/evidence/run.mjs` refuses an untracked log in the tree ("working tree is
  dirty", exit 2): commit reel logs before the evidence run.
- GATES 02:03 `node tools/evidence/run.mjs --no-bench` on `317e86f2` (code = `87d7dc2b`), tree
  untouched during it: exit 0, lint 13/13 (967 files), unit 1204/1204, scenarios 52/52, parity
  bit-exact over 1200 steps (planted caught at 629), selftest look goldens 11/11, block 5/5
  (`evidence/n7-melee/evidence-run-317e86f2.log`). Bench not run (contended, no lock).
- STOP 02:04 iteration 9. Code commits: `ac548347 c955172e ab8cf8d0` (n7-ranged merges incl. the
  missed prerequisite), `c48b2806` (chips in local space), `87d7dc2b` (the shipped quest 1 starts
  again + test_slice_closure). Docs: call (h), set_clip.sh + the 44 s city clip, trial exes, the
  REQUEST on Kerf's cooldown. NEXT is the 01:53 entry (items 1-4). Scratch: this iteration's AVIs
  deleted; 13 older AVIs kept.

## Iteration 10 (02:05-03:05), phase BUILD
- READ 02:05 JOURNAL NEXT (01:53), git log, n7-ranged JOURNAL to its end (it11 stop 01:56): no new
  hit_feel / feel_cam / camera commits since `ce923514` (merged it9). Their it11 code (`9054e346`
  muzzle on the drawn tip, `8766508f`/`cb98ccd4` molotov wind-up, `63d2a29e` bad --weapon) is
  ranged-weapon art, not the feel layer: not merged (the Director merges branches).
- WITHDRAWN 02:08 my 01:49 REQUEST (Kerf's cuts vs the stop cooldown): stale. n7-ranged decided it
  at 20:46 (`0d4089f1`, camera.json `hitstop_cooldown_ticks` 16), merged here as `20f2263d`; this
  branch's camera.json reads 16 (CameraRig.stop_cooldown loads it; the 20 at camera_rig.gd:21 is
  only the pre-load default), so every 18-tick cut gets its stop. REPORT's "does not" line on it
  removed.
- DECISION 02:08 the plasma sword asset (backlog 3) is now in scope: brief items 1-5 all carry
  evidence; the one weak score left (the ram heap, read 2) is call (h), not buildable view-only.
- IMAGE 02:08-02:09 one Codex round under `gtai-n5/image.lock` (gen.mjs copy in
  `gtai-n7p/scratch/melee/plasma`; refs: the old held_long.png and katana/held.png; no weapon noun
  beyond "heat-blade tool prop"): ok in 60 s, one image, kept in `masters n7/melee/gen/plasma/`
  with jobs.json. Looked at: the old hilt kept, a pronged collar, a tapering paper-white blade in an
  ink ring with five ink arc strokes; no teal, no vermilion on the blade.
- BUILD 02:12 `4540d259`: `tools/art/plasma_blade_fit.py` keys (weapon_cut.key), keeps the largest
  component, fits to the old length_px 526 + 6 px margin: 538x101 vs the old 539x100, grip x 53,
  bore row 50 (was 48), muzzle 531. weapon_art.json numbers updated; provenance row appended. The
  film needed a combo on a body (the deflect chapter cuts nobody): `ReelChapters.extras()` holds a dev
  `plasma_sword` blade chapter (lone cop at 2.6 m), reachable only by `--chapter=`; the cut stays 19.
- LOOK 02:13 before/after (`--chapter=plasma_sword --loadout=pistol --clean --rigs`, 330 ticks, 0
  SCRIPT ERROR all four films, same kill frame): 48 px/m frames 44/84/96 at 3x: the after tapers to a
  point and the arc strokes show as a broken centre line; the before is a square-ended plank. 32 px/m
  at 3x: close to identical (46 px long). Honest result: a detail gain at 48 and up, nothing at 32.
  Call (i) in REPORT; audit 7f; decision line. Clip `M/plasma_sword_blade_ab_32ppm_48slow.mp4`
  (5.9 s) + still `M/plasma_sword_blade_ab_48ppm_3x.png`; frames.json row 0 (dropped
  tonnage_ram_ab from the list to stay at 15; the file stays, REPORT names it).
- GATES 02:20 on the asset tree: lint 13/13, unit 1204/1204.
- CHECK 02:19 director reels on `4540d259` (the asset): arena 19/19 and city 19/19 fully down (14x
  1/1, 2x 2/2, 3x 4/4), 0 SCRIPT ERROR (`evidence/n7-melee/director-{arena,city}-loadout-4540d259.log`).
- LOOK 02:20 the arena Tonnage film at 48 px/m (every 30th frame): after the slam the press chases the
  scattering cops at 4.2 m/s; there is no clean charge in either live path, so the ram wake (NEXT 3)
  stays unbuilt (01:38 note holds). The plasma sword's swing already draws its own hot-cream smear
  (MeleeSmearView.tint_of), so a "hot" cue at 32 px/m needs nothing more on the swing.
- SOUND 02:17 a swing whoosh (the audit's open sound gap): the shipped bank has no whoosh-like
  sound, and the only generator (`tools/audio/gen_sfx.py`) is a paid ElevenLabs call; the lane cannot
  listen to a synthesized one. Not built; stays a call.
- FINDING 02:25 (capture, not game): every film of this lane (and n7-ranged's: their film.sh,
  film_chapter.sh, cut.sh pass `--resolution 1280x720`) drew the HUD layers ~70 px left of the world:
  the ghost card read "onnage", the telemetry box lost its first letters. The project viewport is
  1280x800 with stretch expand: a 16:9 window widens the viewport to ~1422x800, and the movie keeps
  the centred 1280, so a HUD anchored 36 px from the left edge lands at about -35. In a real 16:9
  window the full width shows, so the game is fine (the world framing is identical in both films).
  film.sh now takes `RES` and defaults to 1280x800; `clean_test800` frame 150 shows the whole card 36
  px from the edge. set_clip.sh now films with `--clean` (no dev telemetry box over the owner's
  clip; the game HUD stays). Both take effect at the freeze re-cut.

### FYI 02:26 to n7-ranged: your films cut the HUD at the left edge
Your `evidence/film.sh`, `film_chapter.sh` and `cut.sh` pass `--resolution 1280x720`; the project
viewport is 1280x800 (stretch expand), so the movie keeps the centre 1280 of a ~1422-wide viewport and
every HUD layer lands ~70 px left (the ghost card's "Tonnage" reads "onnage"). The world is framed the
same either way. `--resolution 1280x800` fixes it (checked on a city Dent film). Matters only for
clips the owner sees with a HUD; your before/after pairs are consistent among themselves.
- CHECK 02:27 scenarios on `4540d259`: 52 ran, 0 failed (`evidence/n7-melee/scenarios-4540d259.log`).
- MILESTONE 02:28 combined city clip re-cut on `3efd6d47` (code `4540d259`) with --clean at 1280x800:
  44.2 s, 0 SCRIPT ERROR in all 9 films. LOOK (sheet every 1.5 s): no telemetry box, the ghost card
  whole at the bottom left in every segment, every tile still shows an attack. frames.json note and
  REPORT line updated. Scratch AVIs from it kept for a RECUT at the freeze if the code does not move.
- LOOK 02:31 Tonnage in quest 1's real view (`dev/ghost-powers/quest_hauler_rec.tscn --ppm=32`, 360
  PNGs, 0 SCRIPT ERROR; quest_hauler: stomps 1, stomp_hits 1, ram_hits 3, kills 4): the ram's cream
  bursts (RamMarks, `0c4161d8`) print on the dock guards on the ram kills (frames ~124-170), the slam
  ring and blood read. Small stars by the press head at 84-88 could be plate sparks or slam chips:
  not proven (the recorder's ring guards may not fire). Still
  `M/quest1_tonnage_ram_marks_32ppm.png`; REPORT's "not filmed" line rewritten. PNGs deleted.
- GATES 02:39 `node tools/evidence/run.mjs --no-bench` on `5e466b7f` (code `4540d259`), tree untouched:
  exit 0, lint 13/13, unit 1204/1204, scenarios 52/52, parity bit-exact over 1200 steps (planted
  caught at 629), selftest look goldens 11/11, block 5/5 (`evidence/n7-melee/evidence-run-5e466b7f.log`).
  Bench not run (contended, no lock).
- BUILD 02:44 `9a2d3137`: the plasma sword's pickup (floor ring, wall rack) and HUD icon still showed the
  plank blade; both now come from the new part (`plasma_blade_fit.py --icon`: pickup fit to the old
  487 px width, so PickupsView/WeaponRackView draw it at the same size; icon = pickup padded 8 px
  through weapon_cut.icon). Looked at both PNGs (the icon silhouette tapers to the point). Provenance
  rows appended. Unit 1204/1204 on the tree. Not filmed (the pickup ring is not on the reel paths).

NEXT (written 02:35, for iteration 11):
1. Read n7-ranged's JOURNAL to its end: cherry-pick new hit_feel / feel_cam / camera commits -x with
   their prerequisites (check each new name exists here), unit before the merge note. Their it11
   code (muzzle on the drawn tip, molotov wind-up) is weapon art, not the feel layer: not merged.
   Check for a reply to the 02:26 FYI (film resolution).
2. Freeze (by 08:30), in order: gates on the final head (lint, unit, `bash evidence/n7-melee/reels.sh
   <head>`, `node tools/evidence/run.mjs --no-bench` with the tree untouched and logs committed
   first); `bash evidence/n7-melee/set_clip.sh <head>` only if code moved since `4540d259` (else
   the 02:28 cut stands; look at a 1.5 s sheet); bake_city + both exes: `--export-release
   windows-showcase ../build/export/windows/RTAI.exe` and `--export-release windows-slice
   ../build/export/windows-slice/RTAI.exe`; boot each once (showcase: call (h)'s and call (i)'s
   lines; slice: the title card, 0 SCRIPT ERROR); finish REPORT.md (exe lines per call a-i, gates,
   drop "DRAFT").
3. Build candidates, weakest first (all small; the big ones are owner calls): Tonnage's plates in
   quest 1: proven 02:44 (below); (the plasma sword's pickup and icon: done 02:44, `9a2d3137`); call (b) (route the
   stomp's stop and shake through FeelCam so --feel=off covers it) if the owner's page wants it.
4. `test_slice_closure` is the check for any merge onto quest 1's path.
- LOOK 02:44 Tonnage's plates in quest 1 (NEXT 3, closed): quest_hauler_rec now logs the plate
  sparks on screen (dev only, `_count_sparks`): 274 of 330 ticks, max 12 at once (= the cap, 2 a
  tick x 6 ticks), 0 SCRIPT ERROR (`evidence/n7-melee/quest1-hauler-rec-plates.log`). 2x crops of
  frames 60/64/100/104/200/204: small cream stars on the press's flank, not a blur; the ram's big
  star at 200. Still `M/quest1_tonnage_plates_32ppm_2x.png`; REPORT line updated. PNGs deleted.
- STOP 02:52 iteration 10. Code commits: `4540d259` (plasma sword held blade + dev plasma_sword
  chapter), `9a2d3137` (its pickup and icon), `4b43491e` (quest 1 Hauler recorder counts plate
  sparks, dev only). Gates: full evidence run green on `5e466b7f` (code `4540d259`); reels 19/19 x2 and
  scenarios 52/52 on `4540d259`; unit 1204/1204 on `9a2d3137`'s tree; lint 13/13 on `4b43491e`.
  Docs: withdrawn Kerf REQUEST, call (i), audit 7f, decision line, film.sh 1280x800 + set_clip
  --clean (city clip re-cut on `3efd6d47`), FYI to n7-ranged on film resolution, quest 1 Tonnage
  ram marks and plates evidenced. NEXT is the 02:35 entry (items 1-4; item 3's first two closed).
  Scratch: this iteration's AVIs and sheets deleted; the set_* AVIs kept for a RECUT; plasma/out kept
  (copy in masters).

## Iteration 11 (runner iteration 12; 02:53-03:53), phase BUILD
- READ 02:53 JOURNAL NEXT (02:35), git log, n7-ranged JOURNAL to its end (it14, 02:44). New on their
  branch since my last merge: `5c171ed8` (tune hit_feel: mini-nuke launch kick), `311684d4` (its
  test), plus rig/art fixes (`9df494f6` molotov rise, `5586a80e` tube side): rig code, not the feel
  layer, not merged. No reply to my 02:26 FYI yet.
- MERGE 02:55 `4c2cc4a2` + `ce8c039b` (cherry-pick -x of n7-ranged `5c171ed8`, `311684d4`; clean,
  fire_kick_px was already here). Unit 1205/1205 after the merge.
- Registry rules applied this iteration: motion-quality-gating (judge the sequence, not a still;
  A/B at 32 then 48), realtime-combat-semantics (anticipation names the target before the active
  frame, without moving the active frame).
- BUILD 03:00 `96e1abe6` Kerf's sight (audit row 1, antic. 2 = the weakest untouched craft score):
  a dashed teal sighting line to the body the next press cuts and a white two-bracket lock on it,
  at sight_k x (0.4 + 0.6 x gap refill), none without a charge. View only: KerfStage.sight_aim (the
  last aim, not in write_state) + ready_k(); KerfView._sight calls pick(). Tests: the sight names
  the next cut, dims on the blink, refills with gap_s, its aim is not sim state; planted no-floor
  fails 3 asserts (a first plant made a parse error: not a clean plant, redone). kerf_stage.gd 208
  lines (soft warning only).
- LOOK 03:05 first pass: the cut tick on the target hid under the cop; the squared ramp from 0.25
  read faint mid-gap. Changed to brackets outside the body and linear from 0.4. Looked at again
  (32 px/m frames 98-120 every 2nd, 150-290 every 10th; 48 px/m 94/110): the first cut is called
  across 6 m, the lock on the next cop shows 4 frames after each cut; no sight once the charges are
  spent (correct). Same sim frames before and after.
- FRICTION 03:01 the pre-commit lint caught a 116-char doc line: the commit did not land, re-done.
- CLIP `M/kerf_sight_ab_32ppm_48slow.mp4` (7.3 s) + still; frames.json row 0 (kerf_chain dropped
  from the list to stay at 15; its file stays, REPORT names it). Audit antic. 2 -> 4, REPORT row and
  call (j), decision line.
- LOOK 03:07 Kerf's sight in the city block (`--arena=city --bot=ghosts --ghost=kerf`, 32 px/m,
  every 8th frame 70-229, 0 SCRIPT ERROR): the dashed teal line reads on the dark asphalt to the
  cops by the ambulance; the lock shows on the next cop after each cut.
- FRICTION 03:05 the background reels on `96e1abe6` ran while I edited the RamWake files: their city
  and scenario logs are not a clean read of any commit. Deleted; re-run on `bc788d09`. Same lesson
  for data flips: the 48 px/m before film set ram_wake_k 0 for ~40 s while the bc788d09 arena reel
  ran (a view value only, it cannot change a chapter's pass); restored from a copy. Next time film
  befores before starting a gate.
- BUILD 03:09 `bc788d09` RamWake (audit 7b, Tonnage ram antic. 2): a bow wave of two swept arcs
  (cream in ink) and flank dust streaks while HaulerForm.vel > 0.8 x ram_mps, full at ram_mps;
  TonnageView and CastView (quest 1) draw it. ghost_attacks.json tonnage ram_wake_k (0 = before).
  Test test_ram_wake (off below 0.8, grows in, capped); planted ram_wake_k 0 fails 3 asserts.
- LOOK 03:08 first pass (wave 0.45-0.55 m past the 0.9 m body) lay under the press art (the form
  draws over TonnageView; the press is drawn ~0.7 m past its body, the gear arms 1.1 m): only faint
  cream curves through the press. Moved to 1.3-1.5 m: the arc rides outside the press ahead of the
  cops at the car (110) and the riot cop (222, the ram burst at 232). Antic. 2 -> 3, not more: the
  live beats have no long charge, only a close shove at ram speed.
- CLIP `M/tonnage_ram_wake_ab_32ppm_48slow.mp4` (9.3 s) + still; frames.json row 0
  (plasma_deflect dropped from the list; its file stays, REPORT names it). REPORT row + call (k),
  audit 7b, decision line.
- FRICTION 03:11 a unit run without GODOT_BIN exported reports "import exit -1 ... (1205 passed)":
  the runner re-reads a stale result. Not a test result; log deleted, re-run.
- LOOK 03:14 RamWake in quest 1's real view (`dev/ghost-powers/quest_hauler_rec.tscn --ppm=32`, 0
  SCRIPT ERROR; ram_hits 3, kills 4 as before): the cream arc rides round the press as it pushes east
  through the dock guards (frames ~105-130), ahead of the ram bursts. Still
  `M/quest1_tonnage_ram_wake_32ppm.png` (frames 100-175 every 5th). PNGs deleted.

NEXT (written 03:17, for iteration 12):
1. Read n7-ranged's JOURNAL to its end: cherry-pick new hit_feel / feel_cam / camera commits -x
   (check prerequisites), unit with GODOT_BIN exported. Last merged: `5c171ed8`, `311684d4`.
2. The combined city clip is stale since `96e1abe6` (Kerf's sight) and `bc788d09` (the ram wake):
   re-cut with `bash evidence/n7-melee/set_clip.sh <head>` (code-moved path, not RECUT) and look at a
   1.5 s sheet; the old set_* AVIs are stale.
3. Freeze (by 08:30), in order: gates on the final head (lint, unit, `bash evidence/n7-melee/reels.sh
   <head>`, `node tools/evidence/run.mjs --no-bench`, tree untouched, logs committed first; never
   edit or flip data while a gate runs); bake_city + both exes (`--export-release windows-showcase
   ../build/export/windows/RTAI.exe`, `--export-release windows-slice
   ../build/export/windows-slice/RTAI.exe`); boot each once (calls (h)-(k) lines; slice title card);
   finish REPORT.md (exe lines per call a-k, gates, drop "DRAFT").
4. Build candidates, weakest first: Dent seize read 3 (camera call open: impact only); Ohm bolt read
   3 at 32 (the bolt is thin); the ram heap (call h, not view-buildable). Call (b) only on the owner's
   word.
- GATES 03:20 on `bc788d09` (Kerf's sight + the ram wake), tree untouched by code during them:
  unit 1208/1208 (GODOT_BIN exported); scenarios 52 ran, 0 failed, 0 SCRIPT ERROR; director reels
  arena 19/19 and city 19/19 fully down (14x 1/1, 2x 2/2, 3x 4/4), 0 SCRIPT ERROR
  (`evidence/n7-melee/{unit,director-arena-loadout,director-city-loadout,scenarios}-bc788d09.log`).
- MILESTONE 03:21 combined city clip re-cut on `d4c3ccc9` (code `bc788d09`): the Kerf and Tonnage
  segments refilmed (the only code that moved since `4540d259`), the other seven from the existing
  AVIs (RECUT=1): 44.2 s, 0 SCRIPT ERROR in all 9 films. LOOK (1.5 s sheet over 20-38.5 s): every
  tile shows an attack, the ghost card whole. NEXT 2 is done unless code moves again.
- GATES 03:29 `node tools/evidence/run.mjs --no-bench` on `af4eff02` (code `bc788d09`), tree
  untouched, GODOT_BIN exported: exit 0, lint 13/13 (969 files), unit 1208/1208, scenarios 52/52,
  parity bit-exact over 1200 steps (planted caught at 629), selftest look goldens 11/11, block 5/5
  (`evidence/n7-melee/evidence-run-af4eff02.log`). Bench not run (contended, no lock).
- READ 03:27 (for NEXT 4) Ohm's bolt strokes are already 10/6/2.5 px (ink/teal/core) with a 0.22 s
  hang (ohm_view.gd INK_W/TEAL_W/CORE_W, HANG_S): a thicker bolt is not the lever. The likely gap
  at 32 px/m is the world mark where the bolt lands (ink-and-paper scorch/burst on the struck
  body or car, as RamMarks/DeflectMarks do); film the bolt at 48 px/m first and score it.
- LOOK 03:33 (prep for NEXT 4) Ohm beat at 48 px/m (`--bot=ghosts --ghost=ohm --rigs --clean`, 0
  SCRIPT ERROR; crop 760x420 frames 84-131 every 3rd): the bolt reads strongly (thick jagged teal on
  ink, ~13 frames of hang, then the tell's white reach sparks rebuild); the second bolt (129) lands
  on the cop cluster with ink-and-white star sparks and the x-ray. The first bolt (90-111) runs past
  the cops to the right edge of the crop: its landing (a car? the beat's no-body-in-cone press)
  was not in frame. Next: a full-frame look at frames 90-115 to see what it strikes and whether
  that landing prints a world mark; score Ohm bolt impact/read again before building anything.
- STOP 03:34 iteration 11 (runner 12). Code commits: `4c2cc4a2` + `ce8c039b` (n7-ranged merge:
  mini-nuke launch kick), `96e1abe6` (Kerf's sight), `bc788d09` (Tonnage's ram wake). Gates: full
  evidence run green on `af4eff02` (code `bc788d09`); reels 19/19 x2, scenarios 52/52, unit 1208 on
  `bc788d09`. Clips: `kerf_sight_ab_32ppm_48slow.mp4`, `tonnage_ram_wake_ab_32ppm_48slow.mp4` (+
  stills, quest 1 ram wake still), city clip re-cut. Calls (j), (k) added. NEXT is the 03:17 entry
  (item 2 done at 03:21; item 4: Ohm per the 03:33 look). Scratch: this iteration's AVIs deleted;
  the set_* AVIs are current for a RECUT.
- LOOK 03:35 (closes the 03:33 open question) Ohm at 48 px/m, full frames 88/91/94/100: the first
  bolt strikes the near cop and forks on to the robot thug behind; the robot's landing prints white
  star sparks edged in ink (100), so a world mark exists. The weak read is the hop on the first
  cop: the bolt line runs straight across that body and hides it. Candidate for NEXT 4: break the
  stroke at a struck body (draw the bolt to the body's rim and on from the far rim, or draw the
  struck body's x-ray above the bolt) so each link of the chain lands on a visible body. View only;
  film A/B at 32 and 48 first.

## Iteration 12 (runner iteration 13; 03:33-04:33), phase BUILD
- READ 03:33 JOURNAL NEXT (03:17) + the 03:33/03:35 Ohm looks, git log, n7-ranged JOURNAL to its end
  (it14 stop 03:21, call-6 look 03:25, FYI 03:26 on the blast lead in the feel layer).
- MERGE 03:34 `da1e6a22` + `94dce278` (cherry-pick -x of n7-ranged `8efe76ca`, `a63bd8e0`: BlastLead,
  the camera leads toward the mini-nuke's shell, capped at 300 screen px; feel layer, view only;
  clean). Not merged: `d4559823` (ranged weapons' shot audio, not the feel layer). Unit 1212/1212
  after the merge, GODOT_BIN exported (`evidence/n7-melee/unit-94dce278.log`).
- Registry rules applied: motion-quality-gating (A/B at 32 then 48 on the same sim frames, judge the
  sequence), depth-ordered-layered-art (a mark must not cover the body it marks: the stroke stops at
  the rim instead of being drawn into the body under the actor).
- FINDING 03:38 (corrects the 03:35 look) full-res crops at 48 px/m, frames 91-99: the first bolt
  never struck the near cop. It strikes the robot thug directly and only passes over that cop's
  head (no flash, no stun on the cop). The cop sits on the bolt's straight line; it is not a link.
- BUILD 03:40 `a27fb59c` Ohm's rim (NEXT 4): OhmView stops each stroke ghost_attacks.json ohm rim_m
  (0.6 m; a body is 0.45) short of a struck body, the hop leaves from its far rim, and the body gets
  a crackling ink-and-white ring (5 arcs, re-cut every other tick) instead of the solid white disc.
  A hop too short for two rims and 0.3 m of stroke draws body to body. View only. Test test_ohm_rim;
  planted rim_m 0 + no trim fails 4 asserts.
- LOOK 03:42 (b/a at 32 and 48, single bolt, plus tier-1 mass arc at 48, 0 SCRIPT ERROR in all 7
  films): the robot's torso (the white ring-eye) now reads inside the ring where the stroke used to
  vanish into it, at both scales. Tier-1: the cops' rings are faint under the stun stars, no gain
  there and no added clutter. A small gain, not a step: impact 3 -> 3, read 3 -> 3+ (audit 7g).
- CLIP `M/ohm_bolt_rim_ab_32ppm_48slow.mp4` (3.3 s) + still `M/ohm_bolt_rim_ab_32_48ppm.png`;
  frames.json row 0 (tonnage_slam dropped from the list to stay at 15; its file stays, REPORT names
  it). REPORT row + call (l), decision line.
- GATES 04:00 on `a27fb59c` (the Ohm rim), tree untouched by code during them: director reels arena
  19/19 and city 19/19 fully down (14x 1/1, 2x 2/2, 3x 4/4 each), 0 SCRIPT ERROR; scenarios 52 ran,
  0 failed, 0 SCRIPT ERROR (`evidence/n7-melee/{director-arena-loadout,director-city-loadout,
  scenarios}-a27fb59c.log`). Unit 1216/1216 with test_ohm_rim (the 03:39 run).
- LOOK 03:52 Dent's beat at 32 px/m (`--bot=ghosts --ghost=dent --rigs --clean`, every 20th frame):
  the blast is a 0.45 s fireball and ink ring over the car, which then lies dark among the bodies;
  nothing of the car leaves the blast. The lever is debris (the press slam's lesson), not the camera
  (the owner's open call). Drafted BlastDebris in scratch while the gate ran.
- TIME NOTE 03:52: `date` reads 03:51 at the Dent commit; my hand-written stamps above ran ~10 min
  fast (the "GATES 04:00" entry was at about 03:49; "LOOK 03:52" at about 03:45). Stamps below are
  from `date`.
- FRICTION 03:48 copying the scratch draft in overwrote `tests/unit/test_blast_debris.gd`: the name
  belongs to n5-look's rocket debris test (WeaponFxDebris, table blast_debris.json). Restored it from
  HEAD at once (`git checkout HEAD -- <path>`, one path, my own overwrite); never committed. It also
  showed that a debris drawer already exists, so the Dent-only BlastDebris draft was dropped.
- BUILD 03:50 `5c4219b2` Dent's blast debris (audit 7, impact 3): DentView draws WeaponFxDebris at
  the blast (scaled from Ink's 48 px/m to the view's ppm): ghost_attacks.json dent blast_debris 1;
  0, --feel=off or --blast-debris=off = the before. Test test_dent_blast_debris; planted 0 fails.
- LOOK 03:51 (b/a at 32 and 48 on the same sim frames, 0 SCRIPT ERROR): the slabs fly out over the
  cops past the ink ring at 32; at 48 the blast sits at the frame's right edge (camera on Dent, the
  open call) and the slabs fly back into frame. Impact 3 -> 4 (audit 7). CLIP
  `M/dent_blast_debris_ab_32ppm_48slow.mp4` (3.7 s) + still; frames.json row 0 (dent_car_blow dropped
  from the list, its file stays), REPORT row + call (m), decision line.
- LOOK 03:53 Dent's slabs in the city block (`--arena=city --bot=ghosts --ghost=dent --rigs --clean`,
  32 px/m, every 8th frame 140-260): the slabs draw far from the origin (no float32 drop-out), fly
  over the ambulance and the cops. The log's one ERROR is the exit-time "resources still in use"
  line, present in the before films too.
- MILESTONE 03:55 combined city clip re-cut on `5c4219b2`: Dent and Ohm segments refilmed, the other
  seven reused (RECUT=1), 44.2 s, 0 SCRIPT ERROR in all 9 films. LOOK (sheet over the Dent and Ohm
  segments): the slabs fly from the car bomb; the bolts land. frames.json note updated.
- GATES 04:01 on `5c4219b2` (Ohm rim + Dent debris), tree untouched by code during them: unit
  1219/1219; director reels arena 19/19 and city 19/19 fully down (14x 1/1, 2x 2/2, 3x 4/4 each),
  0 SCRIPT ERROR; scenarios 52 ran, 0 failed, 0 SCRIPT ERROR
  (`evidence/n7-melee/{unit,director-arena-loadout,director-city-loadout,scenarios}-5c4219b2.log`).
- FRICTION 04:02 `node tools/evidence/run.mjs` exits 2 on a dirty tree, and its own log written into
  evidence/ made the tree dirty. Re-run with the log in /tmp, copied in after.
- GATES 04:08 `node tools/evidence/run.mjs --no-bench` on `be852011` (code `5c4219b2`), tree clean,
  GODOT_BIN exported: exit 0, lint 13/13 (973 files), unit 1219/1219, scenarios 52/52, parity
  bit-exact over 1200 steps (planted caught at 629), selftest look goldens 11/11, block 5/5
  (`evidence/n7-melee/evidence-run-be852011.log`). Bench not run (contended, no lock).
- LOOK 04:04 chainsaw re-scored from the city set film at 2x (the only weak cell never re-scored after
  its fix): the halves read apart after the parting burst. Read 2 -> 3 (audit item 5).
- READ 04:03 n7-ranged JOURNAL to its end: nothing new in the feel layer since `a63bd8e0` (merged);
  `d4559823` is shot audio (not merged). No REQUEST to melee in n7-king / n7-servo.

NEXT (written 04:09, for iteration 13):
1. Read n7-ranged's JOURNAL to its end: cherry-pick new hit_feel / feel_cam / camera commits -x
   (check prerequisites), unit with GODOT_BIN exported. Last merged: `8efe76ca`, `a63bd8e0`.
2. Freeze (by 08:30), in order: gates on the final head (lint, unit, `bash evidence/n7-melee/reels.sh
   <head>`, then `node tools/evidence/run.mjs --no-bench > /tmp/<log>` on a clean tree, log copied
   in after; never edit or flip data while a gate runs); bake_city + both exes (`--export-release
   windows-showcase ../build/export/windows/RTAI.exe`, `--export-release windows-slice
   ../build/export/windows-slice/RTAI.exe`); boot each once (calls (h)-(m) lines; slice title card);
   finish REPORT.md (exe lines per call a-m, gates, drop "DRAFT").
3. The combined city clip is current on `5c4219b2`. Re-cut only if code moves (refilm the moved
   segments with film.sh set_<name>, then `RECUT=1 bash evidence/n7-melee/set_clip.sh <head>`).
4. Build candidates, weakest first: the claw and chainsaw anticipation (3); Dent read 3 (the camera
   call sets where the blast lands: impact only); the ram heap (call h, not view-buildable). Ohm's
   tier-1 rings are faint under the stun stars (no gain there, none needed). Call (b) only on the
   owner's word.
- STOP 04:09 iteration 12 (runner 13). Code commits: `da1e6a22` + `94dce278` (n7-ranged merge: the
  nuke blast lead), `a27fb59c` (Ohm's rim), `5c4219b2` (Dent's blast debris via WeaponFxDebris).
  Gates: reels 19/19 x2 + scenarios 52 on `a27fb59c` and on `5c4219b2`; unit 1219; full evidence run
  green on `be852011`. Clips: `ohm_bolt_rim_ab_32ppm_48slow.mp4`, `dent_blast_debris_ab_32ppm_48slow.mp4`
  (+ stills), city clip re-cut. Calls (l), (m) added. Scratch: the ohm_rim_* and dent_* AVIs deleted;
  the set_* AVIs are current for a RECUT.
- SCOUT 04:12 (for NEXT 4, no build): the claw's anticipation can't be judged from the city set
  film (the camera moves; two blind 2x crops missed Rivet). Next iteration: film the claw alone,
  `bash evidence/n7-melee/film.sh claw48 48 420 --bot=reel --reel=director --chapter=claw_combo
  --loadout=pistol --lone --clean`, then a 48 px/m sheet of the wind-up before each hit frame (74,
  106 in the arena chapter) and score the anticipation before building anything (the d7 blade hold
  measures the arc from the forearm line: keep it). Launch flags checked: `--blast-debris=off` is
  n5-look's own flag (read from the OS args, not in KNOWN_FLAGS; boot only warns on unknown flags),
  so calls (l) and (m) need no new flag.
- STOP 04:13 iteration 12 (final). NEXT is the 04:09 entry (items 1-4) plus the 04:12 claw scout.
- LOOK 04:15 (closes the 04:12 scout early) the claw alone (`film.sh claw48 48 200 --bot=reel
  --reel=director --chapter=claw_combo --loadout=pistol --lone --clean`, 0 SCRIPT ERROR; 1.5x crop of
  frames 62-100 every 2nd): the jab's wind-up is a small pull of the claw arm in to the chest over
  about frames 64-70 (~10 px at 48 px/m), then the arm crosses the cop at 72 and the rakes print on
  74; the second blow (the kill) has the same short pull. Antic. 3 holds: it reads at 48 and barely
  at 32. Build idea for NEXT 4: a deeper view-only pull-back of the claw arm (and a shoulder turn)
  in the frames before the hit, the hit frame unchanged (realtime-combat-semantics: anticipation
  without moving the active frame); find where the rig poses the jab (MeleeSwing / the claw rig
  part) and check it against the d7 hold (the off claw is an open owner call: touch only the main
  claw's jab). Film deleted (scratch).
