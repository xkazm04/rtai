extends RefCounted
## The arena's real rounds against a PitDummy dodge reader. It counters with Gloria after
## seeing the first attack (or after three seconds), and keeps dodging until rounds land.

const LIMIT_TICKS: int = 1800
const COUNTER_DELAY: int = 18
const OPENING_TICKS: int = 3 * SimClock.TICK_RATE

var enemy: StringName = StringName(LaunchArgs.value("--enemy"))


func knows(id: StringName) -> bool:
	return EnemyRoster.shipped(EnemyRoster.TABLE, true).archetype(id) != null


func run(id: StringName, seed_value: int, profile: String) -> Dictionary:
	var rng: RandomNumberGenerator = RngRegistry.new(seed_value).stream(&"combat")
	var bus: EventBus = EventBus.new()
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	arena.rivet.weapon = &"gloria"
	var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2(14, 0), id)
	var row: Dictionary = {
		"seed": seed_value,
		"damage_to_rivet": 0.0,
		"enemy_killed_tick": null,
		"tells_shown": 0,
		"shots_fired": 0
	}
	_fight(arena, h, row, _reader(profile, seed_value))
	bus.free()
	return row


func _reader(profile: String, seed_value: int) -> PitDummy:
	var dummy: PitDummy = PitDummy.new(PitDummy.Mode.DODGE)
	if profile != "perfect":
		dummy.react_ticks = 15 if profile == "average" else 25
		dummy.read_frac = 0.75 if profile == "average" else 0.5
		dummy.aim_err_deg = 4.0 if profile == "average" else 8.0
		dummy.read_salt = seed_value
		# Same human-reader convention as enemy_pit_view: a missed tell is a missed dodge.
		dummy.watch_rounds = false
	return dummy


func _fight(arena: CombatArena, h: Fighter, row: Dictionary, dummy: PitDummy) -> void:
	var nails: int = 0
	var counter_at: int = OPENING_TICKS
	var telling: bool = false
	for tick: int in range(1, LIMIT_TICKS + 1):
		_dodge(dummy, arena)
		if tick >= counter_at and h.alive():
			var offset: float = (
				(fposmod((nails + 1) * 0.618034, 1.0) * 2.0 - 1.0) * dummy.aim_err_deg
			)
			var aimed: Vector2 = (h.pos - arena.rivet.pos).rotated(deg_to_rad(offset))
			nails += int(arena.rivet_fire(arena.rivet.pos + aimed))
		var hp: float = arena.rivet.hp
		arena.step(tick)
		row.damage_to_rivet += maxf(0.0, hp - arena.rivet.hp)
		var mind: SquadMind = arena.squad_ai.minds.get(h.id)
		if mind != null:
			var windup: bool = h.tell_left > 0 or h.swing_left > 0
			row.tells_shown += int(windup and not telling)
			telling = windup
			var swung: bool = (
				h.swing_tick >= 0 and tick == h.swing_tick + mind.agent.arch.telegraph_ticks
			)
			var fired: bool = mind.agent.shot_tick == tick and not swung and not mind.agent.melee()
			row.shots_fired += int(fired)
			if swung or fired:
				counter_at = mini(counter_at, tick + COUNTER_DELAY)
		if not h.alive() and row.enemy_killed_tick == null:
			row.enemy_killed_tick = tick
		if not arena.rivet.alive() or (not h.alive() and arena.shots.is_empty()):
			break


func _dodge(dummy: PitDummy, arena: CombatArena) -> void:
	var pit: EnemyPit = arena.squad_ai.pit
	pit.rivet_pos = arena.rivet.pos
	pit.shots = arena.shots
	dummy.step(pit)
	arena.rivet.pos = pit.rivet_pos
