extends GutTest
## n10 call r-2 (owner): a held trigger does not fire while Rivet is in the roll, because no gun is
## drawn in the ball. The recovery fires again.

var _stage: CollectCallStage
var _pilot: StagePilot


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_stage = CollectCallStage.new(StageLayout.shipped())
	var ctx: WorldContext = World.build_context(bus, data, 1)
	_stage.setup(ctx)
	_pilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = _pilot
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)
	var carry: RivetCarry = RivetCarry.new(
		WeaponTable.shipped(), ArsenalTable.shipped(), ctx.rng.stream(&"gunplay")
	)
	carry.select(carry.add(&"pistol"), _stage.arena)
	_pilot.carry = carry


## Holds fire aimed right for `ticks`, the motion phase pinned; how many ticks sent a shot.
func _shots(phase: PlayerMotion.Phase, ticks: int) -> int:
	var bits: int = 1 << _pilot.actions.bit(&"fire")
	bits |= PlayerCommand.pack_aim(Vector2.RIGHT, _pilot.actions)
	var fired: int = 0
	for t: int in ticks:
		_stage.tick += 1
		_stage.intent.clear()
		_pilot.motion.phase = phase
		_pilot.motion._phase_tick = 0
		_pilot.drive(_stage, TickInput.new(bits, 0, 0))
		fired += 1 if _stage.intent.fire_at != Vector2.INF else 0
	return fired


func test_a_held_trigger_fires_when_free() -> void:
	assert_gt(_shots(PlayerMotion.Phase.FREE, 90), 0, "the control: this setup does fire")


func test_no_shot_leaves_during_the_roll() -> void:
	assert_eq(_shots(PlayerMotion.Phase.ROLL, 90), 0, "the ball draws no gun, so it sends no shot")


func test_the_recovery_fires() -> void:
	assert_gt(_shots(PlayerMotion.Phase.RECOVER, 90), 0, "only the roll itself holds fire")
