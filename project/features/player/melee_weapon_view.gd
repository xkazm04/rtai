class_name MeleeWeaponView
extends Node2D
## A melee weapon drawn in Rivet's weapon hand (rivet-motion, a placeholder until weapon art):
## the prop runs from the fist along the forearm, at the table's length_m, with the D5 ink
## outline. While a hit is active it leaves a short smear of the last tip positions, so a slash
## reads as an arc at 32 px/m. A slash sweeps the prop off the forearm line: cocked back by
## `sweep_rad` over the windup, swept through to the other side over the active ticks, and
## settled back over the recovery; hits alternate sides, and a lunge hit (a thrust) never
## sweeps. Electric tips are pale blue-white: teal is souls only and vermilion danger only.
## Add it as a sibling of the rig (same canvas), call track() per tick.

const INK: Color = Color("15171b")
const STEEL: Color = Color("c4c9d0")
const GRIP: Color = Color("2b2622")
const SHAFT: Color = Color("7d8794")
const SPARK: Color = Color("e6eeff")
const SMEAR_TICKS: int = 4
const INK_PX: float = 1.5

var kind: StringName = &"katana"
var length_px: float = 32.0
var sweep_rad: float = 1.0
var _grip: Vector2 = Vector2.ZERO
var _tip: Vector2 = Vector2.RIGHT
var _smear: PackedVector2Array = PackedVector2Array()
var _hot: bool = false
## A stun on a struck body: where (host space) and the ticks left; flickering zigzag arcs.
var _zap_at: Vector2 = Vector2.ZERO
var _zap_ticks: int = 0


## Places the prop on `rig`'s weapon hand, swept by `combo`'s current hit.
func track(rig: CutRig, combo: MeleeCombo) -> void:
	var hot: bool = combo.phase() == MeleeCombo.Phase.ACTIVE
	var side: RigLimbs = rig.sides[maxi(rig.plan.gun_arm, 0)]
	var spr: Sprite2D = side.hand if side.hand != null else side.fore
	var ts: Vector2 = spr.texture.get_size()
	var host: Node2D = get_parent() as Node2D
	var g: Vector2 = spr.global_transform * (ts * 0.5 + spr.offset)
	var dir: Vector2 = spr.global_transform.x.normalized().rotated(sweep_of(combo))
	_grip = host.to_local(g) if host != null else g
	_tip = _grip + dir * length_px
	_hot = hot
	if hot:
		@warning_ignore("return_value_discarded")
		_smear.append(_tip)
		if _smear.size() > SMEAR_TICKS:
			_smear.remove_at(0)
	else:
		_smear.clear()
	_zap_ticks = maxi(_zap_ticks - 1, 0)
	queue_redraw()


## Shows a hit's stun on the body at `at` (host space) for `ticks`.
func zap(at: Vector2, ticks: int) -> void:
	_zap_at = at
	_zap_ticks = ticks


## The sweep angle off the forearm for `combo`'s current hit (0 when idle or on a thrust).
func sweep_of(combo: MeleeCombo) -> float:
	var h: MeleeHit = combo.current()
	if h == null or h.lunge_m > 0.0:
		return 0.0
	var side: float = sweep_rad * (1.0 if combo.hit_index % 2 == 1 else -1.0)
	var t: float = float(combo.tick_in)
	if t < h.windup:
		return lerpf(0.0, side, t / float(h.windup))
	if t < h.windup + h.active:
		return lerpf(side, -side, (t - h.windup + 1.0) / float(h.active))
	return lerpf(-side, 0.0, (t - h.windup - h.active) / maxf(float(h.recovery), 1.0))


func _draw() -> void:
	var smear: Color = Color(STEEL, 0.4)
	for i: int in range(1, _smear.size()):
		var tri: PackedVector2Array = PackedVector2Array([_grip, _smear[i - 1], _smear[i]])
		draw_primitive(tri, PackedColorArray([smear, smear, smear]), PackedVector2Array())
	if _zap_ticks > 0 and _zap_ticks % 4 < 3:
		_draw_zap()
	var dir: Vector2 = (_tip - _grip).normalized()
	var hilt: Vector2 = _grip + dir * length_px * 0.22
	if kind == &"electro_baton":
		_bar(_grip - dir * 4.0, hilt, 3.4, GRIP)
		_bar(hilt, _tip, 3.0, SHAFT)
		draw_circle(_tip, 3.6 if _hot else 2.2, SPARK)
		if _hot:
			draw_arc(_tip, 7.0, 0.0, TAU, 12, Color(SPARK, 0.7), 1.5)
		return
	_bar(_grip - dir * 4.0, hilt, 3.4, GRIP)
	_bar(hilt, _tip, 3.0, STEEL)
	draw_line(hilt - dir.orthogonal() * 3.5, hilt + dir.orthogonal() * 3.5, INK, 2.0)


## Three zigzag arcs around the stunned body, re-drawn from the tick count (no RNG).
func _draw_zap() -> void:
	for k: int in 3:
		var a: float = float(k) * TAU / 3.0 + float(_zap_ticks) * 0.9
		var pts: PackedVector2Array = PackedVector2Array()
		for j: int in 5:
			var r: float = 9.0 + 4.0 * float(j)
			var jit: float = 0.35 if (j + _zap_ticks) % 2 == 0 else -0.35
			@warning_ignore("return_value_discarded")
			pts.append(_zap_at + Vector2.RIGHT.rotated(a + jit) * r)
		draw_polyline(pts, INK, 3.5)
		draw_polyline(pts, SPARK, 1.5)


## A capsule-ish bar with the ink outline under it.
func _bar(a: Vector2, b: Vector2, w: float, col: Color) -> void:
	draw_line(a, b, INK, w + INK_PX * 2.0)
	draw_line(a, b, col, w)
