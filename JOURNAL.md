# JOURNAL - lane gunplay (night 2026-11-04, branch n-gunplay)

## Iteration 1 (01:05-02:05), BUILD

- 01:05 Read: evening REPORT (largest gap: CombatArena direct hits only), AGENTS, arena README,
  combat_arena.gd, gun_hand.gd, impact.gd, projectile_sim.gd, hit_link.gd. No other night lane has a
  JOURNAL yet (brutality, human-reactions, rivet-arsenal, showcase, weapon-art checked 01:12).
- Registry rules applied (realtime-combat-semantics): one damage chokepoint, the kill payload decided
  before the lethal hit lands, sim state in ticks with no RNG in the area model.

### REQUEST 1 -> brutality, human-reactions: the kill-event payload (proposal, 01:15)
`CombatArena.kill_landed(victim: Fighter, weapon: StringName, dir: Vector2, at: Vector2, kind: StringName)`,
emitted from the one chokepoint `CombatArena.damage()` right after `Events.actor_killed`, for every
lethal hit on a non-Rivet fighter, in the arena, the city block and the quest.
- `weapon`: the weapons.json id (`pistol`, `rocket_launcher`, `plasma_rifle`...) or quest ids
  (`gloria`, `assault-rifle`); `&"burn"` for a damage-over-time or fire-patch kill.
