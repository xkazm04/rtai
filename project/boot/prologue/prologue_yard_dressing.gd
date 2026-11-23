class_name PrologueYardDressing
extends RefCounted
## Paint can be shared between dressings. Only an explicit layout replaces the stage geometry.

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
	var tint: Color
	var ochre: bool


class CoverArt:
	extends RefCounted
	var art: String
	var crop: Rect2 = Rect2(0, 0, 1, 1)


var id: String
var paint_id: String
var layout: Dictionary
var lights: PrologueYardLights
var ground: Array[Ground] = []
var cover: Dictionary[String, CoverArt] = {}
var decals: Array[Piece] = []
var factory_front: Array[Piece] = []
var fixtures: Array[Piece] = []
var phone_art: String
var phone_size: Vector2
var shadow_reach: Vector2
var shadow_tint: Color
var outside: Array[Piece] = []
var use_stage_decals: bool
var ochre_strength: float


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
	if row.has("lights"):
		result.lights = PrologueYardLights.new(table, table.object(row, "lights"))
	result.paint_id = row.get("paint_from", wanted)
	if row.has("layout"):
		result.layout = table.object(row, "layout")
	var overrides: Dictionary = row.get("cover", {})
	for key: String in overrides:
		result.cover[key] = _cover_art(table, table.object(overrides, key))
	var paint: Dictionary = table.object(rows, result.paint_id).merged(row, true)
	result._read_paint(table, paint, table.object(rows, "plain"))
	if not table.ok():
		Log.error("prologue-yard", str(table.errors()))
	return result


func _read_paint(table: DataTable, row: Dictionary, plain: Dictionary) -> void:
	var ground_row: Dictionary = row if row.has("ground") else plain
	for layer: Dictionary in table.array(ground_row, "ground"):
		ground.append(_layer(table, layer))
	use_stage_decals = not row.has("decals")
	decals = _pieces(table, row, "decals")
	factory_front = _pieces(table, row, "factory_front")
	fixtures = _pieces(table, row, "fixtures")
	if row.has("phone"):
		var phone: Dictionary = table.object(row, "phone")
		phone_art = table.text(phone, "art")
		phone_size = table.vec(phone, "size_m")
	if row.has("shadows"):
		var shadows: Dictionary = table.object(row, "shadows")
		shadow_reach = table.vec(shadows, "reach_m")
		shadow_tint = Color(table.text(shadows, "tint"))
	ochre_strength = table.num(row, "ochre_strength") if row.has("ochre_strength") else 0.0
	outside = _pieces(table, row, "outside")
	if row.get("include_plain_outside", false):
		outside.append_array(_pieces(table, plain, "outside"))


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
		piece.tint = Color(str(row.get("tint", "ffffff")))
		piece.ochre = row.get("ochre", false)
		pieces.append(piece)
	return pieces
