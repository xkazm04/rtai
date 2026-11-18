class_name CityHeatTune
extends RefCounted
## n18 living police: the heat table's `city` block (data/tables/heat.json) for CityHeat and the
## sim's set_police(). Everything the ladder counts or times is read here, nothing in code.

## false: the sim keeps its pre-n18 police (set_heat level -1, every cop pursues Rivet).
var living: bool = true
## One level drains per this many ticks out of every cop's sight (the city's own drain).
var drain_ticks: int = 1200
## Foot cops CityPatrol keeps in the bubble (0 when not living).
var patrol_cops: int = 0
## Quest 1 (the slice boot): its stage heat drives the sim police; the patrol it keeps there.
var quest1: bool = false
var quest1_patrol_cops: int = 0
## Quest 1 under --sim-police: the city patrol replacing the stage's scripted patrols.
var quest1_sim_police_cops: int = 0
var quest1_cars: PackedInt32Array = PackedInt32Array([0, 0, 0, 0])
## Heat 2 dispatch: cars per level, the delay (ticks) and the spawn ring round the point (m).
var cars: PackedInt32Array = PackedInt32Array([0, 0, 0, 0])
var car_delay_ticks: int = 180
var car_ring_m: Vector2 = Vector2(60.0, 110.0)
## Heat 3 roadblock: cars per level, the delay (ticks), the junction window ahead and the gap past.
var roadblock_cars: PackedInt32Array = PackedInt32Array([0, 0, 0, 0])
var roadblock_delay_ticks: int = 120
var roadblock_ahead_m: Vector2 = Vector2(25.0, 90.0)
var roadblock_past_m: float = 6.0
## SimConst.PT_LEN floats for CitySimBackend.set_police.
var sim_tune: PackedFloat64Array = PackedFloat64Array()


static func load_table(path: String = HeatMeter.TABLE) -> CityHeatTune:
	var out: CityHeatTune = CityHeatTune.new()
	var t: DataTable = DataTable.open(path, HeatMeter.SCHEMA)
	var c: Dictionary = t.object(t.raw, "city")
	var foot: Array = t.array(c, "foot_cops")
	out.sim_tune = SimArrays.f64(SimConst.PT_LEN)
	for k: int in 4:
		out.sim_tune[SimConst.PT_FOOT0 + k] = t.num({"n": foot[k]}, "n") if k < foot.size() else 0.0
	out.sim_tune[SimConst.PT_SEARCH_S] = t.num(c, "search_s")
	out.sim_tune[SimConst.PT_ARRIVE_M] = t.num(c, "arrive_m")
	out.sim_tune[SimConst.PT_WALK_V] = t.num(c, "walk_mps")
	out.sim_tune[SimConst.PT_CREW] = t.num(c, "crew")
	out.sim_tune[SimConst.PT_CAR_STOP_M] = t.num(c, "car_stop_m")
	out.sim_tune[SimConst.PT_BAIL_S] = t.num(c, "bail_s")
	out.sim_tune[SimConst.PT_SQUAD] = t.num(c, "squad")
	var looks: Vector2 = t.vec(c, "squad_looks")
	out.sim_tune[SimConst.PT_SQUAD_V0] = looks.x
	out.sim_tune[SimConst.PT_SQUAD_V1] = looks.y
	_roadblock(out, t, c)
	var per: Array = t.array(c, "cars")
	for k: int in mini(4, per.size()):
		out.cars[k] = t.integer({"n": per[k]}, "n")
	out.car_delay_ticks = ceili(t.num(c, "car_delay_s") * SimClock.TICK_RATE)
	out.car_ring_m = t.vec(c, "car_ring_m")
	out.drain_ticks = ceili(t.num(c, "drain_s_per_level") * SimClock.TICK_RATE)
	out.living = c.get("living_police", true) == true
	out.patrol_cops = t.integer(c, "patrol_cops") if out.living else 0
	out.quest1 = out.living and c.get("quest1", false) == true
	out.quest1_patrol_cops = t.integer(c, "quest1_patrol_cops") if out.quest1 else 0
	out.quest1_sim_police_cops = t.integer(c, "quest1_sim_police_cops") if out.quest1 else 0
	var q: Array = t.array(c, "quest1_cars")
	for k: int in mini(4, q.size()):
		out.quest1_cars[k] = t.integer({"n": q[k]}, "n")
	if not t.ok():
		Log.error("heat", str(t.errors()))
	return out


static func _roadblock(out: CityHeatTune, t: DataTable, c: Dictionary) -> void:
	var per: Array = t.array(c, "roadblock_cars")
	for k: int in mini(4, per.size()):
		out.roadblock_cars[k] = t.integer({"n": per[k]}, "n")
	out.roadblock_delay_ticks = ceili(t.num(c, "roadblock_delay_s") * SimClock.TICK_RATE)
	out.roadblock_ahead_m = t.vec(c, "roadblock_ahead_m")
	out.roadblock_past_m = t.num(c, "roadblock_past_m")
