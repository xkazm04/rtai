class_name ArenaStage
extends CollectCallStage
## The dev arena on quest 1's stage machinery, so Rivet is the real player Rivet: the same
## StagePilot (bound input, TopDownMover, aim, fire, the electroshock jab), the same CombatArena
## (shots that travel, damage, blood Events) and features/bodies, with the quest's places, patrols,
## phones and crates cleared. Stations (ArenaStations) put their dummies on the floor; telemetry
## samples every tick. No QuestSystem runs here.

const WEAPON: StringName = &"gloria"

var plan: ArenaPlan
var stations: ArenaStations
var targets: ArenaTargets = ArenaTargets.new()
var telemetry: ArenaTelemetry = ArenaTelemetry.new()
var _shots_before: int = 0


func _init(p_plan: ArenaPlan, p_stations: ArenaStations) -> void:
	super(cleared_layout(p_plan))
	plan = p_plan
	stations = p_stations


## Quest 1's layout with everything quest-only removed and Rivet at the arena hub.
static func cleared_layout(p_plan: ArenaPlan) -> StageLayout:
	var l: StageLayout = StageLayout.shipped(false)
	l.rivet_start = p_plan.rivet_start
	l.hide_at.clear()
	l.hide_r.clear()
	l.patrols.clear()
	l.phones.clear()
	l.whisper_cues.clear()
	l.line_hooks.clear()
	l.crates_count = 0
	l.crates_at = Vector2(1.0e6, 1.0e6)
	l.metal = PackedVector2Array()
	l.start_heat = 0
	return l


func setup(ctx: WorldContext) -> void:
	super.setup(ctx)
	arena.rivet.weapon = WEAPON
	var id: int = 1000
	for s: ArenaStation in stations.stations:
		for sp: ArenaStation.Spawn in s.spawns:
			if sp.kind == "target":
				@warning_ignore("return_value_discarded")
				targets.add(arena, sp, plan.base, id)
				id += 1
	targets.step(0)


func step(p_tick: int, tick_input: TickInput) -> void:
	var from: Vector2 = arena.rivet.pos
	var hp: float = arena.rivet.hp
	super.step(p_tick, tick_input)
	if shots_fired > _shots_before:
		targets.engage(from, arena.rivet.facing, p_tick)
	targets.step(p_tick)
	telemetry.shots = shots_fired
	telemetry.hits = targets.total_hits()
	var stick: Vector2 = Vector2(tick_input.move_x, tick_input.move_y)
	var facing: Vector2 = pilot.facing() if pilot != null else arena.rivet.facing
	var lost: float = hp - arena.rivet.hp if arena.rivet.alive() else hp
	telemetry.sample(p_tick, stick, arena.rivet.pos.distance_to(from), facing, lost)
	_shots_before = shots_fired


func write_state(out: StreamPeerBuffer) -> void:
	super.write_state(out)
	out.put_32(targets.total_hits())


func telemetry_dict() -> Dictionary:
	return telemetry.to_dict(targets.ttk_s)
