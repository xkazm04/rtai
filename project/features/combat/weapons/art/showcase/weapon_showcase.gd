class_name WeaponShowcase
extends RefCounted
## n8-hud: a weapon's SHOWCASE form (the owner's 19:10 split: a) showcase for vendors, crates,
## floor pickups and the HUD, b) equipped, drawn with the final Rivet). One drawing per weapon per
## pitch, keyed by the view row's art key, never by a hard-coded pitch:
## `res://features/combat/weapons/art/showcase/<form>/<id>.png`, form `p70` (play), `p55` (boss
## arenas) or `icon` (the flat HUD cut). The drawings are already drawn for their camera, muzzle to
## +x, so a view stands them up (scale.y / ground_k) and never spins them.
## A weapon without a drawing at a form returns null: the caller keeps the shipped pickup part (a
## stand-in, counted by stand_ins(), never reported as showcase art).
## `--showcase=off` = before (every form null; the shipped parts everywhere).

const DIR: String = "res://features/combat/weapons/art/showcase/"
const ICON: String = "icon"

var _tex: Dictionary[String, Texture2D] = {}
var _miss: Dictionary[String, bool] = {}


## The showcase form a view draws: "" straight down (top keeps today's art) or when the row names
## no art key; else the row's live art key (combo sets it at its swap pitch).
static func form_of(v: ViewMode) -> String:
	if v == null or v.is_flat() or not on():
		return ""
	return v.art


## False with `--showcase=off` (the before: the shipped parts everywhere).
static func on() -> bool:
	return LaunchArgs.value("--showcase") != "off"


static func path_of(id: StringName, form: String) -> String:
	return "%s%s/%s.png" % [DIR, form, id]


## The drawing of `id` at `form`, or null (no form, or no drawing yet: the caller's stand-in).
func texture(id: StringName, form: String) -> Texture2D:
	if form == "" or not on():
		return null
	var p: String = path_of(id, form)
	if _tex.has(p):
		return _tex[p]
	if _miss.has(p):
		return null
	if not ResourceLoader.exists(p):
		_miss[p] = true
		return null
	var t: Texture2D = load(p) as Texture2D
	if t == null:
		_miss[p] = true
		return null
	_tex[p] = t
	return t


func has(id: StringName, form: String) -> bool:
	return texture(id, form) != null


## The ids of `ids` with no drawing at `form` (the shipped part stands in): the evidence count.
func stand_ins(ids: Array[StringName], form: String) -> Array[StringName]:
	var out: Array[StringName] = []
	for id: StringName in ids:
		if not has(id, form):
			out.append(id)
	return out
