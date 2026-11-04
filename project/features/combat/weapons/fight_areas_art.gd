class_name FightAreasArt
extends RefCounted
## The real fight's area effects and table projectiles in the D5 ink (drawn by quest 1's FxView
## onto the print layer, world pixels via Ink.px): fire patches (the fx_fire loop over an ink
## scorch), burning humans, stunned sparks, blasts (cream flash, ink ring, smoke), chain arcs,
## and per kind the rocket (wobbling body, smoke trail), the flame puff (grows and fades), the
## electro bolt (a jumping zigzag) and the molotov (an arc over its ground shadow). Lane gunplay.

const ARC_TICKS: int = 12
const BLAST_TICKS: int = 30
const SMOKE: Color = Color(0.090, 0.075, 0.106, 0.55)
const SCORCH: Color = Color(0.090, 0.075, 0.106, 0.35)
const TRAIL_M: float = 4.0
const LOB_M: float = 2.2


static func draw(ci: CanvasItem, arena: CombatArena, tick: int) -> void:
	var a: FightAreas = arena.areas
	for i: int in a.patches.size():
		_patch(ci, a.patches[i], a.patch_ticks[i], tick)
	for h: Fighter in arena.hostiles:
		var e: FighterFx = a.effect(h)
		if e != null and h.alive():
			if e.burn_ticks > 0:
				_fire(ci, h.pos + Vector2(0.0, -0.45), 0.85, tick + h.id * 3, 1.0)
			if e.stun_ticks > 0:
				_stun(ci, h.pos, tick + h.id)
	for i: int in a.blasts.size():
		_blast(ci, a.blasts[i], tick - a.blast_ticks[i])
	for i: int in a.chain_arcs.size():
		if tick - a.arc_ticks[i] < ARC_TICKS:
			var arc: PackedVector2Array = a.chain_arcs[i]
			_bolt(ci, arc[0], arc[1], tick / 2 + i, 11.0, Ink.INK)
			_bolt(ci, arc[0], arc[1], tick / 2 + i, 4.5, Ink.CREAM)


## A table round that is not a plain bullet; false when the kind is drawn as a tracer instead.
static func shot(ci: CanvasItem, s: Shot, tick: int) -> bool:
	var dir: Vector2 = s.vel.normalized()
	var went: float = s.origin.distance_to(s.pos)
	match s.spec.kind:
		WeaponSpec.Kind.ROCKET:
			_rocket(ci, s.pos, dir, went, tick)
		WeaponSpec.Kind.CONE:
			var k: float = clampf(went / maxf(s.spec.range_m, 0.1), 0.0, 1.0)
			_fire(ci, s.pos, 0.4 + 0.75 * k, tick + int(went * 10.0), 1.0 - k * 0.5)
		WeaponSpec.Kind.BOLT:
			_bolt(ci, s.pos - dir * 2.0, s.pos, tick, 10.0, Ink.INK)
			_bolt(ci, s.pos - dir * 2.0, s.pos, tick, 4.0, Ink.CREAM)
			ci.draw_circle(Ink.px(s.pos), 7.0, Ink.INK)
			ci.draw_circle(Ink.px(s.pos), 4.0, Ink.CREAM)
		WeaponSpec.Kind.THROWN:
			_bottle(ci, s, went, tick)
		_:
			return false
	return true


static func _rocket(ci: CanvasItem, at: Vector2, dir: Vector2, went: float, tick: int) -> void:
	var side: Vector2 = dir.orthogonal()
	var head: Vector2 = at + side * sin(float(tick) * 0.9) * 0.1
	for k: int in 9:
		var back: float = 0.9 + float(k) * 0.5
		if back > minf(went, TRAIL_M):
			break
		var wob: Vector2 = side * sin(float(tick - k * 3) * 0.9) * 0.1 * float(k)
		var r: float = (0.16 + 0.08 * float(k)) * Ink.PX_PER_M
		var c: Color = SMOKE
		c.a *= 1.0 - float(k) / 9.0
		ci.draw_circle(Ink.px(at - dir * back + wob), r, c)
	_fire(ci, head - dir * 0.95, 0.2 + 0.04 * float(tick % 3), tick, 1.0)
	ci.draw_line(Ink.px(head - dir * 0.9), Ink.px(head - dir * 0.05), Ink.INK, 20.0)
	ci.draw_line(Ink.px(head - dir * 0.8), Ink.px(head - dir * 0.25), Ink.CREAM, 9.0)
	var fins: PackedVector2Array = PackedVector2Array(
		[
			Ink.px(head - dir * 0.95 + side * 0.22),
			Ink.px(head - dir * 0.6),
			Ink.px(head - dir * 0.95 - side * 0.22)
		]
	)
	ci.draw_polyline(fins, Ink.INK, 6.0, true)
	ci.draw_circle(Ink.px(head), 9.0, Ink.INK)


static func _bottle(ci: CanvasItem, s: Shot, went: float, tick: int) -> void:
	var f: float = clampf(went / maxf(went + s.left_m, 0.1), 0.0, 1.0)
	var lift: float = 4.0 * LOB_M * f * (1.0 - f)
	var shadow: Rect2 = Rect2(Ink.px(s.pos) - Vector2(14.0, 6.0), Vector2(28.0, 12.0))
	ci.draw_rect(shadow.grow(-2.0 * lift), SCORCH)
	var at: Vector2 = s.pos + Vector2(0.0, -lift)
	var spin: Vector2 = Vector2.from_angle(float(tick) * 0.5) * 0.22
	ci.draw_line(Ink.px(at - spin), Ink.px(at + spin), Ink.INK, 10.0)
	ci.draw_line(Ink.px(at - spin * 0.6), Ink.px(at + spin * 0.4), Ink.CREAM, 4.0)
	_fire(ci, at + spin * 1.3, 0.16, tick, 1.0)


