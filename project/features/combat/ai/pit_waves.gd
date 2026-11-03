class_name PitWaves
extends RefCounted
## enemy_waves.json (gtai.enemy_waves/1) read once: the difficulty curves (lists of waves), the
## live curve, the spawn gates and the pacing, times in 60 Hz ticks. A wave is a flat spawn
## list of {arch, at} with the groups interleaved (gate A, gate B, gate A ...) so a wave
## arrives from several sides at once instead of one gate draining before the next opens.

const TABLE: String = "res://data/tables/enemy_waves.json"
const SCHEMA: String = "gtai.enemy_waves/1"
## Metres between two enemies walking in through the same gate.
const FILE_GAP_M: float = 2.0

var curve_id: StringName = &"standard"
var breather_ticks: int = 180
var spawn_gap_ticks: int = 36
var gates: Dictionary[StringName, Vector2] = {}
var _curves: Dictionary[StringName, Array] = {}
var _errors: Array[String] = []


static func shipped(path: String = TABLE) -> PitWaves:
	var w: PitWaves = PitWaves.new()
	var t: DataTable = DataTable.open(path, SCHEMA)
	w.curve_id = StringName(t.text(t.raw, "curve"))
	w.breather_ticks = CombatTuning.ticks(t.num(t.raw, "breather_s"))
	w.spawn_gap_ticks = CombatTuning.ticks(t.num(t.raw, "spawn_gap_s"))
	var g: Dictionary = t.object(t.raw, "gates")
	for gid: String in g:
		w.gates[StringName(gid)] = t.vec(g, gid)
	var curves: Dictionary = t.object(t.raw, "curves")
	for cid: String in curves:
		w._curves[StringName(cid)] = t.array(curves, cid)
	w._errors.append_array(t.errors())
	if not w.ok():
		Log.error("enemy-ai", str(w._errors))
	return w


func ok() -> bool:
	return _errors.is_empty()


func curve_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(_curves.keys())
	out.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return out


## The waves of `curve` (the live curve when empty): one Array of {arch, at} per wave.
func waves(curve: StringName = &"") -> Array[Array]:
	var rows: Array = _curves.get(curve if curve != &"" else curve_id, [])
	var out: Array[Array] = []
	for raw: Variant in rows:
		var row: Dictionary = raw if raw is Dictionary else {}
		var groups: Array = []
		if row.get("groups") is Array:
			groups = row["groups"]
		out.append(_spawns(groups))
	return out


func wave_ids(curve: StringName = &"") -> Array[String]:
	var out: Array[String] = []
	for raw: Variant in _curves.get(curve if curve != &"" else curve_id, []):
		var row: Dictionary = raw if raw is Dictionary else {}
		out.append(str(row.get("id", "")))
	return out


func _spawns(groups: Array) -> Array[Dictionary]:
	var lanes: Array[Array] = []
	for raw: Variant in groups:
		var grp: Dictionary = raw if raw is Dictionary else {}
		var gate: Vector2 = gates.get(StringName(str(grp.get("gate", ""))), Vector2.ZERO)
		var n: int = int(str(grp.get("count", 0)))
		var side: Vector2 = Vector2(0.0, 1.0) if absf(gate.x) > absf(gate.y) else Vector2(1.0, 0.0)
		var lane: Array[Dictionary] = []
		for k: int in n:
			var at: Vector2 = gate + side * (float(k) - float(n - 1) * 0.5) * FILE_GAP_M
			lane.append({"arch": StringName(str(grp.get("arch", ""))), "at": at})
		lanes.append(lane)
	var out: Array[Dictionary] = []
	var more: bool = true
	var k: int = 0
	while more:
		more = false
		for lane: Array in lanes:
			if k < lane.size():
				out.append(lane[k])
				more = true
		k += 1
	return out
