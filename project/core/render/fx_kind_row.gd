class_name FxKindRow
extends RefCounted
## One FX kind's per-particle constants, read once from its fx.json row (FxSystem.kinds) when a
## particle is put. FxPool.step used to look ~14 String keys up in the kind Dictionary for every
## live particle on every tick (the riot's ground marks: ~0.13 ms a frame). The values and the
## float ops are the Dictionary path's own (FxPool.custom_of / cell stay the reference).

var life: float = 0.0
var life_i: int = 0
var drag: float = 0.0
var size_m: float = 0.0
var grow: float = 0.0
var color: Color = Color.WHITE
var fade_from: float = 0.0
var shape_id: float = 0.0
var rim: float = 0.0
var has_cell: bool = false
var cell0: float = 0.0
var cell_n: float = 1.0
var anim: bool = false
var frame_ticks: float = 1.0


static func of(k: Dictionary) -> FxKindRow:
	var r: FxKindRow = FxKindRow.new()
	r.life = k["life_ticks"]
	r.life_i = int(r.life)
	r.drag = k["drag"]
	r.size_m = k["size_m"]
	r.grow = k["grow"]
	r.color = k["color"]
	r.fade_from = k.get("fade_from", 0.0)
	r.shape_id = k["shape_id"]
	r.rim = k.get("rim", 0.0)
	r.has_cell = k.has("cell0")
	if r.has_cell:
		r.cell0 = k["cell0"]
		r.cell_n = k["cell_n"]
		r.anim = k["anim"]
		if r.anim:
			r.frame_ticks = k.get("frame_ticks", r.life / r.cell_n)
	return r


## FxPool.cell for this kind (the same ops): the sheet cell + 1 at `age`, 0 = the analytic shape.
func cell(age: int, s: float) -> float:
	if not has_cell:
		return 0.0
	var f: float = floorf(s * cell_n)
	if anim:
		f = floorf(age / frame_ticks)
	return cell0 + clampf(f, 0.0, cell_n - 1.0) + 1.0
