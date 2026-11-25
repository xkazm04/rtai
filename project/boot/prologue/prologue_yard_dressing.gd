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
	## Drawn on the over-print layer, after the impression, not in the world pass.
	var over_impression: bool


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
var ground_shade: float = 1.0
var cover: Dictionary[String, CoverArt] = {}
var decals: Array[Piece] = []
var factory_front: Array[Piece] = []
var front_replaces: Rect2
var fixtures: Array[Piece] = []
var phone_art: String
var phone_size: Vector2
var shadow_reach: Vector2
var fixture_shadow_reach: Vector2
var shadow_tint: Color
var outside: Array[Piece] = []
var use_stage_decals: bool
var ochre_strength: float
## Row flag: the impression and the flagged ground layers and decals sit under the ochre layer.
var ochre_over_impression: bool = false
## Cover and debris ids drawn over the world print, in the art's own colours.
var over_print: PackedStringArray = PackedStringArray()
## A ground layer laid on the over-print layer, under the over-print pieces: a second impression.
var impression: Ground
## Multiplies the own-colour wrecks on the over-print layer (1 = the art as drawn).
var over_print_shade: float = 1.0
## Row flag: the stage scorch marks and the decals without `ochre` (stains, tyre marks) print on
## the over-print layer, after the ground layers there. The split-off decals wait in `decals_over`.
var decals_over_impression: bool = false
var decals_over: Array[Piece] = []
## Row value: multiplies the tint alpha of the tyre-mark stamps over the impression (clamped to 1).
var decal_over_alpha: float = 1.0
## Fire light over the void north of the hall roof (PrologueRoofGlow.read), empty = none.
var roof_glow: Dictionary = {}
## Drop shadow under Rivet on an overhead span (PrologueSpanShadow.read), empty = none.
var span_shadow: Dictionary = {}


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
	if row.has("ground_shade"):
		result.ground_shade = table.num(row, "ground_shade")
	if row.has("lights"):
		result.lights = PrologueYardLights.new(table, table.object(row, "lights"))
	if row.has("roof_glow"):
		result.roof_glow = PrologueRoofGlow.read(table, table.object(row, "roof_glow"))
	if row.has("span_shadow"):
		result.span_shadow = PrologueSpanShadow.read(table, table.object(row, "span_shadow"))
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
	_split_decals_over(table, row)
	factory_front = _pieces(table, row, "factory_front")
	fixtures = _pieces(table, row, "fixtures")
	if row.has("phone"):
		var phone: Dictionary = table.object(row, "phone")
		phone_art = table.text(phone, "art")
		phone_size = table.vec(phone, "size_m")
	if row.has("shadows"):
		var shadows: Dictionary = table.object(row, "shadows")
		shadow_reach = table.vec(shadows, "reach_m")
		fixture_shadow_reach = table.vec(shadows, "fixture_reach_m")
		shadow_tint = Color(table.text(shadows, "tint"))
	ochre_strength = table.num(row, "ochre_strength") if row.has("ochre_strength") else 0.0
	ochre_over_impression = row.get("ochre_over_impression", false)
	if row.has("over_print"):
		over_print = PackedStringArray(table.array(row, "over_print"))
	if row.has("over_print_shade"):
		over_print_shade = table.num(row, "over_print_shade")
	if row.has("ground_impression"):
		impression = _layer(table, table.object(row, "ground_impression"))
	outside = _pieces(table, row, "outside")
	if row.has("front_replaces_m"):
		var front: Dictionary = table.object(row, "front_replaces_m")
		front_replaces = Rect2(table.vec(front, "origin"), table.vec(front, "size"))
		for i: int in range(outside.size() - 1, -1, -1):
			if front_replaces.has_point(outside[i].at):
				outside.remove_at(i)
	if row.get("include_plain_outside", false):
		outside.append_array(_pieces(table, plain, "outside"))


## With `decals_over_impression` the decals without `ochre` move to `decals_over`; the tyre marks
## among them get their tint alpha times `decal_over_alpha`.
func _split_decals_over(table: DataTable, row: Dictionary) -> void:
	decals_over_impression = row.get("decals_over_impression", false)
	if not decals_over_impression:
		return
	decal_over_alpha = table.num(row, "decal_over_alpha") if row.has("decal_over_alpha") else 1.0
	for piece: Piece in decals.duplicate():
		if piece.ochre:
			continue
		decals.erase(piece)
		decals_over.append(piece)
		if piece.art.contains("/tyre_"):
			piece.tint.a = minf(piece.tint.a * decal_over_alpha, 1.0)


static func _layer(table: DataTable, row: Dictionary) -> Ground:
	var layer: Ground = Ground.new()
	layer.texture = table.text(row, "texture")
	var rect: Dictionary = table.object(row, "rect_m")
	layer.rect = Rect2(table.vec(rect, "origin"), table.vec(rect, "size"))
	layer.tiled = row["tiled"]
	layer.tile_size = table.vec(row, "tile_size_m") if row.has("tile_size_m") else layer.rect.size
	layer.tint = Color(str(row.get("tint", "ffffff")))
	layer.wash = Color(str(row.get("wash", "00000000")))
	layer.over_impression = row.get("over_impression", false)
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
