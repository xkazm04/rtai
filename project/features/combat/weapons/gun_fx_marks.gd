class_name GunFxMarks
extends RefCounted
## Lane gunplay: what GunFx leaves on the floor, in the D5 ink (split out of GunFxArt): shells and
## magazines that hop and lie, the ink scuff of a round in the ground, and the moment a round
## stops (dust on the ground, sparks on metal and plating, an ink burst on a body, a plasma
## bolt's scorch ring).

const SCUFF: Color = Color(0.090, 0.075, 0.106, 0.55)


static func bit(ci: CanvasItem, fx: GunFx, i: int) -> void:
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


static func scuff(ci: CanvasItem, at: Vector2, dir: Vector2, age: int, seed_tick: int) -> void:
	var fade: float = clampf(float(GunFx.SCUFF_TICKS - age) / 60.0, 0.0, 1.0)
	var c: Color = Color(SCUFF, SCUFF.a * fade)
	ci.draw_line(Ink.px(at - dir * 0.25), Ink.px(at + dir * 0.1), c, 6.0)
	for k: int in 4:
		var h: float = NoirPack.hash01(seed_tick * 31 + k)
		var off: Vector2 = dir.rotated(-0.9 + 1.8 * h) * (0.18 + 0.12 * float(k % 2))
		ci.draw_circle(Ink.px(at + off), 2.0 + 1.5 * float(k % 2), c)


## The moment a round stops: dust kicked back along the shot on the ground, cream sparks on
## metal and on Rivet's plating, a small ink burst on a body.
static func impact(
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


## Where a plasma bolt stopped: a burnt ring in the ground that fades over SCUFF_TICKS.
static func scorch(ci: CanvasItem, at: Vector2, age: int) -> void:
	var fade: float = clampf(float(GunFx.SCUFF_TICKS - age) / 60.0, 0.0, 1.0)
	ci.draw_circle(Ink.px(at), 0.3 * Ink.PX_PER_M, Color(SCUFF, 0.7 * fade))
	ci.draw_arc(Ink.px(at), 0.36 * Ink.PX_PER_M, 0.0, TAU, 18, Color(Ink.INK, 0.8 * fade), 3.0)


## The moment a plasma bolt bursts: a cream ring in ink opening to 0.8 m and a hot core.
static func pop(ci: CanvasItem, at: Vector2, age: int) -> void:
	var k: float = float(age + 1) / float(GunFx.IMPACT_TICKS)
	var r: float = (0.2 + 0.6 * k) * Ink.PX_PER_M
	ci.draw_arc(Ink.px(at), r, 0.0, TAU, 24, Ink.INK, 10.0 * (1.0 - k) + 2.0)
	ci.draw_arc(Ink.px(at), r, 0.0, TAU, 24, Ink.CREAM, 5.0 * (1.0 - k) + 1.0)
	if age < 4:
		ci.draw_circle(Ink.px(at), 0.22 * Ink.PX_PER_M, Ink.CREAM)
