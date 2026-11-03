class_name HudArt
extends RefCounted
## The HUD's art by id (data/tables/hud_art.json, DAT-05): HudView asks for `cash_frame`, never
## a path, so an art lane can swap a file in the table without touching the scene. An id that is
## missing or does not load draws a flat ink square and logs once (a later art landing must not
## break the HUD). Also the numeral strip's metrics and the memo frame's 9-slice margin.

const TABLE: String = "res://data/tables/hud_art.json"
const SCHEMA: String = "gtai.hud-art/1"
const INK: Color = Color("17131b")

var digits_art: StringName = &"hud_digits"
var glyphs: String = ""
var cell_px: Vector2 = Vector2.ONE
var advance_px: PackedFloat32Array = []
var baseline_px: float = 0.0
var cap_px: float = 1.0
var space_px: float = 0.0
var memo_art: StringName = &"memo_frame"
var memo_margin_px: float = 1.0
var memo_scale: float = 1.0

var _paths: Dictionary[StringName, String] = {}
var _sizes: Dictionary[StringName, Vector2] = {}
var _tex: Dictionary[StringName, Texture2D] = {}
var _placeholder: Texture2D = null


func _init(path: String = TABLE) -> void:
	var t: DataTable = DataTable.open(path, SCHEMA)
	for row: Variant in t.array(t.raw, "art"):
		var r: Dictionary = row if row is Dictionary else {}
		var id: StringName = StringName(t.text(r, "id"))
		_paths[id] = t.text(r, "art")
		_sizes[id] = t.vec(r, "size_px")
	_read_digits(t, t.object(t.raw, "digits"))
	var memo: Dictionary = t.object(t.raw, "memo")
	memo_art = StringName(t.text(memo, "art"))
	memo_margin_px = t.num(memo, "margin_px")
	memo_scale = t.num(memo, "scale")
	if not t.ok():
		Log.error("hud", str(t.errors()))


## The texture for `id`, loaded once; a flat ink square when the id is unknown or fails to load.
func texture(id: StringName) -> Texture2D:
	if _tex.has(id):
		return _tex[id]
	var tex: Texture2D = null
	var path: String = _paths.get(id, "")
	if path != "" and ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	if tex == null:
		Log.warn("hud", "no art for id %s (%s): drawing a placeholder" % [id, path])
		tex = _flat()
	_tex[id] = tex
	return tex


## The authored size of `id` in px (the box the layout coordinates refer to).
func size_px(id: StringName) -> Vector2:
	return _sizes.get(id, Vector2.ONE)


func has(id: StringName) -> bool:
	return _paths.has(id)


func _read_digits(t: DataTable, d: Dictionary) -> void:
	digits_art = StringName(t.text(d, "art"))
	glyphs = t.text(d, "glyphs")
	cell_px = t.vec(d, "cell_px")
	for v: Variant in t.array(d, "advance_px"):
		@warning_ignore("return_value_discarded")
		advance_px.append(t.num({"v": v}, "v"))
	baseline_px = t.num(d, "baseline_px")
	cap_px = t.num(d, "cap_px")
	space_px = t.num(d, "space_px")
	if advance_px.size() != glyphs.length():
		var n: Array[int] = [advance_px.size(), glyphs.length()]
		Log.error("hud", "hud_art.digits: %d advances for %d glyphs" % n)


func _flat() -> Texture2D:
	if _placeholder == null:
		var img: Image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
		img.fill(INK)
		_placeholder = ImageTexture.create_from_image(img)
	return _placeholder
