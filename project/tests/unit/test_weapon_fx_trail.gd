extends GutTest
## Lane n7-ranged it24: a round of Rivet's that stops in a body leaves its path as a fading trail
## for its weapon's hit_feel.json trail_ticks; the Gatling (no row value) and --feel=off leave
## none, a burst never holds more than MAX_TRAILS, and a trail is gone once its life is over.

const ORIGIN: Vector2 = Vector2(0.0, 0.0)
const WOUND: Vector2 = Vector2(0.0, 5.0)


func after_each() -> void:
	WeaponFxTrail.reset()


func test_a_pistol_hit_leaves_a_trail_that_fades_and_expires() -> void:
	WeaponFxTrail.reset(HitFeel.shipped())
	var life: int = WeaponFxTrail.ticks_of(&"pistol")
	assert_gt(life, 0, "the pistol has a trail")
	var trails: Array[WeaponFxTrail.Trail] = []
	WeaponFxTrail.add(trails, ORIGIN, WOUND, &"pistol", 100)
	assert_eq(trails.size(), 1)
	assert_gt(
		trails[0].from.distance_to(ORIGIN), 1.0, "starts at the held gun, not in Rivet's chest"
	)
	assert_eq(WeaponFxTrail.fade_k(0, life), 1.0, "full on the hit tick")
	assert_gt(WeaponFxTrail.fade_k(1, life), WeaponFxTrail.fade_k(life - 1, life), "fading")
	WeaponFxTrail.expire(trails, 100 + life - 1)
	assert_eq(trails.size(), 1, "still there on its last tick")
	WeaponFxTrail.expire(trails, 100 + life)
	assert_eq(trails.size(), 0, "gone once its life is over")


func test_the_gatling_and_feel_off_leave_none() -> void:
	WeaponFxTrail.reset(HitFeel.shipped())
	var trails: Array[WeaponFxTrail.Trail] = []
	WeaponFxTrail.add(trails, ORIGIN, WOUND, &"gatling", 100)
	assert_eq(trails.size(), 0, "sustained fire draws no curtain of lines")
	var off: HitFeel = HitFeel.shipped()
	off.enabled = false
	WeaponFxTrail.reset(off)
	WeaponFxTrail.add(trails, ORIGIN, WOUND, &"pistol", 100)
	assert_eq(trails.size(), 0, "--feel=off: no trail")


func test_a_burst_into_a_crowd_is_capped() -> void:
	WeaponFxTrail.reset(HitFeel.shipped())
	var trails: Array[WeaponFxTrail.Trail] = []
	for i: int in 30:
		WeaponFxTrail.add(trails, ORIGIN, WOUND + Vector2(float(i), 0.0), &"machine_pistol", 100)
	assert_eq(trails.size(), WeaponFxTrail.MAX_TRAILS, "30 hits in one tick hold the cap")
