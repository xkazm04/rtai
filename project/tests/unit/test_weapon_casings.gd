extends GutTest
## features/combat/weapons/art/weapon_casings.gd: one casing per new round, thrown to the gun claw's
## side of the aim, the same places for the same round count (no RNG), none for casing-less guns,
## a tick that runs backwards clears the floor, and the floor keeps at most MAX_LYING.


func before_each() -> void:
	WeaponCasings.clear()


func _gun() -> GunHand:
	var reg: RngRegistry = RngRegistry.new(3)
	return GunHand.make(WeaponTable.shipped(), &"pistol", reg.stream(&"gunplay"))


func test_one_casing_per_round_on_the_gun_side() -> void:
	var r: Fighter = Fighter.make(Fighter.Kind.RIVET, 0, Vector2.ZERO, 100.0)
	var gun: GunHand = _gun()
	for i: int in 3:
		gun.shots_fired = i + 1
		WeaponCasings.track(r, gun, 10 * i, &"casing")
		WeaponCasings.track(r, gun, 10 * i + 1, &"casing")  # the same round again: no new brass
	assert_eq(WeaponCasings.count(), 3)
	gun.shots_fired = 4
	WeaponCasings.track(r, gun, 40, &"")
	assert_eq(WeaponCasings.count(), 3, "a gun without a casing cell drops none")


func test_backwards_tick_clears_and_the_floor_is_capped() -> void:
	var r: Fighter = Fighter.make(Fighter.Kind.RIVET, 0, Vector2.ZERO, 100.0)
	var gun: GunHand = _gun()
	for i: int in WeaponCasings.MAX_LYING + 10:
		gun.shots_fired = i + 1
		WeaponCasings.track(r, gun, i, &"casing")
	assert_eq(WeaponCasings.count(), WeaponCasings.MAX_LYING)
	gun.shots_fired = 1
	WeaponCasings.track(r, gun, 0, &"casing")
	assert_lt(WeaponCasings.count(), 2, "a replay from the start clears the floor")


func test_brass_lands_off_the_aim_line_on_the_claw_side() -> void:
	var r: Fighter = Fighter.make(Fighter.Kind.RIVET, 0, Vector2.ZERO, 100.0)
	r.facing = Vector2.RIGHT
	var gun: GunHand = _gun()
	gun.shots_fired = 1
	WeaponCasings.track(r, gun, 5, &"casing")
	var to: Vector2 = WeaponCasings._to[0]
	assert_lt(to.y, -0.5, "thrown to aim.orthogonal() (screen up when aiming right)")
