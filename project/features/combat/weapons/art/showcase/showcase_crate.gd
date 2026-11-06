class_name ShowcaseCrate
extends RefCounted
## n8-hud: the open weapon crate a floor gun's showcase drawing lies in (the brief's "in an open
## crate"; the owner's open call: hover over the disc vs lying in a crate). One cut per pitch,
## keyed by the view row's art key like the showcase drawings (`crate/<form>.png`, tools/art/
## crate_cut.py from the library's weapon_crate_open_<70|55>): the lid leans behind the hollow so
## the straw floor is never covered. The crate is drawn for its camera (stood up, never spun) and
## the weapon lies still on its straw: no hover, no bob, no disc.
## `--pickup-crate=on|off` picks the display; DEFAULT_ON false: the hover stays (it5: at 32 px/m the
## paper disc pops "loot" off the grey floor, the tan crates merge into one band; the crate reads
## as a stocked armory, an owner call). Straight down (top) a
## pickup never sits in a crate (the flat path is untouched).

const DIR: String = "res://features/combat/weapons/art/showcase/crate/"
const DEFAULT_ON: bool = false
## The crate's long side in metres, and the longest a weapon lies in it (the straw's span).
const LONG_M: float = 1.6
const FILL_M: float = 1.3
## A standing drawing (the molotov's bottle) is never taller than this in the straw.
const STAND_M: float = 0.7
## Where the weapon's bottom edge rests, as a fraction of the cut (x, y) from its top-left: the
## straw's front edge, under the hollow (measured on the cuts, it5 23:20). A 55 drawing has depth
## (it is drawn lying, seen from the side and above), so its bottom, not its centre, sits here.
const BED: Dictionary[String, Vector2] = {"p70": Vector2(0.5, 0.58), "p55": Vector2(0.5, 0.56)}
## The ink shadow under the crate (ground ellipse, fraction of LONG_M, alpha).
const SHADOW_W: float = 0.56
const SHADOW_H: float = 0.3
const SHADOW_A: float = 0.28

var _tex: Dictionary[String, Texture2D] = {}


## True when floor guns lie in crates (`--pickup-crate=on|off`, else DEFAULT_ON).
static func on() -> bool:
	var v: String = LaunchArgs.value("--pickup-crate")
	if v == "":
		return DEFAULT_ON
	return v == "on"


## The crate cut at `form` ("" or no cut: null, the caller keeps the hover).
func texture(form: String) -> Texture2D:
	if form == "":
		return null
	if not _tex.has(form):
		var p: String = DIR + form + ".png"
		_tex[form] = load(p) as Texture2D if ResourceLoader.exists(p) else null
	return _tex[form]


## Sizes `crate` (its texture set) LONG_M long, stood up for a view with ground factor `gk`.
static func size_crate(crate: Sprite2D, gk: float) -> void:
	var k: float = LONG_M * SimConst.PX_PER_M / maxf(crate.texture.get_width(), 1.0)
	crate.scale = Vector2(k, k / gk)


## The weapon's span in the crate: its own span, never longer than the straw; a standing drawing
## (taller than wide, spanned by its height) never taller than STAND_M.
static func fill_m(span_m: float, standing: bool = false) -> float:
	return minf(span_m, STAND_M if standing else FILL_M)


## Where the centre of a weapon `weapon_h_px` tall (in its parent's px) lies, relative to the
## crate sprite's (centred) position: its bottom edge on the BED.
static func lie_px(crate: Sprite2D, form: String, weapon_h_px: float) -> Vector2:
	var f: Vector2 = BED[form] if BED.has(form) else Vector2(0.5, 0.5)
	var size: Vector2 = crate.texture.get_size()
	return (f - Vector2(0.5, 0.5)) * size * crate.scale - Vector2(0.0, weapon_h_px * 0.5)