static func _patch(ci: CanvasItem, p: Vector4, left: int, tick: int) -> void:
	var c: Vector2 = Vector2(p.x, p.y)
	var fade: float = clampf(float(left) / 30.0, 0.0, 1.0)
	ci.draw_circle(Ink.px(c), p.z * Ink.PX_PER_M, Color(SCORCH, SCORCH.a * (0.5 + fade * 0.5)))
	var n: int = maxi(ceili(p.z * 2.5), 1)
	for i: int in n:
		var ang: float = TAU * float(i) / float(n) + float(i) * 0.7
		var off: Vector2 = Vector2.from_angle(ang) * p.z * (0.25 + 0.4 * float(i % 2))
		_fire(ci, c + off, 0.6 + 0.15 * float(i % 3), tick + i * 5, fade)


## A rocket blast as a comic burst: a jagged cream star in a heavy ink rim (6 ticks), then an
## ink shock ring that grows and thins, smoke puffs rolling out and ink debris flung wide.
static func _blast(ci: CanvasItem, b: Vector3, age: int) -> void:
	if age >= BLAST_TICKS:
		return
	var c: Vector2 = Vector2(b.x, b.y)
	var k: float = float(age) / float(BLAST_TICKS)
	var r: float = b.z * Ink.PX_PER_M
	for i: int in 10:
		var dir: Vector2 = Vector2.from_angle(TAU * float(i) / 10.0 + 0.3 + float(i % 3) * 0.2)
		var puff: Vector2 = c + dir * b.z * (0.3 + 0.5 * k)
		ci.draw_circle(Ink.px(puff), r * (0.14 + 0.14 * k), Color(SMOKE, SMOKE.a * (1.0 - k)))
	if age < 8:
		var pts: Array[Vector2] = []
		for i: int in 17:
			var spike: float = (0.75 if i % 2 == 0 else 0.38) * (0.6 + 0.07 * float(age))
			pts.append(Ink.px(c + Vector2.from_angle(TAU * float(i) / 16.0 + 0.2) * b.z * spike))
		var star: PackedVector2Array = PackedVector2Array(pts)
		ci.draw_colored_polygon(star.slice(0, 16), Ink.CREAM)
		ci.draw_polyline(star, Ink.INK, 7.0, true)
	ci.draw_arc(Ink.px(c), r * (0.55 + 0.5 * k), 0.0, TAU, 48, Ink.INK, 10.0 * (1.0 - k) + 1.0)
	for i: int in 12:
		var dir: Vector2 = Vector2.from_angle(TAU * float(i) / 12.0 + float(i * 7 % 5) * 0.3)
		var fly: float = b.z * (0.4 + 1.1 * k) * (0.7 + 0.1 * float(i % 4))
		ci.draw_circle(Ink.px(c + dir * fly), 4.0 + float(i % 3) * 2.0, Ink.INK)


static func _stun(ci: CanvasItem, at: Vector2, tick: int) -> void:
	for i: int in 3:
		var ang: float = float(tick) * 0.3 + TAU * float(i) / 3.0
		var a: Vector2 = at + Vector2(0.0, -0.6) + Vector2.from_angle(ang) * 0.45
		var b: Vector2 = a + Vector2.from_angle(ang + 1.6) * 0.3
		Ink.zigzag(ci, a, b, 3, tick + i, Ink.INK)
		Ink.zigzag(ci, a, b, 3, tick + i + 2, Ink.CREAM)


## One frame of quest 1's fire loop (features/fx/art/fx_fire.png, 4 cells of 2.5 m), `scale` x.
static func _fire(ci: CanvasItem, at: Vector2, scale: float, tick: int, alpha: float) -> void:
	var tex: Texture2D = QuestArt.shared().texture(&"fx_fire")
	if tex == null:
		return
	var size: Vector2 = Vector2.ONE * 2.5 * scale * Ink.PX_PER_M
	var src: Rect2 = Rect2(Vector2(float((tick / 5) % 4), 0.0) * 256.0, Vector2(256.0, 256.0))
	ci.draw_texture_rect_region(
		tex, Rect2(Ink.px(at) - size * 0.5, size), src, Color(1, 1, 1, alpha)
	)


## An electric zigzag of `width` px (kinks every ~0.3 m, re-jagged every tick by `phase`).
static func _bolt(
	ci: CanvasItem, a: Vector2, b: Vector2, phase: int, width: float, c: Color
) -> void:
	var normal: Vector2 = (b - a).orthogonal().normalized()
	var kinks: int = maxi(ceili(a.distance_to(b) / 0.3), 2)
	var pts: Array[Vector2] = []
	for i: int in kinks + 1:
		var t: float = float(i) / float(kinks)
		var end: bool = i == 0 or i == kinks
		var jag: float = 0.0 if end else sin(float(phase * 7 + i * 13)) * 0.22
		pts.append(Ink.px(a.lerp(b, t) + normal * jag))
	ci.draw_polyline(PackedVector2Array(pts), c, width, true)
