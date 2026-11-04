class_name GunFxArt
extends RefCounted
## Lane gunplay: GunFx in the D5 ink (world pixels via Ink.px, drawn by quest 1's FxView on the
## print layer). Per weapon (gun_fx.json): the muzzle flash (a heavy single shot = a long flare
## with two side jets; an automatic = a star that turns every shot), the tracer's weight, gun
## smoke, shells and magazines, and the impacts: a dust puff and an ink scuff on the ground,
## cream sparks on metal and on Rivet's plating, an ink burst on a body (the blood is red, from
## the combat blood). The reload shows as a ring filling around the claw.

const SMOKE: Color = Color(0.090, 0.075, 0.106, 0.55)
const SCUFF: Color = Color(0.090, 0.075, 0.106, 0.55)
## A tracer's tail never reaches back past the muzzle (a round leaves radius + 0.1 m out; the
## flash sits at radius + 0.45 m), and its head meets the sim's line CONVERGE_M out.
const MUZZLE_BACK_M: float = 0.35
const CONVERGE_M: float = 3.0


static func draw_under(ci: CanvasItem, fx: GunFx, tick: int) -> void:
	for i: int in fx.impacts.size():
		var im: Vector4 = fx.impacts[i]
		if int(im.z) == GunFx.Hit.GROUND:
			_scuff(ci, Vector2(im.x, im.y), fx.impact_dir[i], tick - int(im.w), int(im.w))
	for i: int in fx.bits.size():
		_bit(ci, fx, i)


static func draw_over(ci: CanvasItem, fx: GunFx, arena: CombatArena, tick: int) -> void:
	for sm: Vector4 in fx.smoke:
		var age: float = float(tick - int(sm.z)) / float(GunFx.SMOKE_TICKS)
		var at: Vector2 = Vector2(sm.x, sm.y) + Vector2(0.15, -0.6) * age
		var c: Color = Color(SMOKE, SMOKE.a * (1.0 - age))
		ci.draw_circle(Ink.px(at), (0.18 + 0.32 * age) * sm.w * Ink.PX_PER_M, c)
	for i: int in fx.impacts.size():
		var im: Vector4 = fx.impacts[i]
		var age: int = tick - int(im.w)
		if age < GunFx.IMPACT_TICKS:
			_impact(ci, fx, Vector2(im.x, im.y), fx.impact_dir[i], int(im.z), age)
	for ef: Vector4 in fx.enemy_flashes:
		_star(ci, Vector2(ef.x, ef.y), ef.w, 0.45 - 0.1 * float(tick - int(ef.z)), tick)
	var gun: GunHand = arena.gun
	var row: Dictionary = fx.look(gun.trigger.spec.id)
	var flash: int = row.get("muzzle_ticks", 2)
	if tick - fx.fired_tick < flash and fx.fired_count > 0:
		_muzzle(ci, fx, arena.rivet, row, tick - fx.fired_tick)
	if gun.trigger.reloading():
		var k: float = (
			1.0 - float(gun.trigger.reload_left) / maxf(gun.trigger.spec.reload_ticks, 1.0)
		)
		var at: Vector2 = Ink.px(arena.rivet.pos + Vector2(0.0, -1.5))
		ci.draw_arc(at, 11.0, 0.0, TAU, 24, Ink.INK, 7.0)
		ci.draw_arc(at, 11.0, -PI / 2.0, -PI / 2.0 + TAU * k, 24, Ink.CREAM, 3.5)


## A table bullet's tracer at its weapon's weight: ink casing, cream core, a cream head; an enemy
## round keeps the vermilion core (danger) and its short tail.
static func tracer(ci: CanvasItem, fx: GunFx, s: Shot, enemy_tail_m: float) -> void:
	var row: Dictionary = fx.look(s.spec.id if s.spec != null else &"")
	var tail_m: float = s.spec.tracer_len_m if s.from_rivet and s.spec != null else enemy_tail_m
	var w: float = row.get("tracer_px", 9.0) if s.from_rivet else 9.0
	var core_w: float = row.get("tracer_core_px", 4.0) if s.from_rivet else 4.0
	var core: Color = Ink.CREAM if s.from_rivet else Ink.VERMILION
	var dir: Vector2 = s.vel.normalized()
	var head: Vector2 = s.pos
	if s.from_rivet:
		# never behind the muzzle, and from the claw side onto the sim's line over CONVERGE_M
		var went: float = s.origin.distance_to(s.pos)
		tail_m = clampf(went - MUZZLE_BACK_M, 0.05, tail_m)
		var side: float = fx.p.get("claw_side_m", 0.0)
		head -= dir.orthogonal() * side * clampf(1.0 - went / CONVERGE_M, 0.0, 1.0)
	var tail: Vector2 = head - dir * tail_m
	ci.draw_line(Ink.px(tail), Ink.px(head), Ink.INK, w)
	ci.draw_line(Ink.px(tail.lerp(head, 0.3)), Ink.px(head), core, core_w)
	ci.draw_circle(Ink.px(head), core_w + 1.0, core)


