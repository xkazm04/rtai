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
		_shove_lane(view, h, mind)
	if FoeShieldCardView.enabled(h):
		return
	var chest: Vector2 = Ink.px(h.pos + Vector2.UP * 0.76 * LOOK_SCALE)
	view.draw_set_transform(chest, h.facing.angle(), Vector2.ONE * LOOK_SCALE)
	view.draw_texture_rect(TORSO, Rect2(-23, -24, 46, 48), false)
	view.draw_texture_rect(FoeTurretView.HEAD, Rect2(-5, -15, 28, 30), false)
	var raised: bool = h.swing_left > 0
	var front: float = 0.58 if raised else 0.85
	var lift: float = 1.12 if raised else 0.67
	var at: Vector2 = Ink.px(h.pos + (h.facing * front + Vector2.UP * lift) * LOOK_SCALE)
	FoeStunView.place_shield(view, at, h, mind, tick)
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


static func _shove_lane(view: Node2D, h: Fighter, mind: SquadMind) -> void:
	var e: EnemyAgent = mind.agent
	var lane: PackedVector2Array = FoeShoveZone.polygon(
		_tell_start(h, mind), e.aim, e.arch.speed_mps, e.arch.weapon.reach_m
	)
	for i: int in lane.size():
		lane[i] = Ink.px(lane[i])
	view.draw_set_transform(Vector2.ZERO, 0.0)
	view.draw_colored_polygon(lane, Color(Ink.VERMILION, 0.46))
	var inset: Vector2 = (lane[3] - lane[0]).normalized() * 2.0
	view.draw_line(lane[0] + inset, lane[1] + inset, Ink.VERMILION, 4.0, true)
	view.draw_line(lane[3] - inset, lane[2] - inset, Ink.VERMILION, 4.0, true)
	var tip: Vector2 = (lane[1] + lane[2]) * 0.5 - e.aim * 3.0
	var upper: Vector2 = lane[1].lerp(lane[0], 0.20) + inset
	var lower: Vector2 = lane[2].lerp(lane[3], 0.20) - inset
	view.draw_polyline(PackedVector2Array([upper, tip, lower]), Ink.VERMILION, 3.0, true)


static func _tell_start(h: Fighter, mind: SquadMind) -> Vector2:
	# Keep the first observed plant even if a wall blocks subsequent lunge steps.
	# On a first draw mid-lunge, backtrack all elapsed steps. If blocked, this still
	# covers the current position through every remaining step and the full reach.
	var shield: FoeShield = mind.shield
	if shield.get_meta(&"shove_view_tick", -2) != h.swing_tick:
		var elapsed: int = 0 if h.swing_left > 0 else FoeShield.LUNGE_TICKS - shield.lunge_left
		var travel: float = elapsed * SimClock.TICK_DT * mind.agent.arch.speed_mps
		shield.set_meta(&"shove_view_start", h.pos - mind.agent.aim * travel)
		shield.set_meta(&"shove_view_tick", h.swing_tick)
	return shield.get_meta(&"shove_view_start")


static func _sparks(view: Node2D, at: Vector2, shield: FoeShield, tick: int) -> void:
	var spark: Vector2 = at - Ink.px(shield.block_dir * 0.25)
	var spread: float = 11.0 + 2.0 * (tick - shield.block_tick)
	for angle: float in [-0.75, -0.22, 0.4, 0.95]:
		var dir: Vector2 = -shield.block_dir.rotated(angle)
		view.draw_line(spark + dir * 4.0, spark + dir * spread, Ink.CREAM, 3.5, true)
