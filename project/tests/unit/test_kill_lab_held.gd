extends GutTest
## n16 tools (kills-new REQUEST 3): the kill lab held the trigger 1 tick per shot, so the Gatling's
## barrels (spin_s) never spun up and the reel's lab never killed with it. A spun gun is now held
## through its spin-up and three rounds; a tap gun still taps.


func _held(weapon: StringName) -> int:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var world: World = World.new()
	world.start(bus, data, 7)
	var stage: ArenaStage = ArenaStage.new(ArenaPlan.shipped(), ArenaStations.shipped())
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	world.add_system(stage)
	world.loop().step()
	var rng: RandomNumberGenerator = RngRegistry.new(7).stream(&"gunplay")
	stage.arena.gun = GunHand.make(WeaponTable.shipped(), weapon, rng)
	var held: int = KillLab.new()._held_ticks(stage)
	world.free()
	bus.free()
	data.free()
	return held


func test_the_gatling_is_held_past_its_spin_up_for_rounds() -> void:
	var t: WeaponTable = WeaponTable.shipped()
	var rng: RandomNumberGenerator = RngRegistry.new(7).stream(&"gunplay")
	var spec: WeaponSpec = GunHand.make(t, &"gatling", rng).trigger.spec
	assert_gt(spec.spin_ticks, 0, "the Gatling spins up (spin_s)")
	var held: int = _held(&"gatling")
	assert_gte(held, spec.spin_ticks + 2 * spec.interval_ticks, "spun up, then two hits (its TTK)")
	assert_lt(held, KillLab.SHOT_EVERY, "released before the next shot")


func test_a_tap_gun_still_taps() -> void:
	assert_eq(_held(&"pistol"), 1)
