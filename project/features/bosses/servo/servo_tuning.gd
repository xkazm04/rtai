class_name ServoTuning
extends RefCounted
## Servo's swarm numbers (data/tables/servo.json, gtai.servo/1), seconds turned into 60 Hz ticks
## once here. Servo-only: the shared boss framework never reads this table.

const TABLE: String = "res://data/tables/servo.json"
const SCHEMA: String = "gtai.servo/1"


class Phase:
	extends RefCounted
	var max_alive: int = 6
	var wave: int = 3
	var spread_m: float = 1.9


static var _shipped: ServoTuning = null

var cruise_mps: float = 9.0
var accel_mps2: float = 28.0
var sep_m: float = 1.3
var fly_h_m: float = 3.0
var arrive_m: float = 0.35
var radius_m: float = 0.35
## The drop ring from the drone's launch (true) or only over its hover (the owner call).
var ring_from_launch: bool = true
var launch_ticks: int = 30
var hover_ticks: int = 42
var life_ticks: int = 840
var refill_ticks: int = 180
var fall_ticks: int = 21
var bomb_share: float = 0.5
var bomb_damage: float = 22.0
var ring_m: float = 1.6
var crate_hp: int = 3
var crate_life_ticks: int = 720
var crate_m: float = 0.9
var cells: int = 12
var cell_dx_m: float = 0.9
var row_dy_m: float = 0.5
var phases: Array[Phase] = []
var errors: Array[String] = []


static func shipped() -> ServoTuning:
	if _shipped == null:
		_shipped = from_table(DataTable.open(TABLE, SCHEMA))
	return _shipped


static func ticks(seconds: float) -> int:
	return roundi(seconds * SimClock.TICK_RATE)


static func from_table(t: DataTable) -> ServoTuning:
	var s: ServoTuning = ServoTuning.new()
	var d: Dictionary = t.object(t.raw, "drone")
	s.cruise_mps = t.num(d, "cruise_mps")
	s.accel_mps2 = t.num(d, "accel_mps2")
	s.sep_m = t.num(d, "sep_m")
	s.fly_h_m = t.num(d, "fly_h_m")
	s.arrive_m = t.num(d, "arrive_m")
	s.radius_m = t.num(d, "radius_m")
	s.ring_from_launch = d.get("ring_from_launch", true) == true
	s.launch_ticks = ticks(t.num(d, "launch_s"))
	s.hover_ticks = ticks(t.num(d, "hover_s"))
	s.life_ticks = ticks(t.num(d, "life_s"))
	s.refill_ticks = ticks(t.num(d, "refill_s"))
	_read_parcels(t, s)
	var r: Dictionary = t.object(t.raw, "rack")
	s.cells = t.integer(r, "cells")
	s.cell_dx_m = t.num(r, "cell_dx_m")
	s.row_dy_m = t.num(r, "row_dy_m")
	for row: Variant in t.array(t.raw, "phases"):
		var p: Phase = Phase.new()
		var pd: Dictionary = row if row is Dictionary else {}
		p.max_alive = t.integer(pd, "max_alive")
		p.wave = t.integer(pd, "wave")
		p.spread_m = t.num(pd, "spread_m")
		s.phases.append(p)
	s.errors = t.errors()
	return s


static func _read_parcels(t: DataTable, s: ServoTuning) -> void:
	var p: Dictionary = t.object(t.raw, "parcels")
	s.fall_ticks = ticks(t.num(p, "fall_s"))
	s.bomb_share = t.num(p, "bomb_share")
	s.bomb_damage = t.num(p, "bomb_damage")
	s.ring_m = t.num(p, "ring_m")
	s.crate_hp = t.integer(p, "crate_hp")
	s.crate_life_ticks = ticks(t.num(p, "crate_life_s"))
	s.crate_m = t.num(p, "crate_m")


## Phase 1..3 (clamped), so a bad phase number never indexes out.
func phase(n: int) -> Phase:
	if phases.is_empty():
		return Phase.new()
	return phases[clampi(n - 1, 0, phases.size() - 1)]
