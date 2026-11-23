class_name PrologueYardDressing
extends RefCounted
## Paint instructions only. Cover overrides are sampled into the stage's existing footprint.

const TABLE: String = "res://data/tables/prologue_yard_dressings.json"
const SCHEMA: String = "gtai.prologue_yard_dressings/1"


class Ground:
	extends RefCounted
	var texture: String
	var rect: Rect2
	var tiled: bool
	var tile_size: Vector2
	var tint: Color
	var wash: Color


class Piece:
	extends RefCounted
	var art: String
	var at: Vector2
	var size_m: Vector2
	var rotation: float
	var flip: bool


class CoverArt:
	extends RefCounted
	var art: String
	var crop: Rect2 = Rect2(0, 0, 1, 1)


var id: String
var ground: Array[Ground] = []
var cover: Dictionary[String, CoverArt] = {}
var decals: Array[Piece] = []
var factory_front: Array[Piece] = []
var outside: Array[Piece] = []
var use_stage_decals: bool


static func resolve(
	stage_id: String, override_id: String = "", table: DataTable = null
) -> PrologueYardDressing:
	if table == null:
		table = DataTable.open(TABLE, SCHEMA)
	var rows: Dictionary = table.object(table.raw, "dressings")
	var wanted: String = stage_id if override_id.is_empty() else override_id
	if not rows.has(wanted):
		Log.error("prologue-yard", "unknown dressing '%s', using plain" % wanted)
		wanted = "plain"
	var result: PrologueYardDressing = PrologueYardDressing.new()
	result.id = wanted
	var row: Dictionary = table.object(rows, wanted)
	var plain: Dictionary = table.object(rows, "plain")
	var ground_row: Dictionary = row if row.has("ground") else plain
	for layer: Dictionary in table.array(ground_row, "ground"):
		result.ground.append(_layer(table, layer))
	var overrides: Dictionary = row.get("cover", {})
	for key: String in overrides:
		result.cover[key] = _cover_art(table, table.object(overrides, key))
	result.use_stage_decals = not row.has("decals")
	result.decals = _pieces(table, row, "decals")
	result.factory_front = _pieces(table, row, "factory_front")
	result.outside = _pieces(table, row, "outside")
	if not table.ok():
		Log.error("prologue-yard", str(table.errors()))
	return result


static func _layer(table: DataTable, row: Dictionary) -> Ground:
	var layer: Ground = Ground.new()
	layer.texture = table.text(row, "texture")
	var rect: Dictionary = table.object(row, "rect_m")
	layer.rect = Rect2(table.vec(rect, "origin"), table.vec(rect, "size"))
	layer.tiled = row["tiled"]
	layer.tile_size = table.vec(row, "tile_size_m") if row.has("tile_size_m") else layer.rect.size
	layer.tint = Color(str(row.get("tint", "ffffff")))
	layer.wash = Color(str(row.get("wash", "00000000")))
	return layer


static func _cover_art(table: DataTable, row: Dictionary) -> CoverArt:
	var skin: CoverArt = CoverArt.new()
	skin.art = table.text(row, "art")
	if row.has("crop"):
		var crop: Dictionary = table.object(row, "crop")
		skin.crop = Rect2(table.vec(crop, "origin"), table.vec(crop, "size"))
	return skin


static func _pieces(table: DataTable, dressing: Dictionary, key: String) -> Array[Piece]:
	var pieces: Array[Piece] = []
	var rows: Array = dressing.get(key, [])
	for row: Dictionary in rows:
		var piece: Piece = Piece.new()
		piece.art = table.text(row, "art")
		piece.at = table.vec(row, "at")
		piece.size_m = table.vec(row, "size_m")
		piece.rotation = deg_to_rad(table.num(row, "rotation_deg"))
		piece.flip = row.get("flip", false)
		pieces.append(piece)
	return pieces
