extends GutTest
## rivet-motion: the melee-weapon framework (data/tables/melee_weapons.json). The electro baton and
## the katana load into the claw's MeleeTable shape and MeleeCombo plays them unchanged: the baton
## chains faster than the claw and stuns, its finisher arcs to metal, the katana out-reaches the
## claw and its finisher lunges exactly lunge_m. Planted faults: a missing weapon, a broken row,
## and a lunge stretched into the recovery are each caught.


func test_shipped_weapons_load() -> void:
	assert_eq(MeleeTable.weapon_ids(), [&"electro_baton", &"katana"] as Array[StringName])
	for wid: StringName in MeleeTable.weapon_ids():
		var w: MeleeTable = MeleeTable.weapon(wid)
		assert_true(w.ok(), "%s: %s" % [wid, w.errors])
		assert_eq(w.hits.size(), 3, "%s is a 3-hit combo" % wid)
		assert_eq(w.id, wid)


func test_claw_keeps_weapon_fields_at_zero() -> void:
	var claw: MeleeTable = MeleeTable.shipped()
	assert_true(claw.ok(), str(claw.errors))
	for h: MeleeHit in claw.hits:
		assert_eq([h.stun_ticks, h.chain_hops, h.lunge_m], [0, 0, 0.0], str(h.id))
	assert_eq(claw.move_mult, 1.0)


func test_baton_is_the_fast_stun_stick() -> void:
	var baton: MeleeTable = MeleeTable.weapon(&"electro_baton")
	assert_lt(_mashed_chain_ticks(baton), _mashed_chain_ticks(MeleeTable.shipped()), "faster")
	for h: MeleeHit in baton.hits:
		assert_gt(h.stun_ticks, 0, "%s stuns" % h.id)
	assert_gt(baton.hits[2].chain_hops, 0, "the finisher chains to metal")
	assert_gt(baton.chain_radius_m, 0.0)


func test_katana_reaches_and_lunges() -> void:
	var katana: MeleeTable = MeleeTable.weapon(&"katana")
	var claw: MeleeTable = MeleeTable.shipped()
	for i: int in 3:
		assert_gt(katana.hits[i].reach_m, claw.hits[i].reach_m, "katana hit %d out-reaches" % i)
	var c: MeleeCombo = _combo_at_hit(katana, 3)
	var travelled: float = 0.0
	var landed_after: float = -1.0
	for _t: int in katana.hits[2].length():
		travelled += c.lunge_step_m()
		if c.lands():
			landed_after = travelled
		c.step()
	assert_almost_eq(travelled, katana.hits[2].lunge_m, 1e-4, "the thrust closes lunge_m")
	assert_lt(landed_after, katana.hits[2].lunge_m, "it lands mid-lunge, not after")
	assert_eq(c.lunge_step_m(), 0.0, "no drift once the combo ends")


func test_move_scale_only_while_a_hit_plays() -> void:
	var katana: MeleeTable = MeleeTable.weapon(&"katana")
	var c: MeleeCombo = MeleeCombo.new(katana)
	assert_eq(c.move_scale(), 1.0)
	c.press()
	assert_eq(c.move_scale(), katana.move_mult)
	assert_lt(katana.move_mult, 1.0, "a two-hand blade slows Rivet while it swings")


func test_view_sweeps_slashes_and_never_a_thrust() -> void:
	var katana: MeleeTable = MeleeTable.weapon(&"katana")
	var view: MeleeWeaponView = MeleeWeaponView.new()
	var c: MeleeCombo = MeleeCombo.new(katana)
	assert_eq(view.sweep_of(c), 0.0, "idle: on the forearm line")
	c.press()
	var h: MeleeHit = katana.hits[0]
	for _t: int in h.windup:
		c.step()
	assert_almost_eq(view.sweep_of(c), view.sweep_rad * (1.0 - 2.0 / h.active), 1e-4)
	for _t: int in h.active - 1:
		c.step()
	assert_almost_eq(view.sweep_of(c), -view.sweep_rad, 1e-4, "swept through to the far side")
	var thrust: MeleeCombo = _combo_at_hit(katana, 3)
	thrust.step()
	assert_eq(view.sweep_of(thrust), 0.0, "the lunge thrust stays on line")
	view.free()


