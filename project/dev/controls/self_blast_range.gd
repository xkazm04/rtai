extends ArenaFloorView
## The actual station target gets a paper bullseye on a sloping stand. Both panels use the
## station's collision boxes and the production arena's three-metre wall height.


func _draw() -> void:
	super._draw()
	var arena: ArenaStage = stage as ArenaStage
	if arena == null or arena.targets.targets.is_empty():
		return
	var target: ArenaTargets.Target = arena.targets.targets[0]
	var foot: Vector2 = Ink.px(target.fighter.pos)
	var hit_age: int = arena.tick - (target.down_until - ArenaTargets.DOWN_TICKS)
	var kick: float = 0.0
	if target.hits > 0 and hit_age < 25:
		kick = 0.16 * exp(-0.14 * hit_age) * sin(0.7 * hit_age)
	draw_set_transform(foot, kick, Vector2.ONE * Ink.PX_PER_M)
	draw_rect(Rect2(-0.58, -0.12, 1.16, 0.24), Ink.INK)
	draw_line(Vector2.ZERO, Vector2(0, -1.65), Ink.INK, 0.19, true)
	var board: Rect2 = Rect2(-0.88, -3.05, 1.76, 1.95)
	draw_rect(board, Ink.CREAM)
	draw_rect(board, Ink.INK, false, 0.09)
	var centre: Vector2 = board.get_center()
	for radius: float in [0.63, 0.44, 0.24]:
		draw_arc(centre, radius, 0.0, TAU, 48, Ink.INK, 0.065, true)
	draw_circle(centre, 0.16, Ink.VERMILION)
	draw_set_transform(Vector2.ZERO)


func _prop(ci: CanvasItem, at: Vector2, p: ArenaStation.Prop) -> void:
	super._prop(ci, at, p)
	if p.kind != "wall_high":
		return
	var top: Rect2 = Rect2(Ink.px(at - p.size * 0.5), p.size * Ink.PX_PER_M)
	var lift: Vector2 = ViewMode.shared().lift_at(
		ci.get_global_transform() * top.get_center(), PROP_H_M["wall_high"]
	)
	var face: Rect2 = Rect2(top.position.x, top.end.y + lift.y, top.size.x, -lift.y)
	ArenaFloorStatic.barrier(ci, face)
	var inset: Rect2 = face.grow(-2.0)
	ci.draw_rect(inset, Color("594b3b"))
	var pitch: float = Ink.PX_PER_M * 1.3
	for i: int in floori(inset.size.x / pitch):
		var a: Vector2 = inset.position + Vector2(pitch * (i + 0.4), inset.size.y - 2.0)
		var b: Vector2 = a + Vector2(inset.size.y * 0.65, 4.0 - inset.size.y)
		ci.draw_line(a, b, Color("edbd66"), 6.0, true)
	top.position += lift
	ArenaFloorStatic.barrier(ci, top)
