class_name ArenaStation
extends RefCounted
## One arena station as data (gtai.arena-station/1, data/tables/arena_stations/<lane>.json): its
## area, what it spawns, the props it lays on the floor, the tuning keys it exposes to the live
## panel and the measurements its telemetry reports. Positions are metres from the arena hub.


class Spawn:
	extends RefCounted
	var id: String = ""
	var kind: String = ""
	var at: Vector2 = Vector2.ZERO
	var motion: String = "static"
	var speed_mps: float = 0.0
	var span_m: float = 0.0


class Prop:
	extends RefCounted
	var kind: String = ""
	var at: Vector2 = Vector2.ZERO
	var size: Vector2 = Vector2.ONE


class Knob:
	extends RefCounted
	var key: String = ""
	var min_value: float = 0.0
	var max_value: float = 1.0
	var step: float = 0.0


var id: String = ""
var name: String = ""
var area: String = ""
## The lane whose file this station came from.
var lane: String = ""
var spawns: Array[Spawn] = []
var props: Array[Prop] = []
var knobs: Array[Knob] = []
var measures: Array[String] = []


static func from_row(t: DataTable, row: Dictionary, p_lane: String) -> ArenaStation:
	var s: ArenaStation = ArenaStation.new()
	s.id = t.text(row, "id")
	s.name = t.text(row, "name")
	s.area = t.text(row, "area")
	s.lane = p_lane
	for v: Variant in t.array(row, "spawns"):
		var d: Dictionary = v if v is Dictionary else {}
		var sp: Spawn = Spawn.new()
		sp.id = t.text(d, "id")
		sp.kind = t.text(d, "kind")
		sp.at = t.vec(d, "at")
		sp.motion = t.text(d, "motion")
		sp.speed_mps = t.num(d, "speed_mps")
		sp.span_m = t.num(d, "span_m")
		s.spawns.append(sp)
	for v: Variant in t.array(row, "props"):
		var d: Dictionary = v if v is Dictionary else {}
		var p: Prop = Prop.new()
		p.kind = t.text(d, "kind")
		p.at = t.vec(d, "at")
		p.size = t.vec(d, "size")
		s.props.append(p)
	for v: Variant in t.array(row, "tuning"):
		var d: Dictionary = v if v is Dictionary else {}
		var k: Knob = Knob.new()
		k.key = t.text(d, "key")
		k.min_value = t.num(d, "min")
		k.max_value = t.num(d, "max")
		k.step = t.num(d, "step")
		s.knobs.append(k)
	for v: Variant in t.array(row, "measures"):
		s.measures.append(str(v))
	return s
