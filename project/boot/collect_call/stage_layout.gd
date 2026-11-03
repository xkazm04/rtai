class_name StageLayout
extends RefCounted
## collect_call_stage.json (gtai.collect-call-stage/1) and the quest's places table, read once
## into typed fields: where Rivet starts, hide spots, patrol routes, payphones, Dock 9 (spawn
## points and the wave director), the crate stack and its metal, the Toner Room line hooks.

const TABLE: String = "res://data/tables/collect_call_stage.json"
const SCHEMA: String = "gtai.collect-call-stage/1"
const PLACES: String = "res://data/tables/collect_call_places.json"


class Patrol:
	extends RefCounted
	var id: String = ""
	var mps: float = 2.0
	var route: Array[Vector2] = []


var places: QuestPlaces
var rivet_start: Vector2 = Vector2.ZERO
var start_heat: int = 0
var hide_at: Dictionary[String, Vector2] = {}
var hide_r: Dictionary[String, float] = {}
var patrols: Array[Patrol] = []
## Payphone id (its marker name) -> where it stands.
var phones: Dictionary[String, Vector2] = {}
## Whisper cues (data whispers.cues): beat id -> ticks the cue's condition must hold
## ("hidden" is the one condition so far). Each fires once.
var whisper_cues: Dictionary[String, int] = {}
var spawn_points: Dictionary[String, Vector2] = {}
var waves: WaveDirector
var crates_at: Vector2 = Vector2.ZERO
var crates_count: int = 40
var crates_label: String = ""
var torch_reach_m: float = 3.0
var metal: PackedVector2Array = PackedVector2Array()
var tape_bill: int = 0
var refusal_ticks: int = 420
var line_hooks: Dictionary[String, String] = {}
var _errors: Array[String] = []


static func shipped() -> StageLayout:
	var s: StageLayout = StageLayout.new()
	s.places = QuestPlaces.from_json_text(FileAccess.get_file_as_string(PLACES))
	var t: DataTable = DataTable.open(TABLE, SCHEMA)
	s._read(t, t.raw)
	s._errors = t.errors() + s.places.errors()
	if not s.ok():
		Log.error("stage", str(s._errors))
	return s


func ok() -> bool:
	return _errors.is_empty()


func marker(name: String) -> QuestPlaces.Marker:
	return places.markers[name]


func _read(t: DataTable, raw: Dictionary) -> void:
	rivet_start = t.vec(raw, "rivet_start")
	start_heat = t.integer(raw, "start_heat")
	var spots: Dictionary = t.object(raw, "hide_spots")
	for id: String in spots:
		hide_at[id] = t.vec(t.object(spots, id), "at")
		hide_r[id] = t.num(t.object(spots, id), "r")
	for row: Variant in t.array(raw, "patrols"):
		var d: Dictionary = row if row is Dictionary else {}
		patrols.append(_patrol(t, d))
	for id: Variant in t.array(raw, "payphones"):
		phones[str(id)] = places.markers[str(id)].phone
	for cue: Variant in t.array(t.object(raw, "whispers"), "cues"):
		var c: Dictionary = cue if cue is Dictionary else {}
		whisper_cues[t.text(c, "beat")] = CombatTuning.ticks(t.num(c, "after_s"))
	var points: Dictionary = t.object(raw, "spawn_points")
	for id: String in points:
		spawn_points[id] = t.vec(points, id)
	waves = WaveDirector.new(t, t.array(raw, "waves"), t.object(raw, "dock"))
	_read_crates(t, raw)
	tape_bill = t.integer(raw, "tape_bill")
	refusal_ticks = CombatTuning.ticks(t.num(raw, "refusal_s"))
	var hooks: Dictionary = t.object(raw, "line_hooks")
	for id: String in hooks:
		line_hooks[id] = str(hooks[id])


func _read_crates(t: DataTable, raw: Dictionary) -> void:
	var c: Dictionary = t.object(raw, "crates")
	crates_at = t.vec(c, "at")
	crates_count = t.integer(c, "count")
	crates_label = t.text(c, "label")
	torch_reach_m = t.num(c, "torch_reach_m")
	var points: Array = t.array(raw, "metal")
	var out: Array[Vector2] = []
	for i: int in points.size():
		out.append(t.vec({"p": points[i]}, "p"))
	metal = PackedVector2Array(out)


func _patrol(t: DataTable, row: Dictionary) -> Patrol:
	var p: Patrol = Patrol.new()
	p.id = t.text(row, "id")
	p.mps = t.num(row, "mps")
	var route: Array = t.array(row, "route")
	for i: int in route.size():
		p.route.append(t.vec({"p": route[i]}, "p"))
	return p
