extends GutTest
## rivet-arsenal: the flamethrower's hose sways the sim's fire line (rivet_arsenal.json
## backpack_hose sway_rad / sway_ticks) instead of a recoil kick, so the jet and the wand move as
## one: a held trigger sends fire_at either side of the aim within sway_rad, and the pilot's
## sway_rad (which ArenaRigs turns the arm onto) is the same angle.
## Planted fault: the pistol (one_hand, no sway) fires exactly on the aim line.

var _stage: CollectCallStage
var _pilot: StagePilot
var _ctx: WorldContext


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_stage = CollectCallStage.new(StageLayout.shipped())
	_ctx = World.build_context(bus, data, 1)
	_stage.setup(_ctx)
	_pilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = _pilot
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)


func _carry(id: StringName) -> void:
	var carry: RivetCarry = RivetCarry.new(
		WeaponTable.shipped(), ArsenalTable.shipped(), _ctx.rng.stream(&"gunplay")
	)
	carry.select(carry.add(id), _stage.arena)
	_pilot.carry = carry


## Holds fire aimed right for `ticks` after the draw; the fire line's angles off the aim.
func _fire_angles(id: StringName, ticks: int) -> PackedFloat32Array:
	_carry(id)
	var bits: int = 1 << _pilot.actions.bit(&"fire")
	bits |= PlayerCommand.pack_aim(Vector2.RIGHT, _pilot.actions)
	var out: PackedFloat32Array = PackedFloat32Array()
	for t: int in 60 + ticks:
		_stage.tick = t
		_stage.intent.clear()
		_pilot.drive(_stage, TickInput.new(bits, 0, 0))
		if _stage.intent.fire_at != Vector2.INF:
			var a: float = (_stage.intent.fire_at - _stage.arena.rivet.pos).angle()
			assert_almost_eq(a, _pilot.sway_rad, 0.001, "the wand's angle is the jet's")
			@warning_ignore("return_value_discarded")
			out.push_back(a)
	return out


func test_the_flame_line_sways_both_sides_within_sway_rad() -> void:
	var g: ArsenalTable.Grip = ArsenalTable.shipped().grips[&"backpack_hose"]
	var angles: PackedFloat32Array = _fire_angles(&"flamethrower", g.sway_ticks)
	assert_gt(angles.size(), g.sway_ticks / 2, "the trigger fires through the sway")
	var lo: float = INF
	var hi: float = -INF
	for a: float in angles:
		lo = minf(lo, a)
		hi = maxf(hi, a)
	assert_gt(hi, g.sway_rad * 0.8, "it swings to one side")
	assert_lt(lo, -g.sway_rad * 0.8, "and to the other")
	assert_lt(maxf(hi, -lo), g.sway_rad + 0.001, "never past sway_rad")


func test_no_sway_once_the_trigger_is_released() -> void:
	@warning_ignore("return_value_discarded")
	_fire_angles(&"flamethrower", 20)
	_pilot.drive(_stage, TickInput.new(0, 0, 0))
	assert_eq(_pilot.sway_rad, 0.0)


func test_planted_fault_the_pistol_fires_on_the_aim_line() -> void:
	var angles: PackedFloat32Array = _fire_angles(&"pistol", 30)
	assert_gt(angles.size(), 0)
	for a: float in angles:
		assert_almost_eq(a, 0.0, 0.0001, "a one-hand gun has no sway")
