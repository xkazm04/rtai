class_name FoeShieldView
extends RefCounted
## The carrier's slab rides ahead of the thug rig, with a deep steel rim visible
## edge-on. During the strike clip it lifts and pulls back against the shoulder.

const HUB: Texture2D = preload("res://features/characters/art/thug/r_forearm_endon.png")
const TORSO: Texture2D = preload("res://features/characters/art/thug/torso.png")
const LOOK_SCALE: float = 1.6
static var _plate: PackedVector2Array = PackedVector2Array(
	[
		Vector2(-12, -33),
		Vector2(1, -42),
		Vector2(12, -35),
		Vector2(17, -20),
		Vector2(17, 20),
		Vector2(12, 35),
		Vector2(1, 42),
		Vector2(-12, 33)
	]
)


static func draw_plate(view: Node2D, h: Fighter, mind: SquadMind, tick: int) -> void:
	var shield: FoeShield = mind.shield if mind != null else null
	if shield != null and (h.swing_left > 0 or shield.lunge_left > 0):
		_shove_lane(view, h.pos, mind.agent.aim, mind.agent.arch.weapon.reach_m)
	var chest: Vector2 = Ink.px(h.pos + Vector2.UP * 0.76 * LOOK_SCALE)
	view.draw_set_transform(chest, h.facing.angle(), Vector2.ONE * LOOK_SCALE)
	view.draw_texture_rect(TORSO, Rect2(-23, -24, 46, 48), false)
	view.draw_texture_rect(FoeTurretView.HEAD, Rect2(-5, -15, 28, 30), false)
	var raised: bool = h.swing_left > 0
	var front: float = 0.58 if raised else 0.85
	var lift: float = 1.12 if raised else 0.67
	var at: Vector2 = Ink.px(h.pos + (h.facing * front + Vector2.UP * lift) * LOOK_SCALE)
	view.draw_set_transform(at, h.facing.angle(), Vector2.ONE * LOOK_SCALE)
	view.draw_colored_polygon(_plate, FoeTurretView.STEEL)
	view.draw_polyline(_plate, Ink.INK, 3.5, true)
	view.draw_line(_plate[-1], _plate[0], Ink.INK, 3.5, true)
	view.draw_line(Vector2(11, -29), Vector2(11, 29), FoeTurretView.AMBER, 7.0)
	for y: int in range(-24, 28, 12):
		view.draw_line(Vector2(7, y), Vector2(15, y + 5), Ink.INK, 4.0)
	view.draw_texture_rect(HUB, Rect2(-11, -12, 20, 24), false)
	view.draw_set_transform(Vector2.ZERO, 0.0)
	if shield != null and tick - shield.block_tick < 7:
		_sparks(view, at, shield, tick)


static func _shove_lane(view: Node2D, pos: Vector2, aim: Vector2, reach: float) -> void:
	view.draw_set_transform(Ink.px(pos), aim.angle())
	var end: float = reach * Ink.PX_PER_M
	var lane: PackedVector2Array = PackedVector2Array(
		[
			Vector2(0, -13),
			Vector2(end * 0.68, -23),
			Vector2(end, 0),
			Vector2(end * 0.68, 23),
			Vector2(0, 13)
		]
	)
	view.draw_colored_polygon(lane, Color(Ink.VERMILION, 0.46))
	for side: int in [-1, 1]:
		var rail: PackedVector2Array = PackedVector2Array(
			[Vector2(0, side * 13), Vector2(end * 0.68, side * 23), Vector2(end, 0)]
		)
		view.draw_polyline(rail, Ink.INK, 8.0, true)
		view.draw_polyline(rail, Ink.VERMILION, 4.5, true)
	view.draw_set_transform(Vector2.ZERO, 0.0)


static func _sparks(view: Node2D, at: Vector2, shield: FoeShield, tick: int) -> void:
	var spark: Vector2 = at - Ink.px(shield.block_dir * 0.25)
	var spread: float = 11.0 + 2.0 * (tick - shield.block_tick)
	for angle: float in [-0.75, -0.22, 0.4, 0.95]:
		var dir: Vector2 = -shield.block_dir.rotated(angle)
		view.draw_line(spark + dir * 4.0, spark + dir * spread, Ink.CREAM, 3.5, true)
