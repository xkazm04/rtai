extends Scenario
## City production fight, measured at the same pre-ballistics point as the five-seed probe.
## Stop on the last kill of wave five. Use the five probe seeds for flank opportunities:
## an underfilled ranged group can give every living flanker a shooting token.

const WAVES: int = 5
const SEEDS: int = 5
const LIMIT: int = 90 * SimClock.TICK_RATE
const CITY_COVER: float = 0.4419
const CROWD_LIMIT: float = 0.02


func run(_tree: SceneTree) -> String:
	var contract: String = _row_contract()
	if not contract.is_empty():
		return contract
	var live: Dictionary = _fight(false)
	var complete: bool = live.cleared == WAVES and live.spawned == WAVES and live.replayed
	var flank_ticks: Array[int] = [live.flank_ticks]
	for i: int in range(1, SEEDS):
		var other: Dictionary = _fight(false, ArenaSession.MASTER_SEED + i)
		complete = complete and other.cleared == WAVES and other.spawned == WAVES and other.replayed
		flank_ticks.append(other.flank_ticks)
	var bad: Dictionary = _fight(true)
	@warning_ignore("return_value_discarded")
	write_evidence("arena-squad.json", {"live": live, "no_separation": bad, "flanks": flank_ticks})
	if not complete:
		return "one or more city squads failed to clear five waves and replay"
	if (
		live.crowded >= CROWD_LIMIT
		or live.cover <= CITY_COVER
		or live.flankers < 1
		or flank_ticks.max() <= 0
	):
		return "city squad positioning: %s" % live
	if bad.crowded < CROWD_LIMIT:
		return "crowding judge missed separation disabled: %s" % bad
	return ""


func _open(brain: String = "mixed", seed: int = ArenaSession.MASTER_SEED) -> ArenaSession:
	var options: ArenaArgs = ArenaArgs.parse(["--arena=city", "--enemy-brain=" + brain])
	return ArenaSession.open_with_args(Events, Data, seed, null, options)


func _fight(plant: bool, seed: int = ArenaSession.MASTER_SEED) -> Dictionary:
	var s: ArenaSession = _open("mixed", seed)
	var arena: FightProbeArena = FightProbeArena.attach(s.stage.arena)
	arena.squad_ai.plant_no_separation = plant
	arena.squad = s.stage.pit.standing
	var meter: FightProbeSample = FightProbeSample.new(arena)
	meter.walls = s.stage.walls
	meter.cells = s.stage.cells
	meter.observing = true
	arena.sampled = meter.sample
	s.world.loop().set_input(ArenaPitBot.new(s.stage, s.actions))
	s.world.loop().start_recording()
	while s.tick() < LIMIT and s.stage.pit.waves_cleared < WAVES:
		s.step()
	var log: ReplayLog = s.world.loop().finish_recording()
	var result: Dictionary = {
		"cleared": s.stage.pit.waves_cleared,
		"spawned": s.stage.pit.wave,
		"ticks": s.tick(),
		"crowded": float(meter.crowded) / maxi(meter.hostile_ticks, 1),
		"cover": float(meter.covered) / maxi(meter.hostile_ticks, 1),
		"flankers": meter.flankers.size(),
		"flank_ticks": meter.states.get("flank", 0),
	}
	arena.sampled = Callable()
	_close(s)
	if not plant:
		var again: ArenaSession = _open("mixed", seed)
		result.replayed = again.world.verify_replay(log) == ""
		_close(again)
	return result


func _close(s: ArenaSession) -> void:
	s.stage.hooks.clear()
	s.live.cursor_px = Callable()
	if s.stage.vehicles != null:
		s.stage.vehicles.world = null
	s.world.free()


