class_name GunFxArt
extends RefCounted
## Lane gunplay: GunFx in the D5 ink (world pixels via Ink.px, drawn by quest 1's FxView on the
## print layer). Per weapon (gun_fx.json): the muzzle flash (a heavy single shot = a long flare
## with two side jets; an automatic = a star that turns every shot), the tracer's weight, gun
## smoke, shells and magazines, and the impacts: a dust puff and an ink scuff on the ground,
## cream sparks on metal and on Rivet's plating, an ink burst on a body (the blood is red, from
## the combat blood). The reload shows as a ring filling around the claw.

const SMOKE: Color = Color(0.090, 0.075, 0.106, 0.55)
## A tracer's tail never reaches back past the muzzle (a round leaves radius + 0.1 m out; the
## flash sits at radius + 0.45 m), and its head meets the sim's line CONVERGE_M out.
const MUZZLE_BACK_M: float = 0.35
const CONVERGE_M: float = 3.0
## A heavy gun's shock ring (gun_fx.json ring_m) opens over this many ticks.
const RING_TICKS: int = 9


## Floor marks. FxView draws above the actor layer, so a burnt ring is left only where an energy
## round stopped on the ground or metal: on a body it would print over the corpse's chest (the
## body's mark is its blood; the pop still bursts there in draw_over).
## `shells` false = another art lane draws the brass; `mags` false = it draws the magazine too.
## `ground` false = FxGround keeps the scorch and scuffs (perf-city), only the bits draw here.
static func draw_under(
	ci: CanvasItem,
	fx: GunFx,
	tick: int,
	shells: bool = true,
	mags: bool = true,
	ground: bool = true
) -> void:
	if ground:
		_ground(ci, fx, tick)
	for i: int in fx.bits.size():
		if mags if fx.bits[i].w < 0.0 else shells:
			GunFxMarks.bit(ci, fx, i)


static func _ground(ci: CanvasItem, fx: GunFx, tick: int) -> void:
	fx.scorch.draw(ci, tick)
	for i: int in fx.impacts.size():
		var im: Vector4 = fx.impacts[i]
		if int(im.z) >= GunFx.SCORCH and int(im.z) % GunFx.SCORCH != GunFx.Hit.BODY:
			GunFxMarks.scorch(ci, Vector2(im.x, im.y), tick - int(im.w))
		elif int(im.z) == GunFx.Hit.GROUND:
			GunFxMarks.scuff(ci, Vector2(im.x, im.y), fx.impact_dir[i], tick - int(im.w), int(im.w))


## `muzzle` false = Rivet's flash is drawn by another art lane (smoke, impacts stay).
static func draw_over(
	ci: CanvasItem, fx: GunFx, arena: CombatArena, tick: int, muzzle: bool = true
) -> void:
	for sm: Vector4 in fx.smoke:
		var age: float = float(tick - int(sm.z)) / float(GunFx.SMOKE_TICKS)
		var at: Vector2 = Vector2(sm.x, sm.y) + Vector2(0.15, -0.6) * age
		var c: Color = Color(SMOKE, SMOKE.a * (1.0 - age))
		ci.draw_circle(Ink.px(at), (0.18 + 0.32 * age) * sm.w * Ink.PX_PER_M, c)
	for i: int in fx.impacts.size():
		var im: Vector4 = fx.impacts[i]
		var age: int = tick - int(im.w)
		if age < GunFx.IMPACT_TICKS:
			var at: Vector2 = Vector2(im.x, im.y)
			GunFxMarks.impact(ci, fx, at, fx.impact_dir[i], int(im.z) % GunFx.SCORCH, age)
			if int(im.z) >= GunFx.SCORCH:
				GunFxMarks.pop(ci, at, age)
	for ef: Vector4 in fx.enemy_flashes:
		_star(ci, Vector2(ef.x, ef.y), ef.w, 0.45 - 0.1 * float(tick - int(ef.z)), tick)
	var gun: GunHand = arena.gun
	var row: Dictionary = fx.look(gun.trigger.spec.id)
	var flash: int = row.get("muzzle_ticks", 2)
	if muzzle and tick - fx.fired_tick < flash and fx.fired_count > 0:
		_muzzle(ci, fx, arena.rivet, row, tick - fx.fired_tick)
	var ring_m: float = row.get("ring_m", 0.0)
	if ring_m > 0.0 and tick - fx.fired_tick < RING_TICKS and fx.fired_count > 0:
		var k: float = float(tick - fx.fired_tick + 1) / float(RING_TICKS)
		var at_px: Vector2 = Ink.px(fx.muzzle(arena.rivet, 0.45))
		ci.draw_arc(at_px, ring_m * k * Ink.PX_PER_M, 0.0, TAU, 32, Ink.INK, 14.0 * (1.0 - k) + 3.0)
		ci.draw_arc(
			at_px, ring_m * k * Ink.PX_PER_M, 0.0, TAU, 32, Ink.CREAM, 4.0 * (1.0 - k) + 1.0
		)
	_claw_state(ci, fx, arena, tick)
	FightShardArt.stuck(ci, fx, arena)


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
	var bolt: float = row.get("bolt_px", 0.0) if s.from_rivet else 0.0
	if bolt > 0.0:
		_bolt(ci, tail, head, bolt, s.origin.distance_to(s.pos))
		return
	ci.draw_line(Ink.px(tail), Ink.px(head), Ink.INK, w)
	ci.draw_line(Ink.px(tail.lerp(head, 0.3)), Ink.px(head), core, core_w)
	ci.draw_circle(Ink.px(head), core_w + 1.0, core)


