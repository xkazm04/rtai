class_name DentLook
extends RefCounted
## Shared render tuning for Dent's seatbelt, crash disc and blast preview.

const PATH: String = "res://data/tables/dent_look.json"
const SCHEMA: String = "gtai.dent_look/1"

static var _cached: DentLook

var tether_look: String
var buckle_m: float
var disc_m: float
var disc_rim_alpha: float
var hand_height_m: float
var ring_edge_m: float
var ring_fill_alpha: float
var ring_ink_m: float
var strap_edge_m: float
var strap_feed_k: float
var strap_sag_m: float
var strap_stripe_m: float
var strap_tick_gap_m: float
var strap_tremble_m: float
var strap_webbing_alpha: float
var strap_width_m: float


static func shipped() -> DentLook:
	if _cached == null:
		var table: DataTable = DataTable.open(PATH, SCHEMA)
		for row: Dictionary in table.array(table.raw, "rows"):
			if table.text(row, "id") == "dent":
				_cached = DentLook.new(table, row)
		if not table.ok():
			Log.error("dent_look", str(table.errors()))
	return _cached


func _init(table: DataTable, row: Dictionary) -> void:
	tether_look = table.text(row, "tether_look")
	buckle_m = table.num(row, "buckle_m")
	disc_m = table.num(row, "disc_m")
	disc_rim_alpha = table.num(row, "disc_rim_alpha")
	hand_height_m = table.num(row, "hand_height_m")
	ring_edge_m = table.num(row, "ring_edge_m")
	ring_fill_alpha = table.num(row, "ring_fill_alpha")
	ring_ink_m = table.num(row, "ring_ink_m")
	strap_edge_m = table.num(row, "strap_edge_m")
	strap_feed_k = table.num(row, "strap_feed_k")
	strap_sag_m = table.num(row, "strap_sag_m")
	strap_stripe_m = table.num(row, "strap_stripe_m")
	strap_tick_gap_m = table.num(row, "strap_tick_gap_m")
	strap_tremble_m = table.num(row, "strap_tremble_m")
	strap_webbing_alpha = table.num(row, "strap_webbing_alpha")
	strap_width_m = table.num(row, "strap_width_m")


func requested() -> String:
	var override: String = LaunchArgs.value("--dent-tether")
	return tether_look if override.is_empty() else override


func resolved() -> String:
	return "strings" if requested() == "strings" else "strap"
