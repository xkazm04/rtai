extends GutTest
## Exact calibration used by the pre-table grids. Independent of the JSON loader.

const RUN_CYCLE_CELL: Dictionary[String, float] = {"p70": 258.0, "p55": 212.0}
const CYCLE_CELL: Dictionary[String, float] = {"p70": 60.0, "p55": 60.0}
const ARMED_CYCLE_CELL: Dictionary[String, float] = {
	"p70/machine_pistol": 73.7,
	"p70/hand_cannon": 69.7,
	"p70/assault_rifle": 78.0,
	"p70/electro_baton": 68.7,
	"p70/chainsaw": 64.3,
	"p70/rocket_launcher": 84.0,
	"p70/gloria": 86.7,
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
	"p70/gloria/0": 0.98,
	"p70/gloria/3": 0.97,
	"p70/gloria/4": 0.92,
	"p70/gatling/4": 0.94,
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
	StrideMatch.ROOT + "p70/rivet_walk_eq_machine_pistol.png": Vector2(21.0, 27.0),
	StrideMatch.ROOT + "p70/rivet_walk_eq_hand_cannon.png": Vector2(25.0, 30.0),
	StrideMatch.ROOT + "p70/rivet_walk_eq_assault_rifle.png": Vector2(20.5, 29.5),
	StrideMatch.ROOT + "p70/rivet_walk_eq_electro_baton.png": Vector2(15.0, 28.5),
	StrideMatch.ROOT + "p70/rivet_walk_eq_chainsaw.png": Vector2(18.5, 28.0),
	StrideMatch.ROOT + "p70/rivet_walk_eq_rocket_launcher.png": Vector2(23.0, 36.5),
	StrideMatch.ROOT + "p70/rivet_walk_eq_gloria.png": Vector2(26.0, 32.5),
}


func test_all_five_calibrations_match_the_measured_grids() -> void:
	var grid: RivetGridStride = RivetGridStride.shared()
	assert_eq(grid.run_cycle_cell, RUN_CYCLE_CELL)
	assert_eq(grid.cycle_cell, CYCLE_CELL)
	assert_eq(grid.armed_cycle_cell, ARMED_CYCLE_CELL)
	assert_eq(grid.run_row_k, RUN_ROW_K)
	assert_eq(grid.walk_profile_travel, WALK_PROFILE_TRAVEL)


func test_bare_phase_carries_distance_across_unequal_stances_and_back() -> void:
	var cycles: Vector2 = Vector2(40.0, 80.0)
	assert_almost_eq(RivetWalk.bare_phase(0.25, 18.0, cycles), 0.6, 0.00001)
	assert_almost_eq(RivetWalk.bare_phase(0.6, -18.0, cycles), 0.25, 0.00001)
	assert_almost_eq(RivetWalk.bare_phase(0.9, 12.0, cycles), 0.1, 0.00001)
	assert_almost_eq(RivetWalk.bare_phase(0.1, -12.0, cycles), 0.9, 0.00001)


func test_live_bare_profile_uses_the_two_stances_at_game_speed() -> void:
	var rig: CutRig = add_child_autofree(CutRig.new())
	var card: Sprite2D = Sprite2D.new()
	rig.add_child(card)
	rig.head_card = card
	var path: String = StrideMatch.ROOT + "p70/rivet_run8.png"
	card.texture = load(path)
	card.set_meta(RivetFrames.ON, path)
	card.hframes = 8
	card.vframes = 8
	var grid: RivetGridStride = RivetGridStride.shared()
	var profile: Vector2 = grid.bare_run["p70"][2]
	var scale: float = 0.72
	rig.speed_now = 9.3 * CharacterRigs.PX_PER_M
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
