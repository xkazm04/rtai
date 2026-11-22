class_name FoeWalkerView
extends RefCounted
## The shoulder cannon rides over the scaled thug rig. Paired exhausts at the back
## open to show amber heat for the full recovery window.

const THIGH: Texture2D = preload("res://features/characters/art/thug/l_thigh.png")
const FOOT: Texture2D = preload("res://features/characters/art/thug/l_foot.png")
const LOOK_SCALE: float = 1.72


static func draw_machine(view: Node2D, h: Fighter, mind: SquadMind, arena: CombatArena) -> void:
	var walker: FoeWalker = mind.walker
	var e: EnemyAgent = mind.agent
	var radius: float = walker.ring_radius(e)
	if radius > 0.0:
		danger_ring(view, walker.landing, radius)
	var at: Vector2 = Ink.px(h.pos + Vector2.UP * 1.02 * LOOK_SCALE)
	var row: MoveTable.ArmourCrack = arena.squad_ai.moves.tonnage_armour_crack
	var sag: bool = row.enabled and TonnageCrack.post_stomp(mind)
	_legs(view, h, e.vel.length(), arena.tick)
	if sag:
		at.y += FoeWalkerCrackView.SAG_PX
	view.draw_set_transform(at, h.facing.angle(), Vector2.ONE * LOOK_SCALE)
	Ink.box(view, Vector2(1.12, 0), Vector2(2.12, 0.41), FoeTurretView.STEEL)
	Ink.box(view, Vector2(2.06, 0), Vector2(0.42, 0.55), FoeTurretView.DARK)
	Ink.box(view, Vector2(-0.12, 0), Vector2(1.54, 1.5), FoeTurretView.STEEL)
	view.draw_texture_rect(FoeShieldView.TORSO, Rect2(-30, -29, 55, 58), false)
	for side: int in [-1, 1]:
		var y: float = side * (28.0 + (FoeWalkerCrackView.LIFT_PX if sag else 0.0))
		view.draw_rect(Rect2(-29, y - 5, 55, 10), FoeTurretView.AMBER)
		for x: int in range(-23, 24, 14):
			view.draw_line(Vector2(x, y - 5), Vector2(x + 6, y + 5), Ink.INK, 6.0)
	view.draw_texture_rect(FoeTurretView.HEAD, Rect2(4, -15, 29, 30), false)
	FoeWalkerCrackView.plates(view, sag, TonnageCrack.is_open(mind, row, arena.tick))
	var vent: Color = Ink.INK
	if e.state == EnemyAgent.State.RECOVER:
		var heat: float = float(h.cooldown) / walker.attack.cooldown_ticks
		vent = FoeTurretView.AMBER.lerp(Ink.CREAM, heat)
	for side: int in [-1, 1]:
		Ink.box(view, Vector2(-0.68, side * 0.36), Vector2(0.45, 0.49), FoeTurretView.DARK)
		for x: int in [-37, -32]:
			var y: float = side * 17.0
			view.draw_line(Vector2(x, y - 8), Vector2(x, y + 8), vent, 4.5)
	view.draw_set_transform(Vector2.ZERO, 0.0)


## Two loaded knees carry the chassis. Tread and thigh stay planted during the tells.
static func _legs(view: Node2D, h: Fighter, speed: float, tick: int) -> void:
	var stride: float = sin(float(tick) * 0.12) * speed * 8.0
	var at: Vector2 = Ink.px(h.pos + Vector2.UP * 0.38 * LOOK_SCALE)
	view.draw_set_transform(at, h.facing.angle(), Vector2.ONE * LOOK_SCALE)
	for side: int in [-1, 1]:
		var x: float = side * stride
		var y: float = side * 44.0
		view.draw_texture_rect(FOOT, Rect2(x - 31, y - 14, 65, 28), false)
		var hip: Vector2 = Vector2(-14, side * 17)
		var knee: Vector2 = Vector2(x + 8, y)
		view.draw_line(hip, knee, Ink.INK, 13.0, true)
		view.draw_line(hip, knee, FoeTurretView.STEEL, 8.0, true)
		view.draw_texture_rect(THIGH, Rect2(x - 26, y - 11, 43, 21), false)
	view.draw_set_transform(Vector2.ZERO, 0.0)


static func danger_ring(view: Node2D, centre: Vector2, radius_m: float) -> void:
	var at: Vector2 = Ink.px(centre)
	var radius: float = radius_m * Ink.PX_PER_M
	view.draw_arc(at, radius, 0.0, TAU, 96, Ink.INK, 7.0, true)
	view.draw_arc(at, radius, 0.0, TAU, 96, Ink.VERMILION, 3.5, true)
