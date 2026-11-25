extends GutTest

const RUN_CYCLE_CELL: Dictionary[String, float] = {"p70": 258.0, "p55": 212.0}
const CYCLE_CELL: Dictionary[String, float] = {"p70": 60.0, "p55": 60.0}
const ARMED_CYCLE_CELL: Dictionary[String, float] = {
	"p70/gloria": 74.7,
	"p70/plasma_sword": 66.7,
	"p70/molotov": 81.0,
	"p70/ray_gun": 79.0,
	"p70/homing_shard": 78.7,
	"p70/mini_nuke": 71.3,
	"p70/electro_gun": 82.3,
	"p70/machine_pistol": 73.7,
	"p70/hand_cannon": 69.7,
	"p70/assault_rifle": 78.0,
	"p70/electro_baton": 68.7,
	"p70/chainsaw": 64.3,
	"p70/rocket_launcher": 84.0,
	"p70/pistol": 76.0,
	"p70/plasma_rifle": 76.0,
	"p70/katana": 66.0,
	"p70/gatling": 68.0,
	"p55/pistol": 77.0,
	"p55/plasma_rifle": 74.0,
	"p55/katana": 72.0,
	"p55/gatling": 81.0,
}
const RUN_ROW_K: Dictionary[String, float] = {
	"p70/molotov/0": 0.98,
	"p70/molotov/1": 0.98,
	"p70/molotov/3": 0.96,
	"p70/molotov/4": 0.99,
	"p70/gloria/5": 0.64,
	"p70/plasma_sword/1": 0.98,
	"p70/electro_gun/5": 0.96,
	"p70/electro_gun/4": 0.86,
	"p70/electro_gun/3": 0.93,
	"p70/electro_gun/0": 0.87,
	"p70/electro_gun/1": 0.89,
	"p70/machine_pistol/0": 0.86,
	"p70/machine_pistol/1": 0.95,
	"p70/machine_pistol/4": 0.91,
	"p70/hand_cannon/0": 0.91,
	"p70/hand_cannon/3": 0.91,
	"p70/hand_cannon/4": 0.84,
	"p70/hand_cannon/5": 0.96,
	"p70/assault_rifle/0": 0.87,
	"p70/assault_rifle/1": 0.95,
	"p70/assault_rifle/3": 0.82,
	"p70/assault_rifle/4": 0.85,
	"p70/assault_rifle/5": 0.96,
	"p70/electro_baton/0": 0.96,
	"p70/electro_baton/1": 0.90,
	"p70/electro_baton/3": 0.87,
	"p70/electro_baton/4": 0.98,
	"p70/electro_baton/5": 0.97,
	"p70/chainsaw/0": 0.89,
	"p70/chainsaw/1": 0.82,
	"p70/chainsaw/3": 0.89,
	"p70/chainsaw/4": 0.84,
	"p70/chainsaw/5": 0.88,
	"p70/rocket_launcher/0": 0.91,
	"p70/rocket_launcher/3": 0.94,
	"p70/rocket_launcher/4": 0.93,
	"p70/gatling/4": 0.94,
	"p55/sprint/2": 0.98,
	"p55/sprint/6": 0.98,
	"p70/flamethrower/3": 0.91,
	"p70/flamethrower/4": 0.92,
	"p55/pistol/1": 0.79,
	"p55/pistol/3": 0.89,
	"p55/plasma_rifle/1": 0.76,
	"p55/plasma_rifle/3": 0.89,
	"p55/katana/1": 0.84,
	"p55/gatling/1": 0.77,
	"p55/gatling/3": 0.83,
	"p55/gatling/4": 0.92,
	"p55/flamethrower/1": 0.68,
	"p55/flamethrower/3": 0.93,
}
const WALK_PROFILE_TRAVEL: Dictionary[String, Vector2] = {
	StrideMatch.ROOT + "p70/rivet_walk_eq_gloria.png": Vector2(22.0, 32.0),
	StrideMatch.ROOT + "p70/rivet_walk_eq_plasma_sword.png": Vector2(15.5, 30.0),
	StrideMatch.ROOT + "p70/rivet_walk_eq_molotov.png": Vector2(27.5, 34.5),
	StrideMatch.ROOT + "p70/rivet_walk_eq_ray_gun.png": Vector2(25.5, 34.5),
	StrideMatch.ROOT + "p70/rivet_walk_eq_homing_shard.png": Vector2(25.0, 34.0),
	StrideMatch.ROOT + "p70/rivet_walk_eq_mini_nuke.png": Vector2(22.5, 31.0),
	StrideMatch.ROOT + "p70/rivet_walk_eq_electro_gun.png": Vector2(26.5, 33.5),
	StrideMatch.ROOT + "p70/rivet_walk_eq_machine_pistol.png": Vector2(21.0, 27.0),
	StrideMatch.ROOT + "p70/rivet_walk_eq_hand_cannon.png": Vector2(25.0, 30.0),
	StrideMatch.ROOT + "p70/rivet_walk_eq_assault_rifle.png": Vector2(20.5, 29.5),
	StrideMatch.ROOT + "p70/rivet_walk_eq_electro_baton.png": Vector2(15.0, 28.5),
	StrideMatch.ROOT + "p70/rivet_walk_eq_chainsaw.png": Vector2(18.5, 28.0),
	StrideMatch.ROOT + "p70/rivet_walk_eq_rocket_launcher.png": Vector2(23.0, 36.5),
}