func test_planted_fault_missing_weapon_is_an_error() -> void:
	var w: MeleeTable = MeleeTable.weapon(&"chainsaw")
	assert_false(w.ok(), "no chainsaw row tonight: an error, not a crash")
	assert_true(w.hits.is_empty())


func test_planted_fault_broken_row_is_caught() -> void:
	var json: String = FileAccess.get_file_as_string(MeleeTable.WEAPONS)
	json = json.replace('"move_mult": 0.7', '"move_mult": "slow"')
	var t: DataTable = DataTable.parse(json, MeleeTable.WEAPONS_SCHEMA, "planted")
	assert_false(MeleeTable.weapon_from(t, &"katana").ok(), "a string move_mult is caught")


func test_planted_fault_lunge_into_recovery_is_caught() -> void:
	var katana: MeleeTable = MeleeTable.weapon(&"katana")
	var c: MeleeCombo = _combo_at_hit(katana, 3)
	var h: MeleeHit = katana.hits[2]
	for _t: int in h.windup + h.active:
		c.step()
	assert_eq(c.lunge_step_m(), 0.0, "recovery does not drift")
	h.windup += h.recovery
	h.recovery = 0
	assert_gt(c.lunge_step_m(), 0.0, "the fault (lunge stretched over the recovery) is caught")


func test_baton_finisher_arcs_through_the_metal_line() -> void:
	# The station's metal dummies sit at x 6/8/10 plus 14 (past the chain radius); a human at 4.
	var baton: MeleeTable = MeleeTable.weapon(&"electro_baton")
	var pos: PackedVector2Array = [
		Vector2(6, 0), Vector2(8, 0), Vector2(10, 0), Vector2(14, 0), Vector2(4, 0)
	]
	var metal: PackedByteArray = [1, 1, 1, 1, 0]
	var finisher: MeleeHit = baton.hits[2]
	assert_eq(
		Array(baton.chain_for(finisher, pos, metal, 0)), [0, 1, 2], "two hops, 14 out of range"
	)
	assert_eq(Array(baton.chain_for(baton.hits[0], pos, metal, 0)), [0], "hit 1 does not arc")
	assert_eq(
		Array(baton.chain_for(finisher, pos, metal, 4)), [4], "a human struck first never arcs"
	)


func test_planted_fault_baton_without_radius_does_not_arc() -> void:
	var baton: MeleeTable = MeleeTable.weapon(&"electro_baton")
	var pos: PackedVector2Array = [Vector2(6, 0), Vector2(8, 0)]
	var metal: PackedByteArray = [1, 1]
	assert_eq(baton.chain_for(baton.hits[2], pos, metal, 0).size(), 2)
	baton.chain_radius_m = 0.0
	assert_eq(baton.chain_for(baton.hits[2], pos, metal, 0).size(), 1, "the fault is caught")


## Ticks from the first press to the end of the finisher when melee is mashed every 3 ticks.
func _mashed_chain_ticks(table: MeleeTable) -> int:
	var c: MeleeCombo = MeleeCombo.new(table)
	for t: int in 300:
		if t % 3 == 0 and c.starts < table.hits.size():
			c.press()
		c.step()
		if c.hit_index == 0 and c.last_index == table.hits.size():
			return t + 1
	return 300


## A combo whose `index`-th hit has just started (presses chained through the cancel points).
func _combo_at_hit(table: MeleeTable, index: int) -> MeleeCombo:
	var c: MeleeCombo = MeleeCombo.new(table)
	c.press()
	while c.hit_index < index:
		c.press()
		c.step()
	return c
