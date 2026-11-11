extends GutTest
## n12: Rivet's drawn strips are fetched before the fight asks for them; the warm lists exactly
## the shipped files his pose can ask for, and RivetFrames hands out the same textures.

const DIR: String = RivetStrips.DIR + "p70/"

var _view: ViewMode = null


func test_paths_list_the_base_strips_and_each_carried_weapons_own() -> void:
	var weapons: Array[StringName] = [&"pistol", &"", &"rocket_launcher"]
	var paths: PackedStringArray = RivetStripWarm.paths("p70", weapons)
	for file: String in [
		"rivet_frames.png",
		"rivet_walk8.png",
		"rivet_eq_pistol.png",
		"rivet_eq_pistol_left.png",
		"rivet_reload_pistol.png",
		"rivet_walk_eq_pistol.png",
		"rivet_run8_eq_pistol.png",
		"rivet_eq_rocket_launcher.png",
	]:
		assert_true(paths.has(DIR + file), file)
	assert_false(paths.has(DIR + "rivet_eq_gatling.png"), "a gun he does not carry")


func test_paths_hold_only_shipped_files_once_each() -> void:
	var weapons: Array[StringName] = [&"pistol", &"pistol", &"flamethrower"]
	var paths: PackedStringArray = RivetStripWarm.paths("p70", weapons)
	assert_true(paths.has(DIR + "rivet_eq_flamethrower_diag.png"), "the diagonal cut")
	for p: String in paths:
		assert_true(ResourceLoader.exists(p), p)
		assert_eq(paths.count(p), 1, p)


func test_paths_match_what_the_pose_asks_for() -> void:
	var paths: PackedStringArray = RivetStripWarm.paths("p70", [&"pistol"] as Array[StringName])
	assert_true(paths.has(RivetStrips.strip_of("p70", &"pistol")))
	assert_true(paths.has(RivetStrips.left_of("p70", &"pistol")))


func test_no_art_key_no_paths() -> void:
	assert_eq(RivetStripWarm.paths("", [&"pistol"] as Array[StringName]).size(), 0)


func test_a_prefetched_strip_is_the_loaded_texture() -> void:
	var path: String = DIR + "rivet_eq_pistol.png"
	StreetStrips.prefetch(path)
	assert_same(StreetStrips.get_tex(path), load(path) as Texture2D)


func test_warm_still_loads_the_carried_guns_art() -> void:
	var art: WeaponArt = WeaponArt.new()
	var slots: Array[StringName] = [&"pistol", &"", &"", &""]
	RivetStripWarm.warm(slots, ArsenalTable.shipped(), art)
	var id: StringName = ArsenalTable.shipped().art_id(&"pistol")
	assert_true(art.has(id), "the pistol has weapon art")
	assert_same(art.held_texture(id), art.held_texture(id), "cached by the warm")


func before_each() -> void:
	_view = ViewMode._shared  # the suite runs under the flat default: hand it back untouched


func after_each() -> void:
	LaunchArgs.parse(PackedStringArray())  # a unit run carries no user args
	TextureThreads.override = -1
	ViewMode._shared = _view


func _warm(view: String, weapon: StringName) -> void:
	ViewMode.select(view)
	var slots: Array[StringName] = [weapon, &"", &"", &""]
	RivetStripWarm.warm(slots, ArsenalTable.shipped(), WeaponArt.new())


func test_warm_asks_a_worker_for_every_strip_of_the_carried_gun() -> void:
	LaunchArgs.parse(PackedStringArray())
	TextureThreads.override = 1  # a real renderer's path (headless never asks a worker)
	_warm("combo", &"gatling")
	var paths: PackedStringArray = RivetStripWarm.paths("p70", [&"gatling"] as Array[StringName])
	assert_true(paths.has(DIR + "rivet_reload_gatling_left.png"))
	for p: String in paths:
		assert_true(StreetStrips.known(p), p)


func test_a_flat_view_fetches_no_strip() -> void:
	LaunchArgs.parse(PackedStringArray())
	_warm("top", &"hand_cannon")
	assert_false(StreetStrips.known(DIR + "rivet_eq_hand_cannon_left.png"), "no cards, no strips")


func test_strip_prefetch_off_fetches_no_strip() -> void:
	LaunchArgs.parse(PackedStringArray(["--strip-prefetch=off"]))
	_warm("combo", &"machine_pistol")
	assert_false(StreetStrips.known(DIR + "rivet_eq_machine_pistol_left.png"), "the before")


func test_headless_asks_no_worker_and_loads_on_first_use() -> void:
	LaunchArgs.parse(PackedStringArray())
	assert_false(
		TextureThreads.allowed(), "the unit run is headless: its renderer is not thread-safe"
	)
	_warm("combo", &"molotov")
	var path: String = DIR + "rivet_eq_molotov_left.png"
	assert_false(StreetStrips.known(path), "no worker decode under the dummy renderer")
	assert_not_null(StreetStrips.get_tex(path), "loaded in place on first use")
