extends GutTest
## Lane gunplay: the shared hit-feel module maps damage classes onto reactions, flash and the rig.

var _kinds: Array[StringName] = []


func _on_reaction(_id: int, kind: StringName, _dir: Vector2, _ticks: int) -> void:
	_kinds.append(kind)


func test_every_weapon_hit_class_has_a_row() -> void:
	var feel: HitFeel = HitFeel.shipped()
	assert_true(feel.ok())
	var table: WeaponTable = WeaponTable.shipped()
	for id: StringName in table.order:
		assert_true(feel.has_class(table.weapon(id).hit_class), str(id))


func test_a_rocket_knocks_down_and_a_kill_has_no_reaction() -> void:
	var feel: HitFeel = HitFeel.shipped()
	_kinds.clear()
	var err: int = feel.reaction.connect(_on_reaction)
	assert_eq(err, OK)
	assert_eq(feel.land(1, &"blast", Vector2.RIGHT, false, 10), 0, "no rig, no stop")
	assert_eq(feel.land(2, &"blast", Vector2.RIGHT, true, 10), 0)
	assert_eq(_kinds, [&"knockdown"] as Array[StringName])


func test_flash_fades_from_one_to_zero() -> void:
	var feel: HitFeel = HitFeel.shipped()
	var hold: int = feel.land(5, &"heavy", Vector2.UP, false, 100)
	assert_eq(hold, 0)
	assert_almost_eq(feel.flash(5, 100), 1.0, 1e-6)
	assert_gt(feel.flash(5, 103), 0.0)
	assert_eq(feel.flash(5, 200), 0.0)


func test_with_a_rig_a_kill_stops_and_reduced_motion_does_not() -> void:
	var rig: CameraRig = CameraRig.new()
	var feel: HitFeel = HitFeel.shipped(rig)
	assert_gt(feel.land(1, &"light", Vector2.RIGHT, true, 1000), 0)
	rig.reduced_motion = true
	assert_eq(feel.land(2, &"light", Vector2.RIGHT, true, 5000), 0)


func test_beat_mode_holds_the_kill_longer() -> void:
	var rig: CameraRig = CameraRig.new()
	var feel: HitFeel = HitFeel.shipped(rig)
	var plain: int = feel.land(1, &"light", Vector2.RIGHT, true, 1000)
	feel.beat_mode = true
	var beat: int = feel.land(2, &"light", Vector2.RIGHT, true, 5000)
	assert_eq(plain, 6)
	assert_eq(beat, 8)
