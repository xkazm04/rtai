class_name WeaponArt
extends RefCounted
## The weapons' art by weapon id (data/tables/weapon_art.json; docs/art/weapons.md). The held
## part is drawn top-down pointing +x; `grip_px` is where the claw closes, `muzzle_px` the bore
## tip. make_held() returns a Sprite2D whose origin IS the grip, already scaled to world px
## (32 per m), so a socket only parents and rotates it, and muzzle_m() is where shots spawn.
## Unknown ids and missing files draw a flat ink bar and log once (a later art landing must not
## break the fight). Frames of an fx id `flash_pistol` are `flash_pistol_0..n`, or the id itself.

const TABLE: String = "res://data/tables/weapon_art.json"
const SCHEMA: String = "gtai.weapon-art/1"
const WORLD_PX_PER_M: float = 32.0
const INK: Color = Color("1b1517")
## The paper rim under a held part (the rigs' cream sticker halo, which the weapons lacked: at
## 32 px/m a gun in the claw printed as a dark blob). World px; `--weapon-rim=off` drops it.
const RIM_WORLD_PX: float = 1.0
const RIM_DIRS: int = 8

static var rim: bool = not OS.get_cmdline_user_args().has("--weapon-rim=off")

var rig_px_per_m: float = 320.0
## FX cells draw at this many times the rig part scale (fx_scale()).
var fx_draw_scale: float = 2.0
## projectile_k by weapon id (rows that set it): the round's cell drawn k thicker and sqrt(k)
## longer (the hand cannon's slug); absent = 1.
var round_k: Dictionary[StringName, float] = {}

var _rows: Dictionary[StringName, Row] = {}
var _fx: Dictionary[StringName, Cell] = {}
var _tex: Dictionary[String, Texture2D] = {}
var _missing: Dictionary[StringName, bool] = {}
var _placeholder: Texture2D = null


class Row:
	extends RefCounted
	var grip_class: StringName = &"one_hand"
	var held: String = ""
	var pickup: String = ""
	var icon: String = ""
	var grip: Vector2 = Vector2.ZERO
	var muzzle: Vector2 = Vector2.ZERO
	var length_px: float = 1.0
	var length_m: float = 0.5
	var muzzle_fx: StringName = &""
	var projectile_fx: StringName = &""
	var casing: StringName = &""
	var parts: Dictionary[String, String] = {}
	var part_grip: Dictionary[String, Vector2] = {}


class Cell:
	extends RefCounted
	var art: String = ""
	var anchor: Vector2 = Vector2.ZERO


func _init(path: String = TABLE) -> void:
	var t: DataTable = DataTable.open(path, SCHEMA)
	rig_px_per_m = t.num(t.raw, "rig_px_per_m")
	fx_draw_scale = t.num(t.raw, "fx_draw_scale")
	for row: Variant in t.array(t.raw, "weapons"):
		var r: Dictionary = row if row is Dictionary else {}
		_rows[StringName(t.text(r, "id"))] = _read_weapon(t, r)
		if r.has("projectile_k"):
			round_k[StringName(t.text(r, "id"))] = t.num(r, "projectile_k")
	for row: Variant in t.array(t.raw, "fx"):
		var r: Dictionary = row if row is Dictionary else {}
		var c: Cell = Cell.new()
		c.art = t.text(r, "art")
		c.anchor = t.vec(r, "anchor_px")
		_fx[StringName(t.text(r, "id"))] = c
	if not t.ok():
		Log.error("weapon_art", str(t.errors()))


func has(id: StringName) -> bool:
	return _rows.has(id)


func ids() -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(_rows.keys())
	return out


func grip_class(id: StringName) -> StringName:
	return _row(id).grip_class


func grip_px(id: StringName) -> Vector2:
	return _row(id).grip


func muzzle_px(id: StringName) -> Vector2:
	return _row(id).muzzle


func length_m(id: StringName) -> float:
	return _row(id).length_m


## Sprite scale for the held part in world px (32 per m): the tail-to-tip span is length_m long.
func world_scale(id: StringName) -> float:
	return length_m(id) * WORLD_PX_PER_M / maxf(_row(id).length_px, 1.0)


## The same scale in the cutout rig's part px (CutRig.SC = 0.1 world px per part px).
func rig_scale(id: StringName) -> float:
	return world_scale(id) * rig_px_per_m / WORLD_PX_PER_M


## Muzzle relative to the grip, in metres, +x along the barrel.
func muzzle_m(id: StringName) -> Vector2:
	return (muzzle_px(id) - grip_px(id)) * world_scale(id) / WORLD_PX_PER_M


func muzzle_fx(id: StringName) -> StringName:
	return _row(id).muzzle_fx


func projectile_fx(id: StringName) -> StringName:
	return _row(id).projectile_fx


func casing_fx(id: StringName) -> StringName:
	return _row(id).casing


