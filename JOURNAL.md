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
- 03:16 Ray gun in the city proving block at 32 px/m: 5 rays / 5 kills, no SCRIPT ERROR
  (`MASTERS/n4/gunplay/city_ray_block_32ppm/`). `side_by_side_uniques_64ppm.mp4`: hand cannon, plasma,
  ray (range lane) + electro gun (pit) 2x2, 5 s, sound off. frames.json: 15 entries, every file checked
  to exist; the four-gun and uniques side-by-sides first.
- Session end 03:18: no Godot process of mine running (all windowed runs used --quit-after), no
  bench.lock or image.lock held, scratch renders under gtai-n4/scratch/gp deleted (only the clips
  in MASTERS/n4/gunplay and the stills in evidence/n4 kept).

NEXT (iteration 5, in order; supersedes the list above):
1. Plasma bolt contrast at 32 px/m on cream paving (find bolt frames in city_plasma_block_32ppm; if it
   sinks, thicken the `_bolt` ink rim or take weapon-art's energy accent once weapon-art-3 is decided).
2. Ray gun impact: rays are not tracked by GunFxRounds (BOLT kind) so they leave no mark; add a
   sizzle (small cream ring + scorch) where a ray stops, view-only.
3. Homing shard gun, then mini-nuke (rows exist, disabled): projectile designs (shards that curve
   onto a target with a scratch trail; a slow fat shell, a huge blast ring and a fire patch), damage
   one-shot for humans, tests, range + pit + city clips.
4. Kill close-ups with the camera on the victim (48-64 px/m) for the three uniques; brutality's
   hand_cannon_blowback on a scratch merge for the reel.
5. Riot bench before/after of record under bench.lock (nothing this iteration touched the sim or
   the riot's per-frame cost; render-only).
- 03:19 DONE NEXT item 2: a ray now marks where it stops (GunFxRounds tracks a bolt with no chain;
  gun_fx.json `ray_gun`: scorch + a small turning burst at the claw): pop ring + burnt ring on the
  dummy, `evidence/n4/ray_range_64ppm_sizzle.png`. Unit test extended. Gates: unit 711/711
  (`unit-h.log`), scenarios 29/29 (`scenarios-h.log`), lint 13/13. NEXT for iteration 5 is now items
  1, 3, 4, 5 of the list above.

## Iteration 5 (03:20-04:20)
- Read: JOURNAL, git log, REQUESTs to gunplay (new: showcase REQUEST 11 -> weapon-art, gunplay: one
  owner for Rivet's muzzle flash and brass). Registry rules applied (realtime-combat-semantics,
  motion-quality-gating): sim rules stay tick math with no RNG and only the new rows take the new
  branch (hashes of the other nine guns unchanged); presentation reads the sim; judged in motion at
  32 / 48 / 64 px/m on the cast rigs, in the pit and the city block.
- 03:26 MILESTONE mini-nuke, the fourth unique gun, enabled (1c0aa98f): `FightNukeArt` draws the
  shell (fat finned capsule, lobbed 4.5 m over its shadow, small vermilion nose) and the blast (one
  cream flash over the 12 m circle for 5 ticks, jagged fireball, two ink shock rings, a mushroom of
  smoke, a dust ring); then the 6 m fire patch. Pit 32 px/m: 5 shells, 8 kills
  (`MASTERS/n4/gunplay/arena_nuke_pit_32ppm/`, `blast_sequence.png`); city block 32 px/m: 4 shells,
  5 kills, the flash disc visible on the cream paving (`city_nuke_block_32ppm/overview_2fps.png`).
- 03:33 MILESTONE homing shard gun, the fifth unique gun, enabled (12dfc10d): `homing_dps` column,
  `FightReach.home` (240 deg/s, 60 deg cone, 12 m), one shard drops a human, a small burst where it
  stops; `FightShardArt`: a cream crystal in an ink rim, a scratch trail along the flown curve. The
  first cut at 48 px/m was mostly ink (rim ate the cream) -> 0.62 x 0.2 m, rim 6 px. Pit 48 + 64
  px/m (`arena_shard_pit_48ppm/`, `arena_shard_pit_64ppm/shard_sequence.png`), city 32 px/m: 16
  shards, 5 kills (`city_shard_block_32ppm/`). NOT shown in a clip yet: a shard visibly curving (the
  bot aims dead at its target); the unit test and the scenario prove the turn.
- Determinism: `scenario_gunplay_fight` now runs all eleven table guns (the core six + the unique
  five), twice on a seed + a planted fault each: all identical, all faults caught; shards aimed 2 m
  off the knot still kill all five (11 shots), one nuke shell kills all five. Gates at 12dfc10d: lint
  13/13, unit 714/714 (`evidence/n4/unit-i.log`), scenarios 29/29 (`scenarios-i.log`).
- FRICTION: the `run_unit.mjs` runner needs `GODOT_BIN` in the environment; without it it prints
  "exit -1" and the counts of the previous run (looked green, was stale).
- 03:38 plasma bolt on cream paving (NEXT 1): the frames of `city_plasma_block_32ppm` show the bolt as
  a thin outline that sinks into the cream (its glow is cream, its rim 4 px). Fix: an ink halo under
  the cream glow, rim r + 7 (gun_fx_art `_bolt`). Re-shoot after the bench.
- Answer to showcase REQUEST 11 (cc weapon-art): gunplay agrees with the split showcase's merge r4
  wrote (decisions.md there): weapon-art's `WeaponFxArt` owns Rivet's muzzle flash and brass for any
  gun with weapon-art art; GunFx draws them only for a gun without art and always draws the smoke,
  the impacts, the magazines and the hostiles' muzzle stars and shells. No second path to delete on
  this branch. Merge note: my new `FightAreasArt.shot` branch (homing round -> `FightShardArt`) sits
  before the `match`; weapon-art's hook ("asked first") stays above it, so weapon-art's `shard` cell
  wins when it has one and my crystal is the fallback. The nuke's `_blast` branch is the same.
- 03:40 MEASURE riot + drive on HEAD under bench.lock, CONTENDED (`evidence/n5/riot-head.md`, raw
  `evidence/n5/bench/`): riot p99 10.28 / 8.73 ms, 1 % low 66 / 72 fps, combat blood 80 / 67 us a frame
  (under 1 % of the p99); drive p99 3.69 / 5.29 ms. The riot p99 follows the machine's load (01:55
  same method: 8.68 / 6.47), nothing in the riot path changed. Brief item 5 stays where iteration 3
  left it: the blood is not the riot cost; the idle bench of record (6.007 ms) is the Director's.
- 03:41 plasma halo A/B (`evidence/n4/plasma_bolt_cream_paving_ab_32ppm.png`, same frame): the bolt
  now reads as an ink teardrop with a halo on the cream paving (was a thin outline). Modest change.
- 03:44 DECISION homing fan (a071c7b0): shards leave the claw 20 deg off the aim, alternating, and
  curve back in: the swarm's curve shows in every shot (with a dead-on aim they flew straight and the
  gun read as a slow pistol). `arena_shard_pit_64ppm/shard_sequence.png` shows the bent trails.
- 03:46 `MASTERS/n4/gunplay/side_by_side_unique_five.mp4` (3x2, 5 s, sound off, every cell labelled):
  hand cannon, plasma, ray (pit 48), shard (pit 64), nuke pit + nuke city (32). frames.json: 15
  entries, the six new ones first; dropped the superseded uniques side-by-side and four older stills.
- 03:49 fix: a mini-nuke kill is "blown", not "burned" (b97fc382): `FightAreas.BLAST_KILL_M` 6 m.
- 03:52 TTK table of every playable weapon incl. the unique five (`evidence/n5/ttk.md`, range model,
  24 trials a cell). Note: the range model flies the shard straight; its curve is the real fight's.
