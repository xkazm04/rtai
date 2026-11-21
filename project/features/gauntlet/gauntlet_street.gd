class_name GauntletStreet
extends ArenaHook
## An eastbound street. Only the leading block, its predecessor and its successor are resident.
## RNG draws happen on first entry into a new block, independent of frames and backtracking.

signal window_changed

const TABLE: String = "res://data/tables/gauntlet.json"
const SCHEMA: String = "gtai.gauntlet/1"

var window: Array[GauntletSegment] = []
var index: int = 0
## A wave can hold Rivet at its far seam without adding a prop or blocking the enemy squad.
var forward_limit: float = INF
var rest: GauntletRest
var _table: DataTable
var _rows: Array[Dictionary] = []
var _rng: RandomNumberGenerator


## Keep the squad and its enrolled fighters when its bounded route grid moves.
class StreetSquad:
	extends ArenaSquad

	var mods: StatMods

	func follow_map(map: GuardRouteMap) -> void:
		_map = map

	func spawn_member(arena: CombatArena, at: Vector2, id: StringName = &"") -> Fighter:
		var foe: Fighter = super.spawn_member(arena, at, id)
		foe.damage_k *= mods.value(&"damage")
		return foe

	func step(foe: Fighter, arena: CombatArena, rng: RandomNumberGenerator) -> Shot:
		var shot: Shot = super.step(foe, arena, rng)
		var arch: EnemyRoster.Archetype = pit.roster.archetype(foe.archetype)
		if arch.explicit_spawn and arch.shield_front_mult < 1.0:
			# ArenaSquad just recalculated directional armour. Keep that fresh factor.
			foe.damage_k *= mods.value(&"damage")
		return shot


func _init(registry: RngRegistry) -> void:
	_rng = registry.stream(&"gauntlet")
	_table = DataTable.open(TABLE, SCHEMA)
	for row: Dictionary in _table.array(_table.raw, "segments"):
		if _table.num(row, "length_m") > 0.0:
			_rows.append(row)
	if not _table.ok() or _rows.is_empty():
		Log.error("gauntlet", "invalid street templates: %s" % [_table.errors()])
		return
	_append(0.0)
	_append(window[-1].end_x())


func current() -> GauntletSegment:
	return window[0 if index == 0 else 1]


func _append(x: float) -> void:
	var row: Dictionary = _rows[_rng.randi_range(0, _rows.size() - 1)]
	window.append(GauntletSegment.new(_table, row, x))


## Also handles a teleport across multiple blocks without changing the seeded sequence.
func advance_to(x: float) -> bool:
	var before: int = index
	while x >= current().end_x():
		if window.size() == 3:
			window.remove_at(0)
		index += 1
		_append(window[-1].end_x())
	return index != before


func setup(stage: ArenaStage, _ctx: WorldContext) -> void:
	_install(stage)
	@warning_ignore("return_value_discarded")
	stage.arena.kill_landed.connect(_death)


func _death(
	foe: Fighter, _weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName
) -> void:
	rest.place(foe)


func solid_px(px: Vector2) -> bool:
	return rest.solid_px(px)


func step(stage: ArenaStage, _tick: int) -> void:
	var arena: CombatArena = stage.arena
	arena.rivet.pos.x = minf(arena.rivet.pos.x, forward_limit)
	var limits: Rect2 = arena.squad_ai.pit.bounds
	for foe: Fighter in arena.hostiles:
		if not foe.alive():
			# Melee shoves keep stepping after the lethal hit and after the clear.
			rest.place(foe)
		elif is_finite(forward_limit) and arena.squad_ai.owns(foe):
			foe.pos = foe.pos.clamp(limits.position, limits.end)
	if advance_to(stage.arena.rivet.pos.x):
		_install(stage)
		window_changed.emit()


## Stations feed the existing shot culling and body collision. The back wall closes only
## the retired end, so stepping backwards never takes the player off the retained street.
func _install(stage: ArenaStage) -> void:
	var stations: ArenaStations = stage.stations
	stations.stations.clear()
	var bounds: Rect2 = window[0].bounds
	for segment: GauntletSegment in window:
		stations.stations.append(segment.station)
		bounds = bounds.merge(segment.bounds)
	var gate: ArenaStation = ArenaStation.new()
	var wall: ArenaStation.Prop = ArenaStation.Prop.new()
	wall.kind = "wall_high"
	wall.size = Vector2(1.0, window[0].bounds.size.y)
	wall.at = Vector2(window[0].start_x - 0.5, window[0].bounds.get_center().y)
	gate.props.append(wall)
	stations.stations.append(gate)
	stage.walls.boxes.assign(ArenaWalls.from_stations(stations, stage.plan.base).boxes)
	var road: Rect2 = window[0].road_bounds(0.0).merge(window[-1].road_bounds(0.0))
	rest = GauntletRest.new(road, stage.walls.boxes)
	var arena: CombatArena = stage.arena
	var map: GuardRouteMap = GuardRouteMap.new(
		bounds, stage.walls.boxes, null, arena.tuning.human["radius_m"]
	)
	arena.guard_map = map
	if arena.squad_ai is StreetSquad:
		(arena.squad_ai as StreetSquad).follow_map(map)
	else:
		arena.squad_ai = StreetSquad.new(map)
	var radius: float = arena.tuning.human["radius_m"]
	arena.squad_ai.pit.bounds = window[0].road_bounds(radius).merge(window[-1].road_bounds(radius))
	for fighter: Fighter in arena.hostiles:
		if fighter.alive() and fighter.pursuit != null:
			fighter.pursuit = GuardPursuit.new(map)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_64(index)
	for segment: GauntletSegment in window:
		out.put_utf8_string(String(segment.id))
		out.put_double(segment.start_x)
