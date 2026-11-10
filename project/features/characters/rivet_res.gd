class_name RivetRes
extends RefCounted
## n11 it14: Rivet's one-row strips cut at RivetWalk.RES x the 110 px figure ("<art>/<file>", one
## weapon per commit; tools/art/rivet_frames.json carries each one's fig_h 165). Their cell-px
## tables (foot pad, rivet_muzzle.json points, smear tip) stay in 110 space, read through of().

const X15: PackedStringArray = [
	"p70/rivet_eq_pistol.png",
	"p70/rivet_eq_pistol_left.png",
	"p70/rivet_eq_plasma_rifle.png",
	"p70/rivet_eq_katana.png",
	"p70/rivet_eq_chainsaw.png",
	"p70/rivet_eq_chainsaw_windup.png",  # n14: the asset lane drew its cells at the x1.5 strip's scale
]


## Texture px per 110-space px of the one-row strip at `path` (RivetWalk.RES when in X15).
static func of(path: String) -> float:
	return RivetWalk.RES if X15.has(path.trim_prefix(RivetStrips.DIR)) else 1.0


## A strip's texture, loaded once by RivetFrames; names the path when it loads empty (it11, it16:
## a rare null texture in scenario_rig_stress's COMBO pass comes from this load, sheet unknown).
static func tex(path: String) -> Texture2D:
	var t: Texture2D = load(path) as Texture2D
	if t == null or t.get_width() == 0:
		Log.warn("view", "strip %s loaded empty" % path)
	return t
