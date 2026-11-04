class_name RivetMagView
extends Node2D
## rivet-arsenal: the magazine in Rivet's off claw through a reload (render only), a placeholder
## ink block until weapon-art's magazine parts land (REQUEST 8). RivetHeldView feeds it the rig's
## reload_k each frame: phase 0 (0..1) the spent magazine rides the off claw from the gun down to
## the drop point and falls there (it lies on the floor DROP_LINGER_S, then fades); phase 1 (1..2)
## a fresh one rides the claw back up into the gun; phase 2 (the rack) shows none.

## Block size as shares of the forearm's length (long side) and of the long side (short side).
const LONG_K: float = 1.1
const SHORT_K: float = 0.38
const DROP_LINGER_S: float = 1.4
const DROP_FADE_S: float = 0.4
const MAX_DROPPED: int = 4
## Above the rig's arms (they reach z 9) for the held block; just under the held view, dropped.
const HELD_Z: int = 12
const FLOOR_Z: int = -1
const INK: Color = Color("1b1517")
const FILL: Color = Color("5a5560")
const SHINE: Color = Color("efe6d4")

var _held: bool = false
var _xf: Transform2D = Transform2D.IDENTITY
var _size: Vector2 = Vector2.ZERO
var _last_k: float = -1.0
## Spent magazines on the floor and their ages (s).
var _drop_xf: Array[Transform2D] = []
var _drop_tick: PackedInt32Array = PackedInt32Array()
var _now: int = 0

## The floor layer: spent magazines lie under the bodies, the held one rides above the rig.
var _floor: Node2D = null


func _ready() -> void:
	top_level = true
	z_index = HELD_Z
	_floor = Node2D.new()
	_floor.top_level = true
	_floor.z_index = FLOOR_Z
	add_child(_floor)
	@warning_ignore("return_value_discarded")
	_floor.draw.connect(_draw_floor)


## Called each frame by RivetHeldView after the rig is posed (`k` < 0: no reload; `tick` the
## fight's tick, which ages the spent magazines).
func feed(rig: CutRig, k: float, tick: int) -> void:
	_now = tick
	var off: int = 1 - rig.plan.gun_arm if rig.plan.gun_arm >= 0 else -1
	_held = k >= 0.0 and k < 2.0 and off >= 0 and off < rig.sides.size()
	if _held:
		_place(rig, rig.sides[off], rig.plan.fore_len[off])
	if _last_k >= 0.0 and _last_k < 1.0 and k >= 1.0 and _size != Vector2.ZERO:
		_drop()
	_last_k = k
	_age()
	queue_redraw()
	if _floor != null:
		_floor.queue_redraw()


## The block in the off claw: at the arm's hand joint (rig-local part px, in the forearm's parent
## space, as RigArm placed it), the long side across the forearm line.
func _place(rig: CutRig, side: RigLimbs, fore_len: float) -> void:
	var parent: Node2D = side.fore.get_parent() as Node2D
	var xf: Transform2D = parent.global_transform if parent != null else rig.global_transform
	var at: Vector2 = xf * side.j_hand
	var along: Vector2 = at - xf * side.j_elbow
	var k: float = xf.get_scale().abs().x
	_size = Vector2(fore_len * LONG_K * k, fore_len * LONG_K * SHORT_K * k)
	_xf = Transform2D(along.angle() + PI * 0.5, at + along.normalized() * _size.y * 0.5)


func dropped_count() -> int:
	return _drop_xf.size()


func _drop() -> void:
	var xf: Transform2D = _xf.translated_local(Vector2(0.0, _size.y * 0.6))
	_drop_xf.append(xf.rotated_local(0.6))
	@warning_ignore("return_value_discarded")
	_drop_tick.append(_now)
	if _drop_xf.size() > MAX_DROPPED:
		_drop_xf.remove_at(0)
		_drop_tick.remove_at(0)


func _age_s(i: int) -> float:
	return float(_now - _drop_tick[i]) * SimClock.TICK_DT


func _age() -> void:
	for i: int in range(_drop_xf.size() - 1, -1, -1):
		if _age_s(i) >= DROP_LINGER_S + DROP_FADE_S:
			_drop_xf.remove_at(i)
			_drop_tick.remove_at(i)


func _draw() -> void:
	if _held:
		_block(self, _xf, 1.0)


func _draw_floor() -> void:
	for i: int in _drop_xf.size():
		var a: float = 1.0 - clampf((_age_s(i) - DROP_LINGER_S) / DROP_FADE_S, 0.0, 1.0)
		_block(_floor, _drop_xf[i], a)


func _block(on: CanvasItem, xf: Transform2D, alpha: float) -> void:
	on.draw_set_transform_matrix(xf)
	var r: Rect2 = Rect2(-_size * 0.5, _size)
	var ink: float = maxf(1.5, _size.y * 0.18)
	on.draw_rect(r.grow(ink * 0.5), Color(INK, alpha))
	on.draw_rect(r, Color(FILL, alpha))
	var shine: Rect2 = Rect2(
		r.position + Vector2(ink, ink * 0.6), Vector2(r.size.x - ink * 2.0, ink)
	)
	on.draw_rect(shine, Color(SHINE, alpha * 0.85))
	on.draw_set_transform_matrix(Transform2D.IDENTITY)