func test_all_five_calibrations_match_the_measured_grids() -> void:
	var grid: RivetGridStride = RivetGridStride.shared()
	assert_eq([grid.run_cycle_cell, grid.cycle_cell], [RUN_CYCLE_CELL, CYCLE_CELL])
	assert_eq([grid.armed_cycle_cell, grid.run_row_k], [ARMED_CYCLE_CELL, RUN_ROW_K])
	assert_eq(grid.walk_profile_travel, WALK_PROFILE_TRAVEL)


func _bare_rig(file: String, face: float = 0.0, speed: float = 0.0) -> CutRig:
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.face_to = face
	rig.speed_now = speed
	var card: Sprite2D = Sprite2D.new()
	rig.add_child(card)
	rig.head_card = card
	var path: String = StrideMatch.ROOT + file
	card.texture = load(path)
	card.set_meta(RivetFrames.ON, path)
	card.hframes = 8
	card.vframes = 8
	return rig


func test_live_bare_profile_uses_the_two_stances_at_game_speed() -> void:
	var rig: CutRig = _bare_rig("p70/rivet_run8.png", 0.0, 9.3 * CharacterRigs.PX_PER_M)
	var grid: RivetGridStride = RivetGridStride.shared()
	var profile: Vector2 = grid.bare_run["p70"][2]
	var scale: float = 0.72
	var distance: float = rig.speed_now * SimClock.TICK_DT
	var cycles: Vector2 = (profile * scale).max(
		Vector2.ONE * rig.speed_now / grid.bare_max_cycles_s
	)
	var phase: float = 0.0
	assert_eq(RivetWalk.phase_of(rig, "p70", scale), phase)
	for tick: int in 65:
		rig.global_position.x += distance
		phase = RivetWalk.bare_phase(phase, distance, cycles)
		assert_almost_eq(RivetWalk.phase_of(rig, "p70", scale), phase, 0.00002, str(tick))


func test_front_and_back_keep_each_original_cycle_and_speed_cap() -> void:
	for pitch: String in ["p55", "p70"]:
		for running: bool in [false, true]:
			var file: String = RivetWalk.RUN if running else RivetWalk.STRIP
			var rig: CutRig = _bare_rig(pitch + "/" + file)
			var cell: float = RUN_CYCLE_CELL[pitch] if running else CYCLE_CELL[pitch]
			for facing: float in [PI / 2.0, -PI / 2.0]:
				rig.face_to = facing
				for speed: float in [32.0, 297.6]:
					rig.speed_now = speed
					var expected: float = maxf(cell * 0.25, speed / (3.5 if running else 2.0))
					var cycles: Vector2 = RivetWalk._bare_cycles(rig.head_card, pitch, rig, 0.25)
					assert_almost_eq(cycles, Vector2.ONE * expected, Vector2.ONE * 0.0001)


