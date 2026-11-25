extends GutTest
## n27 withheld gloria's old long-gun grids at p70 (walk_grid.by_weapon gloria: bare_claw_p70).
## n29 drew her own compact-gun p70 walk on the pistol's legs and deleted that row: she walks on
## her own grid, and a sprint borrows the bare run with the held part until her run8 ships.

var rig: CutRig


func before_each() -> void:
	rig = add_child_autofree(CutRig.new())


func test_gloria_is_no_longer_held_only_and_the_pistol_keeps_its_grid() -> void:
	assert_false(RivetFramesGrids.held_only(&"gloria", "p70"), "n29: her own p70 grid")
	assert_false(RivetFramesGrids.held_only(&"gloria", "p55"), "p55 keeps her own grids")
	assert_false(RivetFramesGrids.held_only(&"pistol", "p70"))
	assert_eq(RivetFramesGrids.grid_for(&"gloria"), RivetFramesGrids.BARE, "the sprint fallback")


func test_gloria_walks_on_her_own_p70_grid() -> void:
	var dir: String = RivetStrips.DIR + "p70/"
	rig.speed_now = 2.4 * CharacterRigs.PX_PER_M
	var own: String = dir + RivetWalk.ARMED + "gloria.png"
	assert_eq(RivetWalk.motion_path(rig, "p70", &"gloria"), own)
	assert_eq(RivetWalk.path_of(rig, "p70", &"gloria"), own)


func test_gloria_sprints_on_a_run_grid_never_the_old_long_gun() -> void:
	var dir: String = RivetStrips.DIR + "p70/"
	rig.speed_now = 3.2 * CharacterRigs.PX_PER_M
	var own_run: String = dir + RivetWalk.ARMED_RUN + "gloria.png"
	var want: String = own_run if RivetStrips.has_file(own_run) else dir + RivetWalk.RUN
	assert_eq(RivetWalk.motion_path(rig, "p70", &"gloria"), want)


func test_a_weapon_with_its_own_grid_still_uses_it() -> void:
	rig.speed_now = 2.4 * CharacterRigs.PX_PER_M
	var dir: String = RivetStrips.DIR + "p70/"
	assert_eq(RivetWalk.motion_path(rig, "p70", &"pistol"), dir + RivetWalk.ARMED + "pistol.png")


func test_gloria_at_p55_is_untouched_by_the_p70_grid() -> void:
	rig.speed_now = 2.4 * CharacterRigs.PX_PER_M
	var dir: String = RivetStrips.DIR + "p55/"
	assert_false(ResourceLoader.exists(dir + RivetWalk.ARMED + "gloria.png"), "no p55 grid exists")
	assert_eq(RivetWalk.motion_path(rig, "p55", &"gloria"), dir + RivetWalk.STRIP)


func test_held_only_loads_the_table_on_a_cold_start() -> void:
	RivetFramesGrids._grid = {}
	RivetFramesGrids._held_only = {}
	assert_false(RivetFramesGrids.held_only(&"gloria", "p70"))
	assert_eq(RivetFramesGrids.grid_for(&"katana"), &"katana", "the table was read")