## A heavy single shot (spikes 3): a long forward flare, two side jets, a short back lip. An
## automatic (spikes 4+): a star whose points turn half a step every shot, so a burst strobes.
static func _muzzle(ci: CanvasItem, fx: GunFx, r: Fighter, row: Dictionary, age: int) -> void:
	var f: Vector2 = r.facing.normalized()
	var at: Vector2 = fx.muzzle(r, 0.45)
	var shrink: float = 1.0 - 0.25 * float(age)
	var fwd: float = row.get("muzzle_m", 0.7)
	var side: float = row.get("muzzle_side_m", 0.3)
	fwd *= shrink
	side *= shrink
	var spikes: int = row.get("spikes", 4)
	if spikes == 0:  # an energy gun
		_sun(ci, at, fwd, fx.fired_count)
		return
	var star: Array[Vector2] = []
	if spikes == 3:
		var fat: float = row.get("fat", 1.0)
		for a: Vector2 in [
			Vector2(0.0, fwd),
			Vector2(0.3, 0.16 * fat),
			Vector2(PI / 2.0, side),
			Vector2(2.3, 0.12 * fat),
			Vector2(PI, 0.14),
			Vector2(-2.3, 0.12 * fat),
			Vector2(-PI / 2.0, side),
			Vector2(-0.3, 0.16 * fat)
		]:
			star.append(a)
	else:
		var turn: float = (PI / float(spikes)) * float(fx.fired_count % 2)
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
## A flare shrunk to a sliver (snapped points collapse) draws nothing (showcase REQUEST 18).
static func _flash(ci: CanvasItem, pts: PackedVector2Array, rim: float) -> void:
	if Geometry2D.triangulate_polygon(pts).is_empty():
		return
	var ring: PackedVector2Array = pts.duplicate()
	@warning_ignore("return_value_discarded")
	ring.append(pts[0])
	ci.draw_colored_polygon(pts, Ink.CREAM)
	ci.draw_polyline(ring, Ink.INK, rim, true)


## A plasma bolt: a cream teardrop (fat hot head, tail tapering back to a point) in an ink rim
## inside a soft cream glow, swelling and thinning on the distance flown, two sparks trailing.
static func _bolt(ci: CanvasItem, tail: Vector2, head: Vector2, w: float, went: float) -> void:
	var r: float = w * 0.5 * (1.0 + 0.22 * sin(went * 5.0))
	var hp: Vector2 = Ink.px(head)
	# an ink halo under a cream glow: the bolt reads on the cream paving and on grey concrete
	ci.draw_circle(hp, r * 2.8, Color(Ink.INK, 0.2))
	ci.draw_circle(hp, r * 2.1, Color(Ink.CREAM, 0.35))
	ci.draw_colored_polygon(_drop(hp, Ink.px(tail), r + 7.0), Ink.INK)
	ci.draw_colored_polygon(_drop(hp, Ink.px(tail.lerp(head, 0.12)), r), Ink.CREAM)
	ci.draw_circle(hp, r * 0.35, Color(Ink.INK, 0.6))
	var back: Vector2 = (Ink.px(tail) - hp).normalized()
	for k: int in 2:
		var off: Vector2 = back.orthogonal() * r * (1.2 if k == 0 else -1.0) * sin(went * 7.0 + k)
		ci.draw_circle(Ink.px(tail) + back * r * float(k + 1) + off, 2.5, Ink.CREAM)


## A teardrop: a half disc of radius r round `head` facing away from `tip`, closed at `tip`.
static func _drop(head: Vector2, tip: Vector2, r: float) -> PackedVector2Array:
	var back: float = (tip - head).angle()
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in 11:
		var a: float = back + PI / 2.0 + PI * float(i) / 10.0
		@warning_ignore("return_value_discarded")
		pts.append(head + Vector2.from_angle(a) * r)
	@warning_ignore("return_value_discarded")
	pts.append(tip)
	return pts


## An energy gun's muzzle: a 10-point cream burst in ink that turns every shot, a hot core.
static func _sun(ci: CanvasItem, at: Vector2, fwd: float, count: int) -> void:
	var sun: PackedVector2Array = PackedVector2Array()
	for i: int in 20:
		var k: float = fwd * (0.55 if i % 2 == 0 else 0.3)
		var a: float = TAU * float(i) / 20.0 + 0.3 * float(count % 3)
		@warning_ignore("return_value_discarded")
		sun.append(Ink.px(at + Vector2.from_angle(a) * k))
	_flash(ci, sun, 3.0)
	ci.draw_circle(Ink.px(at), fwd * 0.12 * Ink.PX_PER_M, Ink.INK)


## The claw's state: a charge gun's gathering crackle; the reload as a ring filling over Rivet.
static func _claw_state(ci: CanvasItem, fx: GunFx, arena: CombatArena, tick: int) -> void:
	var gun: GunHand = arena.gun
	if gun.trigger.charge > 0:
		FightChargeArt.crackle(ci, fx.muzzle(arena.rivet, 0.45), gun.trigger.charge_frac(), tick)
	if gun.trigger.spin > 0:  # the barrels winding up: a whirl at the muzzle (WeaponFxSpin)
		WeaponFxSpin.draw(ci, arena.rivet, gun, tick)
	if gun.trigger.reloading():
		var k: float = (
			1.0 - float(gun.trigger.reload_left) / maxf(gun.trigger.spec.reload_ticks, 1.0)
		)
		var at: Vector2 = Ink.px(arena.rivet.pos + Vector2(0.0, -1.5))
		ci.draw_arc(at, 11.0, 0.0, TAU, 24, Ink.INK, 7.0)
		ci.draw_arc(at, 11.0, -PI / 2.0, -PI / 2.0 + TAU * k, 24, Ink.CREAM, 3.5)
