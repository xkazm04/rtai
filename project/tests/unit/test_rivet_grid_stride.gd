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
