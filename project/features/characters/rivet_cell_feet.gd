class_name RivetCellFeet
extends RefCounted
## n17 rivet-strike (owner 2026-11-11: "a hit cell must stand at the walk cell's height, same boot
## line"): a strip whose strike cell draws its swing below his boots is cut with the arc's lowest
## pixel on the cell's foot line, so on that cell the boots float above the walk cells' boot line
## (the katana's side strike: 29 strip px over the 2 px pad, about 15 screen px at 64 px/m; its
## camera strike, the blade reaching down the cell toward the viewer: 118 px, a body height).
## FEET names, per "<art key>/<file>:<cell>", the boots' bottom above the cell bottom in strip
## px (side cells: the lowest boot pixel per 16 px column band with the arc's cream masked; camera
## cells: read off a 10 px ruler, +-5 px, the boots sit beside the blade); a cell
## not listed keeps RivetStrips.foot_px. `--rivet-cell-feet=off` (CastFlags) = before.

const FEET: Dictionary[String, float] = {
	"p70/rivet_eq_katana.png:5": 31.0,
	"p70/rivet_eq_katana.png:6": 120.0,
	"p70/rivet_eq_plasma_sword.png:5": 23.0,
	"p70/rivet_eq_plasma_sword.png:6": 78.0,
	"p70/rivet_eq_chainsaw.png:5": 29.0,
	"p70/rivet_eq_chainsaw.png:6": 75.0,
	"p70/rivet_eq_electro_baton.png:5": 18.0,
	"p70/rivet_eq_electro_baton.png:6": 57.0,
}

static var enabled: bool = true


## Shows `cell` of `card`'s strip and seats it on its own foot line (the strip's pad elsewhere).
static func show(card: Sprite2D, cell: int) -> void:
	card.frame = cell
	var path: String = str(card.get_meta(RivetFrames.ON, ""))
	if card.texture == null or not FEET.has(_key(path, 5)) and not FEET.has(_key(path, 6)):
		return
	card.offset.y = foot_of(path, cell) - card.texture.get_height() / float(card.vframes)


## The boots' pad of `cell` in the strip at `path` (strip px): the listed value, else the strip's.
static func foot_of(path: String, cell: int) -> float:
	var key: String = _key(path, cell)
	return FEET[key] if enabled and FEET.has(key) else RivetStrips.foot_px(path)


static func _key(path: String, cell: int) -> String:
	return "%s/%s:%d" % [path.get_base_dir().get_file(), path.get_file(), cell]
