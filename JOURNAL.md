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
