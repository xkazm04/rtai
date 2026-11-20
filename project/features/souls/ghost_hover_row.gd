class_name GhostHoverRow
extends RefCounted
## Typed visual tuning. The cache shares rows across views, never their flight state.

const PATH: String = "res://data/tables/ghost_hover.json"
const SCHEMA: String = "gtai.ghost_hover/1"

static var _rows: Dictionary[StringName, GhostHoverRow] = {}

var id: StringName
var height_m: float
var bob_m: float
var bob_ticks: int
var bank_deg: float
var bank_per_dps: float
var lag_ticks: int
var lean_deg: float
var start_lift_m: float
var cruise_bob_k: float
var sway_m: float
var fade_from: float
var belt_width_k: float
var top_mps: float
var tail: Tail
var shadow: Shadow


class Tail:
	var anchor_m: Vector2
	var length_m: float
	var width_m: float
	var stretch_k: float
	var swing_k: float
	var segments: int
	var fray: float
	var strands: int
	var spread_m: float
	var rise_m: float
	var wisps: int
	var flow_ticks: int
	var curl_m: float

	func _init(t: DataTable, r: Dictionary) -> void:
		anchor_m = t.vec(r, "anchor_m")
		length_m = t.num(r, "length_m")
		width_m = t.num(r, "width_m")
		stretch_k = t.num(r, "stretch_k")
		swing_k = t.num(r, "swing_k")
		segments = t.integer(r, "segments")
		fray = t.num(r, "fray")
		strands = r.get("strands", 1)
		spread_m = r.get("spread_m", 0.0)
		rise_m = r.get("rise_m", 0.0)
		wisps = r.get("wisps", 3)
		flow_ticks = r.get("flow_ticks", 60)
		curl_m = r.get("curl_m", 0.12)


class Shadow:
	var radius_m: float
	var alpha: float
	var pool_m: float
	var pool_alpha: float
	var shrink_k: float

	func _init(t: DataTable, r: Dictionary) -> void:
		radius_m = t.num(r, "radius_m")
		alpha = t.num(r, "alpha")
		shrink_k = t.num(r, "shrink_k")
		pool_m = r.get("pool_m", radius_m * 2.5)
		pool_alpha = r.get("pool_alpha", 0.32)


static func of(form_id: StringName) -> GhostHoverRow:
	if _rows.is_empty():
		var table: DataTable = DataTable.open(PATH, SCHEMA)
		for data: Dictionary in table.array(table.raw, "rows"):
			var row: GhostHoverRow = GhostHoverRow.new(table, data)
			_rows[row.id] = row
		if not table.ok():
			Log.error("ghost_hover", str(table.errors()))
			_rows.clear()
	return _rows.get(form_id)


func _init(t: DataTable, r: Dictionary) -> void:
	id = StringName(t.text(r, "id"))
	height_m = t.num(r, "height_m")
	bob_m = t.num(r, "bob_m")
	bob_ticks = t.integer(r, "bob_ticks")
	bank_deg = t.num(r, "bank_deg")
	bank_per_dps = t.num(r, "bank_per_dps")
	lag_ticks = t.integer(r, "lag_ticks")
	lean_deg = t.num(r, "lean_deg")
	start_lift_m = r.get("start_lift_m", 0.0)
	cruise_bob_k = r.get("cruise_bob_k", 1.0)
	sway_m = r.get("sway_m", 0.0)
	fade_from = r.get("fade_from", 0.0)
	belt_width_k = r.get("belt_width_k", 0.4)
	top_mps = t.num(r, "top_mps")
	tail = Tail.new(t, t.object(r, "tail"))
	shadow = Shadow.new(t, t.object(r, "shadow"))
