class_name WeaponCursor
extends RefCounted
## The system arrow for melee, a weapon-class mark for guns and a teal rim for ghost forms.
## These are hardware pointers (Input.set_custom_mouse_cursor). Gun art: tools/art/cursor_draw.py.

const DIR: String = "res://features/hud/art/cursors/"
const HOTSPOT: Vector2 = Vector2(24.0, 24.0)
const SYSTEM_ARROW: StringName = &"system_arrow"
const PLAIN_DOT: StringName = &"plain_dot"
## Set to PLAIN_DOT to use the small outlined dot for all melee selections.
const STYLE_MELEE: StringName = SYSTEM_ARROW
const STYLE_RIFLE: StringName = &"rifle"
## Gun ids by cursor class.
const GUNS: Dictionary[StringName, StringName] = {
	&"pistol": &"small_arm",
	&"hand_cannon": &"small_arm",
	&"machine_pistol": &"auto",
	&"gatling": &"auto",
	&"gloria": STYLE_RIFLE,
	&"plasma_rifle": &"energy",
	&"ray_gun": &"energy",
	&"electro_gun": &"energy",
	&"flamethrower": &"flame",
	&"rocket_launcher": &"blast",
	&"mini_nuke": &"blast",
	&"molotov": &"blast",
	&"homing_shard": &"lock",
}
## Ghost form ids by cursor class.
const FORMS: Dictionary[StringName, StringName] = {
	&"tonnage": &"ghost_tonnage",
	&"dent": &"ghost_dent",
	&"kerf": &"ghost_kerf",
	&"ohm": &"ghost_ohm",
}

static var _melee: Array[StringName] = []
static var _dot: ImageTexture = null

var _shown: StringName = &""


## The cursor class for `weapon` (&"" = bare claws) while Rivet is in ghost form `form`
## (&"base" = none).
static func style_of(weapon: StringName, form: StringName) -> StringName:
	if FORMS.has(form):
		return FORMS[form]
	if GUNS.has(weapon):
		return GUNS[weapon]
	if weapon in [&"", &"hands", &"claw"] or _is_melee(weapon):
		return STYLE_MELEE
	return STYLE_RIFLE


static func _is_melee(id: StringName) -> bool:
	if _melee.is_empty():
		_melee = MeleeTable.weapon_ids()
	return _melee.has(id)


## Puts the class's cursor on the mouse; a change only, so a frame's call costs nothing.
func show_for(weapon: StringName, form: StringName) -> void:
	var style: StringName = style_of(weapon, form)
	if style == _shown:
		return
	_shown = style
	var hotspot: Vector2 = Vector2.ZERO if style == SYSTEM_ARROW else HOTSPOT
	if style == PLAIN_DOT:
		hotspot = Vector2(4, 4)
	Input.set_custom_mouse_cursor(texture_for(style), Input.CURSOR_ARROW, hotspot)


static func texture_for(style: StringName) -> Texture2D:
	if style == SYSTEM_ARROW:
		return null
	if style != PLAIN_DOT:
		return load(DIR + String(style) + ".png") as Texture2D
	if _dot == null:
		var img: Image = Image.create_empty(9, 9, false, Image.FORMAT_RGBA8)
		for y: int in 9:
			for x: int in 9:
				var d: int = Vector2i(x - 4, y - 4).length_squared()
				if d <= 9:
					img.set_pixel(x, y, Color.WHITE if d <= 4 else Color.BLACK)
		_dot = ImageTexture.create_from_image(img)
	return _dot


## Back to the system arrow (menus, pause, leaving the fight).
func clear() -> void:
	if _shown == &"":
		return
	_shown = &""
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