func test_only_the_boot_with_enough_travel_uses_its_measured_cycle() -> void:
	var rig: CutRig = _bare_rig("p55/rivet_run8.png")
	rig.face_to = -3.0 * PI / 4.0  # back left, [0, 125.10]
	rig.speed_now = 9.3 * CharacterRigs.PX_PER_M
	var cycles: Vector2 = RivetWalk._bare_cycles(rig.head_card, "p55", rig, 0.72)
	assert_almost_eq(cycles, Vector2(212.0, 125.10) * 0.72, Vector2.ONE * 0.0001)
	rig.face_to = -PI / 4.0  # back right, [0, 13.30]
	cycles = RivetWalk._bare_cycles(rig.head_card, "p55", rig, 0.72)
	assert_almost_eq(cycles, Vector2.ONE * 212.0 * 0.72, Vector2.ONE * 0.0001)
	rig = _bare_rig("p70/rivet_walk8.png", PI / 4.0, 32.0)  # front right, [30.17, 0]
	cycles = RivetWalk._bare_cycles(rig.head_card, "p70", rig, 0.72)
	assert_almost_eq(cycles, Vector2(30.17, 60.0) * 0.72, Vector2.ONE * 0.0001)


func test_short_measured_stance_keeps_two_sprint_ticks_per_drawing() -> void:
	var rig: CutRig = _bare_rig("p70/rivet_run8.png", PI / 4.0, 9.3 * CharacterRigs.PX_PER_M)
	var cycles: Vector2 = RivetWalk._bare_cycles(rig.head_card, "p70", rig, 0.5)
	var two_ticks: float = rig.speed_now * SimClock.TICK_DT * 2.0
	assert_almost_eq(cycles / 8.0, Vector2.ONE * two_ticks, Vector2.ONE * 0.0001)


func test_each_boot_accepts_a_measurement_exactly_at_the_cutoff() -> void:
	var grid: RivetGridStride = RivetGridStride.shared()
	assert_eq(grid.bare_min_travel, 0.4)
	var rig: CutRig = _bare_rig("p70/rivet_walk8.png", PI / 2.0, 32.0)
	var original: PackedVector2Array = grid.bare_walk["p70"]
	var rows: PackedVector2Array = original.duplicate()
	rows[0] = Vector2(24.0, 23.9)  # 40% of the 60 px walk cycle is 24 px.
	grid.bare_walk["p70"] = rows
	var first: Vector2 = RivetWalk._bare_cycles(rig.head_card, "p70", rig, 1.0)
	rows[0] = Vector2(23.9, 24.0)
	grid.bare_walk["p70"] = rows
	var second: Vector2 = RivetWalk._bare_cycles(rig.head_card, "p70", rig, 1.0)
	grid.bare_walk["p70"] = original
	assert_eq([first, second], [Vector2(24.0, 60.0), Vector2(60.0, 24.0)])


func test_turn_from_profile_to_depth_carries_phase_and_steps_at_the_new_rate() -> void:
	var rig: CutRig = _bare_rig("p70/rivet_run8.png")
	rig.speed_now = 6.75 * CharacterRigs.PX_PER_M
	var scale: float = 0.72
	rig.set_meta(RivetWalk.META_PH, 0.625)
	var phase: float = RivetWalk.phase_of(rig, "p70", scale)
	assert_almost_eq(phase, 0.625, 0.00001)
	rig.face_to = PI / 2.0
	assert_almost_eq(RivetWalk.phase_of(rig, "p70", scale), phase, 0.00001)
	rig.position.x += rig.speed_now * SimClock.TICK_DT
	phase += rig.speed_now * SimClock.TICK_DT / (258.0 * scale)
	assert_almost_eq(RivetWalk.phase_of(rig, "p70", scale), phase, 0.00001)
