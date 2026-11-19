extends GutTest


func _rig() -> CutRig:
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.plan = RivetPlan.build()
	for side: RigLimbs in rig.sides:
		side.fore = Sprite2D.new()
		rig.add_child(side.fore)
		side.j_hand = Vector2(10, 2)
	return rig


func test_every_positive_capacity_arsenal_weapon_resolves_a_shipped_texture() -> void:
	var arsenal: ArsenalTable = ArsenalTable.shipped()
	var guns: WeaponTable = WeaponTable.shipped()
	var combat: CombatTuning = CombatTuning.shipped()
	var mag: RivetMagView = autofree(RivetMagView.new())
	var art: WeaponArt = WeaponArt.new()
	var checked: Array[StringName] = []
	for id: StringName in arsenal.weapon_grip:
		var capacity: int = 0
		if guns.weapons.has(id):
			capacity = guns.weapon(id).magazine
		elif combat.weapons.has(id):
			capacity = combat.weapon(id).magazine
		if capacity <= 0:
			continue
		var key: StringName = arsenal.art_id(id)
		var tex: Texture2D = mag.reload_texture(key)
		assert_not_null(tex, String(id))
		if tex != null:
			assert_true(tex.resource_path.begins_with("res://"), String(id))
			assert_true(ResourceLoader.exists(tex.resource_path), tex.resource_path)
			if arsenal.weapon_grip[id] in [&"one_hand", &"two_hand_long"]:
				assert_same(tex, art.part_texture(key, "mag"), String(id))
		checked.append(id)
	assert_has(checked, &"assault-rifle")
	assert_has(checked, &"electro_gun")


func test_unknown_mag_drops_once_at_the_phase_boundary_and_expires() -> void:
	var mag: RivetMagView = add_child_autofree(RivetMagView.new())
	var rig: CutRig = _rig()
	var id: StringName = &"test_unknown_mag"
	if RivetMagView._warned.has(id):
		assert_true(RivetMagView._warned.erase(id))
	var warning: String = "[WARN] rivet: unknown reload magazine for " + String(id)
	var warnings_before: int = Log.recent().count(warning)
	mag.feed(rig, -1.0, 0, id)
	assert_false(RivetMagView._warned.has(id))
	mag.feed(rig, 0.0, 1, id)
	assert_true(mag._held)
	assert_true(RivetMagView._warned.has(id))
	mag.feed(rig, 1.0, 2, id)
	mag.feed(rig, 1.5, 3, id)
	assert_eq(mag.dropped_count(), 1)
	mag.feed(rig, 2.0, 4, id)
	assert_false(mag._held)
	mag.feed(rig, -1.0, 109, id)
	assert_eq(mag.dropped_count(), 1)
	mag.feed(rig, -1.0, 110, id)
	assert_eq(mag.dropped_count(), 0)
	assert_eq(Log.recent().count(warning) - warnings_before, 1)
	assert_true(RivetMagView._warned.erase(id))


func test_real_magazines_skip_the_block_and_tubes_show_only_the_inward_round() -> void:
	var mag: RivetMagView = add_child_autofree(RivetMagView.new())
	var rig: CutRig = _rig()
	for id: StringName in [&"machine_pistol", &"hand_cannon", &"electro_gun", &"gloria"]:
		mag.feed(rig, 0.5, 0, id)
		assert_false(mag._held)
		mag.feed(rig, 1.0, 1, id)
		assert_eq(mag.dropped_count(), 0)
	for tube: StringName in [&"mini_nuke", &"rocket_launcher"]:
		mag.feed(rig, 0.99, 0, tube)
		assert_false(mag._held)
		mag.feed(rig, 1.0, 1, tube)
		assert_true(mag._held)
		assert_same(mag._tex, mag.reload_texture(tube))
		mag.feed(rig, 2.0, 2, tube)
		assert_false(mag._held)
		assert_eq(mag.dropped_count(), 0)


func test_drop_expires_at_the_inclusive_lifetime() -> void:
	var mag: TimedMagazine = add_child_autofree(TimedMagazine.new())
	mag._drop()
	# A live tick can skip across an exact floating-point timestamp.
	# Sample the timestamp itself as well as the preceding tick.
	var lifetime: float = RivetMagView.DROP_LINGER_S + RivetMagView.DROP_FADE_S
	mag.age = lifetime - SimClock.TICK_DT
	mag._age()
	assert_eq(mag.dropped_count(), 1)
	mag.age = lifetime
	mag._age()
	assert_eq(mag.dropped_count(), 0)


class TimedMagazine:
	extends RivetMagView

	var age: float = 0.0

	func _age_s(_index: int) -> float:
		return age
