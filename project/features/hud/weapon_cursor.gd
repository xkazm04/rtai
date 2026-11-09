class_name WeaponCursor
extends RefCounted
## The mouse cursor styled per weapon (n11, owner note "Cursor icon should be styled per weapon
## equipped"): one ink mark per weapon class, a teal rim for the ghost forms. A hardware cursor
## (Input.set_custom_mouse_cursor), so it does not lag the mouse. Art: tools/art/cursor_draw.py.
## Melee weapons come from MeleeTable, every other unknown gun id reads as a rifle.

const DIR: String = "res://features/hud/art/cursors/"
const HOTSPOT: Vector2 = Vector2(24.0, 24.0)
const STYLE_MELEE: StringName = &"melee"
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

var _shown: StringName = &""


## The cursor class for `weapon` (&"" = bare claws) while Rivet is in ghost form `form`
## (&"base" = none).
static func style_of(weapon: StringName, form: StringName) -> StringName:
	if FORMS.has(form):
		return FORMS[form]
	if GUNS.has(weapon):
		return GUNS[weapon]
	if weapon == &"" or _is_melee(weapon):
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
	var tex: Resource = load(DIR + String(style) + ".png")
	Input.set_custom_mouse_cursor(tex, Input.CURSOR_ARROW, HOTSPOT)


## Back to the system arrow (menus, pause, leaving the fight).
func clear() -> void:
	if _shown == &"":
		return
	_shown = &""
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
