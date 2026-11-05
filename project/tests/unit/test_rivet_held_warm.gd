extends GutTest
## perf-city: RivetHeldView.warm() loads the art of every carried gun at load, so Rivet's first
## draw of a gun mid-fight does not read textures from disk (an 8-19 ms frame at tick 2019).

const CARRIED: Array[StringName] = [&"pistol", &"plasma_rifle", &"flamethrower", &"molotov"]


func _view(ids: Array[StringName]) -> RivetHeldView:
	var carry: RivetCarry = RivetCarry.new(
		WeaponTable.shipped(), ArsenalTable.shipped(), RngRegistry.new(7).stream(&"gunplay")
	)
	for id: StringName in ids:
		assert_gte(carry.add(id), 0, "%s has a carry slot" % id)
	var view: RivetHeldView = RivetHeldView.new()
	view.pilot = StagePilot.new(PlayerActions.shipped())
	view.pilot.carry = carry
	return view


## The paths the live view would load on each carried gun's first draw (_swap + the reload parts).
func _first_draw_paths(view: RivetHeldView) -> Array[String]:
	var cold: WeaponArt = WeaponArt.new()
	for weapon: StringName in view.pilot.carry.slots:
		var id: StringName = view.arsenal.art_id(weapon) if weapon != &"" else &""
		if cold.has(id):
			cold.make_held(id).free()
			for part: String in ["mag", "tank"]:
				@warning_ignore("return_value_discarded")
				cold.part_texture(id, part)
	var paths: Array[String] = cold._tex.keys()
	return paths


func test_warm_loads_every_carried_guns_art() -> void:
	var view: RivetHeldView = _view(CARRIED)
	var want: Array[String] = _first_draw_paths(view)
	assert_gt(want.size(), CARRIED.size() - 1, "the carried guns have art to load")
	assert_eq(view.art._tex.size(), 0, "nothing loaded before warm")
	view.warm()
	for path: String in want:
		assert_true(view.art._tex.has(path), "%s is warm" % path)
	view.free()


func test_a_first_draw_after_warm_loads_nothing_new() -> void:
	var view: RivetHeldView = _view(CARRIED)
	view.warm()
	var before: int = view.art._tex.size()
	for weapon: StringName in CARRIED:
		view.art.make_held(view.arsenal.art_id(weapon)).free()
	assert_eq(view.art._tex.size(), before, "every first draw hits the cache")
	view.free()


func test_warm_without_a_carry_is_a_no_op() -> void:
	var view: RivetHeldView = RivetHeldView.new()
	view.warm()
	assert_eq(view.art._tex.size(), 0)
	view.pilot = StagePilot.new(PlayerActions.shipped())
	view.warm()
	assert_eq(view.art._tex.size(), 0)
	view.free()
