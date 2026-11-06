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
## The carried parcel is a kraft box slung under the drone (the sheet's), drawn under the sprite so
## it shows round the hub and through the rotors, and it falls into its ring as the same box (its
## shadow closing in as it lands). false = it16: a cream square on the hub, no falling box.
const SLUNG_PARCEL: bool = true
## The slung box's side (m); the landed crate is ServoTuning.crate_m.
const PARCEL_M: float = 0.62
## How far the slung box hangs under the drone (m): drawn that much toward the drone's shadow, so
## it peeks out from under the hub on the shadow side.
const SLING_M: float = 0.5

## Pixels per metre of the canvas drawn on (32 in the dev view, Ink.PX_PER_M in the arena).
var px: float = 32.0
var pal: PaletteTokens = PaletteTokens.shared()
var drone_tex: Texture2D = load(ServoArt.path(&"drone")) as Texture2D
var crate_tex: Texture2D = load(ServoRig.ART % "crate") as Texture2D


## The ground layer: drop rings, falling-parcel fills, blast scorches, crates.
func parcels(c: CanvasItem, s: ServoSwarm) -> void:
	var verm: Color = pal.color(&"vermilion")
	for d: ServoDrone in s.drones:
		if d.carrying() and (s.tuning.ring_from_launch or d.state == ServoDrone.State.HOVER):
			_dashed_ring(c, d.goal, s.tuning.ring_m, Color(verm, 0.8), 3.0)
	for d: ServoDrone in s.drones:
		if d.dive and (d.state == ServoDrone.State.HOVER or d.state == ServoDrone.State.DIVE):
			_dive_tell(c, s, d)
	for p: ServoParcels.Parcel in s.parcels.falling:
		var k: float = 1.0 - float(p.fall_left) / p.fall_total
		c.draw_circle(p.pos * px, s.tuning.ring_m * px * k, Color(verm, 0.28))
		_dashed_ring(c, p.pos, s.tuning.ring_m, verm, 3.0)
		if SLUNG_PARCEL:
			_falling_box(c, p.pos, k, s.tuning)
	for b: ServoParcels.Blast in s.parcels.booms:
		_boom(c, b.pos * px, b.radius_m * px, 1.0 - float(b.life_left) / ServoParcels.BOOM_TICKS)
	for d: ServoParcels.Parcel in s.parcels.debris:
		_debris(c, d.pos, 1.0 - float(d.life_left) / ServoParcels.DEBRIS_TICKS, s.tuning.crate_m)
	for cr: ServoParcels.Parcel in s.parcels.crates:
		var half: float = s.tuning.crate_m * 0.5 * px
		var box: Rect2 = Rect2(cr.pos * px - Vector2(half, half), Vector2(half, half) * 2.0)
		c.draw_rect(box.grow(2.0), Color(pal.color(&"ink"), 0.35))
		var k: float = px / SimConst.PX_PER_M  # d8: under a tilt the crate stands up as a box
		if not ServoCrateStack.draw(c, cr.pos * px, half * 2.0, crate_tex, k):
			_sprite(c, crate_tex, cr.pos * px, 0.0, 1.0)
		ServoCrateStack.label(c, box, px, pal.color(&"ink"), k)


## A crate the rotor dash smashed: six cardboard shards fly out over a dust puff, k 0..1.
func _debris(c: CanvasItem, at: Vector2, k: float, crate_m: float) -> void:
	var fade: float = 1.0 - k
	c.draw_circle(at * px, crate_m * (0.6 + 0.8 * k) * px, Color(pal.color(&"paper_2"), 0.5 * fade))
	var shard: Vector2 = Vector2(0.22, 0.12) * px
	for i: int in 6:
		var dir: Vector2 = Vector2.from_angle(TAU * i / 6.0 + at.x)
		var p: Vector2 = (at + dir * crate_m * (0.3 + 1.4 * k)) * px
		c.draw_set_transform(p, dir.angle() + k * 6.0 + i, Vector2.ONE)
		c.draw_rect(Rect2(-shard * 0.5, shard), Color(pal.color(&"paper"), fade))
		c.draw_rect(Rect2(-shard * 0.5, shard), Color(pal.color(&"ink"), fade), false, 1.5)
	c.draw_set_transform(Vector2.ZERO)


## A bomb's or a dive's blast, k 0..1: an ink scorch, a shock ring out to the blast radius and
## Dent's car-bomb fireball (amber, cream-hot core, ink rim; no red: red is blood only).
func _boom(c: CanvasItem, at: Vector2, r: float, k: float) -> void:
	var fade: float = 1.0 - k
	var grow: float = 1.0 - pow(1.0 - k, 3.0)
	c.draw_circle(at, r * 0.6, Color(pal.color(&"ink"), 0.35 * fade))
	c.draw_arc(
		at, r * grow, 0.0, TAU, 40, Color(DentView.INK, fade), lerpf(8.0, 2.0, k) * _line_k()
	)
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in 18:
		var reach: float = r * 0.7 * grow * (1.0 if i % 2 == 0 else 0.62)
		@warning_ignore("return_value_discarded")
		pts.push_back(at + Vector2.from_angle(TAU * i / 18.0 + 0.2 * sin(i * 2.3)) * reach)
	c.draw_colored_polygon(pts, Color(DentView.FIRE, 0.9 * fade))
	@warning_ignore("return_value_discarded")
	pts.append(pts[0])
	c.draw_polyline(pts, Color(DentView.INK, fade), 2.5 * _line_k())
	c.draw_circle(at, r * 0.3 * grow * (1.0 - 0.5 * k), Color(DentView.HOT, fade))


