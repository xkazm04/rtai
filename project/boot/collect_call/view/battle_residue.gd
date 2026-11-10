class_name BattleResidue
extends Node2D
## n12 E2 (battle residue): a round's ground scuff lived 4 s (GunFx.SCUFF_TICKS) and was gone long
## before the fight was; now, when a scuff leaves GunFx, this ring keeps a settled copy where it was
## (the same GunFxMarks.scuff stroke and seed, at `alpha` of its fresh ink), so the street keeps a
## record of where the fight went. A hard cap (`cap`) with the oldest `fade_n` fading out first; one
## node draws them all and redraws only when the ring changes (retained, as FxGround's marks).
## Placement is the impact's own (position, direction, born tick as the seed): no RNG, no sim
## state. data/tables/battle_residue.json; `on` false = the before.

const TABLE: String = "res://data/tables/battle_residue.json"
## Line widths (px) of the stroke, the small dots and the large dots (GunFxMarks.scuff).
const WIDTHS: PackedFloat32Array = [6.0, 4.0, 7.0]

var on: bool = false
var cap: int = 0
var fade_n: int = 1
var alpha: float = 0.0
var _at: PackedVector2Array = PackedVector2Array()
var _dir: PackedVector2Array = PackedVector2Array()
var _seed: PackedInt32Array = PackedInt32Array()
var _live: Dictionary[Vector4, Vector2] = {}


func _init() -> void:
	show_behind_parent = true
	use_parent_material = true
	read(TABLE)


func read(path: String) -> void:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		return
	var d: Dictionary = parser.data
	on = d.get("on", false) == true
	var c: float = d.get("cap", 0.0)
	var f: float = d.get("fade_n", 1.0)
	cap = roundi(c)
	fade_n = maxi(1, roundi(f))
	alpha = d.get("alpha", 0.0)


## Each frame after GunFx.step: scuffs that left GunFx since the last call join the ring.
func sync(fx: GunFx) -> void:
	if not on or fx == null:
		return
	var live: Dictionary[Vector4, Vector2] = {}
	for i: int in fx.impacts.size():
		var im: Vector4 = fx.impacts[i]
		if int(im.z) == GunFx.Hit.GROUND:
			live[im] = fx.impact_dir[i]
	var grew: bool = false
	for im: Vector4 in _live:
		if not live.has(im):
			keep(Vector2(im.x, im.y), _live[im], int(im.w))
			grew = true
	_live = live
	if grew:
		queue_redraw()


## One settled scuff at `at` (m) along `dir`, seeded by its born tick; the oldest goes past cap.
func keep(at: Vector2, dir: Vector2, born: int) -> void:
	@warning_ignore("return_value_discarded")
	_at.append(at)
	@warning_ignore("return_value_discarded")
	_dir.append(dir)
	@warning_ignore("return_value_discarded")
	_seed.append(born)
	while _at.size() > cap:
		_at.remove_at(0)
		_dir.remove_at(0)
		_seed.remove_at(0)


func size() -> int:
	return _at.size()


## The ink of the i-th kept scuff (0 = oldest): the oldest fade_n of a full ring fade out first.
func ink_of(i: int) -> float:
	var room: int = cap - _at.size()
	return alpha * clampf(float(i + 1 + room) / float(fade_n), 0.0, 1.0)


## The whole ring in three batched calls (the stroke, the small dots, the large dots: each dot a
## short segment as wide as the dot), rebuilt only when the ring changes. GunFxMarks.scuff's own
## geometry and seed, settled: a redraw that drew each mark's circles cost up to 10 ms at 96.
func _draw() -> void:
	var g: Array = geometry()
	for k: int in 3:
		var pts: PackedVector2Array = g[2 * k]
		var cols: PackedColorArray = g[2 * k + 1]
		if not pts.is_empty():
			draw_multiline_colors(pts, cols, WIDTHS[k])


## The ring's segments and their colours: [strokes, colours, small dots, colours, large dots,
## colours], two points per segment, one colour per segment; the faded-out marks left out.
func geometry() -> Array:
	var out: Array = []
	for k: int in 3:
		out.append_array([PackedVector2Array(), PackedColorArray()])
	for i: int in _at.size():
		var ink: float = ink_of(i)
		if ink <= 0.0:
			continue
		var c: Color = Color(GunFxMarks.SCUFF, GunFxMarks.SCUFF.a * ink)
		var at: Vector2 = _at[i]
		var dir: Vector2 = _dir[i]
		_seg(out, 0, Ink.px(at - dir * 0.25), Ink.px(at + dir * 0.1), c)
		for j: int in 4:
			var h: float = NoirPack.hash01(_seed[i] * 31 + j)
			var off: Vector2 = dir.rotated(-0.9 + 1.8 * h) * (0.18 + 0.12 * float(j % 2))
			var p: Vector2 = Ink.px(at + off)
			_seg(out, 1 + j % 2, p - Vector2(0.5, 0.0), p + Vector2(0.5, 0.0), c)
	return out


func _seg(out: Array, k: int, a: Vector2, b: Vector2, c: Color) -> void:
	var pts: PackedVector2Array = out[2 * k]
	var cols: PackedColorArray = out[2 * k + 1]
	pts.append_array([a, b])
	@warning_ignore("return_value_discarded")
	cols.append(c)
	out[2 * k] = pts
	out[2 * k + 1] = cols
