extends GutTest
## rivet-arsenal: WeaponHold over rivet_arsenal.json. The draw from the bare claw takes the grip's
## draw_ticks for every class, a switch is the old grip's stow plus the new grip's draw, nothing
## fires before the draw ends, a reload walks out -> in -> cock over the weapon's reload_s, and
## every weapon in weapons.json and melee_weapons.json has a grip. Planted faults: a zero-tick
## draw and a weapon with an unknown grip are refused.


func _ticks_until_ready(h: WeaponHold) -> int:
	var n: int = 0
	while not h.can_fire() and n < 600:
		h.step()
		n += 1
	return n


func test_table_is_valid() -> void:
	var t: ArsenalTable = ArsenalTable.shipped()
	assert_true(t.ok(), str(t.errors))
	assert_eq(t.grips.size(), 6, "six grip classes")


func test_draw_time_per_class_is_the_tables() -> void:
	var t: ArsenalTable = ArsenalTable.shipped()
	var sample: Dictionary[StringName, StringName] = {
		&"one_hand": &"pistol",
		&"two_hand_long": &"plasma_rifle",
		&"shoulder": &"rocket_launcher",
		&"backpack_hose": &"flamethrower",
		&"thrown": &"molotov",
		&"heavy_two_hand": &"chainsaw",
	}
	for g: StringName in sample:
		var h: WeaponHold = WeaponHold.new(t)
		assert_true(h.equip(sample[g]))
		assert_eq(h.state, WeaponHold.State.DRAWING)
		assert_eq(_ticks_until_ready(h), t.grips[g].draw_ticks, "%s draw" % g)


func test_switch_is_stow_then_draw_and_holds_fire() -> void:
	var t: ArsenalTable = ArsenalTable.shipped()
	var h: WeaponHold = WeaponHold.new(t)
	@warning_ignore("return_value_discarded")
	h.equip(&"pistol")
	@warning_ignore("return_value_discarded")
	_ticks_until_ready(h)
	assert_true(h.can_fire())
	assert_true(h.equip(&"rocket_launcher"))
	assert_false(h.can_fire(), "no shot while the pistol goes away")
	var n: int = _ticks_until_ready(h)
	assert_eq(n, t.grips[&"one_hand"].stow_ticks + t.grips[&"shoulder"].draw_ticks)
	assert_eq(n, h.switch_ticks(&"pistol", &"rocket_launcher"))
	assert_eq(h.held, &"rocket_launcher")
	assert_false(h.equip(&"rocket_launcher"), "already in hand")


func test_reload_walks_out_in_cock() -> void:
	var h: WeaponHold = WeaponHold.new()
	@warning_ignore("return_value_discarded")
	h.equip(&"pistol")
	@warning_ignore("return_value_discarded")
	_ticks_until_ready(h)
	assert_true(h.reload(1.1))
	var seen: Array[WeaponHold.Reload] = []
	while h.state == WeaponHold.State.RELOADING:
		var p: WeaponHold.Reload = h.reload_phase()
		if seen.is_empty() or seen[-1] != p:
			seen.append(p)
		h.step()
	var want: Array[WeaponHold.Reload] = [
		WeaponHold.Reload.MAG_OUT, WeaponHold.Reload.MAG_IN, WeaponHold.Reload.COCK
	]
	assert_eq(seen, want)
	assert_true(h.can_fire())


func test_every_weapon_has_a_grip() -> void:
	var t: ArsenalTable = ArsenalTable.shipped()
	var guns: DataTable = DataTable.open("res://data/tables/weapons.json", "gtai.weapons/1")
	for row: Dictionary in guns.raw["weapons"]:
		var id: String = row["id"]
		assert_not_null(t.grip_of(StringName(id)), "gun %s" % id)
	var melee: Dictionary = DataTable.open(MeleeTable.WEAPONS, MeleeTable.WEAPONS_SCHEMA).raw
	for id: String in melee["weapons"]:
		assert_not_null(t.grip_of(StringName(id)), "melee %s" % id)


func test_planted_bad_rows_are_refused() -> void:
	var raw: DataTable = DataTable.open(ArsenalTable.TABLE, ArsenalTable.SCHEMA)
	raw.raw["classes"]["one_hand"]["draw_ticks"] = 0
	raw.raw["weapons"]["pistol"] = "no_such_grip"
	var t: ArsenalTable = ArsenalTable.from_table(raw)
	assert_eq(t.errors.size(), 2, str(t.errors))
