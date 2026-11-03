class_name ArenaBodies
extends RefCounted
## Rivet against the fighters of a CombatArena (quest 1's stage, outside the city sim): after
## the arena step, every live hostile overlapping Rivet is resolved by the body table through
## BodyContact, so he never ends a tick inside one. Every arena hostile today is a human (the
## dock guards and quartermaster Mertz, "a human (1 hp)"), so Rivet always wins: a walk shoves,
## a run knocks them back by the rule's knockback (the arena has no lying-down state yet: the
## combat lane owns that). A robot or big boss fighter needs its own body class here.

static var _table: BodyTable = null


static func table() -> BodyTable:
	if _table == null:
		_table = BodyTable.load_default()
	return _table


static func class_of(f: Fighter) -> StringName:
	return RivetBody.CLASS if f.kind == Fighter.Kind.RIVET else RivetBody.PERSON


## Resolves Rivet (moving at rivet_vel m/s this tick) against every live hostile; returns the
## number of contacts.
static func resolve(arena: CombatArena, rivet_vel: Vector2) -> int:
	var t: BodyTable = table()
	var n: int = 0
	if not arena.rivet.alive():
		return 0
	for h: Fighter in arena.hostiles:
		if not h.alive():
			continue
		var c: BodyContact = BodyContact.resolve(
			t, RivetBody.CLASS, class_of(h), PackedVector2Array([arena.rivet.pos, h.pos]), rivet_vel
		)
		if c.result == &"":
			continue
		n += 1
		arena.rivet.pos = c.a_pos
		h.pos = c.b_pos
		if c.knockback_m > 0.0:
			h.pos += (c.b_pos - c.a_pos).normalized() * c.knockback_m
	return n