- `dir`: unit vector of the hit (the round's travel, the blast centre -> victim, the chain hop).
- `at`: the hit point in metres (on the round's path; the victim's position for burn).
- `kind`: the events.json death kind: `shot` (bullets, bolts), `blown` (rocket direct + splash),
  `burned` (flame, molotov, burning, fire patches). Non-lethal hits keep `CombatArena.struck`.
Agree by replying in your JOURNAL; I will not change the shape without a line here.
- 01:20 MILESTONE real-fight area model: `FightAreas` + `FighterFx` (features/combat/weapons), wired into
  CombatArena (lazy with the first GunHand shot), `Shot.spec`, rockets/bottles end at the aim point.
  DECISION chain through humans (flag), DECISION burn lethal (dot_s 3.5). Unit 700/700 (5 new in
  test_fight_areas.gd); scenarios 28/28 (`evidence/n1/scenarios-a.log`), lint 13/13.
- FRICTION: python on Windows writes CRLF in text mode; use newline='' (fixed before commit).
- FRICTION: bash heredoc with a long GDScript body failed to parse in the Bash tool; use Write.
- 01:15 FRICTION: `dev/gunplay/pistol_fight.tscn` (evening's quest-1 dock clip) renders blank paper on the
  merged tree after the first frame (camera off the drawn stage; no errors in run.log). Not chased:
  the brief's target is the arena / city block, so clips move there.
- 01:20 MILESTONE arena wiring: station `data/tables/arena_stations/gunplay.json` (`gunplay_range`) names
  `GunplayHook`: `--weapon=<id>` arms Rivet with the table gun on the arena's real CombatArena
  (GunHand + FightAreas + GuardTell + HitLink knockback). Without `--weapon` the arena keeps Gloria,
  so the arena scenarios do not move. `--bot=gunplay` (GunplayBot) fights the pit at the weapon's
  own reach (0.75 x range, <= 13 m), skipping burning guards. One small edit in the arena lane's
  `dev/arena/arena_game.gd` (the bot switch) and `tests/unit/test_arena_hooks.gd` (it assumed no
  shipped station has a hook; it now finds the probe hook by type).
- DECISION arena default weapon stays Gloria tonight (the table gun only with `--weapon`): flipping the
  arena to the table pistol changes the pit and range scenarios' measures; revisit once the weapon
  switch (rivet-arsenal) lands. Alternative = arm in GunplayHook.setup when no --weapon is given.
- 01:22 MILESTONE `FightAreasArt` (drawn by FxView): rocket body + exhaust + wobbling smoke trail, blast
  as a comic starburst + ink shock ring + smoke + debris, flame puffs that grow and fade (fx_fire
  loop), electro zigzag bolt + chain arcs, molotov arc over its ground shadow, fire patches over an
  ink scorch, burning humans (fire on the figure), stun sparks.
- Clips (CONTENDED GPU): `MASTERS/n4/gunplay/arena_rocket_pit_32ppm/` (10 rockets, 10 kills, 10
  knockdowns, pre-starburst art), `arena_flame_pit_32ppm/` (--rigs --clean, 68 puffs, 5 ignitions, 5 kills).
- Gates: lint 13/13, unit 700/700 (`evidence/n1/unit-d.log`), scenarios 28/28 (`evidence/n1/scenarios-c.log`).
- FRICTION: run_unit.mjs needs GODOT_BIN exported (it silently reports "import exit -1"); gdformat on
  Windows writes CRLF (normalised by git); editing a script while scenarios run fails that scenario.
- 01:35 MILESTONE `scenario_gunplay_fight`: the core six in the REAL fight (CombatArena + GunHand +
  FightAreas) at a knot of five contractors for 6 s: identical hash on the same seed, the planted
  fault (one contractor 5 cm off) caught for every weapon, and each behaviour shows (rocket
  knockdowns, flame/molotov ignitions + burn kills + patches, electro chain hits + 4 stunned at once).
  Evidence `evidence/n1/gunplay-fight.json`.
- 01:31 FRICTION->fix: in the arena the molotov never landed (24 throws, 0 ignitions): `StagePilot` sets
  `fire_at = rivet + aim * aim_range_m` because TickInput carries a direction only, so bottles flew to
  full range. DECISION: a thrown weapon lands on the living hostile closest to the aim line within
  0.2 rad and its range (`FightAreas.lob_target`), else at the aim point. Alternative (a real aim
  distance in TickInput) is an input-schema change for later. Flame puffs enlarged (0.4 -> 1.15 x a
  2.5 m fire cell over the puff's life) and fire on burning humans 0.85: at 32 px/m the old puffs read as dots.
- Gates after the fix: lint 13/13, scenarios 29/29 (`evidence/n1/scenarios-e.log`), unit 701/701 (`unit-e.log`).
- DEBT: fight_areas.gd is 254 lines (soft 200): split the patches + lob into their own file next.
- 01:36 Panic run bends (`PANIC_TURN_RAD` 0.015/tick, side by id): in the 32 px/m flame clip burning
  cops ran straight out of the pit and off the floor. GunplayBot max reach 13 -> 9 m so a 48/64 px/m
  camera that follows Rivet frames the impact (the 64 px/m rocket clip had its blasts at the edge).
  Molotov patch flames: 2.5 cells per metre of radius at 0.6-0.9 x a fire cell (they read as dots).
- Arena electro: stuns and kills (7 at 64 px/m) but no chain hops in the pit: the pit's guards stand
  > 4 m apart (chain_radius_m 4). The chain is proven in scenario_gunplay_fight (10 hops, 4 stunned
  at once). Needs a clustered station (range dummies on a metal post line) for the clip.
- 01:40 Gates: lint 13/13, scenarios 29/29 (`evidence/n1/scenarios-f.log`), unit 701/701 (`unit-f.log`). Electro bolt + chain arcs now a 10-11 px ink zigzag with a 4 px cream core (`FightAreasArt._bolt`).
- 01:44 frames.json written: `C:\Users\kazda\kiro\gtai-masters\n4\gunplay\frames.json` (10 entries, every
  file checked to exist; I looked at contact sheets / sequence crops of every clip). Removed the
  blank quest-dock render and the pre-rig rocket clip.

### REQUEST 2 -> human-reactions: the area states to animate (01:45)
`arena.areas.effect(fighter) -> FighterFx` (null until something landed): `burn_ticks > 0` = burning
(play a flailing run; FightAreas already moves the body along `flee`), `stun_ticks > 0` = stunned
(twitch in place), `down_ticks > 0` = knocked down (lie along the last hit dir, get up when it hits 0;
54 ticks). Deaths: `CombatArena.kill_landed` (REQUEST 1) with kind `burned` / `blown` / `shot`.

### REQUEST 3 -> weapon-art (01:45, low priority, after the pistol/machine pistol art)
For FightAreasArt: a rocket body cell (top-down, ~0.9 m), a flame-puff loop (the quest's `fx_fire`
stands in now), a scorch decal (ink, 2-4 m), an electro spark cell. Chroma-green part sheet as usual.

### REQUEST 4 -> rivet-arsenal (01:45)
Switching Rivet's weapon in the real fight = `arena.gun = GunHand.make(WeaponTable.shipped(), id,
ctx.rng.stream(&"gunplay"))`; `CombatArena.areas` is built with the first GunHand shot and keeps its
fires/burns across a switch. The arena hook (`GunplayHook`) arms only with `--weapon=`; if you add a
switch, the hook can step aside (tell me in your JOURNAL).

NEXT (iteration 2, in order):
1. Riot blood cost (brief item 5): read `features/fx/combat_blood.gd` + `features/fx/noir/blood_fx.gd`
   (`draw_us`, `settled_every`, `queue_redraw` at line ~175), print `CombatBlood.spent_us/frames` and
   `BloodFx.draw_us` into the bench JSON, `settled_redraw_ticks` 6 -> 30, redraw only changed pools;
   bench before/after under `C:\Users\kazda\kiro\gtai-n4\bench.lock` (`node tools/bench/run.mjs`).
2. Pistol and machine pistol finished in the arena + city block (`--arena=city`): `--weapon=pistol
   --bot=gunplay --rigs --clean` at 32 and 64 px/m; shell casings + wall/ground impact decals + the
   muzzle flash per weapon in FightAreasArt (bullets still draw FxView's tracer).
3. The electro chain in a clip: a clustered station (dummies 2-3 m apart) or a `--bot=gunplay` wave
   that bunches. Rockets burst on arena walls (ArenaDodges.cull removes them silently today).
4. Split fight_areas.gd (254 lines): patches + lob into their own file.
5. Re-render molotov/electro 32 px/m with the new patch flames and thick bolts; side-by-side clip.
- 01:45 MILESTONE riot blood redraw split (brief item 5, first cut, NOT benched yet): `BloodFx` drew every
  pool and decal again on each tick while any droplet flew (in a riot: always). The flying drops now
  draw on their own child canvas item (`_drops_view`, parent's material, redrawn every tick while
  drops fly); the pools/decals redraw only when busy or every `settled_redraw_ticks` (6, unchanged).
  `BloodFx.drops_us/drops_draws` added; `CombatBlood.spent_us` now includes the drops' redraw.
  Look goldens 11/11 unchanged (worst mean 0.020 of 4.0; `evidence/n1/look/run.log`), unit 700/701
  with the known `test_noir_shadows` load flake (2/2 alone), scenarios 29/29 (`scenarios-g.log`).
  NEXT: bench riot before/after under bench.lock, then settled 6 -> 30 and bake settled pools.
- 01:50 MEASURE bench after the blood split (b3b3c92f; exported windows-bench, 1 run x 4 x 30 s, under
  bench.lock) - CONTENDED (other lanes rendering; not an idle number): riot p99 7.305 ms, avg 1.926 ms,
  1 % low 104 fps, rigs p99 0.648; drive p99 5.336 / avg 1.094; drive48 p99 2.565. The gate line says
  MISSES p99CpuMs (7.305 > 7) under this load. NO before was taken on the same load, so this proves
  nothing yet about the split (the bisect's contended tip avg was 2.06 ms; idle record riot p99 6.007).
  Raw: `evidence/n1/bench/bench-*.json`, log `evidence/n1/bench-after.log`. FRICTION: the bench export
  needs `build/export/windows-bench/` to exist in a fresh worktree (mkdir it first).
- NEXT (replaces the 01:45 list, in order):
  1. Riot A/B on the SAME load, back to back under bench.lock: this tree vs `git worktree` at 3bf98d63
     (before the split), riot only if run.mjs allows, else all 4 x 30 s; add `CombatBlood.spent_us /
     frames`, `BloodFx.draw_us`, `drops_us` into the bench JSON (dev/bench/city_bench.gd metrics);
     then settled_redraw_ticks 6 -> 30 and re-check look goldens (junction + `--site=block`).
  2. Pistol + machine pistol finished in the arena and city block (`--arena=city --weapon=pistol
     --bot=gunplay --rigs --clean`, 32 + 64 px/m): casings, wall/ground impact decals, per-weapon muzzle.
  3. Electro chain clip (clustered targets); rockets burst on arena walls (ArenaDodges.cull).
  4. Split fight_areas.gd (now ~258 lines).
  5. Side-by-side clip of the core six (5 s each, sound off) once 2 lands; re-render molotov/electro.

## Iteration 3 (01:53-02:53)
- Read: JOURNAL, git log, REQUESTs addressed to gunplay in n-brutality, n-human-reactions, n-showcase.
- Registry rules applied (realtime-combat-semantics, motion-quality-gating): presentation reads the sim,
  never writes it (GunFx is view-only, stepped on the stage tick, hash-varied, no RNG stream), so the
  replay and parity goldens cannot move; judged in motion at 48 and 32 px/m on the cast rigs.
- 01:57 MEASURE riot blood A/B (brief item 5), riot only, 4 x 30 s back to back under bench.lock,
  CONTENDED: settled 6 / 30 / 6 / 30 -> p99 8.68 / 6.33 / 6.47 / 7.16 ms; the combat blood itself is
  59 / 41 / 50 / 49 us a frame (CPU: step + pool + drop redraw), pool redraws 301 vs 61 in 30 s.
  `evidence/n3/riot-blood-ab.md`, raw `evidence/n3/bench/`. The bench JSON now carries
  `bloodUsPerFrame`, `bloodPoolDraws`, `bloodDropDraws` (01b034aa).
- DECISION settled_redraw_ticks stays 6: after the drop split the blood is 0.04-0.06 ms a frame (~1 % of
  the riot p99); 30 saves ~5-10 us, inside the noise, and would step the pool growth visibly and move
  the look goldens. Alternative = one value in blood_fx.json. The riot p99 is not the blood any more:
  the next suspect is the 400 actors' canvas / rigs, not this lane's.
- 02:12 MILESTONE GunFx + GunFxArt (features/combat/weapons, data gun_fx.json): every bullet gun reads
  as its weapon in the real fight (arena pit, city block, quest path through FxView when a table gun
  is wired): pistol = a long forward flare with two side jets (3 ticks), heavy 12 px tracer, 0.24 m
  brass shells, a big smoke puff; machine pistol = a 4-point star that turns half a step every shot
  (a strobe), 7 px tracer, small shells piling up, small puffs that haze; a magazine drops on reload
  and a ring fills over Rivet; impacts by surface: ground = dust kicked back + an ink scuff (4 s),
  metal = cream sparks, Rivet's plating (enemy rounds) = cream sparks, a body = a short ink burst
  (the red comes from the combat blood). Unit `test_gun_fx.gd` 4/4.
- DECISION shell colour `#b8913f` (a muted brass; red is blood only, vermilion is danger): one palette
  value in gun_fx.json.
- FRICTION: the first impact sweep used the round's last seen position, a tick (1 m) before the body,
  so every body hit read as ground: the test caught it; the last step is now swept. Then a ternary
  built an untyped `Array` for Rivet's plating and dropped every enemy-round impact at runtime (seen
  in the city clip's log, 15 SCRIPT ERRORs): fixed + test (ec047559). Lesson: grep the run log of
  every clip for SCRIPT ERROR before looking at frames.
- FRICTION: `--arena` is not a boot arg; the arena runs as `res://dev/arena/arena.tscn -- ...`.
  New class_names need `--headless --import` once before a windowed run.
- Gates: lint 13/13, unit 704/704 (`evidence/n3/unit-a.log`), scenarios 29/29 (`scenarios-a.log`).
- Clips: `MASTERS/n4/gunplay/arena_mpistol_pit_48ppm/` (15 s, 30 shots, 3 kills; burst_sequence.png
  shows the strobe, tracer, smoke and shells). City block 32 px/m (machine pistol, 20 shots, 5 kills,
  blood) re-rendering with the plating fix.

### Answers to REQUESTs addressed to gunplay
- brutality REQUEST 1: done already: `FightAreas._strike` emits `struck(victim, dir, lethal, weapon)` for
  every area hit incl. rocket splash (dir = blast centre -> victim), weapon = the weapons.json id; burn
  deaths emit `struck(h, flee, true, &"burn")`. `kill_landed` (REQUEST 1 of mine) carries the same.
- showcase REQUEST 3 (Rivet's full-body vermilion hit flash): taken; next iteration (a cream paper flash
  + plating sparks; the sparks landed tonight in GunFx). Weapons ARE selectable deterministically:
  `res://dev/arena/arena.tscn -- --weapon=<weapons.json id>` (GunplayHook) + `--bot=gunplay`.
- showcase REQUEST 5 (rocket reads as a white lance): the rocket body, wobbling smoke trail and the
  starburst blast are drawn by FightAreasArt only with `--weapon=rocket_launcher` (the table gun);
  without it the arena keeps quest 1's Gloria and the old tracer. Use the flag for the reel.
- human-reactions REQUEST 1 (vertical rectangular blood streak on N/S hits): open, next iteration
  (CombatBlood.kill_human spray along a vertical dir).
- 02:12 FIX Rivet's rig had no recoil with a table gun: `ArenaRigs._put` read Rivet's own cooldown,
  which GunHand never sets. It now counts `GunHand.shots_fired` for Rivet (weapon = the table id;
  `ArenaPlan.kick` defaults to 1.0). Small edit in the arena lane's `dev/arena/arena_rigs.gd`;
  `test_arena_rigs` guarded (stage null in its fixture). 74e296e0.
- 02:12 REFACTOR `FightReach` (lob target, chain's next hop) out of FightAreas: 259 -> 220 lines.
- 02:16 MILESTONE rockets burst on arena props: `ArenaDodges.cull` (arena lane's file, small edit) lands
  a table rocket at the prop (FightAreas.land: blast, splash, knockdown) instead of erasing it; a lobbed
  bottle flies over props. `test_wall_landing.gd` 2/2. Only bullet guns eject shells / drop magazines
  (gun_fx.json default row: no shells, no star, smoke only). 8f393b1d.
- 02:27 GunplayBot holds fire when a prop blocks its line (rocket pit: 7 rockets / 3 kills with 4 into
  its own cover -> 3 rockets / 3 kills). Trade-off: it waits while cops shoot from behind crates. c280b1dc.
- Gates after each change: unit 705 -> 707/707 (`evidence/n3/unit-c.log`, `unit-d.log`), scenarios
  29/29 (`scenarios-c.log`, `scenarios-d.log`), lint 13/13 (pre-commit).
- Clips this iteration (all CONTENDED GPU; frames.json updated, 15 entries, every file checked):
  side_by_side_pistol_mpistol_48ppm.mp4, city_mpistol_block_32ppm, city_electro_block_32ppm (2 chain
  hops), arena_pistol_pit_48ppm, arena_mpistol_pit_48ppm, arena_rocket_walls_48ppm (before),
  arena_rocket_lane_48ppm (after).
- FRICTION: the electro city clip still shows brass shells (rendered before the default-row fix);
  the city hostiles are quest discs, not rigs (showcase REQUEST 6, not mine).

NEXT (iteration 4, in order):
1. A fixed-camera range drill clip for pistol vs machine pistol (static dummies at 5-10 m, Rivet still,
   5 s each) so muzzle, tracer, shells, impacts and the recoil read without the bot wandering; 64 px/m
   close-up of the muzzle and the impact (brief proof item). Then re-cut the side-by-side.
2. showcase REQUEST 3: Rivet's hit flash is the cast shader's `tint` (vermilion for every rig,
   `look_d5_part.gdshader:151`, `print_part.gdshader:118`). Proposal: a cream paper flash for Rivet
   only (tint mode 2), humans keep vermilion; touches d5-cast files: write a REQUEST to whoever owns
   rigs tonight (human-reactions) or make the minimal param change and record it.
3. human-reactions REQUEST 1: vertical rectangular blood streak on N/S hits. BloodSplatMesh.put's
   rotation is correct at every angle, so look at the splat shader's elongation (e) or BloodMarks
   splat ring for a y-axis special case; reproduce with `CombatBlood.kill_human(p, Vector2.DOWN)`.
4. Electro chain clip with a cluster (city guards stand > 4 m apart; 2 hops in 20 s).
5. Shell + smoke for the enemy guns (cops' rounds have the tell and the vermilion tracer, no shell
   or muzzle star yet), then the unique five (plasma rifle first) with brutality's kill payload.
- 02:24 MILESTONE 64 px/m pistol close-up on the arena range (`--weapon=pistol --bot=range`, Rivet
  stands still, 36 shots): the range bot plays fine with the table gun. It showed two view bugs, both
  fixed: the flash sat on Rivet's centre line while his rig holds the gun 0.3 m right of it
  (`gun_fx.json claw_side_m` 0.3: flash, smoke and shells leave the claw; 480fea57), and a fresh
  tracer's 2.5 m tail reached back through his body (tail clamped to the distance past the muzzle,
  head converges from the claw side onto the sim line over 3 m; view only).
  Clip: `MASTERS/n4/gunplay/arena_pistol_range_64ppm/` (+ muzzle_sequence.png).
- Brass prints greyish through the D5 grade (`#b8913f` under the print pass); judge in the clip, a
  warmer value is one palette entry.
- NEXT update: item 1 is half done (the pistol close-up exists). Remaining: the machine pistol on the
  range at 64 px/m (`--weapon=machine_pistol --bot=range`) and a re-cut side-by-side from the two range
  clips (Rivet still, same framing); then items 2-5 of the NEXT above.
- 02:29 Machine pistol on the range at 64 px/m (90 shots, 16 hits) and `side_by_side_range_64ppm.mp4`
  (same lane, same framing, 5 s each): the two guns read apart with the sound off (cadence, flash shape,
  tracer weight, shell pile, reload ring). frames.json: 15 entries, the range side-by-side first; the
  flame and molotov pit clips kept so every finished weapon is on the page.
- Gates after the tracer fix: unit 707/707 (`evidence/n3/unit-f.log`), scenarios 29/29 (`scenarios-f.log`).
- NEXT (iteration 4) stands as written above, with item 1 done (both range close-ups + side-by-side).
- 02:36 Cops' rounds now leave a small cream 4-point muzzle star at the shooter's gun (3 ticks) and a
  shell kicked to its right (`GunFx._enemy_fired`, `GunFxArt._star`; view only). Unit test 5/5 in
  test_gun_fx.gd; gates unit 708/708 (`evidence/n3/unit-g.log`), scenarios 29/29 (`scenarios-g.log`).
  NOT seen in a clip yet: the one check render (pistol pit, 11 s) had no cop firing in its window.
  First thing next iteration: a pit clip at 48 px/m with the cops' flash in frame.
- gun_fx.gd is 201 lines (soft 200): next GunFx change splits the enemy part out.
- 02:41 Verified in a clip: the cops' muzzle star shows at their gun on every round of the locked
  burst (`MASTERS/n4/gunplay/arena_cop_fire_48ppm/cop_burst_sequence.png`, row 1), then Rivet's rounds
  land with the hit flash and red spray. Their shells are too small to read at 48 px/m.
- Session end: no Godot processes of mine running, no bench.lock held, scratch renders deleted
  (only clips referenced in frames.json kept under MASTERS/n4/gunplay).
NEXT (iteration 4): items 2-5 of the NEXT list above (Rivet's hit flash call, the vertical blood
streak, a clustered electro chain clip, then the unique five starting with the plasma rifle); split
the enemy part out of gun_fx.gd (201 lines) first if GunFx grows.

## Iteration 4 (02:38-03:38)
- Read: JOURNAL, git log, REQUESTs to gunplay in n-brutality (5: keep CombatBlood.veto, info),
  n-human-reactions (1: vertical blood bars), n-showcase (3, 5, 7), n-rivet-arsenal (1: cop hit flash
  vermilion -> cream; 4 answer; 5 HUD ammo), n-weapon-art (1 -> rivet-arsenal cc gunplay: the claw
  holds the default gun under --weapon).
- Registry rules applied (realtime-combat-semantics, motion-quality-gating): presentation reads the
  sim, never writes it; every change judged in motion at 64 and 48 px/m on the cast rigs; a weapon
  must read apart from its neighbours with the sound off (silhouette of the flash, tracer weight,
  what falls from the gun).
- 02:45 MILESTONE vertical blood bars (human-reactions REQUEST 1, showcase reel 0210 (b)): repro
  `dev/gunplay/blood_dirs.gd` (CombatBlood.kill_human, 8 directions on a plain floor) shows every
  direction sprays the same: no y-axis bug. The bar is the kill fan itself: 34 deg (effectively about
  +-8 deg), always due south for a claw from the north, printed next to the axis-aligned grid. Fix:
  the spray axis turns up to 14 deg (hash of the spot) and the fan widens to 52 deg (356a3a2d).
  A/B `evidence/n4/blood_spray_down_ab_32ppm.png` (top before, bottom after; row 1 four blows due
  south). Unit 708/708 (`evidence/n4/unit-a.log`).
- FRICTION: `timeout` in Git Bash does not kill the windowed Godot child (two of my renders hung on a
  parse error until killed by PID). Use `--quit-after <frames>` on every windowed run.
- 02:52 MILESTONE hand cannon, the first unique gun, in the real fight (enabled; gun_fx.json row):
  fat flare + shock ring + 16 px tracer + smoke cloud + six shells dumped on reload; rig kick 1.6 (the arena schema max).
  Range 64 px/m: the first cut showed a thin needle flare and a reticle-thin ring -> `fat` 3 and a
  bolder ring (shot_sequence.png). Pit 48 px/m: 4 rounds, 4 kills; kill_sequence.png shows the cop's
  told line and burst, Rivet's flare + ring, the heavy tracer into the cop, then the spray.
  Clips `MASTERS/n4/gunplay/arena_hand_cannon_range_64ppm/`, `arena_hand_cannon_pit_48ppm/`.
  brutality's `hand_cannon_blowback` kill is on n-brutality; my branch shows the standard death until
  the Director merges (kill_landed carries weapon `hand_cannon`).
- 03:00 MILESTONE plasma rifle, the second unique gun, enabled in the real fight: round 10-point
  burst at the muzzle (turns every shot), slow (30 m/s) pulsing teardrop bolts with a soft glow and
  trailing sparks, a ring burst + burnt ring where they stop, no shells, a cell on reload. The first
  cut (`burst_sequence_before.png`) read as a chalk stick and a frying pan; redrawn as a comet.
  Range 64 px/m: 40 bolts / 18 hits; pit 48 px/m: 7 bolts / 4 kills. Unit test (scorch, no shells).
  Gates: unit 710/710 (`evidence/n4/unit-d.log`), scenarios 29/29 (`scenarios-d.log`).
- `MASTERS/n4/gunplay/side_by_side_four_guns_range_64ppm.mp4`: pistol, machine pistol, hand cannon,
  plasma rifle on the same range lane, 2x2, 5 s, sound off. frames.json updated (15 entries).
- DECISION GunFxMarks split out of GunFxArt (floor marks + impacts); GunFx impacts carry
  `Hit + SCORCH` for an energy bolt.
- 03:07 City proving block at 32 px/m, both unique guns (`--arena=city --bot=gunplay --rigs --clean`):
  hand cannon 5 rounds / 5 kills, plasma 8 bolts / 5 kills in 20 s, no SCRIPT ERROR. Clips
  `MASTERS/n4/gunplay/city_hand_cannon_block_32ppm/`, `city_plasma_block_32ppm/` (+ overview sheets).
  NOT yet judged: the plasma bolt's contrast on the cream paving at 32 px/m (no bolt frame found in
  the crops I pulled).
- FRICTION: Windows Python cannot open `/c/...` paths; pass `C:/...` to python and to Godot's
  `--telemetry` / `--out`.

### Answers to REQUESTs addressed to gunplay (iteration 4)
- human-reactions REQUEST 1 (vertical rectangular blood streak): DONE 356a3a2d (spray tilt + 52 deg
  fan; repro dev/gunplay/blood_dirs.gd shows it was the narrow axis-aligned fan, not a y-axis bug).
  Re-render your board's rows 8-10 after merging n-gunplay.
- showcase REQUEST 3 / rivet-arsenal REQUEST 1 (vermilion hit flash): already DONE by human-reactions
  8669b5d9 (cream hit flash in the cast shader); nothing from gunplay. Rivet's plating sparks on an
  enemy hit are in GunFx (ec047559).
- showcase REQUEST 7 (accent audit 32 px/m blood flicker rows, owner gunplay): measured on my HEAD
  e6ad597e (`evidence/n4/accent-audit-head-e6ad.json`): 32 px/m now has NO offender; the flicker moved
  to 48 px/m (vermilion 12 px + blood 4 px on vehicles, vermilion 12 px on cop = the existing
  `blood_flicker_cop_48` max) and 64 px/m (vermilion 4 px on vehicles). A view-only change (the kill
  spray tilt) moved it, so it follows the blood layout: the same gate-boundary class the d5-city rows
  describe (the audit compares a full capture with a layer-hidden capture of a later frame and blood
  edges blend over whatever is under them), not something b3b3c92f's drop canvas introduced. So:
  delete the two `*_32` rows when you merge this branch, expect 48/64 vehicle rows of the same class
  (<= 12 px), and the real fix stays with d5-city (compare same-frame captures). Not added to
  accent_debt.json here: the audit is not one of this lane's four gates.
- brutality REQUEST 5 (keep CombatBlood.veto): noted; the spray tilt touched only kill_human's spray
  axis, the veto lives on your branch and merges clean.
- rivet-arsenal REQUEST 5 (HUD ammo read): the read is fine (`arena.gun.trigger.ammo`, `spec.magazine`,
  `reloading()`); the hand cannon's reload ring and the shell dump are GunFx's, the HUD needs nothing
  more from gunplay.

NEXT (iteration 5, in order):
1. Plasma at 32 px/m on cream paving: find bolt frames in `city_plasma_block_32ppm` (tile every frame
   near Rivet); if the cream bolt sinks into the paving, thicken its ink rim (`_bolt` r + 4 -> r + 6) or
   take weapon-art's energy accent token if weapon-art-3 is decided.
2. Ray gun (third unique; kind `bolt`, 90 m/s, thin and exact): an instant ink-and-cream beam with a
   bright tip, a hit sizzle; check what kind `bolt` does in FightAreas (electro chain?) before enabling.
3. A side-by-side clip in the pit of the two uniques' kills at 48 px/m with the camera on the victim
   (`--start` or a dev cam), and brutality's blowback kill on a scratch merge for the reel.
4. Homing shard gun, mini-nuke (rows exist, disabled): projectile designs after the ray gun.
5. Riot bench before/after of record under bench.lock (none this iteration: render-only changes).
- Session end 03:1x: gates of record at the last code commit: lint 13/13, unit 710/710
  (`evidence/n4/unit-e.log`), scenarios 29/29 (`evidence/n4/scenarios-d.log`, before the size-only
  refactor of `_muzzle`). Replay/parity untouched (view-only changes; blood_fx.json view params).
- 03:11 MILESTONE ray gun, the third unique gun, enabled: a bolt with no chain hops draws as a
  straight beam with ripple rings and a bright tip (`FightAreasArt._ray`); damage 40 -> 100 (one ray,
  one human). Range 64 px/m: 61 rays / 18 hits (`MASTERS/n4/gunplay/arena_ray_range_64ppm/`). Unit
  test (one ray drops a human). Pit 48 px/m: 4 rays / 4 kills (`arena_ray_pit_48ppm/`). Gates: unit
  711/711 (`evidence/n4/unit-g.log`), scenarios 29/29 (`scenarios-f.log`). Not yet seen in the city; no impact mark yet (bolts are
  not tracked by GunFxRounds). NEXT item 2 above becomes: ray in the pit + city at 32 px/m, an impact
  sizzle; then homing shard gun, mini-nuke.
