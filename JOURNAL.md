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
