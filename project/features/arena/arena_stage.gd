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
var walls: ArenaWalls
var pit: ArenaPit
var dodges: ArenaDodges = ArenaDodges.new()
## Other lanes' code, from their stations' `script` (ArenaHook), in station-file order.
var hooks: Array[ArenaHook] = []
var _shots_before: int = 0


func _init(p_plan: ArenaPlan, p_stations: ArenaStations) -> void:
	super(cleared_layout(p_plan))
	plan = p_plan
	stations = p_stations
	walls = ArenaWalls.from_stations(p_stations, p_plan.base)
	pit = ArenaPit.from_plan(p_plan, p_stations)


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
	if cells != null:
		pit = ArenaPit.from_plan(plan, stations, cells)
	arena.rivet.weapon = WEAPON
	var id: int = 1000
	for s: ArenaStation in stations.stations:
		for sp: ArenaStation.Spawn in s.spawns:
			if _dummy(s, sp) and _clear(plan.base + sp.at):
				@warning_ignore("return_value_discarded")
				targets.add(arena, sp, plan.base, id)
				id += 1
	targets.step(0)
	arena.metal = targets.metal_points()
	for s: ArenaStation in stations.stations:
		var hook: ArenaHook = ArenaHook.make(s)
		if hook != null:
			hooks.append(hook)
			hook.setup(self, ctx)


func step(p_tick: int, tick_input: TickInput) -> void:
	var from: Vector2 = arena.rivet.pos
	var hp: float = arena.rivet.hp
	dodges.cull(arena, walls)
	super.step(p_tick, tick_input)
	if shots_fired > _shots_before:
		targets.engage(from, arena.rivet.facing, p_tick)
	targets.step(p_tick)
	if not arena.metal.is_empty():
		arena.metal = targets.metal_points()
	pit.step(arena, p_tick)
	dodges.watch(arena)
	telemetry.shots = shots_fired
	telemetry.hits = targets.total_hits() + pit.kills
	telemetry.pit_kills = pit.kills
	telemetry.pit_waves = pit.wave
	telemetry.dodges = dodges.dodges
	telemetry.deaths = deaths
	var stick: Vector2 = Vector2(tick_input.move_x, tick_input.move_y)
	var facing: Vector2 = pilot.facing() if pilot != null else arena.rivet.facing
	var lost: float = hp - arena.rivet.hp if arena.rivet.alive() else hp
	telemetry.sample(p_tick, stick, arena.rivet.pos.distance_to(from), facing, lost)
	_shots_before = shots_fired
	for hook: ArenaHook in hooks:
		hook.step(self, p_tick)


func write_state(out: StreamPeerBuffer) -> void:
	super.write_state(out)
	out.put_32(targets.total_hits())
	out.put_32(pit.kills)
	out.put_32(pit.wave)
	for hook: ArenaHook in hooks:
		hook.write_state(out)


## Rivet and every standing hostile keep out of the arena's walls and cover.
## On the city proving block the city's buildings, props and parked cars collide too (cells).
func _collide(p: Vector2) -> Vector2:
	var r: float = arena.tuning.rivet["radius_m"]
	var out: Vector2 = walls.push_out(p, r)
	return cells.push_out(out, r) if cells != null else out


func _collide_hostiles() -> void:
	for h: Fighter in arena.hostiles:
		if h.alive():
			h.pos = walls.push_out(h.pos, h.radius_m)
			h.pos = cells.push_out(h.pos, h.radius_m) if cells != null else h.pos


## A range dummy: kinds "target" and "metal", and an "enemy" outside the pit (the powers pad's
## robot line, a melee line): a dummy with its motion until that lane's hook brings a real brain.
## Enemies in the pit are ArenaPit's waves (or the lane's own pit spawner).
func _dummy(s: ArenaStation, sp: ArenaStation.Spawn) -> bool:
	if sp.kind in ["target", "metal"]:
		return true
	return sp.kind == "enemy" and s.area != str(plan.pit.get("area", "pit"))


## A spawn is allowed where a body fits: anywhere in the dev arena, off buildings on the city.
func _clear(at: Vector2) -> bool:
	if cells == null or cells.clear(at, arena.tuning.human["radius_m"]):
		return true
	Log.info("arena", "city block: spawn at %s is in a building, dropped" % at)
	return false


## Rivet destroyed in the arena: he is back at the hub at full hp and the pit starts over.
func _respawn() -> void:
	if arena.rivet.alive():
		return
	deaths += 1
	arena.rivet.hp = arena.rivet.max_hp
	arena.rivet.pos = plan.rivet_start
	pit.reset(arena)
	Log.info("arena", "Rivet destroyed: back at the hub (deaths %d)" % deaths)


func telemetry_dict() -> Dictionary:
	var out: Dictionary = telemetry.to_dict(targets.ttk_s)
	if vehicles != null:
		out["cars"] = car_counts()
	for hook: ArenaHook in hooks:
		var extra: Dictionary = hook.telemetry()
		if not extra.is_empty():
			out[_telemetry_key(hook)] = extra
	return out


## A hook's telemetry key: its station id, or `hook_<n>` for a hook added in code without a
## station (the showcase's ReelDirector: `--telemetry` with `--reel=director` crashed at quit).
func _telemetry_key(hook: ArenaHook) -> String:
	return String(hook.station.id) if hook.station != null else "hook_%d" % hooks.find(hook)


## The cars by state for the telemetry: total, soul-hijacked, damaged, wrecked.
func car_counts() -> Dictionary:
	var n: Dictionary = {"total": 0, "hijacked": 0, "damaged": 0, "wrecked": 0}
	for b: VehicleBody in cars():
		n["total"] += 1
		if b.soul_hijacked:
			n["hijacked"] += 1
		if b.state == VehicleBody.State.WRECK:
			n["wrecked"] += 1
		elif b.hp_lost > 0.0:
			n["damaged"] += 1
	return n
