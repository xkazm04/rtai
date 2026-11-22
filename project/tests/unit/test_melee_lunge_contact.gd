extends GutTest
## n17 rivet-strike item 2: a hit with lunge_ticks puts all of its lunge_m on the lunge_ticks
## ticks before its contact tick, stepped as PlayerMelee steps it (combo.step(), the hit test,
## then the lunge): the body has arrived when the hit tests, the wind-up's first ticks are planted
## and nothing drifts after contact. lunge_ticks 0 keeps the before (an even spread that lands
## mid-lunge and still moves after contact).


## Per tick of `h` from its start, the lunge (m) PlayerMelee returns; index windup = contact.
func _lunges(h: MeleeHit) -> PackedFloat32Array:
	var t: MeleeTable = MeleeTable.new()
	t.hits.append(h)
	var c: MeleeCombo = MeleeCombo.new(t)
	var out: PackedFloat32Array = PackedFloat32Array()
	c.press()
	for _tick: int in h.length() + 2:
		c.step()
		@warning_ignore("return_value_discarded")
		out.append(c.lunge_step_m() if c.hit_index > 0 else 0.0)
	return out


func _hit(lunge_ticks: int) -> MeleeHit:
	var h: MeleeHit = MeleeHit.new()
	h.windup = 7
	h.active = 5
	h.recovery = 22
	h.lunge_m = 2.5
	h.lunge_ticks = lunge_ticks
	return h


## Metres travelled before the hit test of the contact tick (ticks stepped before it).
func _before_contact(steps: PackedFloat32Array, contact: int) -> float:
	var sum: float = 0.0
	for i: int in steps.size():
		if i + 1 < contact:  # steps[i] is the lunge of tick_in i + 1
			sum += steps[i]
	return sum


func test_contact_lunge_arrives_before_the_hit_test() -> void:
	var h: MeleeHit = _hit(4)
	var steps: PackedFloat32Array = _lunges(h)
	var total: float = 0.0
	for s: float in steps:
		total += s
	assert_almost_eq(total, h.lunge_m, 1e-4, "the whole lunge_m is travelled")
	assert_almost_eq(_before_contact(steps, h.windup), h.lunge_m, 1e-4, "arrived at contact")
	for i: int in steps.size():
		var tick_in: int = i + 1
		var on: bool = tick_in >= h.windup - h.lunge_ticks and tick_in < h.windup
		assert_eq(steps[i] > 0.0, on, "tick_in %d moves only in the lunge window" % tick_in)


func test_even_spread_is_the_before() -> void:
	var h: MeleeHit = _hit(0)
	var steps: PackedFloat32Array = _lunges(h)
	var before: float = _before_contact(steps, h.windup)
	assert_lt(before, h.lunge_m * 0.6, "the before lands mid-lunge (%.2f m)" % before)
	var after: float = 0.0
	for i: int in steps.size():
		if i + 1 >= h.windup:
			after += steps[i]
	assert_gt(after, 0.5, "the before still slides %.2f m from contact on" % after)


func test_lunge_ticks_are_capped_inside_the_windup() -> void:
	var t: DataTable = DataTable.open(MeleeTable.WEAPONS, MeleeTable.WEAPONS_SCHEMA)
	assert_true(t.ok(), str(t.errors()))
	for id: StringName in MeleeTable.weapon_ids():
		for h: MeleeHit in MeleeTable.weapon(id).hits:
			assert_lt(h.lunge_ticks, h.windup, "%s: the lunge starts after tick 0" % h.id)


func test_katana_thrust_and_saw_rev_in_land_on_contact() -> void:
	var rows: Dictionary[StringName, int] = {&"katana": 2, &"chainsaw": 0}
	for id: StringName in rows:
		var weapon: MeleeTable = MeleeTable.weapon(id)
		weapon.single_swing = false  # the original thrust and rev-in rows
		var h: MeleeHit = weapon.hits[rows[id]]
		assert_gt(h.lunge_ticks, 0, "%s lunges onto contact" % h.id)
		var steps: PackedFloat32Array = _lunges(h)
		assert_almost_eq(_before_contact(steps, h.windup), h.lunge_m, 1e-4, str(h.id))