## Exercise alternate row values through the production spawn, trigger and cover return.
## A short peek ends before the holder would normally rotate off its shooting token.
func _row_contract() -> String:
	var rng: RandomNumberGenerator = RngRegistry.new(12).stream(&"combat")
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	var map: GuardRouteMap = GuardRouteMap.new(
		Rect2(-30, -30, 60, 60), [Rect2(-4, -1, 1, 2)], null, 0.45
	)
	arena.guard_map = map
	arena.squad_ai = ArenaSquad.new(map)
	var squad: ArenaSquad = arena.squad_ai
	var patrol: EnemyRoster.Archetype = squad.pit.roster.archetype(&"patrol_cop")
	patrol.production_weapon = &"gloria"
	patrol.peek_ticks = 20
	arena.rivet.pos = Vector2(8, 0)
	var h: Fighter = squad.spawn_member(arena, Vector2.ZERO, patrol.id)
	h.pos = Vector2(-5, 0)
	h.cooldown = 0
	squad.pit.roster.max_shooters = 0
	for tick: int in 60:
		arena.step(tick)
	var peek: String = _judge_peek(arena, h, patrol)
	return _judge_mix(arena) if peek.is_empty() else peek


func _judge_peek(arena: CombatArena, h: Fighter, patrol: EnemyRoster.Archetype) -> String:
	var squad: ArenaSquad = arena.squad_ai
	var hidden: Vector2 = squad.minds[h.id].agent.goal
	var hid: bool = squad.minds[h.id].motion == EnemyAgent.State.COVER
	squad.pit.roster.max_shooters = 1
	arena.rivet.pos = Vector2(-8, 4)
	var exposed: int = 0
	var fired: bool = false
	for tick: int in range(60, 120):
		arena.step(tick)
		exposed += int(squad.minds[h.id].agent.token)
		for shot: Shot in arena.shots:
			fired = fired or shot.weapon == patrol.production_weapon
		if (
			exposed > 0
			and not squad.minds[h.id].agent.token
			and squad.minds[h.id].motion == EnemyAgent.State.COVER
		):
			break
	var back: bool = (
		squad.minds[h.id].motion == EnemyAgent.State.COVER and h.pos.distance_to(hidden) < 1.5
	)
	if not hid or not back or not fired or exposed != patrol.peek_ticks - 1:
		return (
			"patrol cover/peek/weapon: hid %s, returned %s, fired %s, exposed %d"
			% [hid, back, fired, exposed]
		)
	return ""


## Check real wave composition through wave three, then the optional mix and riot override.
func _judge_mix(arena: CombatArena) -> String:
	var stage: ArenaSession = _open()
	var pit: ArenaPit = stage.stage.pit
	var seen: Dictionary[StringName, bool] = {}
	var valid: bool = _contractors_only()
	for i: int in 3:
		pit._spawn_wave(stage.stage.arena)
		for j: int in pit.standing.size():
			var h: Fighter = pit.standing[j]
			valid = valid and h.archetype == pit.squad_mix[(i + j) % pit.squad_mix.size()]
			seen[h.archetype] = true
			valid = valid and _look_matches(h)
		pit.standing.clear()
	_close(stage)
	for id: StringName in [&"patrol_cop", &"riot_cop", &"swat", &"robot_thug", &"robot_gunner"]:
		valid = valid and seen.has(id)
	pit.squad_mix.clear()
	pit.riot_hp = ArenaPit.armored_hp()
	pit._spawn_wave(arena)
	valid = (
		valid
		and pit.standing[0].archetype == &"riot_cop"
		and pit.standing[1].archetype == &"contractor"
	)
	return "" if valid else "mixed squad wave order, riot override or contractor fallback failed"


func _look_matches(h: Fighter) -> bool:
	if h.archetype in [&"robot_thug", &"robot_gunner"]:
		return ArenaRobotRigs.takes(h)
	if ArenaRobotRigs.takes(h):
		return false
	var look: int = ArenaSquadLooks.look(h, false, false)
	match h.archetype:
		&"riot_cop":
			return look == ArenaSquadLooks.RIOT_LOOK
		&"swat":
			return look == RigVariant.SWAT
	return look == ArenaSquadLooks.PATROL_LOOK


func _contractors_only() -> bool:
	var session: ArenaSession = _open("squad")
	var pit: ArenaPit = session.stage.pit
	pit.wave = 1
	pit.riot_hp = ArenaPit.armored_hp()
	pit._spawn_wave(session.stage.arena)
	var valid: bool = session.stage.arena.squad_ai != null and not pit.standing.is_empty()
	for h: Fighter in pit.standing:
		valid = valid and h.archetype == &"contractor"
	_close(session)
	return valid
