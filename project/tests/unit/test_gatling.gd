extends GutTest
## n5-look: the gatling (weapons.json `gatling`): the barrels spin up before the first round,
## then a high rate; they wind down on release; the walk slows while they turn; it has art, a
## grip class with a back box, and a place in the armory and the weapon wall.

var _table: WeaponTable


func before_all() -> void:
	_table = WeaponTable.shipped()


## Ticks held until the first round leaves (the spin), stepping like GunHand.settle.
func _first_round_tick(trig: Trigger) -> int:
	for i: int in 240:
		if trig.pull(true):
			return i
		trig.step()
	return -1


func test_spins_up_before_the_first_round() -> void:
	var w: WeaponSpec = _table.weapon(&"gatling")
	assert_true(_table.ok())
	assert_true(w.auto, "full auto")
	assert_eq(w.spin_ticks, 30, "spin_s 0.5")
	assert_eq(_first_round_tick(Trigger.new(w)), w.spin_ticks - 1, "nothing leaves before the spin")


func test_spun_rate_is_high() -> void:
	var w: WeaponSpec = _table.weapon(&"gatling")
	var trig: Trigger = Trigger.new(w)
	@warning_ignore("return_value_discarded")
	_first_round_tick(trig)
	var shots: int = 0
	for i: int in 60:
		trig.step()
		if trig.pull(true):
			shots += 1
	assert_gte(shots, 18, "about 20 rounds a second once spun")
	assert_gt(shots, 14, "faster than the machine pistol's 14")


func test_release_winds_down_and_a_new_pull_spins_again() -> void:
	var trig: Trigger = Trigger.new(_table.weapon(&"gatling"))
	@warning_ignore("return_value_discarded")
	_first_round_tick(trig)
	for i: int in 40:
		@warning_ignore("return_value_discarded")
		trig.pull(false)
		trig.step()
	assert_false(trig.spinning(), "stopped after a long release")
	assert_gt(_first_round_tick(trig), 20, "spins up again")


func test_other_guns_do_not_spin() -> void:
	for id: StringName in _table.order:
		if id != &"gatling":
			assert_eq(_table.weapon(id).spin_ticks, 0, str(id))
			assert_eq(_table.weapon(id).fire_move_mult, 1.0, str(id))


func test_walk_slows_while_spinning() -> void:
	var w: WeaponSpec = _table.weapon(&"gatling")
	assert_lt(w.fire_move_mult, 0.6, "a heavy slow walk")
	var trig: Trigger = Trigger.new(w)
	assert_false(trig.spinning())
	@warning_ignore("return_value_discarded")
	trig.pull(true)
	assert_true(trig.spinning(), "the first held tick turns the barrels")


func test_art_grip_and_stations() -> void:
	var art: WeaponArt = WeaponArt.new()
	assert_true(art.has(&"gatling"), "weapon_art.json row")
	assert_not_null(art.part_texture(&"gatling", "tank"), "the belt box on the back")
	var arsenal: ArsenalTable = ArsenalTable.shipped()
	assert_eq(arsenal.grip_of(&"gatling").id, &"hip_belt")
	assert_eq(RigGrip.kind_of(&"hip_belt"), RigGrip.Kind.HIP)
	assert_true(RivetHeldView.ON_BACK.has(&"hip_belt"))
	assert_true(ArenaArmory.ORDER.has(&"gatling"))
	assert_true(WeaponRackView.ORDER.has(&"gatling"))


func test_the_feed_line_is_a_brass_belt_for_the_gatling_and_a_hose_for_the_flamer() -> void:
	var owner: Node2D = autofree(Node2D.new())
	var belt: Array[Line2D] = HeldFeedLine.make(owner, true)
	var hose: Array[Line2D] = HeldFeedLine.make(owner, false)
	assert_eq(belt.size(), 2)
	assert_eq(belt[1].default_color, HeldFeedLine.BRASS, "brass core")
	assert_not_null(belt[1].texture, "cut into links")
	assert_gt(belt[0].width, hose[0].width, "the belt is wider than the hose")
	assert_eq(hose[1].default_color, RivetMagView.SHINE, "the flamer keeps its cream hose")
	assert_null(hose[1].texture)
