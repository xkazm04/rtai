class_name ServoFightDraw
extends ServoDraw
## The graybox's own drawing (dev only): the ground, the stand-in Servo (the before) and Rivet's
## stand-in disc. The swarm, the rings and Servo's tells are ServoDraw (shared with the arena).


func ground(c: CanvasItem, half_m: float) -> void:
	var r: Rect2 = Rect2(Vector2(-half_m, -half_m) * px, Vector2(half_m, half_m) * 2.0 * px)
	c.draw_rect(r.grow(px * 30.0), pal.color(&"paper_2"))
	c.draw_rect(r, pal.color(&"paper"))
	var grid: Color = Color(pal.color(&"wash"), 0.18)
	for k: int in range(-int(half_m), int(half_m) + 1, 4):
		c.draw_line(Vector2(k, -half_m) * px, Vector2(k, half_m) * px, grid, 1.0)
		c.draw_line(Vector2(-half_m, k) * px, Vector2(half_m, k) * px, grid, 1.0)
	c.draw_rect(r, pal.color(&"ink_2"), false, 3.0)


func servo(c: CanvasItem, f: BossFight, rack: ServoRack) -> void:
	var o: Vector2 = f.body.pos
	var fwd: Vector2 = f.body.facing
	var side: Vector2 = fwd.orthogonal()
	c.draw_circle((o + SHADOW * 4.0) * px, 2.6 * px, Color(pal.color(&"ink"), 0.22))
	for s: float in [-1.0, 1.0]:
		var pad: Vector2 = o + side * s * 2.1 + fwd * 0.7
		c.draw_circle(pad * px, 0.6 * px, pal.color(&"steel"))
		c.draw_arc(pad * px, 0.6 * px, 0.0, TAU, 24, pal.color(&"ink"), 2.0)
	for i: int in rack.state.size():
		_cell(c, rack.cell_pos(i), rack.state[i])
	c.draw_circle(o * px, 0.75 * px, pal.color(&"paper_2"))
	c.draw_arc(o * px, 0.75 * px, 0.0, TAU, 24, pal.color(&"ink"), 2.5)
	var scanning: bool = f.attack != null and f.state == BossFight.State.WINDUP
	var slit: Color = pal.color(&"vermilion") if scanning else pal.color(&"ink_2")
	c.draw_line((o + fwd * 0.45 - side * 0.3) * px, (o + fwd * 0.45 + side * 0.3) * px, slit, 4.0)


func _cell(c: CanvasItem, at: Vector2, state: int) -> void:
	var h: float = 0.4 * px
	var box: Rect2 = Rect2(at * px - Vector2(h, h), Vector2(h, h) * 2.0)
	var fill: Color = pal.color(&"wash") if state == ServoRack.Cell.FULL else pal.color(&"ink_2")
	if state == ServoRack.Cell.BROKEN:
		fill = pal.color(&"ink")
	c.draw_rect(box, fill)
	c.draw_rect(box, pal.color(&"ink"), false, 1.5)
	if state == ServoRack.Cell.FULL:
		c.draw_circle(at * px, h * 0.45, pal.color(&"paper"))


func rivet(c: CanvasItem, at: Vector2, r: float) -> void:
	c.draw_circle((at + SHADOW) * px, r * px, Color(pal.color(&"ink"), 0.25))
	c.draw_circle(at * px, r * px, pal.color(&"ink_2"))
	c.draw_circle(at * px, r * px * 0.45, pal.color(&"vermilion"))