func held_texture(id: StringName) -> Texture2D:
	return _load(_row(id).held)


func pickup_texture(id: StringName) -> Texture2D:
	return _load(_row(id).pickup)


func icon_texture(id: StringName) -> Texture2D:
	return _load(_row(id).icon)


## An extra part (the flamethrower's `tank`); null when the weapon has none.
func part_texture(id: StringName, part: String) -> Texture2D:
	var r: Row = _row(id)
	return _load(r.parts[part]) if r.parts.has(part) else null


## The held part as a Sprite2D: origin on the grip, +x along the barrel, scaled to world px.
## With `part` (`mag`: the reload magazine, feed end +x) the extra part at the same scale, origin
## where the claw holds it (part_grip_px); null when the weapon has no such part.
func make_held(id: StringName, part: String = "") -> Sprite2D:
	var r: Row = _row(id)
	if part != "" and not r.parts.has(part):
		return null
	var s: Sprite2D = Sprite2D.new()
	s.name = "Held_%s%s" % [id, "" if part == "" else "_" + part]
	s.texture = held_texture(id) if part == "" else _load(r.parts[part])
	s.centered = false
	s.offset = -grip_px(id)
	if part != "":
		s.offset = -(r.part_grip[part] if r.part_grip.has(part) else Vector2.ZERO)
	s.scale = Vector2.ONE * world_scale(id)
	if rim:
		_add_rim(s)
	return s


## The frames of an fx id: `<id>_0..n` when they exist, else the single cell `<id>`.
func fx_frames(id: StringName) -> Array[Texture2D]:
	var out: Array[Texture2D] = []
	var i: int = 0
	while _fx.has(StringName("%s_%d" % [id, i])):
		out.append(_load(_fx[StringName("%s_%d" % [id, i])].art))
		i += 1
	if out.is_empty() and _fx.has(id):
		out.append(_load(_fx[id].art))
	return out


## Sprite scale for an fx cell in world px (32 per m).
func fx_scale() -> float:
	return fx_draw_scale * WORLD_PX_PER_M / rig_px_per_m


## The point of an fx cell that sits on the muzzle (a flash) or is the head (a projectile).
func fx_anchor(id: StringName) -> Vector2:
	var key: StringName = id if _fx.has(id) else StringName("%s_0" % id)
	return _fx[key].anchor if _fx.has(key) else Vector2.ZERO


## Cream silhouettes of the part, RIM_WORLD_PX out in RIM_DIRS directions, drawn under it.
func _add_rim(s: Sprite2D) -> void:
	for i: int in RIM_DIRS:
		var h: Sprite2D = Sprite2D.new()
		h.name = "Rim%d" % i
		h.texture = s.texture
		h.centered = false
		h.offset = s.offset
		h.position = Vector2.from_angle(TAU * i / RIM_DIRS) * RIM_WORLD_PX / s.scale.x
		h.material = PartMaterials.get_mat(PartMaterials.PartKind.HALO, false, 0)
		h.z_index = -1
		s.add_child(h)


func _read_weapon(t: DataTable, r: Dictionary) -> Row:
	var w: Row = Row.new()
	w.grip_class = StringName(t.text(r, "grip_class"))
	w.held = t.text(r, "held")
	w.pickup = t.text(r, "pickup")
	w.icon = t.text(r, "icon")
	w.grip = t.vec(r, "grip_px")
	w.muzzle = t.vec(r, "muzzle_px")
	w.length_px = t.num(r, "length_px")
	w.length_m = t.num(r, "length_m")
	w.muzzle_fx = StringName(t.text(r, "muzzle_fx"))
	w.projectile_fx = StringName(t.text(r, "projectile_fx"))
	w.casing = StringName(t.text(r, "casing"))
	var parts: Dictionary = t.object(r, "parts")
	for k: Variant in parts:
		w.parts[str(k)] = str(parts[k])
	var g: Variant = r.get("part_grip_px", {})
	var grips: Dictionary = g if g is Dictionary else {}
	for k: Variant in grips:
		w.part_grip[str(k)] = t.vec(grips, str(k))
	return w


func _row(id: StringName) -> Row:
	if not _rows.has(id):
		if not _missing.has(id):
			Log.warn("weapon_art", "no art row for %s" % id)
			_missing[id] = true
		return Row.new()
	return _rows[id]


func _load(path: String) -> Texture2D:
	if _tex.has(path):
		return _tex[path]
	var tex: Texture2D = null
	if path != "" and ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	if tex == null:
		Log.warn("weapon_art", "no art at %s: drawing a placeholder" % path)
		tex = _flat()
	_tex[path] = tex
	return tex


func _flat() -> Texture2D:
	if _placeholder == null:
		var img: Image = Image.create(32, 8, false, Image.FORMAT_RGBA8)
		img.fill(INK)
		_placeholder = ImageTexture.create_from_image(img)
	return _placeholder