## A kamikaze's dive line: thin while its strike point tracks Rivet, thick with the blast ring
## once it locks (the dodge cue).
func _dive_tell(c: CanvasItem, s: ServoSwarm, d: ServoDrone) -> void:
	var verm: Color = pal.color(&"vermilion")
	var lock: bool = ServoDive.locked(s, d)
	var w: float = (4.0 if lock else 1.5) * _line_k()
	c.draw_line(d.pos * px, d.strike * px, Color(verm, 0.95 if lock else 0.5), w)
	if lock:
		c.draw_circle(d.strike * px, s.tuning.dive_blast_m * px, Color(verm, 0.18))
		_dashed_ring(c, d.strike, s.tuning.dive_blast_m, verm, 3.0)


## Servo's own telegraphs (attacks with shape "none" in bosses.json; the framework's BossTellView
## draws the dash lane and the beam line from BossZone).
func tells(c: CanvasItem, f: BossFight, m: ServoMoves) -> void:
	if f.attack == null or f.state != BossFight.State.WINDUP:
		return
	var verm: Color = pal.color(&"vermilion")
	var w: float = 5.0 if f.locked else 1.5
	match f.attack.id:
		&"scan_drop", &"kamikaze", &"package_carpet":
			c.draw_line(f.body.pos * px, m.mark * px, Color(verm, 0.9), w * _line_k())
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
		if SLUNG_PARCEL and d.carrying():
			_box(c, p + SHADOW * SLING_M * px, rot, PARCEL_M)
		_sprite(c, drone_tex, p, rot, DRONE_K)
		if d.dive:  # the broken rack's drones spark (danger)
			var spark: Vector2 = Vector2.from_angle(float(d.age) * 2.3) * px * 0.3
			c.draw_circle(p + spark, px * 0.07, pal.color(&"vermilion"))
		if d.carrying() and not SLUNG_PARCEL:
			var h: float = px * 0.2
			c.draw_rect(Rect2(p - Vector2(h, h), Vector2(h, h) * 2.0), pal.color(&"paper_2"))
			c.draw_rect(
				Rect2(p - Vector2(h, h), Vector2(h, h) * 2.0), pal.color(&"ink"), false, 1.0
			)


## A dropped parcel, k 0..1 through its fall: the slung box grows to the crate's size over its
## shadow, which closes in from where the drone's was.
func _falling_box(c: CanvasItem, at: Vector2, k: float, t: ServoTuning) -> void:
	var side: float = lerpf(PARCEL_M, t.crate_m, k)
	var sh: Vector2 = (at + SHADOW * t.fly_h_m * (1.0 - k)) * px
	var half: Vector2 = Vector2.ONE * side * 0.5 * px
	c.draw_rect(Rect2(sh - half, half * 2.0), Color(pal.color(&"ink"), 0.3 + 0.2 * k))
	_box(c, (at + SHADOW * SLING_M * (1.0 - k)) * px, 0.0, side)


## A kraft parcel `side_m` wide at `at_px`: an ink edge, then the crate art.
func _box(c: CanvasItem, at_px: Vector2, rot: float, side_m: float) -> void:
	if crate_tex == null:
		return
	var half: Vector2 = Vector2.ONE * (side_m * 0.5 * px + 1.0)
	c.draw_set_transform(at_px, rot)
	c.draw_rect(Rect2(-half, half * 2.0), pal.color(&"ink"))
	c.draw_set_transform(Vector2.ZERO)
	_sprite(c, crate_tex, at_px, rot, side_m * ServoRig.ART_PPM / crate_tex.get_width())


func _sprite(c: CanvasItem, t: Texture2D, at_px: Vector2, rot: float, k: float) -> void:
	if t == null:
		return
	c.draw_set_transform(at_px, rot, Vector2.ONE * k * px / ServoRig.ART_PPM)
	c.draw_texture(t, -t.get_size() * 0.5)
	c.draw_set_transform(Vector2.ZERO)


func _dashed_ring(c: CanvasItem, at: Vector2, r_m: float, col: Color, w: float) -> void:
	w *= _line_k()
	var n: int = 16
	for k: int in n:
		var a0: float = TAU * k / n
		c.draw_arc(at * px, r_m * px, a0, a0 + TAU / n * 0.55, 6, col, w)


## Line widths are screen pixels at 32 px/m: a canvas drawn at more px/m and scaled down (the
## arena's 48) widens them by as much, so a ring weighs the same on screen in every view.
func _line_k() -> float:
	return px / 32.0
