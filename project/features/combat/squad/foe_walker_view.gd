class_name FoeWalkerView
extends RefCounted
## The shoulder cannon rides over the scaled thug rig. Paired exhausts at the back
## open to show amber heat for the full recovery window.


static func draw_machine(view: Node2D, h: Fighter, mind: SquadMind) -> void:
	var walker: FoeWalker = mind.walker
	var e: EnemyAgent = mind.agent
	var radius: float = walker.ring_radius(e)
	if radius > 0.0:
		danger_ring(view, walker.landing, radius)
	var at: Vector2 = Ink.px(h.pos + Vector2.UP * 1.02)
	view.draw_set_transform(at, h.facing.angle())
	Ink.box(view, Vector2(0.87, 0), Vector2(1.8, 0.38), FoeTurretView.STEEL)
	Ink.box(view, Vector2(1.68, 0), Vector2(0.36, 0.52), FoeTurretView.DARK)
	Ink.box(view, Vector2(-0.12, 0), Vector2(1.2, 1.4), FoeTurretView.STEEL)
	view.draw_texture_rect(FoeShieldView.TORSO, Rect2(-29, -29, 54, 58), false)
	for side: int in [-1, 1]:
		var y: float = side * 28.0
		view.draw_rect(Rect2(-29, y - 5, 55, 10), FoeTurretView.AMBER)
		for x: int in range(-23, 24, 14):
			view.draw_line(Vector2(x, y - 5), Vector2(x + 6, y + 5), Ink.INK, 6.0)
	var vent: Color = Ink.INK
	if e.state == EnemyAgent.State.RECOVER:
		var heat: float = float(h.cooldown) / walker.attack.cooldown_ticks
		vent = FoeTurretView.AMBER.lerp(Ink.CREAM, heat)
	for side: int in [-1, 1]:
		Ink.box(view, Vector2(-0.68, side * 0.34), Vector2(0.35, 0.45), FoeTurretView.DARK)
		for x: int in [-37, -32]:
			var y: float = side * 16.0
			view.draw_line(Vector2(x, y - 7), Vector2(x, y + 7), vent, 3.0)
	view.draw_set_transform(Vector2.ZERO, 0.0)


static func danger_ring(view: Node2D, centre: Vector2, radius_m: float) -> void:
	var at: Vector2 = Ink.px(centre)
	var radius: float = radius_m * Ink.PX_PER_M
	view.draw_arc(at, radius, 0.0, TAU, 96, Ink.INK, 7.0, true)
	view.draw_arc(at, radius, 0.0, TAU, 96, Ink.VERMILION, 3.5, true)
