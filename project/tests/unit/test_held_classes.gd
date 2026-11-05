extends GutTest
## d7-held: the hold table (held_classes.json). Every weapon Rivet can hold is in exactly one
## class; every two-claw class anchors the off claw; a blade turns at the wrist. Planted faults:
## a weapon dropped from its class, a long gun with no foregrip anchor, a weapon in two classes.


func test_shipped_table_is_clean() -> void:
	var h: HeldTable = HeldTable.shipped()
	assert_true(h.ok(), str(h.errors))


func test_every_arsenal_weapon_has_a_class() -> void:
	var h: HeldTable = HeldTable.shipped()
	var a: ArsenalTable = ArsenalTable.shipped()
	var missing: Array[StringName] = []
	missing.assign(a.weapon_grip.keys())
	assert_eq(h.check(missing), [] as Array[String])
	for w: StringName in a.weapon_grip:
		assert_not_null(h.hold_of(w), "%s has a hold class" % w)


func test_owner_blades_are_one_claw() -> void:
	var h: HeldTable = HeldTable.shipped()
	for w: StringName in [&"katana", &"plasma_sword", &"electro_baton"]:
		var c: HeldTable.Hold = h.hold_of(w)
		assert_eq(c.kind, RigGrip.Kind.BLADE, "%s is held as a blade" % w)
		assert_eq(c.off_reach, 0.0, "%s: the off arm is free (combat-notes-1 A)" % w)
		assert_ne(c.wrist_rad, 0.0)


func test_planted_missing_weapon_is_caught() -> void:
	var h: HeldTable = HeldTable.shipped()
	var want: Array[StringName] = [&"katana", &"no_such_gun"]
	var errs: Array[String] = h.check(want)
	assert_eq(errs.size(), 1, str(errs))


func test_planted_missing_anchor_is_caught() -> void:
	var raw: Dictionary = _raw()
	raw["classes"]["long_gun"]["fore_u"] = -1
	var bad: HeldTable = _parse(raw)
	assert_false(bad.ok(), "a long gun with no foregrip anchor fails")


func test_planted_double_class_is_caught() -> void:
	var raw: Dictionary = _raw()
	var side: Array = raw["classes"]["sidearm"]["weapons"]
	side.append("katana")
	var bad: HeldTable = _parse(raw)
	assert_false(bad.ok(), "a weapon in two classes fails")


func test_blade_guard_holds_the_claw_ahead_and_the_off_arm_free() -> void:
	var guard: CutRig = _rig(&"blade", RigGrip.Kind.BLADE)
	var rifle: CutRig = _rig(&"long_gun", RigGrip.Kind.TWO_HAND_LONG)
	var g: int = guard.plan.gun_arm
	var o: int = 1 - g
	gut.p("gun claw %s, off claw %s" % [guard.sides[g].j_hand, guard.sides[o].j_hand])
	assert_gt(guard.sides[g].j_hand.x, guard.plan.shoulder[g].x, "the guard is ahead of the hip")
	var off_gap: float = guard.sides[o].j_hand.distance_to(rifle.sides[o].j_hand)
	assert_gt(off_gap, 40.0, "planted fault: the rifle's off claw reaches under the barrel")
	assert_ne(RigGrip.wrist_turn(guard), 0.0, "the blade turns in at the wrist")
	assert_eq(RigGrip.wrist_turn(rifle), 0.0)


func _rig(hold: StringName, kind: int) -> CutRig:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(RivetPlan.build(), RigVariant.rivet())
	rig.snap_facing(0.0)
	rig.position = Vector2(500, 500)
	for _k: int in 30:
		rig.gun_out = true
		rig.aiming = true
		rig.aim_at = rig.position + Vector2(600, 0)
		rig.grip = kind
		rig.hold = hold
		rig.face_to = 0.0
		rig.drive(SimClock.TICK_DT)
	return rig


func _parse(raw: Dictionary) -> HeldTable:
	return HeldTable.from_table(DataTable.parse(JSON.stringify(raw), HeldTable.SCHEMA, "x"))


func _raw() -> Dictionary:
	return _table().raw.duplicate(true)


func _table() -> DataTable:
	return DataTable.open(HeldTable.TABLE, HeldTable.SCHEMA)
