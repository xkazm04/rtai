extends RefCounted
## Run the same sessions as scenario_arena_pit and scenario_quest_collect_call.
## World ticks are zero-based. Wave intervals run from announcement to the last kill.

const DOCK: String = "Dock 9 bonded storage"
const PIT_TICKS: int = 2400

var session: ArenaSession
var quest: CollectCallPlay
var bus: EventBus
var data: DataStore
var stage: CollectCallStage
var meter: FightProbeSample
var waves: Array[Dictionary] = []
var wave_start: int = -1
var first_tick: int = -1
var third_clear: int = -1
var cleared: int = 0


func run(encounter: String, world_seed: int, trace: FileAccess) -> Dictionary:
	if encounter == "quest1":
		quest = CollectCallPlay.begin(world_seed)
		stage = quest.stage
	else:
		bus = EventBus.new()
		data = DataStore.new()
		session = ArenaSession.open(bus, data, world_seed, null, encounter == "city")
		stage = session.stage
		# Match ArenaGame._dev_fight so the horde trace and the film start from the same fight.
		if ArenaArgs.parse().has("--horde"):
			session.stage.pit.horde()
			stage.arena.rivet.max_hp *= ArenaPit.HORDE_RIVET_HP
			stage.arena.rivet.hp = stage.arena.rivet.max_hp
		var bot: InputSource = ArenaPitBot.new(session.stage, session.actions)
		if ArenaArgs.parse().text("--bot") == "gunplay":
			var pistol: WeaponSpec = WeaponTable.shipped().weapon(&"pistol")
			bot = GunplayBot.new(session.stage, session.actions, pistol.range_m)
		session.world.loop().set_input(bot)
	var arena: FightProbeArena = FightProbeArena.attach(stage.arena)
	meter = FightProbeSample.new(arena)
	meter.trace = trace
	meter.encounter = encounter
	meter.world_seed = world_seed
	meter.cells = stage.cells
	if session != null:
		meter.walls = session.stage.walls
		arena.squad = session.stage.pit.standing
	else:
		arena.squad = arena.hostiles
	arena.sampled = meter.sample
	@warning_ignore("return_value_discarded")
	stage.events().wave_started.connect(_wave)
	_play()
	var result: Dictionary = _result()
	arena.sampled = Callable()
	_release()
	return result


func _release() -> void:
	if session != null:
		session.close()
		bus.free()
		data.free()
	else:
		quest.finish()
		stage.watch(null)
		quest.release()


func _wave(marker: StringName, ordinal: int) -> void:
	if quest != null and marker != StringName(DOCK):
		return
	wave_start = stage.tick
	if first_tick < 0:
		first_tick = stage.tick
		meter.observing = true
	waves.append({"wave": ordinal, "start_tick": wave_start, "clear_s": null})


func _play() -> void:
	var limit: int = PIT_TICKS if session != null else CollectCallPlay.TIMEOUT_TICKS
	for i: int in limit:
		if session != null:
			session.step()
		elif quest.running() and not stage.encounter_cleared(DOCK):
			quest.tick_once()
		else:
			break
		meter.digest_tick()
		if not meter.observing:
			continue
		meter.finish_tick()
		if wave_start >= 0 and _down():
			waves.back()["clear_s"] = (stage.tick - wave_start) * SimClock.TICK_DT
			wave_start = -1
			cleared += 1
			if cleared == 3:
				third_clear = stage.tick


func _down() -> bool:
	if session != null:
		return session.stage.pit.waves_cleared > cleared
	var director: WaveDirector = stage.layout.waves
	if director.current < 0:
		return false
	var full: bool = director.spawned == director.waves[director.current].count
	return full and stage.arena.hostiles_alive() == 0


func _result() -> Dictionary:
	var a: FightProbeArena = meter.arena
	var dock: bool = quest != null
	var complete: bool = stage.encounter_cleared(DOCK) if dock else third_clear >= 0
	var end: int = stage.tick if dock else third_clear
	var fight: Dictionary = {
		"waves": waves,
		"waves_cleared": cleared,
		"encounter_clear_s": (end - first_tick) * SimClock.TICK_DT if complete else null,
		"damage_taken_hp": a.damage_taken,
		"deaths": a.deaths,
		"kills": a.kills if dock else session.stage.pit.kills,
		"hostile_shots": a.rounds,
		"hits_on_rivet": a.hits,
	}
	return {
		"encounter": meter.encounter,
		"objective": DOCK if dock else "first three pit waves",
		"seed": meter.world_seed,
		"tick_budget": CollectCallPlay.TIMEOUT_TICKS if dock else PIT_TICKS,
		"start_tick": first_tick,
		"last_tick": stage.tick,
		"measured_ticks": meter.ticks,
		"objective_reached": complete,
		"valid": meter.ok and meter.hostile_ticks > 0 and not a.costs.is_empty(),
		"digest": meter.hash_ctx.finish().hex_encode(),
		"ai": meter.summary(),
		"fight": fight,
		"cost": meter.cost(),
	}
