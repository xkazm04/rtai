extends GutTest
## n7-melee RamWake (ghost_attacks.json tonnage ram_wake_k, view only): the press's bow wave calls
## the ram before the contact. It is off below 0.8 of ram_mps, grows to full at ram_mps (the speed
## at which a touch starts to hurt), and ram_wake_k scales it (0 = the before).


func test_the_wave_grows_in_as_the_press_reaches_ram_speed() -> void:
	var ram: float = HaulerStage.shipped().form.num(&"ram_mps")
	assert_gt(ram, 0.0, "the hauler has a ram speed")
	assert_eq(RamWake.strength(0.0, ram), 0.0, "none standing still")
	assert_eq(RamWake.strength(ram * 0.79, ram), 0.0, "none well below the ram speed")
	var mid: float = RamWake.strength(ram * 0.9, ram)
	assert_gt(mid, 0.0, "it grows in just below the ram speed (the call before the hurt)")
	assert_lt(mid, RamWake.strength(ram, ram), "and is stronger at it")
	assert_almost_eq(RamWake.strength(ram * 1.5, ram), RamWake.strength(ram, ram), 0.0001, "capped")
	assert_gt(RamWake.strength(ram, ram), 0.0, "the shipped ram_wake_k draws it")