- Gates at b97fc382: lint 13/13, unit 714/714 (`evidence/n4/unit-k.log`), scenarios 29/29
  (`scenarios-k.log`; scenario_gunplay_fight covers all eleven table guns). Parity untouched (no
  native or city-sim file); the quest replay untouched (quest 1 has no GunHand, the new branches are
  behind `homing_rad_per_tick > 0` and a 6 m splash).
- OBSERVED (not mine): when a cop round lands Rivet's whole rig flashes vermilion for a few frames
  (`arena_shard_pit_64ppm/shard_sequence.png`, top row). That is the shared rig HIT tint on Rivet.
  REQUEST 1 (it5) -> human-reactions (cc rivet-arsenal): Rivet's own hit flash is vermilion over the
  whole body; vermilion is for danger/objectives/the collar, and the cops already flash cream. Suggest
  cream like the cops, or vermilion only on the collar; GunFx already throws cream sparks off his
  plating on the hit.
- REQUEST 2 (it5) -> brutality (info): two more unique guns are live on n-gunplay: `homing_shard`
  (kill_landed weapon `homing_shard`, kind `shot`, hit direction = the shard's curved final heading)
  and `mini_nuke` (weapon `mini_nuke`, kind `blown`, direction = out from the blast centre, up to five
  kills in one tick). If you add signature kills for them, key on the weapon id; the nuke's many
  same-tick kills may want a cheaper variant than a per-victim cut.

NEXT (iteration 6, in order):
1. The kill close-ups with the camera on the victim (48-64 px/m) for the unique five; brutality's
   hand_cannon_blowback on a scratch merge for the reel (not on this branch).
2. The nuke at 48 px/m (the flash, the mushroom read; is the 12 m ring too thin at 32?), and the
   cream flash checked against the reduced-motion budget in `hit_feel.json` (one flash, 5 ticks).
3. Plasma bolt: take weapon-art's energy cell when it lands (their hook is asked first anyway).
4. Rivet's own hit reaction in the real fight (brief item 4): a flinch toward the hit on the rig is
   human-reactions' cast work; GunFx sparks are in. Check after REQUEST 1 (it5).
5. Idle riot bench of record when the machine is quiet (the Director's at the merge otherwise).
- 03:54 fix: the nuke's flash read grey on the pit's concrete at 48 px/m (a see-through cream darkens
  on this layer; `arena_nuke_pit_48ppm/blast_sequence_before.png`). Now opaque cream in an ink rim for 2
  ticks, then a thinning opaque cream band (`flash_frames.png`, 8f4838bc). City clip re-shot; the
  side-by-side rebuilt with the 48 px/m pit cell. LESSON: on the FX layer use opaque cream for any
  flash; translucent cream reads as grey over the dark ground.
- 03:56 city shard check at 32 px/m (`city_shard_block_32ppm/shard_tiles_32ppm.png`): the crystals
  read as ink diamonds with dashed trails on the cream paving (their cream fill vanishes there; the
  rim carries them), the burst + blood on the cop reads. Arena station doc lists all eleven ids.
- 03:58 gates of record at 359b0470: lint 13/13, unit 714/714 (`evidence/n4/unit-l.log`), scenarios
  29/29 (`scenarios-l.log`), parity bit-exact over 1200 steps + planted mutation caught at 629
  (`parity-l.log`). The full `tools/evidence/run.mjs` was not run this iteration (the bench part ran
  separately under the lock at 03:37).
- 04:01 kill close-up at 64 px/m (NEXT 1, partly): `MASTERS/n4/gunplay/arena_hand_cannon_pit_64ppm/`
  (4 rounds, 4 kills); `kill_closeup.png` cropped on the victim: shock ring, heavy tracer, red burst,
  knockdown. The arena camera follows Rivet, so a victim-centred camera needs an arena arg (shared
  dev code, not mine): REQUEST 3 (it5) -> arena owner / showcase: a `--cam=victim` (or `--cam-at=x,y`)
  for kill close-ups. frames.json: 15 entries, all files checked to exist.
- Session end ~04:02: no Godot process of mine running (every windowed run used --quit-after, all
  exited), no bench.lock or image.lock held, scratch under gtai-n4/scratch/gp emptied.

NEXT (iteration 6, supersedes the list above):
1. Kill close-ups for plasma, ray, shard, nuke at 64 px/m cropped on the victim (as the hand cannon's).
2. Plasma bolt: weapon-art's energy cell when it lands; else a stronger halo (ink alpha 0.2 -> 0.3).
3. The range model (ProjectileSim) has no homing: port `FightReach.home` there if the TTK table should
   show the shard's real reach (the real fight is the one that matters).
4. Rivet's own hit reaction (after human-reactions answers REQUEST 1 it5).
5. Idle riot bench of record when the machine is quiet.
- 04:04 ray gun kill close-up at 64 px/m (`MASTERS/n4/gunplay/arena_ray_pit_64ppm/kill_closeup.png`, 4
  rays / 4 kills): claw burst, the rippled beam, cream pop ring + red spray, burnt ring, crumple.
  frames.json 15 (dropped the city shard clip; the shard is in the 64 px/m sequence + side-by-side).
  NEXT 1 is now: kill close-ups for plasma, shard and nuke.
- 04:06 plasma kill close-up at 64 px/m (`arena_plasma_pit_64ppm/kill_closeup.png`, 7 bolts / 4 kills).
  frames.json 15 (dropped the pistol range clip; the pistol stays in the four-gun side-by-side).
  NEXT 1 is now: kill close-ups for the shard and the nuke only.
- Session end 04:07: no Godot process of mine running (the four Godot PIDs in tasklist are other
  lanes'), no lock held, scratch emptied. Gates of record unchanged since 605eae59 (docs/evidence only
  after it, plus the nuke flash and station doc, both linted at commit).

## Iteration 6 (session 04:04-05:04)
Read: JOURNAL, git log, other lanes' JOURNALs for REQUESTs to gunplay. Open ones found: weapon-art
REQUEST 5 (double magazine after the merge), showcase REQUEST 16 (the nuke lands on Rivet at close
range). Registry rules applied: realtime-combat-semantics (no dead trigger: a press always yields a
shot; the floor moves the burst, not the input), motion-quality-gating (every claim below has a
clip or a sheet I looked at). No deviation.
- 04:08 weapon-art REQUEST 5 DONE (4953ee25): GunFx reads `data/tables/weapon_art.json` (if present)
  and drops no magazine for a gun with a `mag` part; unit test. After the merge the pistol, machine
  pistol, hand cannon (speed-loader; its six-shell dump stays) and plasma rifle show only weapon-art's
  magazine. FRICTION: strict typing rejects `row.get()` on a Variant and `as Dictionary` casts; read
  into a typed local first. Python on Windows writes CRLF unless `newline=''`: json-canonical and
  gdformat fail on it.
- 04:12 showcase REQUEST 16 DONE (c4a1aa7b): weapons.json `min_lob_m` 13 on the mini-nuke
  (FightReach.lob_target takes the spec). Unit test: a guard 5 m off, the shell lands 13 m out along
  the aim; a molotov still lands on the guard. Evidence: `MASTERS/n4/gunplay/arena_nuke_floor_32ppm/`
  (4 shells, 3 kills, Rivet 0 deaths; overview sheet 4-20 s: every burst at the pit's far edge) and
  `arena_nuke_floor_48ppm/` (at 48 px/m a burst 13 m off sits on the frame edge: the 32 px/m view is
  the nuke's view).
- Gates after both: lint 13/13, unit 716/716 (`evidence/n4/unit-m.log`), scenarios 29/29
  (`scenarios-m.log`; scenario_gunplay_fight's nuke knot is past 13 m, its hash did not move).
- 04:16 shard kill close-up at 64 px/m (`arena_shard_kill_64ppm/kill_closeup.png`, 13 shards, 3
  kills): the fanned shards curve in, cream burst in an ink star, ring + red spray; the body is thrown
  out of the top of the frame. The grey disc left behind looked like a debug marker; checked: it is
  GunFxMarks.scorch (0.36 m burnt ring) with a spent shard in it. REQUEST 3 (it5, victim camera)
  still stands. FRICTION: the arena runs as `res://dev/arena/arena.tscn -- --weapon=.. --bot=gunplay
  --ppm=.. --rigs --clean`; `-- --arena` is ignored by boot (the city overview gets recorded).
- frames.json 15: +shard kill close-up, +nuke floor sheet; dropped the shard sequence (superseded) and
  the plasma halo A/B (modest).
- 04:20 FINDING in the shard close-up: the victim's body vanished when Rivet turned to the next cop.
  Cause: the arena's rig LOD bubble (14 m) sat 7 m ahead of Rivet's aim and the arena has no crowd
  atlas behind it, so anyone outside it is not drawn at all. human-reactions already fixed it
  (f6813fe4 `ArenaRigs.focus_m`); I took only that file's hunk (acbb8c0c, identical lines, merges
  clean). Shared dev file: logged here.
- 04:22 fix (5b51da41): with the body kept, an energy round's grey burnt ring printed over the
  corpse's chest (FxView draws above the actor layer). The ring is now left only where the round
  stopped on ground or metal; the pop still bursts on the body, the body's mark is its blood.
  Re-shot the shard, plasma and ray kill close-ups at 64 px/m (before files kept next to each):
  each cop now crumples into his own blood with nothing printed on him. The hand cannon has no ring.
- Gates at 5b51da41: lint 13/13, unit 716/716 (`evidence/n4/unit-n.log`), scenarios 29/29
  (`scenarios-n.log`). Parity untouched (no native/city-sim file).
- 04:28 NEXT 3 done in code: the range model (ProjectileSim) homes a shard like the real fight
  (same fan off the claw, same turn rate, cone and reach from FightReach); unit test: a target 15 deg
  off the aim dies to one shard, a pistol round passes him. The TTK table can now be re-run with the
  shard's real reach (`dev/gunplay/ttk_bench_run.gd`).
- rivet-arsenal NEXT 2 (molotov wind-up, "REQUEST to gunplay or a pilot-side hold"): NOT built this
  session (it changes the trigger contract and every thrown-weapon scenario hash; too late in the
  hour to land safely). Proposed contract, for whoever builds it next (gunplay owns Trigger):
  thrown specs get an optional weapons.json `wind_s` (molotov 0.25, mini-nuke 0.4); a press starts
  `Trigger.wind_left` (ticks), the throw leaves when it reaches 0 while held, or on release if it is
  already 0 (no throw when released early = a feint, the bottle stays in the claw); `GunHand.winding()`
  and `wind_frac()` for the rig's wind-back pose (rivet-arsenal's WeaponHold/RivetHeldView reads them,
  view only). GunplayBot holds fire through the wind. Replay: the press tick still drives it, so it
  stays deterministic; scenario hashes for the molotov and nuke move once (a dated re-bless line).
- 04:40 TTK re-run with the homing range model (`evidence/n6/ttk-shard.md`, raw `ttk.json`): vs a
  strafing human the shard now kills as fast as vs a still one (5 m 1.70 -> 0.28 s, 20 m 2.17 ->
  1.25 s); every other weapon's rows identical (checked by diff of the JSON).
- 04:39 MEASURE riot + drive on HEAD under bench.lock (`node tools/bench/run.mjs`, log
  `evidence/n6/bench.log`, raw `evidence/n6/bench/`), CONTENDED (other lanes rendering): riot p99
  CPU 8.04 ms, 1 % low 90 fps, combat blood 68 us a frame (3443 drop draws, 601 pool draws over
  28.8 k frames) = 0.8 % of the p99; rigs p99 0.76 ms. Summary line p99 11.0 ms over all four
  scenarios. Brief item 5 stands where iteration 3 left it: the blood redraw is cut (settled 30) and
  is not the riot cost; the idle number of record needs a quiet machine (the Director's at the merge).
- Gates at the homing commit: lint 13/13, unit 717/717 (`evidence/n6/unit-o.log`), scenarios 29/29 (`scenarios-o.log`).
- 04:43 city proving block regression check at 32 px/m, shard (`MASTERS/n4/gunplay/city_shard_block_32ppm_it6/`,
  12 shards, 4 kills, 0 script errors, Rivet 0 deaths): the dead keep their bodies and blood on the
  cream paving after the bubble take and the ring fix.
- DECISION plasma halo stays at 0.2 (NEXT 2 closed without a change): see docs/decisions.md.
- Session end 04:45: no Godot process of mine running (every capture used --quit-after; the bench and
  gates exited), bench.lock released by the bench script at 04:39, no image.lock taken, scratch AVIs
  and sheets deleted (only `scratch/gp/cap.sh` and `sheet.py` kept for the next session).

NEXT (iteration 7, in order):
1. The molotov wind-up per the contract above (Trigger.wind_left, weapons.json `wind_s`, GunHand
   `winding()` / `wind_frac()`), GunplayBot holding through the wind; re-bless the molotov/nuke
   scenario hashes with a dated decision line; tell rivet-arsenal the read is in.
2. The hand cannon and nuke kill close-ups re-shot on the bubble fix (the hand cannon's predates it);
   the nuke at 32 px/m cropped on a victim.
3. REQUEST 3 (it5, victim camera) still open: until it lands, crop on the right edge (the bot faces
   the pit's east side) or run `--start=` at a station that puts the cops mid-screen.
4. Rivet's own hit reaction: human-reactions has not answered REQUEST 1 (it5) (vermilion whole-body
   hit tint on Rivet); check their JOURNAL again; GunFx's plating sparks are in.
5. Idle riot bench of record on a quiet machine (the Director's at the merge otherwise).

## Iteration 7 (session 04:44-05:44)
Read: JOURNAL, git log, other lanes' JOURNALs for REQUESTs to gunplay. New since it6: brutality
REQUEST 11 (ray mark on the dissolve pile), 12 (electro charged shot), 13 (nuke patch hides the
vaporise shadows); rivet-arsenal REQUEST 12 (aim distance for thrown weapons); showcase REQUEST 18
(GunFxArt._flash triangulation failures), 19 (test_gun_fx needs art_mags = {}). My NEXT 1 (molotov
wind-up) was built by rivet-arsenal (60802820, PlayerThrow): closed here, not duplicated.
Registry rules applied: realtime-combat-semantics (no dead trigger: the press always fires, the
charge only adds; the throw lands where the input says, decided on the tick), motion-quality-gating
(every visual claim below has frames I looked at; the charged bolt was re-shot three times until it
read as lightning). No deviation.
- 04:50 a1eb709f: showcase REQUEST 18 DONE (a flare shrunk to a sliver draws nothing:
  Geometry2D.triangulate_polygon checked first); REQUEST 19 DONE (the test sets art_mags = {});
  brutality REQUEST 13 DONE view-only: the nuke's 6 m patch burns as a ring round its rim, ground
  zero burnt out (`MASTERS/n4/gunplay/arena_nuke_ring_32ppm/ring_patch_sequence.png`, 2 shells, 2
  kills). Unit 717/717 (`evidence/n7/unit-a.log`).
- brutality REQUEST 11 (ray mark over the dissolve pile): already answered by 5b51da41 (it6): an
  energy round leaves no burnt ring where it stopped on a body; only the transient pop (12 ticks)
  bursts there. If the pop still covers the pile in brutality's lab, say so with a frame.
- 05:00 0c0465fd MILESTONE the electro gun's charged shot (brutality REQUEST 12): tap = the plain
  60-damage stun bolt at once; held on, it charges 0.6 s once ready (arcs gather onto the claw, a
  cream core swells, a ring snaps at full) and a 150-damage charged bolt leaves by itself, a fat
  double lightning bolt with a hot head; one drops a fresh human (kill_landed electro_gun, so
  brutality's electro_shock fires). test_charge_shot 4/4 (planted: a pistol never charges).
  Evidence: `arena_electro_charge_64ppm/charge_strip_64ppm.png` + the clip (plain bolt stuns at
  9.15 s, charge 9.95-10.12 s, charged bolt 10.25 s, kill 10.45 s); city block regression
  `city_electro_charge_32ppm/` (5 kills, 2 chain hops, 0 script errors, Rivet 0 deaths; no 32 px/m
  charged-bolt still judged yet).
- FINDING + fix in the same commit: every electro bolt and chain arc drew as a smooth wave, not a
  zigzag: `sin(phase * 7 + i * 13)` steps 13 rad = 0.43 rad a kink, so consecutive kinks trace a
  slow sine. Now the kinks alternate sides with a varied depth (FightChargeArt.zap, shared by the
  plain bolt and the chain arcs). LESSON: a "random" sin(i * k) needs k far from a multiple of 2 pi.
  The same pattern lives in Ink.zigzag (boot, shared; stun sparks, 3 kinks, reads OK): not touched.
- Gates at 0c0465fd: lint 13/13, unit 721/721 (`evidence/n7/unit-c.log`), scenarios 29/29
  (`scenarios-c.log`; the electro rows' hashes moved: scenarios check same-seed identity + the
  planted fault, not stored hashes, so no re-bless).
- 05:10 rivet-arsenal REQUEST 12 built (see the DECISION): the cursor's distance in TickInput bits
  25-28 (input_actions.json `aim.aim_reach_step_m` 1.2, shared file, one key + doc); PlayerCommand
  .aim_m; LiveInput.px_per_m (the arena wires it; quest 1 has no GunHand, so not wired there);
  StagePilot lands a thrown weapon at aim_m. test_aim_reach 3/3. Old replays decode aim_m 0.
  Shared files touched: input_actions.json, boot/collect_call/stage_pilot.gd, dev/arena/arena_game.gd,
  features/player/{player_actions,player_command,live_input}.gd. rivet-arsenal: the StagePilot side
  is done; ArenaArsenalBot can now throw short by passing a reach (pack_aim's third arg).
- Gates at b48ec24a (aim reach): lint 13/13, unit 724/724 (`evidence/n7/unit-d.log`), scenarios
  29/29 incl. the 60 s replay (`scenarios-d.log`): old input decodes identically.
- 05:08 GunplayBot sends the foe's distance as the cursor's (pack_aim third arg), so its molotov
  lands on the guard: arena pit 48 px/m, 20 s, 5 bottles -> 5 ignitions, 4 kills, Rivet 0 deaths
  (before, `arena_molotov_pit_48ppm`: 6 bottles -> 4 ignitions, 3 kills). Clip + sheet
  `MASTERS/n4/gunplay/arena_molotov_reach_48ppm/` (looked at: the fire patches sit on the cops).
  The nuke keeps its 13 m floor (FightReach.lob_target). FRICTION: a parameter named like a
  class member (`reach_m`) is a Godot shadowing warning = parse error, and lint (gdlint) does not
  see it; the windowed run silently fell back to nothing (telemetry 0 ticks). Run a Godot load
  (a unit run or the capture's run.log) after every signature change.
- Gates on the bot change: unit 723/724 under load (the known test_noir_shadows flake), re-run
  724/724 (`evidence/n7/noir-shadows-alone.log`, gut ran the whole suite); scenarios 29/29
  (`scenarios-e.log`).
- 05:12 NEXT 2 (hand cannon close-up on the bubble fix) re-shot: `arena_hand_cannon_kill_64ppm/
  kill_closeup.png` (3 rounds, 3 kills): the cop's burst, the flare + heavy tracer, the hit, his
  blood, and his body stays after Rivet turns away. frames.json points at it (before = the it5 one).
  The victim still sits at the frame's top edge: REQUEST 3 (it5, victim camera) stands.
- FINDING in that clip: Rivet flashes vermilion all over when a round hits him (another lane's
  merge carries a whole-body hit tint): my it5 REQUEST 1 to human-reactions looks answered in
  part; a flinch of Rivet's rig is still not there (rig views are ArenaRigs / CityCharacters, not
  this lane's; cast_view's HitLink lean is only wired in dev/gunplay/pistol_fight).
- 05:16 89c5fac9 brutality REQUEST 13 (second ask) DONE: homing shards stay stuck in the body
  (GunFx.stuck, at most 4 per fighter id; `GunFx.stuck_shards(id) -> Array[Vector3(off.x, off.y,
  flight angle)]`, offset from Fighter.pos in m); FightShardArt draws the crystal's back half
  standing out of the corpse. `arena_shard_stuck_64ppm/stuck_closeup.png` (looked at: the crystal
  stands out of the chest on the side the swarm came from). Unit 725/725 (`evidence/n7/unit-f.log`).
- Bench: skipped this iteration (bench.lock held by another lane since 05:05, under 20 minutes).
- Answers posted here for the other lanes (they read this JOURNAL):
  - -> brutality: REQUEST 11 answered by 5b51da41 (it6); REQUEST 12 DONE 0c0465fd (hold fire on the
    electro gun: kill_landed weapon electro_gun from one charged bolt; a tap still only stuns);
    REQUEST 13 DONE a1eb709f (ring patch) + 89c5fac9 (stuck shards: read GunFx.stuck_shards(id)
    from the FxView's GunFx; the list lives as long as the GunFx).
  - -> rivet-arsenal: REQUEST 12 DONE b48ec24a (StagePilot side included): PlayerCommand.aim_m is
    the cursor's distance; pass a reach to pack_aim (third arg) from ArenaArsenalBot to throw short.
  - -> showcase: REQUEST 18 DONE, REQUEST 19 DONE (a1eb709f).
- 05:17 18cbcebe sound hooks per weapon: weapons.json `shot_cue` (every gun names an existing
  audio_cues.json cue; test_charge_shot checks they exist), StageAudio plays it per round (shared
  file features/audio/stage_audio.gd: two small hunks, logged here); the charge-up cues
  `tazer_charge`. Placeholder mapping on tonight's cues, no new assets.
- Gates of record at 18cbcebe: lint 13/13, unit 726/726 (`evidence/n7/unit-g.log`), scenarios
  29/29 (`evidence/n7/scenarios-g.log`). Parity not re-run: no native or city-sim file changed
  this iteration (last bit-exact run it5, `evidence/n4/parity-l.log`). Bench skipped (lock held).

## Calls for the owner (iteration 7 additions, REPORT draft)
- gunplay-7: electro charged shot = held trigger auto-fires at full charge (default; clip
  arena_electro_charge_64ppm) vs release-to-fire. One value each: `charge_s` (0.6), `charge_damage`
  (150; absent = the old two-bolt gun).
- gunplay-8: the mini-nuke's fire burns as a ring round the rim (default, ground zero reads burnt
  out; arena_nuke_ring_32ppm) vs a full 6 m disc (city_nuke_block_32ppm). One value: RING_PATCH_M.
- gunplay-9: a thrown weapon lands at the mouse cursor (default; 1.2 m steps, up to 18 m) vs the
  fixed 14 m lob. One value: input_actions.json aim.aim_reach_step_m (0 = the fixed lob).

NEXT (iteration 8, in order):
1. A pad reach for thrown weapons (the right stick's deflection -> aim_m) and quest 1's
   LiveInput.px_per_m (when quest 1 gets a GunHand).
2. A heavier hit-feel for a charged bolt (needs the charged flag on CombatArena.struck: a shared
   signal; or HitLink reading the shot) and the charged bolt in the side-by-side reel.
3. Rivet's own flinch on his rig (the tint is in from another lane): REQUEST to rivet-motion /
   human-reactions with HitLink.lean as the source, or build it in ArenaRigs if nobody takes it.
4. Idle riot bench of record under the lock on a quiet machine.
5. REQUEST 3 (it5, victim camera) still open: the kill close-ups crop on the frame edge.
- 05:24 a5a890b1 NEXT 2 (first half) DONE: a charged bolt lands as a `blast` in the hit feel
  (HitLink.CHARGED_CLASS: boss_hit stop, knockdown reaction, explosion shake; `heavy` was tried
  first and has the same melee_hit stop as `shock`, so it added nothing); CombatArena.struck_charged
  marks the round being landed (FightAreas emits struck itself for bolts, so a flag, not a signal
  change). A lethal hit still uses the kill stop. Unit 727/727 (`evidence/n7/unit-h.log`), scenarios
  29/29 (`scenarios-h.log`). Charge strip re-cut from a HEAD clip (same sim: 4 bolts, 2 kills).
- Gates of record at a5a890b1: lint 13/13, unit 727/727, scenarios 29/29. Parity not re-run (no
  native/city-sim change). Bench skipped (lock held by another lane).
- Session end 05:27: every Godot run of mine was foreground and exited (the three Godot PIDs in
  tasklist are other lanes'); no bench.lock or image.lock taken; scratch emptied except cap.sh and
  sheet.py. frames.json: 15 entries, all files checked to exist.

NEXT (iteration 8, supersedes the list above):
1. The charged bolt in a side-by-side reel with the other finished guns (sound off, 5 s each).
2. A pad reach for thrown weapons (stick deflection -> aim_m); quest 1's LiveInput.px_per_m when
   quest 1 gets a GunHand.
3. Rivet's own flinch on his rig (the vermilion tint is in from another lane): REQUEST to
   rivet-motion / human-reactions with HitLink.lean as the source, or build it in ArenaRigs.
4. Idle riot bench of record under the lock on a quiet machine.
5. REQUEST 3 (it5, victim camera) still open.

## Iteration 9 (05:26 - 06:26), BUILD
- 05:27 read JOURNAL, git log, other lanes' JOURNALs. New to me:
  - rivet-arsenal REQUEST 16 (molotov wind stacking): ANSWER: the Trigger-side `wind_s` was never
    landed (no `wind_s` anywhere in code or weapons.json); the pilot-side PlayerThrow wind-up
    (60802820, windup_ticks 14) is the only one and stays. Nothing stacks. My NEXT item for it is
    dropped. The mini-nuke stays without a wind-up (free for either lane later).
  - human-reactions' 05:1x note "the arena bot's electro gun kills 1 cop in 45 s": their branch
    does not carry my charged shot (0c0465fd); on n-gunplay the held trigger charges and the
    charged bolt kills (arena_electro_charge_64ppm: 4 bolts, 2 kills in 13 s). A merge fixes it.
- NEXT 3 (Rivet's own flinch) checked: RigClips.hit already plays on Rivet's rig in ArenaRigs
  (rivet-arsenal's it1 note: his hit flinch flings an arm; they own the rig's look), the whole-body
  hit tint is in, and GunFxMarks draws cream sparks off his plating where an enemy round stops
  (gun_fx_rounds: Rivet is the first body checked). Brief item 4 is covered end to end; no build.
- 05:30 bench.lock taken (free), `node tools/bench/run.mjs` on a41b332e running (other lanes'
  Godot processes up: CONTENDED).
- 05:40 MEASURE riot + drive on a41b332e under bench.lock (`node tools/bench/run.mjs`, log
  `evidence/n8/bench.log`, raw `evidence/n8/bench/`), CONTENDED (four other Godot processes up):
  riot p99 CPU 7.09 ms (it6 8.04), 1 % low 99 fps (it6 90), combat blood 57 us a frame (3442 drop
  draws, 601 pool draws over 30.5 k frames) = 0.8 % of the p99; rigs p99 0.68 ms. Drive p99 3.73 ms,
  drive48 3.63 ms. Summary line p99 7.54 ms over all four (MISSES p99CpuMs, as every contended run).
  Brief item 5 stands: the blood is not the riot cost; the idle number of record needs a quiet
  machine (the Director's at the merge).
- 05:45 5a2746c2 NEXT 2 DONE: a pad throws by how far the right stick is pushed
  (LiveInput.stick_reach_m: just past the deadzone = 1.2 m, full push = the old 14 m lob). Unit
  729/729 (`evidence/n8/unit-a.log`), lint 13/13. DECISION in docs/decisions.md. Live input only:
  no replay or scenario input changes. Quest 1's LiveInput.px_per_m stays unset until quest 1
  gets a GunHand (its throw falls back to the fixed lob; nothing to wire tonight).
- 05:44 MILESTONE `MASTERS/n4/gunplay/side_by_side_table_six_48ppm.mp4` (NEXT 1 of it8): the six
  table guns in the arena pit at 48 px/m, 3x2, 5 s each, sound off, labelled: pistol, machine
  pistol, rocket launcher, flamethrower, electro gun (tap stun then the held charged zigzag),
  molotov (lands at the cursor). All six captured fresh on 29da90ec (`reel9_<gun>/`, 25 s each,
  0 script errors, Rivet 0 deaths; kills 4 / 4 / 3 / 4 / 2 / 5). Windows picked from 1 and 4 fps
  contact strips on each gun's first shots. Looked at: every cell reads as its own gun in one
  frame (`side_by_side_table_six_48ppm_still.png`). Cells are at half size (the full clips sit
  beside them).
- 05:50 MILESTONE `side_by_side_city_four_32ppm.mp4`: pistol, rocket, flamethrower, molotov in the
  city proving block (`--arena=city --clean`) at 32 px/m, fresh (`city9_<gun>/`, 0 script errors,
  Rivet 0 deaths, kills 5 / 7 / 4 / 5): the city clips the brief asked for and that were missing
  from MASTERS for these four guns. Looked at: blood on the cream paving, fire patches, a rocket's
  blast ring, tracers; small at the game zoom, as at 32 px/m.
- 05:48 51422333 + fc86e070 FINDING and fix: the range model (TTK table, range station) clicked the
  electro gun and never charged, and ProjectileSim ignored `charge_damage`, so the TTK table showed
  stun taps only. Now RangeDrill.Lane.hold_charge holds a charge gun on and the charged round lands
  charge_damage (GunHand's rule); the TTK bench writes a second row `electro_gun:charged`. The clicked
  rows are identical to it6 cell for cell (checked by diff). `evidence/n8/ttk-electro.md`: the charge
  wins on strafers (10 m 0 -> 100 % kills) and robots (5.6 -> 4.5 s) but two taps beat it on a
  still human (0.62 vs 1.20 s). Owner call gunplay-10 below. Unit 730/730 (`evidence/n8/unit-c.log`),
  scenarios 29/29 on 29da90ec (`scenarios-a.log`; the range-model change touches no scenario golden:
  scenario_gunplay_fire compares a run to itself).

## Calls for the owner (iteration 9 additions, REPORT draft)
- gunplay-10: the electro gun's plain tap bolts stay lethal on humans (default: two taps drop a
  still human in 0.62 s, faster than the 1.2 s held charge) vs stun-only taps on humans so the
  charged one-shot (brutality's electro kill) is the only electro kill. Evidence:
  evidence/n8/ttk-electro.md + arena_electro_charge_64ppm (tap vs charge in one clip). One value:
  the electro row's damage on humans.
- gunplay-11: a pad throws by stick deflection, full push = the old 14 m lob (default) vs full
  push = the 18 m bit maximum. One value in LiveInput.stick_reach_m (aim_range_m -> REACH_MAX steps).
- 05:55 4e737ba1 FINDING + fix (weakest item: the live clips go quiet): in the 25 s pit clips the
  bot stopped shooting after ~13 s while a guard stood behind the crate row firing over it: no lane,
  so it held fire and rocked left-right on the spot (the strafe flips every 45 ticks). Now, blocked
  for FLANK_AFTER 30 ticks, it keeps one side and closes in (half the aim). Same seed, 48 px/m,
  25 s: pistol shots 4 -> 9, kills 4 -> 8; machine pistol 17 -> 34, 4 -> 8; electro gun 2 -> 5 kills
  (tap stun + held charge); Rivet 0 deaths in all (`MASTERS/n4/gunplay/flank9_<gun>/`). Looked at
  the pistol and electro strips: Rivet walks round the crates into wave 3. Dev bot only (no
  scenario uses GunplayBot). This also answers human-reactions' "the arena bot's electro gun kills
  1 cop in 45 s" once they carry 0c0465fd (charge) + 4e737ba1 (flank).
- frames.json: 15 entries (new: the six-gun pit reel + still, the city four-gun reel, the flank
  electro clip; dropped the oldest four, files stay).
- Gates of record at 4e737ba1: lint 13/13 (pre-commit hook on every commit), unit 730/730
  (`evidence/n8/unit-d.log`), scenarios 29/29 (`evidence/n8/scenarios-d.log`). Parity not re-run: no
  native or city-sim file changed this iteration (last bit-exact run it5, `evidence/n4/parity-l.log`).
  Bench: taken and released this iteration (05:30-05:40), numbers above.
- Session end ~06:00: every Godot run of mine was foreground or a finished background job and
  exited; bench.lock released by the bench job; no image.lock taken. Scratch holds only cap.sh,
  city.sh, reel.sh, grid.py and sheet.py.

NEXT (iteration 10, in order):
1. Owner calls gunplay-10 (electro taps lethal on humans) and gunplay-11 (pad full push) as
   REPORT entries; build nothing until the owner answers (both are one value).
2. (done 06:00, see below) the 64 px/m city charge close-up; the kill itself is still off-frame.
3. The idle riot bench of record on a quiet machine (the Director's at the merge otherwise).
4. REQUEST 3 (it5, victim camera) still open for the arena owner / showcase.
5. Re-cut the six-gun pit reel on longer windows once the flank bot fights all waves (the
   current windows sit before the first blocked lane, so they are unchanged by 4e737ba1).
- 06:00 NEXT 2 DONE early: `MASTERS/n4/gunplay/city9_electro_64ppm/` (city block, --clean, 64 px/m,
  20 s, 2 kills, Rivet 0 deaths) + `charge_sequence_64ppm.png` (5 fps: gather, ring, the zigzag
  bolt toward the stunned cop). Looked at: the charge reads at 64 px/m on the cream paving; the
  victim dies just above the frame (camera on Rivet; REQUEST 3). Observation, not a REQUEST: the
  city block's guards draw black-and-white at 64 px/m (the same in the it7 city clip, so not new;
  likely the SWAT/thug kit of enemy-ai's roster, not a cop-blue regression).
- 06:03 NOTE for the Director / the morning page: Rivet still flashes solid vermilion when hit in
  n-gunplay's clips (flank9_electro_gun at 13 s, the hand cannon close-up) because this branch does
  not carry human-reactions' 8669b5d9 (cream hit flash, rivet-arsenal REQUEST 1 / showcase
  REQUEST 3). The merge brings it; not cherry-picked this late (it also carries their area-state rig
  work, a wider change than the flash).

## Iteration 10 (06:02 - 07:02), BUILD
- 06:02 read JOURNAL, git log, other lanes' JOURNALs. Addressed to me and open: human-reactions
  REQUEST 2 (the N/S kill spray still a column on their board) and REQUEST 3 (ReactLink.blocked:
  spark a shield-stopped round instead of a wound mark). weapon-art FRICTION 05:45 (the pit molotov
  never throws in 440 ticks) is on their branch without my bot fixes: on n-gunplay the pit molotov
  throws and kills (reel9_molotov: 5 kills in 25 s; flank fix 4e737ba1). No action.
- 06:06 269deba4 REQUEST 2 DONE: blood_fx.json game.spray_tilt_min_deg 6: every kill spray turns
  6-14 deg off its blow (sign from the spot's hash); 0 = the old 0-14 spread exactly. Unit test with
  a planted 0 floor. First run FAILED on my own typing slip (a Variant into deg_to_rad, warnings are
  errors: 14 failing, `evidence/n9/unit-a.log`); fixed, 731/731 (`unit-b.log`).
  A/B `evidence/n9/blood_spray_floor_ab.png` (dev/gunplay/blood_dirs.gd, four kills due south, min
  0 vs 6). Looked at: the columns lean now, but the change is subtle; the spray still reads as a
  narrow fan. If the board still reads ruler-straight, raise the floor (one value) or widen the
  hit's cone_deg; DECISION in docs/decisions.md.
- 06:08 5efdc825 REQUEST 3 DONE (gunplay side): GunFx.shield_test (fighter, dir) -> bool, a
  render-side hook; a round it says a riot shield stopped draws as METAL (cream sparks) instead of
  the body's ink burst, and no shard sticks. Not wired here: ReactLink is not on this branch.
  For human-reactions: in ArenaRigs (or wherever ShieldSparks is wired) set
  `view.gun_fx.shield_test = func(f, dir): return <ReactLink says f blocked dir>` (FxView builds
  the GunFx lazily: fx_view.gd:34). Unit 732/732 (`unit-c.log`).
- FightCam (REQUEST 3 of it5, the victim camera, built in my own hook): `--cam=fight` in the arena
  pit frames Rivet and the hostile he fights (half way, at most 4.5 m off Rivet, eased 5 % a tick, a
  fresh corpse held 150 ticks). GunplayHook.attach_view sets CollectCallView.focus each tick; the
  city is left alone (city.focus also streams the chunks). View only, dev capture flag. Unit tests
  (lean half way, hold on the body, let go; a far foe never pushes Rivet out). Unit 734/734
  (`unit-d.log`), lint 13/13.
- 06:12 MEASURE FightCam A/B, hand cannon in the pit at 64 px/m, 15 s, same seed: both runs 4 shots,
  4 kills, 8 hits, 0 deaths, identical HUD ticks (the camera is view only). `MASTERS/n4/gunplay/
  fightcam_hand_cannon_64ppm_ab.mp4` (+ `_still.png`, `camfight_hand_cannon/`, `camrivet_hand_cannon/`).
  FINDING on the first cut (150-tick corpse hold): at tick 456 the camera still sat on the first
  corpse while Rivet shot a cop to the north-east, so the new fight left the frame. Fixed in
  eeec4d97 (hold 60 ticks; the faced foe wins). Looked at the re-cut (2 fps strip, 5-14.5 s): Rivet
  and his foe share the frame through most of the fight and the last two kills fall in frame with
  their spurts. LIMIT: a 64 px/m frame is 12.5 m tall; a kill 10 m south still lands at the bottom
  edge with Rivet at the top (tick 417 in the still). It helps; it is not a director camera.
- Gates of record at eeec4d97: lint 13/13, unit 735/735 (`evidence/n9/unit-e.log`), scenarios 29/29
  (`evidence/n9/scenarios-a.log`, on 099b9bab: the later commit touches FightCam and its test only).
- 06:18 MILESTONE `MASTERS/n4/gunplay/fightcam_unique_kills_64ppm.png`: hand cannon, plasma rifle,
  ray gun, homing shard, electro gun in the pit at 64 px/m with --cam=fight, fresh on eeec4d97
  (`camfight_<gun>/`, 15 s each, 0 script errors, Rivet 0 deaths; shots / kills 4/4, 7/4, 4/4,
  13/3, 4/2). Looked at: the hand cannon, plasma and ray kills fall in frame with their spurts
  (the old unique_kills sheet had to crop on a victim at the frame's edge); the shard and electro
  corpses stay in shot. frames.json: the sheet + the hand cannon A/B clip on top, dropped the two
  electro strips whose clips stay (15 entries, every file checked).
- 06:19 re-shooting the six table guns' pit reel at 48 px/m with --cam=fight (`reel10_<gun>/`, 25 s
  each) so the morning's side-by-side shows each victim fall (NEXT 5 of it9).
- 06:24 MILESTONE `MASTERS/n4/gunplay/side_by_side_table_six_fightcam_48ppm.mp4` (+ `_still.png`;
  NEXT 5 of it9 done): the six table guns in the pit at 48 px/m with --cam=fight, fresh on
  eeec4d97 (`reel10_<gun>/`, 25 s each, 0 script errors, Rivet 0 deaths; shots / kills pistol 9/8,
  machine pistol 34/8, rocket 7/6, flamethrower 34/4, electro 10/5, molotov 6/5: the flank bot
  fights all waves now). Windows picked on a kill each from 1 fps strips. Looked at the 1 fps
  preview of the reel: every cell carries its kill in frame (the spurts, the rocket's blast star
  and corpses, flame on a guard, the electro bolt's kill, the bottle's patches). frames.json: it
  replaces the camera-on-Rivet six-gun reel (now its `before`), 15 entries, all files checked.
- NOTE the city keeps its own camera: CitySystem.focus drives the spawner and the sim step
  (city_system.gd:63-70), so a view camera there would move the sim. FightCam stays pit-only.
- 06:26 31948cc2 FxView.gun_fx(): the view's GunFx made on first use, so human-reactions can set
  `view.fx_view.gun_fx().shield_test = func(f: Fighter, dir: Vector2) -> bool: ...` from ArenaRigs
  (ShieldSparks' wiring) before the first shot. Appended at the end of fx_view.gd; _draw untouched
  (FxView is the file weapon-art / showcase / rivet-arsenal merged hunks in). Unit 736/736
  (`evidence/n9/unit-f.log`), lint 13/13.
- REQUEST 3 ANSWER -> human-reactions: done on n-gunplay (5efdc825 + 31948cc2). Wire it in one line
  where ShieldSparks is wired; a blocked round then draws cream sparks (GunFxMarks METAL) at the
  shield instead of the ink burst. Your ShieldSparks can stay for the thrown-back spark fan.
- REQUEST 2 ANSWER -> human-reactions: done (269deba4, spray_tilt_min_deg 6). Cherry-pick it; if
  the board still reads straight, raise that one value.
- 06:27 bench.lock taken (free); `node tools/bench/run.mjs` on 31948cc2 running, other lanes'
  Godot up (CONTENDED).

## Calls for the owner (iteration 10 additions, REPORT draft)
- gunplay-12: the play camera frames the fight (FightCam's rule: half way to the foe Rivet faces,
  at most 4.5 m off him, a fresh kill held 1 s) vs the placeholder arena-2 A (leans toward the
  mouse). Tonight it is a dev capture flag only (`--cam=fight`, pit). Evidence:
  `fightcam_hand_cannon_64ppm_ab.mp4` (left: camera on Rivet; right: fight framing; same sim) and
  `side_by_side_table_six_fightcam_48ppm.mp4`. In the city the camera point also steers the sim's
  spawner (CitySystem.focus), so a game camera there needs a split between the view point and the
  sim focus first (a city-lane change).
- gunplay-13: the kill spray's least turn off the blow, 6 deg (default; human-reactions' number)
  vs a wider floor. Evidence: `evidence/n9/blood_spray_floor_ab.png` (four kills due south, 0 vs 6
  deg: the change is subtle). One value: blood_fx.json game.spray_tilt_min_deg.
- 06:40 MEASURE riot + drive on 31948cc2 under bench.lock (06:27-06:39, `node tools/bench/run.mjs`,
  log `evidence/n9/bench.log`, raw `evidence/n9/bench/`), heavily CONTENDED (two other lanes'
  windowed Godot runs up the whole time): riot p99 CPU 13.09 ms (it9 7.09), 1 % low 42 fps (it9
  99), combat blood 132 us a frame (it9 57) = 1.0 % of the p99; the blood's work is the same as it9
  (3400 drop draws / 599 pool draws vs 3442 / 601), so its time doubled with the machine, not with
  a change. Drive p99 3.53 ms (it9 3.73), drive48 3.36 ms (3.63); rigs p99 1.15 ms. Summary line p99
  13.09 ms MISSES p99CpuMs and low1Fps (exit 1, as every contended run). Not a number of record:
  the idle riot bench stays the Director's at the merge. Brief item 5's finding stands: the blood
  is about 1 % of the riot frame.
- Session end ~06:42: every Godot run of mine was foreground or a finished background job and has
  exited; bench.lock released by the bench job (06:39); no image.lock taken. Scratch
  (gtai-n4/scratch/gp) holds only cap.sh, city.sh, reel.sh, grid.py, sheet.py, killsheet.py.
  frames.json: 15 entries, every file checked to exist.
- Gates of record at a857bfe1: lint 13/13 (pre-commit hook), unit 736/736 (`evidence/n9/unit-f.log`,
  at 31948cc2; a857bfe1 changes a station doc string only), scenarios 29/29
  (`evidence/n9/scenarios-b.log`, at 31948cc2). Parity not re-run: no native or city-sim file
  changed this iteration (last bit-exact run it5, `evidence/n4/parity-l.log`).

NEXT (iteration 11, in order):
1. REPORT: calls gunplay-7..13 with their clips (JOURNAL "Calls for the owner" sections); the
   frames.json top three are the fight-cam six-gun reel, its still and the unique kill sheet.
2. If human-reactions cherry-picks 269deba4 and still sees columns on their board: raise
   spray_tilt_min_deg (one value) and re-shoot evidence/n9's A/B.
3. A 32 px/m city clip per gun is in MASTERS for pistol, rocket, flamethrower, molotov, electro
   (city9_*) and the uniques (city_*_block_32ppm); machine pistol's city clip is
   city_mpistol_block_32ppm (older, pre flank bot): re-shoot it fresh if time allows.
4. The idle riot bench of record stays the Director's (two contended runs tonight: 7.09, 13.09 ms;
   blood 0.8-1.0 % of the p99 both times).
- 06:43 NEXT 3 DONE early: `MASTERS/n4/gunplay/city10_machine_pistol/` (city block, --clean, 32 px/m,
  25 s, fresh on a4df459e: 20 shots, 5 kills, Rivet 0 deaths, 0 script errors) and
  `side_by_side_city_six_32ppm.mp4`: the six table guns in the city at 32 px/m, 5 s each from 6 s
  (pistol, rocket, flamethrower, molotov from city9_*; electro from city_electro_charge_32ppm).
  Looked at the 1 fps preview: each cell shows its gun's work (tracer kills and blood, the
  rocket's blast ring, flame bursts, the electro kill, the bottles' patches); small at the game
  zoom, as at 32 px/m. frames.json: it replaces the city four-gun reel (now its `before`), 15
  entries, all files checked. NEXT list above stands without item 3.
- 06:44 MILESTONE `MASTERS/n4/gunplay/side_by_side_pistol_mpistol_fightcam_64ppm.mp4`: pistol and
  machine pistol in the pit at 64 px/m with --cam=fight, fresh on ca765ba8 (`camfight_pistol/`,
  `camfight_machine_pistol/`, 15 s, 0 script errors, Rivet 0 deaths; 4/4 and 13/3). Looked at the
  2 fps strips and a still (tick 516): Rivet with his shells on the floor and the cop down with his
  spurt in one frame; every kill falls in frame. frames.json: added at 4th, dropped the nuke ring
  sequence strip (its folder stays), 15 entries, all files checked.
- Session end 06:45: no Godot process of mine running, no lock held, scratch holds only the six
  scripts. NEXT list above stands (1, 2, 4).

## Iteration 11 (06:45 - 07:45), BUILD
- 06:45 read JOURNAL, git log, other lanes' JOURNALs (human-reactions, brutality, weapon-art): no
  new REQUEST to gunplay since it10 (REQUEST 2/3 answered at 06:06/06:26; weapon-art's 05:45 pit
  molotov FRICTION is their branch without the flank fix, as noted at 06:02).
- Registry rules applied (motion-quality-gating: judge in motion at the game zoom and a close-up;
  depth-ordered-layered-art: the char prints under the flames and the bodies, same draw slot as the
  old disc).
- 06:47 4e11100b NEXT 1 DONE: `docs/night/2026-11-04/gunplay/REPORT.md` DRAFT (summary, proofs
  table, calls gunplay-7..13 with their clips, gaps); gates of record to fill at the report phase.
- 06:46 full gates started on 4e11100b (`node tools/evidence/run.mjs --no-bench --allow-dirty`,
  log `evidence/n10/evidence.log`).
- 06:48 FINDING (weakest visual item, from the city six-gun reel at 32 px/m and city9_molotov at
  9.2 s): a fire patch prints on a flat translucent grey disc with a crisp edge: it reads as a debug
  area circle, not an ink scorch. Fix in a new view-only file `FightScorchArt` (fight_areas_art.gd
  is 199 lines): a ragged soot blotch (18 points, tongues every third licking past the rim), a
  darker char core, a broken ink edge (about half the sides), seven cinder specks past the rim;
  shape from a hash of the patch centre (stable per patch, no RNG stream). The mini-nuke's ring
  patch is untouched (gunplay-8's evidence). Hook held back until the running gates finish
  (editing a script mid-run fails it).
- 06:49 MEASURE gates on 47476501 (the run started before 4e11100b, a docs-only commit; log
  `evidence/n10/evidence.log`): lint 13/13, unit 736/736, scenarios 29/29, parity bit-exact
  (planted mutation caught at step 629). Selftest FAIL on the accent audit only (NEW off-doctrine
  48 px/m vermilion on vehicles 8 px, 64 px/m vermilion on cop 28 px; look goldens 11/11, block 5/5,
  world lock holds): the blood-edge flicker class of showcase REQUEST 7 (04:xx above: the audit
  compares a full capture with a layer-hidden capture of a later frame; d5-city owns the fix). Not
  one of this lane's four gates.
- 06:50 ec17e8de FightScorchArt + hook (the 06:48 FINDING). First check-only failed on
  `append()`'s discarded bool (warnings are errors): `@warning_ignore` as city_blood.gd does.
- 06:53 9113de63 MILESTONE burnt ground stays: `FightScorch` (view state on GunFx, stepped in
  GunFx.step, drawn first in GunFxArt.draw_under = under the bodies): when a patch leaves
  FightAreas.patches its char stays 900 ticks, fades over 120, 24 marks max; ring patches (nuke)
  leave none. The live char runs 0.7..1.0 strength and the burnt one starts at 0.7, so no pop.
  Second look pass (city at 13 s): the first char was a flat grey stain, its edge invisible at half
  strength -> splash-burn streaks out of the core + floor hatch + firmer edge (0.85, 3 px).
- 06:59 46d87a70 FINDING from the 64 px/m pit close-up: on the dark pit floor the thin streaks and
  long straight edge runs read as cracks / a spider web. Streaks are now flat ink wedges (broad
  base to a point, mostly inside the blotch), the outline 26 points, two edges in five inked.
  Looked at again at 12 s and 16 s: a jagged splash-burn star, dark on dark, no web.
- 07:00 MILESTONE `MASTERS/n4/gunplay/molotov_scorch_ab_city_32ppm.mp4` (+ `.png`): before (city9,
  flat disc, gone with the fire) vs after (city11_molotov, fresh on 46d87a70's look, 25 s, 0 script
  errors) side by side, same sim (flames and bodies match at 9.2 s across the commits: view-only
  change confirmed by eye). `camfight11_molotov/` 64 px/m pit close-up, 20 s, 0 script errors.
  frames.json: the A/B pair + the close-up at 4-6; dropped the old unique kill sheet (superseded by
  the fight-cam one), the stuck-shard still and the flank electro clip; 15 entries, all checked.
- Unit 744/744 at 46d87a70 (`evidence/n10/unit-a.log`; 8 new tests in test_fight_scorch_art.gd and
  test_fight_scorch.gd), lint 13/13 (hook). DECISION line in docs/decisions.md.
- 07:03 scenarios 29/29 at 46d87a70 (`evidence/n10/scenarios-a.log`).
- 07:05 2f520b56 MILESTONE a rocket blast scorches the ground it hit: FightScorch also reads
  FightAreas.blasts (new born ticks only): a char 0.4 x the splash radius at the blast tick, printed
  under the starburst, held 15 s; bursts under MIN_BLAST_M 2 m (homing shard 1.2) and the nuke
  leave none, and a bottle's burst (a live patch at the same centre) is left to its fire patch.
  Unit test (rocket once, bottle and shard none). Evidence: `city11_rocket_launcher/` (32 px/m,
  25 s, 0 script errors), `camfight11_rocket/` (64 px/m pit, 15 s, 0 script errors, still
  `scorch_12s_64ppm.png`), `rocket_scorch_ab_city_32ppm.png` (old it9 clip vs new at 9 and 14 s;
  NOT the same sim: city9 predates the flank fix). Looked at: a dark blast star under the corpse
  and its blood on the cream paving; dark on dark on the pit floor (a burn, not a decal).
- 07:07 checked the flamethrower in the city (`city11_flamethrower/`, 32 px/m, 25 s, 0 script
  errors, still `char_11s_32ppm.png`): its 0.8 m run-off patches leave small overlapping char stars
  along where the flame landed, read as scorched ground; no change needed.
- frames.json: + the rocket A/B still after the molotov close-up; dropped the six-gun reel's still
  (the reel is first). 15 entries, all files checked.
- 07:10 `MASTERS/n4/gunplay/side_by_side_city_six_32ppm_it11.mp4`: the city six-gun reel re-cut
  with the fresh rocket, flamethrower and molotov clips (city11_*), labelled, 5 s each; looked at the
  4 s still: the molotov cell shows the fire and the char of the bottle before it, the rocket cell
  a scorch. frames.json: it replaces the it10 reel (now its `before`), 15 entries, all checked.
- 07:10 scenarios 29/29 at 2f520b56 (`evidence/n10/scenarios-b.log`).
- 07:12 3d85efbe the mini-nuke's burning ring had the same debug look (a smooth translucent
  annulus, `arena_nuke_ring_32ppm/ring_patch_sequence.png`): now a band of char blotches round
  0.85 r (FightScorchArt.ring, one per 2.2 m of rim, each 0.24 r), ground zero bare for the
  vaporised shadows (brutality REQUEST 13's reason holds). `arena_nuke_ring11_32ppm/` (pit 32 px/m,
  15 s, 0 script errors; still `ring_char_13s_32ppm.png`): looked at: a ragged burnt band under the
  flames; the edge strokes are a little busy at this size, read as ink. Unit 745/745
  (`evidence/n10/unit-b.log`). REPORT gunplay-8 points at the new clip.
- 07:16 scenarios 29/29 at 3d85efbe (`evidence/n10/scenarios-c.log`). REPORT draft: gates
  section filled as of 3d85efbe (lint 13/13, unit 745/745, scenarios 29/29, parity bit-exact on
  47476501 with no native/city-sim change since, selftest's accent audit = the known blood-edge
  class, bench CONTENDED only).
- Session end ~07:17: every Godot run of mine was foreground or a finished background job and
  has exited; no bench.lock or image.lock taken this iteration; scratch holds only cap.sh,
  city.sh, reel.sh, grid.py, sheet.py, killsheet.py. frames.json: 15 entries, all files checked.
- Shared files touched this iteration: none (gun_fx.gd / gun_fx_art.gd / fight_areas_art.gd are
  this lane's; docs/decisions.md one DECISION line).

NEXT (iteration 12 / report phase, in order):
1. REPORT: re-run the gates on the final head and update "Gates of record"; check every
   MASTERS path in the REPORT exists; calls gunplay-7..13 stand as drafted.
2. If time: the burnt marks' lifetime (HOLD_TICKS 900) in a long fight: watch a 40 s molotov city
   run for clutter (24 marks cap); lower HOLD_TICKS if the paving reads dirty.
3. If human-reactions still sees blood columns on their board after cherry-picking 269deba4:
   raise spray_tilt_min_deg (one value).
4. The idle riot bench of record stays the Director's (the machine was contended all night).
