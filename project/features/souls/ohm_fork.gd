class_name OhmFork
extends Node2D
## Attachment on the painted staff. Its parent supplies the entire pose and canvas transform.

const GROUP: StringName = &"ohm_spectral_forks"

var stage: OhmStage
var vent: float = 0.0
var _points: PackedVector2Array = []


func _ready() -> void:
	add_to_group(GROUP)


## Two prongs followed by their midpoint, in the shown cell's own (unmirrored) pixels.
static func unpack(row: Dictionary) -> PackedVector2Array:
	var tips: Array = row.prongs_px
	var mid: Array = row.fork_px
	var points: PackedVector2Array = []
	for point: Array in [tips[0], tips[1], mid]:
		var x: float = point[0]
		var y: float = point[1]
		@warning_ignore("return_value_discarded")
		points.append(Vector2(x, y))
	return points


func place(sprite: Sprite2D, cell: PackedVector2Array) -> void:
	_points = cell.duplicate()
	var width: float = sprite.texture.get_width() / float(sprite.hframes)
	for i: int in _points.size():
		if sprite.flip_h:
			_points[i].x = width - _points[i].x
		_points[i] += sprite.offset


func points_on(ink: CanvasItem) -> PackedVector2Array:
	var to_ink: Transform2D = ink.get_global_transform_with_canvas().affine_inverse()
	return (to_ink * get_global_transform_with_canvas()) * _points


static func ohm_prongs(
	prongs: PackedVector2Array, ink: CanvasItem, ppm: float
) -> PackedVector2Array:
	var hand: Vector2 = GhostHand.local_to("ohm", ink)
	if hand == Vector2.INF:
		return prongs
	var shift: Vector2 = hand / ppm - (prongs[0] + prongs[1]) * 0.5
	return PackedVector2Array([prongs[0] + shift, prongs[1] + shift])


## A cancel has three outward amber spits. Only a released bolt gets the three-tick star.
static func fork_ink(amount: float) -> Color:
	return OhmBoltDraw.AMBER if amount > 0.0 else OhmView.WHITE


static func flare(ink: OhmView, at: Vector2, aim: Vector2, age: int, amount: float) -> void:
	var colour: Color = fork_ink(amount)
	if amount > 0.0:
		var t: float = (1.0 - amount) * OhmCharge.VENT_TICKS / OhmVictimRims.SPARK_TICKS
		if t < 1.0:
			for i: int in 3:
				var dir: Vector2 = aim.rotated((i - 1) * 0.8)
				var start: Vector2 = at + dir * (0.07 + 0.23 * t) * ink.ppm
				ink.draw_line(
					start, start + dir * 0.15 * ink.ppm, Color(colour, 1.0 - t), 1.8, true
				)
	elif age >= 0 and age < OhmBoltDraw.FLARE_TICKS:
		var r: float = (0.22 - 0.035 * age) * ink.ppm
		for i: int in 4:
			var ray: Vector2 = aim.rotated(i * PI / 4.0) * r * (1.0 if i % 2 == 0 else 0.55)
			ink.draw_line(at - ray, at + ray, OhmView.TEAL, 2.8, true)
			ink.draw_line(at - ray, at + ray, colour, 1.3, true)
