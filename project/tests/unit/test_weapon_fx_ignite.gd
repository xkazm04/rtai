extends GutTest
## Lane n7-ranged (brief item 5, the flamer's ignition read): the round that lights the flamer
## draws a big nozzle flare that shrinks back to the stream's lick; a steady stream keeps the
## plain lick, a rest lights it again, and --feel=off (or a weapon without the row) means none.

const BASE: float = 0.45


func after_each() -> void:
	WeaponFxIgnite.reset()


## The lick scale at each tick of a stream fired every 3 ticks over [from, to).
func _stream(from: int, to: int) -> Array[float]:
	var out: Array[float] = []
	for t: int in range(from, to):
		var shot: int = t - (t - from) % 3
		out.append(WeaponFxIgnite.lick_k(&"flamethrower", shot, t, BASE))
	return out


func test_the_lighting_round_flares_then_shrinks_to_the_lick() -> void:
	WeaponFxIgnite.reset(HitFeel.shipped())
	var flare: Vector2 = HitFeel.shipped().ignite_flare(&"flamethrower")
	assert_gt(flare.x, BASE, "the flamer has a flare bigger than its lick")
	var ks: Array[float] = _stream(100, 160)
	assert_almost_eq(ks[0], flare.x, 0.001, "full flare on the lighting round")
	assert_gt(ks[1], ks[int(flare.y) - 1], "shrinking")
	assert_eq(ks[int(flare.y)], BASE, "back to the lick once the flare is over")
	assert_eq(ks[59], BASE, "a steady stream does not flare again")
	assert_almost_eq(_stream(190, 191)[0], flare.x, 0.001, "rested 30 ticks: lights again")


func test_off_and_other_guns_keep_the_lick() -> void:
	var off: HitFeel = HitFeel.shipped()
	off.enabled = false
	WeaponFxIgnite.reset(off)
	assert_eq(_stream(100, 101)[0], BASE, "--feel=off: no flare")
	WeaponFxIgnite.reset(HitFeel.shipped())
	assert_eq(WeaponFxIgnite.lick_k(&"pistol", 100, 100, 1.0), 1.0, "no row: no flare")
