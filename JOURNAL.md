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
