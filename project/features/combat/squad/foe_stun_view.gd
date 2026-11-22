class_name FoeStunView
extends RefCounted
## Body-local, short electrical discharges. All motion comes from the display tick.


static func place_shield(view: Node2D, at: Vector2, h: Fighter, mind: SquadMind, tick: int) -> void:
	var scale: Vector2 = Vector2.ONE * FoeShieldView.LOOK_SCALE
	var angle: float = h.facing.angle()
	if mind != null and tick < mind.stun_until:
		# The unpowered slab hangs across the feet. Its raised silhouette clears the chest.
		at = Ink.px(h.pos + h.facing * 0.3 + Vector2.DOWN * 0.18)
		angle += PI * 0.42
		scale.y *= 0.65
	view.draw_set_transform(at, angle, scale)


static func place_gun(view: Node2D, at: Vector2, facing: Vector2, stunned: bool) -> void:
	var scale: Vector2 = Vector2.ONE * FoeTurretView.LOOK_SCALE
	var angle: float = facing.angle()
	if stunned:
		# Project the sag toward screen-down and foreshorten even a gun facing the camera.
		angle = (facing * 0.65 + Vector2.DOWN * 0.85).angle()
		scale.x *= 0.72
	else:
		at += Vector2.UP * 6.0 * FoeTurretView.LOOK_SCALE
	view.draw_set_transform(at, angle, scale)


static func arcs(view: Node2D, h: Fighter, mind: SquadMind, tick: int) -> void:
	var centre: Vector2 = Ink.px(h.pos)
	if mind.walker != null:
		centre += Ink.px(Vector2.UP * 1.02 * FoeWalkerView.LOOK_SCALE)
	elif mind.shield != null:
		centre += Ink.px(Vector2.UP * 0.76 * FoeShieldView.LOOK_SCALE)
	var beat: int = tick / 3 + h.id
	for i: int in 3:
		var dir: Vector2 = Vector2.from_angle(beat * 0.53 + i * TAU / 3)
		var side: Vector2 = dir.orthogonal()
		var start: Vector2 = centre + dir * (15 + (beat + i) % 11)
		var stroke: PackedVector2Array = PackedVector2Array(
			[start, start + side * 8 + dir * 5, start + side * 9 - dir * 2, start + side * 19]
		)
		view.draw_polyline(stroke, OhmBoltDraw.AMBER, 4.0, true)
		view.draw_polyline(stroke, Color.WHITE, 1.4, true)
