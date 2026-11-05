class_name ServoFightDraw
extends RefCounted
## The graybox's drawing (dev only): every shape in metres x PX, palette tokens only. Vermilion
## only for danger (beam, rings, dash lane); ink shadows; paper and steel for bodies.

const PX: float = 32.0
const SHADOW: Vector2 = Vector2(0.25, 0.35)

var pal: PaletteTokens = PaletteTokens.shared()
## The cut parts (ServoRig.ART), drawn at ART_PPM; null = the stand-in shapes.
var drone_tex: Texture2D = load(ServoRig.ART % "drone") as Texture2D
var crate_tex: Texture2D = load(ServoRig.ART % "crate") as Texture2D


func ground(c: CanvasItem, half_m: float) -> void:
	var r: Rect2 = Rect2(Vector2(-half_m, -half_m) * PX, Vector2(half_m, half_m) * 2.0 * PX)
	c.draw_rect(r.grow(PX * 30.0), pal.color(&"paper_2"))
	c.draw_rect(r, pal.color(&"paper"))
	var grid: Color = Color(pal.color(&"wash"), 0.18)
	for k: int in range(-int(half_m), int(half_m) + 1, 4):
		c.draw_line(Vector2(k, -half_m) * PX, Vector2(k, half_m) * PX, grid, 1.0)
		c.draw_line(Vector2(-half_m, k) * PX, Vector2(half_m, k) * PX, grid, 1.0)
	c.draw_rect(r, pal.color(&"ink_2"), false, 3.0)


func parcels(c: CanvasItem, s: ServoSwarm) -> void:
	var verm: Color = pal.color(&"vermilion")
	for d: ServoDrone in s.drones:
		if d.carrying():
			_dashed_ring(c, d.goal, s.tuning.ring_m, Color(verm, 0.7), 2.0)
	for p: ServoParcels.Parcel in s.parcels.falling:
		var k: float = 1.0 - float(p.fall_left) / p.fall_total
		c.draw_circle(p.pos * PX, s.tuning.ring_m * PX * k, Color(verm, 0.28))
		_dashed_ring(c, p.pos, s.tuning.ring_m, verm, 3.0)
	for b: ServoParcels.Blast in s.parcels.blasts:
		c.draw_circle(b.pos * PX, b.radius_m * PX, Color(pal.color(&"ink"), 0.55))
	for cr: ServoParcels.Parcel in s.parcels.crates:
		var half: float = s.tuning.crate_m * 0.5 * PX
		var box: Rect2 = Rect2(cr.pos * PX - Vector2(half, half), Vector2(half, half) * 2.0)
		if crate_tex != null:
			_sprite(c, crate_tex, cr.pos * PX, 0.0)
			c.draw_string(
				ThemeDB.fallback_font, box.position + Vector2(5, half + 4), "CS", 0, -1, 10
			)
			continue
		c.draw_rect(box, pal.color(&"steel"))
		c.draw_rect(box, pal.color(&"ink"), false, 2.0)
		c.draw_string(ThemeDB.fallback_font, box.position + Vector2(3, half + 4), "CS", 0, -1, 11)


func tells(c: CanvasItem, f: BossFight, m: ServoMoves) -> void:
	if f.attack == null or f.state != BossFight.State.WINDUP:
		return
	var verm: Color = pal.color(&"vermilion")
	var w: float = 5.0 if f.locked else 1.5
	match f.attack.id:
		&"scan_drop", &"kamikaze", &"package_carpet":
			c.draw_line(f.body.pos * PX, m.mark * PX, Color(verm, 0.9), w)
			if f.locked:
				_dashed_ring(c, m.mark, 1.0, verm, 4.0)
		&"rotor_dash", &"rotor_dash_hot":
			var a: BossAttack = f.attack
			var side: Vector2 = f.aim.orthogonal() * a.width_m * 0.5
			var o: Vector2 = f.body.pos
			var e: Vector2 = o + f.aim * a.range_m
			var lane: PackedVector2Array = [
				(o + side) * PX, (e + side) * PX, (e - side) * PX, (o - side) * PX
			]
			c.draw_colored_polygon(lane, Color(verm, 0.3 if f.locked else 0.12))
			@warning_ignore("return_value_discarded")
			lane.append(lane[0])
			c.draw_polyline(lane, verm, w * 0.6)
		&"bay_hop":
			_dashed_ring(c, m.mark, f.attack.range_m, verm, w)


