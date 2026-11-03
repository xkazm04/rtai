class_name BodyContact
extends RefCounted
## One contact between two bodies outside the city sim (robots, bosses, quest people): circle vs
## circle, sizes and the result from the body table. A shove splits the overlap by mass (the
## attacker moves defender/(a+d) of it back, the defender the rest); `blocked` stops the attacker
## at contact (the defender holds; the attacker's speed into it is removed, its tangent kept so it
## slides along, the wall rule); stagger and knockdown push the defender clear and report the
## rule's knockback for the caller's state. The city sim's people use the same table
## through RivetBody (sim_core/src/body.cpp), not this class.

## "" when the bodies do not touch (or no rule covers the pair).
var result: StringName = &""
var a_pos: Vector2 = Vector2.ZERO
var b_pos: Vector2 = Vector2.ZERO
var a_vel: Vector2 = Vector2.ZERO
var knockback_m: float = 0.0
var down_s: float = 0.0


static func resolve(
	table: BodyTable, a: StringName, b: StringName, ab_pos: PackedVector2Array, vel: Vector2
) -> BodyContact:
	var c: BodyContact = BodyContact.new()
	c.a_pos = ab_pos[0]
	c.b_pos = ab_pos[1]
	c.a_vel = vel
	var rs: float = table.radius(a) + table.radius(b)
	var delta: Vector2 = c.b_pos - c.a_pos
	var d: float = delta.length()
	var rule: BodyRule = table.rule(a, b)
	if d >= rs or rule == null:
		return c
	var n: Vector2 = delta / d if d > 1e-6 else Vector2.RIGHT
	var closing: float = vel.dot(n)
	c.result = rule.result(closing, table.tackle_mps)
	var pen: float = rs - d
	var share: float = table.share(a, b)
	if c.result == &"blocked":
		share = 0.0
	elif c.result == &"stagger" or c.result == &"knockdown":
		share = 1.0
		c.knockback_m = rule.knockback_m
		c.down_s = rule.down_s
	c.b_pos += n * pen * share
	c.a_pos -= n * pen * (1.0 - share)
	if c.result == &"blocked" and closing > 0.0:
		c.a_vel -= n * closing
	return c
