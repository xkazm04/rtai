extends GutTest
## n7-ranged (it16): quest 1's picked-up rifle (no weapons.json row) draws its rounds and flash
## with the rivet_arsenal.json art stand-in; enemy rounds and table-gun rounds are left alone.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _rifle_round(arena: CombatArena) -> Shot:
	arena.rivet.weapon = &"assault-rifle"
	arena.rifle_ammo = 30
	assert_true(arena.rivet_fire(Vector2(5.0, 0.0)), "Rivet fires the rifle on combat.json's path")
	return arena.shots[-1]


func test_rifle_round_draws_with_its_own_art() -> void:
	var s: Shot = _rifle_round(_arena())
	assert_null(s.spec, "the rifle has no weapons.json row")
	assert_eq(BareGunFx.stand_in(s), &"assault_rifle")
	assert_eq(WeaponFxArt.art().muzzle_fx(BareGunFx.stand_in(s)), &"flash_pistol")


func test_enemy_and_table_rounds_are_not_drawn_here() -> void:
	var s: Shot = _rifle_round(_arena())
	s.from_rivet = false
	assert_eq(BareGunFx.stand_in(s), &"", "an enemy round stays a vermilion dash")
	s.from_rivet = true
	s.spec = WeaponTable.shipped().weapons[&"pistol"]
	assert_eq(BareGunFx.stand_in(s), &"", "a table gun's round is WeaponFxArt's")


func test_art_off_is_the_before() -> void:
	var s: Shot = _rifle_round(_arena())
	WeaponFxArt.enabled = false
	var id: StringName = BareGunFx.stand_in(s)
	WeaponFxArt.enabled = true
	assert_eq(id, &"", "--weapon-fx=shapes keeps the evening path's dashes")


func test_a_turned_round_marks_itself_so_it_draws_no_red_flash() -> void:
	var arena: CombatArena = _arena()
	var s: Shot = _rifle_round(arena)
	assert_false(s.has_meta(PlayerDeflect.TURNED), "Rivet's own round flashes at his bore")
	s.from_rivet = false
	s.shooter_id = 1
	s.vel = Vector2(-10.0, 0.0)
	s.pos = arena.rivet.pos + Vector2(1.0, 0.0)
	assert_true(PlayerDeflect.send_back(arena, s, Vector2.RIGHT), "the round is turned")
	assert_true(s.from_rivet, "it now belongs to Rivet, so BareGunFx draws it")
	assert_true(s.has_meta(PlayerDeflect.TURNED), "and carries the marker that skips the flash")


func test_the_bore_flash_is_for_a_fresh_round_inside_the_flash_ticks_only() -> void:
	var s: Shot = _rifle_round(_arena())
	assert_true(BareGunFx.flashes(s, 0), "a fresh round flashes")
	assert_true(BareGunFx.flashes(s, WeaponFxArt.FLASH_TICKS), "the last flash tick still flashes")
	assert_false(BareGunFx.flashes(s, WeaponFxArt.FLASH_TICKS + 1), "after it, no flash")
	s.set_meta(PlayerDeflect.TURNED, true)
	assert_false(BareGunFx.flashes(s, 0), "a turned round never flashes: red is blood only")
