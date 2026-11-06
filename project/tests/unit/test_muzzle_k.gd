extends GutTest
## n7-ranged: hit_feel.json `weapons` muzzle_k scales Rivet's muzzle flash cell per weapon
## (the pistol's reads at 32 px/m); 1 for a weapon without one, and 1 under --feel=off.


func after_each() -> void:
	WeaponFxIgnite.reset()


func test_the_pistol_flash_is_bigger() -> void:
	var hf: HitFeel = HitFeel.shipped()
	assert_almost_eq(hf.muzzle_k(&"pistol"), 1.6, 0.001)
	assert_gt(hf.muzzle_k(&"gloria"), hf.muzzle_k(&"pistol"), "the heavier sidearm flashes bigger")


func test_the_machine_pistol_flash_is_up_but_under_the_pistol() -> void:
	var hf: HitFeel = HitFeel.shipped()
	var k: float = hf.muzzle_k(&"machine_pistol")
	assert_gt(k, 1.0, "the burst's flicker reads at 32 px/m")
	assert_lt(k, hf.muzzle_k(&"pistol"), "14 rounds a second: a smaller cell than a single shot")


func test_a_weapon_without_a_row_keeps_the_art_size() -> void:
	var hf: HitFeel = HitFeel.shipped()
	assert_eq(hf.muzzle_k(&"plasma_rifle"), 1.0)


func test_feel_off_keeps_the_art_size() -> void:
	var hf: HitFeel = HitFeel.shipped()
	hf.enabled = false
	assert_eq(hf.muzzle_k(&"pistol"), 1.0)


func test_the_fx_art_reads_the_feel_table() -> void:
	var hf: HitFeel = HitFeel.shipped()
	WeaponFxIgnite.reset(hf)
	assert_almost_eq(WeaponFxIgnite.muzzle_k(&"pistol"), 1.6, 0.001)
	hf.enabled = false
	assert_eq(WeaponFxIgnite.muzzle_k(&"pistol"), 1.0)
