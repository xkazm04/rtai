class_name ServoDraw
extends RefCounted
## Servo's swarm on screen, shared by the arena view (ServoBodyView) and the dev view: drop rings
## filling as parcels fall, blasts, CS crates, the drones over their ink shadows, and Servo's own
## tells (the beam to the mark, the lock ring, the carpet lane, the bay-hop ring). Shapes in metres
## x `px`. Vermilion only for danger (beam, rings, lanes); ink shadows. Render only (SIM-03).

const SHADOW: Vector2 = Vector2(0.25, 0.35)
## The drone sprite drawn this much over its art size (a 0.7 m drone is ~22 px at 32 px/m: too
## small to read over the yard).
const DRONE_K: float = 1.4

## Pixels per metre of the canvas drawn on (32 in the dev view, Ink.PX_PER_M in the arena).
var px: float = 32.0
var pal: PaletteTokens = PaletteTokens.shared()
var drone_tex: Texture2D = load(ServoRig.ART % "drone") as Texture2D
var crate_tex: Texture2D = load(ServoRig.ART % "crate") as Texture2D


## The ground layer: drop rings, falling-parcel fills, blast scorches, crates.
func parcels(c: CanvasItem, s: ServoSwarm) -> void:
	var verm: Color = pal.color(&"vermilion")
	for d: ServoDrone in s.drones:
		if d.carrying() and (s.tuning.ring_from_launch or d.state == ServoDrone.State.HOVER):
			_dashed_ring(c, d.goal, s.tuning.ring_m, Color(verm, 0.7), 2.0)
	for p: ServoParcels.Parcel in s.parcels.falling:
		var k: float = 1.0 - float(p.fall_left) / p.fall_total
		c.draw_circle(p.pos * px, s.tuning.ring_m * px * k, Color(verm, 0.28))
		_dashed_ring(c, p.pos, s.tuning.ring_m, verm, 3.0)
	for b: ServoParcels.Blast in s.parcels.blasts:
		c.draw_circle(b.pos * px, b.radius_m * px, Color(pal.color(&"ink"), 0.55))
	for cr: ServoParcels.Parcel in s.parcels.crates:
		var half: float = s.tuning.crate_m * 0.5 * px
		var box: Rect2 = Rect2(cr.pos * px - Vector2(half, half), Vector2(half, half) * 2.0)
		c.draw_rect(box.grow(2.0), Color(pal.color(&"ink"), 0.35))
		_sprite(c, crate_tex, cr.pos * px, 0.0, 1.0)
		var font_px: int = int(px * 0.32)
		c.draw_string(
			ThemeDB.fallback_font,
			box.get_center() + Vector2(-font_px * 0.6, font_px * 0.35),
			"CS",
			0,
			-1,
			font_px,
			pal.color(&"ink")
		)


## Servo's own telegraphs (attacks with shape "none" in bosses.json; the framework's BossTellView
## draws the dash lane and the beam line from BossZone).
func tells(c: CanvasItem, f: BossFight, m: ServoMoves) -> void:
	if f.attack == null or f.state != BossFight.State.WINDUP:
		return
	var verm: Color = pal.color(&"vermilion")
	var w: float = 5.0 if f.locked else 1.5
	match f.attack.id:
		&"scan_drop", &"kamikaze", &"package_carpet":
			c.draw_line(f.body.pos * px, m.mark * px, Color(verm, 0.9), w)
			if f.locked:
				_dashed_ring(c, m.mark, 1.0, verm, 4.0)
			if f.attack.id == &"package_carpet":
				_lane(c, m, f.aim, f.locked)
		&"bay_hop":
			_dashed_ring(c, m.mark, f.attack.range_m, verm, w)


## The carpet's painted lane: one stripe per drop ring along the aim through the mark.
func _lane(c: CanvasItem, m: ServoMoves, aim: Vector2, locked: bool) -> void:
	var n: int = m.swarm.tuning.phase(m.swarm.phase).wave
	var r: float = m.swarm.tuning.ring_m
	var col: Color = Color(pal.color(&"vermilion"), 0.22 if locked else 0.1)
	for at: Vector2 in ServoMoves.carpet(m.mark, aim, n):
		c.draw_circle(at * px, r * px, col)


## The air layer: each drone over its shadow (higher = the shadow further off), rotors and the
## slung parcel; tilted toward its velocity.
func drones(c: CanvasItem, s: ServoSwarm) -> void:
	for d: ServoDrone in s.drones:
		var sh: Vector2 = (d.pos + SHADOW * d.height) * px
		c.draw_circle(sh, 0.35 * px, Color(pal.color(&"ink"), 0.35))
	for d: ServoDrone in s.drones:
		var p: Vector2 = d.pos * px
		var rot: float = d.vel.angle() - PI / 2 if d.vel.length() > 0.5 else 0.0
		_sprite(c, drone_tex, p, rot, DRONE_K)
		if d.carrying():
			var h: float = px * 0.2
			c.draw_rect(Rect2(p - Vector2(h, h), Vector2(h, h) * 2.0), pal.color(&"paper_2"))
			c.draw_rect(
				Rect2(p - Vector2(h, h), Vector2(h, h) * 2.0), pal.color(&"ink"), false, 1.0
			)


func _sprite(c: CanvasItem, t: Texture2D, at_px: Vector2, rot: float, k: float) -> void:
	if t == null:
		return
	c.draw_set_transform(at_px, rot, Vector2.ONE * k * px / ServoRig.ART_PPM)
	c.draw_texture(t, -t.get_size() * 0.5)
	c.draw_set_transform(Vector2.ZERO)


func _dashed_ring(c: CanvasItem, at: Vector2, r_m: float, col: Color, w: float) -> void:
	var n: int = 16
	for k: int in n:
		var a0: float = TAU * k / n
		c.draw_arc(at * px, r_m * px, a0, a0 + TAU / n * 0.55, 6, col, w)