func servo(c: CanvasItem, f: BossFight, rack: ServoRack) -> void:
	var o: Vector2 = f.body.pos
	var fwd: Vector2 = f.body.facing
	var side: Vector2 = fwd.orthogonal()
	c.draw_circle((o + SHADOW * 4.0) * PX, 2.6 * PX, Color(pal.color(&"ink"), 0.22))
	for s: float in [-1.0, 1.0]:
		var pad: Vector2 = o + side * s * 2.1 + fwd * 0.7
		c.draw_circle(pad * PX, 0.6 * PX, pal.color(&"steel"))
		c.draw_arc(pad * PX, 0.6 * PX, 0.0, TAU, 24, pal.color(&"ink"), 2.0)
	for i: int in rack.state.size():
		_cell(c, rack.cell_pos(i), rack.state[i])
	c.draw_circle(o * PX, 0.75 * PX, pal.color(&"paper_2"))
	c.draw_arc(o * PX, 0.75 * PX, 0.0, TAU, 24, pal.color(&"ink"), 2.5)
	var scanning: bool = f.attack != null and f.state == BossFight.State.WINDUP
	var slit: Color = pal.color(&"vermilion") if scanning else pal.color(&"ink_2")
	c.draw_line((o + fwd * 0.45 - side * 0.3) * PX, (o + fwd * 0.45 + side * 0.3) * PX, slit, 4.0)


func _cell(c: CanvasItem, at: Vector2, state: int) -> void:
	var h: float = 0.4 * PX
	var box: Rect2 = Rect2(at * PX - Vector2(h, h), Vector2(h, h) * 2.0)
	var fill: Color = pal.color(&"wash") if state == ServoRack.Cell.FULL else pal.color(&"ink_2")
	if state == ServoRack.Cell.BROKEN:
		fill = pal.color(&"ink")
	c.draw_rect(box, fill)
	c.draw_rect(box, pal.color(&"ink"), false, 1.5)
	if state == ServoRack.Cell.FULL:
		c.draw_circle(at * PX, h * 0.45, pal.color(&"paper"))


func rivet(c: CanvasItem, at: Vector2, r: float) -> void:
	c.draw_circle((at + SHADOW) * PX, r * PX, Color(pal.color(&"ink"), 0.25))
	c.draw_circle(at * PX, r * PX, pal.color(&"ink_2"))
	c.draw_circle(at * PX, r * PX * 0.45, pal.color(&"vermilion"))


func drones(c: CanvasItem, s: ServoSwarm) -> void:
	for d: ServoDrone in s.drones:
		var sh: Vector2 = (d.pos + SHADOW * d.height) * PX
		c.draw_circle(sh, 0.35 * PX, Color(pal.color(&"ink"), 0.35))
		var p: Vector2 = d.pos * PX
		if drone_tex != null:
			_sprite(c, drone_tex, p, d.vel.angle() - PI / 2 if d.vel.length() > 0.5 else 0.0)
			if d.carrying():
				c.draw_rect(Rect2(p + Vector2(-4, -4), Vector2(8, 8)), pal.color(&"paper_2"))
			continue
		for q: Vector2 in [Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]:
			c.draw_arc(p + q * 0.22 * PX, 0.14 * PX, 0.0, TAU, 12, pal.color(&"ink"), 1.5)
		var body: Rect2 = Rect2(p - Vector2(4, 4), Vector2(8, 8))
		c.draw_rect(body, pal.color(&"steel"))
		c.draw_rect(body, pal.color(&"ink"), false, 1.0)
		if d.carrying():
			c.draw_rect(Rect2(p + Vector2(-3, 4), Vector2(6, 5)), pal.color(&"paper_2"))


func _sprite(c: CanvasItem, t: Texture2D, at_px: Vector2, rot: float) -> void:
	c.draw_set_transform(at_px, rot, Vector2.ONE * PX / ServoRig.ART_PPM)
	c.draw_texture(t, -t.get_size() * 0.5)
	c.draw_set_transform(Vector2.ZERO)


func _dashed_ring(c: CanvasItem, at: Vector2, r_m: float, col: Color, w: float) -> void:
	var n: int = 16
	for k: int in n:
		var a0: float = TAU * k / n
		c.draw_arc(at * PX, r_m * PX, a0, a0 + TAU / n * 0.55, 6, col, w)