## A heavy single shot (spikes 3): a long forward flare, two side jets, a short back lip. An
## automatic (spikes 4+): a star whose points turn half a step every shot, so a burst strobes.
static func _muzzle(ci: CanvasItem, fx: GunFx, r: Fighter, row: Dictionary, age: int) -> void:
	var f: Vector2 = r.facing.normalized()
	var at: Vector2 = fx.muzzle(r, 0.45)
	var count: int = fx.fired_count
	var shrink: float = 1.0 - 0.25 * float(age)
	var fwd: float = row.get("muzzle_m", 0.7)
	var side: float = row.get("muzzle_side_m", 0.3)
	fwd *= shrink
	side *= shrink
	var spikes: int = row.get("spikes", 4)
	var star: Array[Vector2] = []
	if spikes == 3:
		for a: Vector2 in [
			Vector2(0.0, fwd),
			Vector2(0.3, 0.16),
			Vector2(PI / 2.0, side),
			Vector2(2.3, 0.12),
			Vector2(PI, 0.14),
			Vector2(-2.3, 0.12),
			Vector2(-PI / 2.0, side),
			Vector2(-0.3, 0.16)
		]:
			star.append(a)
	else:
		var turn: float = (PI / float(spikes)) * float(count % 2)
		for i: int in spikes * 2:
			var k: float = (fwd if i == 0 else side) if i % 2 == 0 else 0.15
			star.append(Vector2(TAU * float(i) / float(spikes * 2) + turn, k))
	var pts: PackedVector2Array = PackedVector2Array()
	for a: Vector2 in star:
		@warning_ignore("return_value_discarded")
		pts.append(Ink.px(at + Vector2.from_angle(f.angle() + a.x) * a.y))
	_flash(ci, pts, 3.5)
	ci.draw_circle(Ink.px(at), 0.16 * Ink.PX_PER_M, Ink.CREAM)


## A hostile's muzzle: a small cream 4-point star in an ink rim along its aim.
static func _star(ci: CanvasItem, at: Vector2, ang: float, r: float, tick: int) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in 8:
		var k: float = r if i % 2 == 0 else r * 0.3
		@warning_ignore("return_value_discarded")
		pts.append(
			Ink.px(at + Vector2.from_angle(ang + TAU * float(i) / 8.0 + 0.1 * float(tick % 2)) * k)
		)
	_flash(ci, pts, 3.0)


## A cream flash polygon in an ink rim of `rim` px.
static func _flash(ci: CanvasItem, pts: PackedVector2Array, rim: float) -> void:
	var ring: PackedVector2Array = pts.duplicate()
	@warning_ignore("return_value_discarded")
	ring.append(pts[0])
	ci.draw_colored_polygon(pts, Ink.CREAM)
	ci.draw_polyline(ring, Ink.INK, rim, true)


static func _bit(ci: CanvasItem, fx: GunFx, i: int) -> void:
	var b: Vector4 = fx.bits[i]
	var age: int = fx.bit_life[i]
	var fade: float = clampf(1.0 - float(age - int(b.z)) / 30.0, 0.0, 1.0)
	var hop: float = 0.0
	if age < GunFx.HOP_TICKS:
		var t: float = float(age) / float(GunFx.HOP_TICKS)
		hop = 0.55 * 4.0 * t * (1.0 - t)
	elif age < GunFx.HOP_TICKS + 8:
		var t2: float = float(age - GunFx.HOP_TICKS) / 8.0
		hop = 0.12 * 4.0 * t2 * (1.0 - t2)
	var at: Vector2 = Vector2(b.x, b.y - hop)
	var spin: float = float(mini(age, GunFx.HOP_TICKS + 8)) * 0.7 + float(i)
	var half: Vector2 = Vector2.from_angle(spin) * absf(b.w) * 0.5
	var mag: bool = b.w < 0.0
	var body: Color = Ink.INK if mag else fx.color("casing")
	ci.draw_line(Ink.px(at - half), Ink.px(at + half), Color(Ink.INK, fade), 12.0 if mag else 9.0)
	ci.draw_line(Ink.px(at - half * 0.7), Ink.px(at + half * 0.7), Color(body, fade), 5.0)


static func _scuff(ci: CanvasItem, at: Vector2, dir: Vector2, age: int, seed_tick: int) -> void:
	var fade: float = clampf(float(GunFx.SCUFF_TICKS - age) / 60.0, 0.0, 1.0)
	var c: Color = Color(SCUFF, SCUFF.a * fade)
	ci.draw_line(Ink.px(at - dir * 0.25), Ink.px(at + dir * 0.1), c, 6.0)
	for k: int in 4:
		var h: float = NoirPack.hash01(seed_tick * 31 + k)
		var off: Vector2 = dir.rotated(-0.9 + 1.8 * h) * (0.18 + 0.12 * float(k % 2))
		ci.draw_circle(Ink.px(at + off), 2.0 + 1.5 * float(k % 2), c)


## The moment a round stops: dust kicked back along the shot on the ground, cream sparks on
## metal and on Rivet's plating, a small ink burst on a body.
static func _impact(
	ci: CanvasItem, fx: GunFx, at: Vector2, dir: Vector2, kind: int, age: int
) -> void:
	var k: float = float(age) / float(GunFx.IMPACT_TICKS)
	if kind == GunFx.Hit.GROUND:
		var dust: Color = fx.color("dust")
		for j: int in 4:
			var d: Vector2 = (-dir).rotated(-0.8 + 0.53 * float(j)) * (0.15 + 0.5 * k)
			ci.draw_circle(
				Ink.px(at + d), (0.1 + 0.12 * k) * Ink.PX_PER_M, Color(dust, 0.8 * (1.0 - k))
			)
		return
	if kind == GunFx.Hit.BODY:
		if age < 4:
			ci.draw_circle(Ink.px(at), (0.22 - 0.03 * float(age)) * Ink.PX_PER_M, Ink.INK)
		return
	var spark: Color = fx.color("spark")
	for j: int in 6:
		var d: Vector2 = (-dir).rotated(-1.3 + 0.52 * float(j)) * (0.2 + 0.7 * k)
		var tip: Vector2 = at + d
		ci.draw_line(Ink.px(at + d * 0.55), Ink.px(tip), Ink.INK, 5.0)
		ci.draw_line(Ink.px(at + d * 0.6), Ink.px(tip), spark, 2.5)
	if age < 3:
		ci.draw_circle(Ink.px(at), 0.18 * Ink.PX_PER_M, spark)
