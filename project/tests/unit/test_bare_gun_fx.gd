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


func test_rifle_round_draws_with_the_stand_in() -> void:
	var s: Shot = _rifle_round(_arena())
	assert_null(s.spec, "the rifle has no weapons.json row")
	assert_eq(BareGunFx.stand_in(s), &"machine_pistol")
	assert_ne(WeaponFxArt.art().muzzle_fx(BareGunFx.stand_in(s)), &"", "the stand-in has a flash")


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
