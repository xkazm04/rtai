class_name WeaponFxCells
extends RefCounted
## The fx cells of data/tables/weapon_art.json (`fx` rows: id, art, anchor_px), split out of
## WeaponArt. Frames of an fx id `flash_pistol` are `flash_pistol_0..n`, or the id itself.
## n5-look: with `fx_colour_dir` set, a cell of the same file name in that folder replaces the
## ink cell (the round 2 colour sheet, tools/art/fx_colour.py); "" = the ink FX.
## d7-calls look-3 (owner, 2026-11-05): the ink FX are the default (fx_colour_dir ""); the colour
## folder stays, and `--fx-colour=on` loads it for an A/B.

const COLOUR_DIR: String = "res://features/combat/weapons/art/fx/colour"

var colour_dir: String = ""

var _art: Dictionary[StringName, String] = {}
var _anchor: Dictionary[StringName, Vector2] = {}


func read(t: DataTable) -> void:
	colour_dir = t.text(t.raw, "fx_colour_dir") if t.raw.has("fx_colour_dir") else ""
	if colour_dir == "" and OS.get_cmdline_user_args().has("--fx-colour=on"):
		colour_dir = COLOUR_DIR
	for row: Variant in t.array(t.raw, "fx"):
		var r: Dictionary = row if row is Dictionary else {}
		var id: StringName = StringName(t.text(r, "id"))
		_art[id] = coloured(t.text(r, "art"), colour_dir)
		_anchor[id] = t.vec(r, "anchor_px")


## The art paths of an fx id: `<id>_0..n` when they exist, else the single cell `<id>`.
func frame_paths(id: StringName) -> Array[String]:
	var out: Array[String] = []
	var i: int = 0
	while _art.has(StringName("%s_%d" % [id, i])):
		out.append(_art[StringName("%s_%d" % [id, i])])
		i += 1
	if out.is_empty() and _art.has(id):
		out.append(_art[id])
	return out


## The point of an fx cell that sits on the muzzle (a flash) or is the head (a projectile).
func anchor(id: StringName) -> Vector2:
	var key: StringName = id if _anchor.has(id) else StringName("%s_0" % id)
	return _anchor.get(key, Vector2.ZERO)


static func coloured(path: String, dir: String) -> String:
	if dir == "":
		return path
	var alt: String = dir.path_join(path.get_file())
	return alt if ResourceLoader.exists(alt) else path
