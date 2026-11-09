extends GutTest
## n10 rivet: the pilot's roll puts the gun away on Rivet's rig row (the ball has no gun), but
## its recovery does not: the 10 RECOVER ticks drew him bare-clawed, then the gun popped back.
## Planted fault: the old `phase != FREE` fails test_the_gun_is_back_for_the_recovery.

var _rigs: ArenaRigs
var _stage: CollectCallStage
var _pilot: StagePilot


func before_each() -> void:
	_rigs = ArenaRigs.new()
	autofree(_rigs)
	autofree(_rigs.rigs)
	_stage = CollectCallStage.new(StageLayout.shipped())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_stage.setup(World.build_context(bus, data, 1))
	_pilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = _pilot
	_rigs.stage = _stage
	_pilot.hold.held = &"pistol"
	_pilot.hold.state = WeaponHold.State.READY


func _flags_in(phase: PlayerMotion.Phase) -> int:
	_pilot.motion.phase = phase
	var f: RigFeed = _rigs.rigs.feed
	f.flags[0] = RigFeed.Flag.GUN_OUT | RigFeed.Flag.AIMING
	_rigs._rivet_clips(f)
	return f.flags[0]


func test_the_roll_puts_the_gun_away() -> void:
	assert_eq(_flags_in(PlayerMotion.Phase.ROLL), 0)


func test_the_gun_is_back_for_the_recovery() -> void:
	assert_ne(_flags_in(PlayerMotion.Phase.RECOVER) & RigFeed.Flag.GUN_OUT, 0)


func test_free_keeps_the_gun_out() -> void:
	assert_ne(_flags_in(PlayerMotion.Phase.FREE) & RigFeed.Flag.GUN_OUT, 0)
