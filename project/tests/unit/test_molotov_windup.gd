extends GutTest
## rivet-arsenal: the molotov's wind-up in the live pilot (PlayerThrow over rivet_arsenal.json
## thrown windup_ticks). A held fire winds the arm back first; the bottle leaves on the wind-up's
## last tick (one fire_at, one shot), and a tap still throws. A switch mid-wind cancels it.
## Planted fault: a class with windup_ticks 0 throws on the press tick.

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


func _carry(table: ArsenalTable) -> void:
	var carry: RivetCarry = RivetCarry.new(
		WeaponTable.shipped(), table, _ctx.rng.stream(&"gunplay")
	)
	carry.select(carry.add(&"molotov"), _stage.arena)
	_pilot.carry = carry
	_pilot.hold = WeaponHold.new(table)


func _bits(fire: bool) -> int:
	var b: int = PlayerCommand.pack_aim(Vector2.RIGHT, _pilot.actions)
	return b | (1 << _pilot.actions.bit(&"fire")) if fire else b


## Drives until the draw ends, then `presses` (true = fire held) one tick each; the tick offsets
## (from the first press) where a bottle left the gun (the stage's own rivet_fire).
func _throws(presses: Array[bool]) -> PackedInt32Array:
	for t: int in 40:
		_pilot.drive(_stage, TickInput.new(_bits(false), 0, 0))
		_stage.intent.clear()
	var out: PackedInt32Array = PackedInt32Array()
	for i: int in presses.size():
		_pilot.drive(_stage, TickInput.new(_bits(presses[i]), 0, 0))
		var at: Vector2 = _stage.intent.fire_at
		if at != Vector2.INF and _stage.arena.rivet_fire(at):
			@warning_ignore("return_value_discarded")
			out.push_back(i)
		_stage.arena.gun.settle()
		_stage.intent.clear()
	return out


func _held(n: int, fire: bool = true) -> Array[bool]:
	var a: Array[bool] = []
	for i: int in n:
		a.append(fire)
	return a


func test_the_bottle_leaves_at_the_end_of_the_windup() -> void:
	var table: ArsenalTable = ArsenalTable.shipped()
	var w: int = table.grips[&"thrown"].windup_ticks
	assert_gt(w, 0, "the thrown class winds up")
	_carry(table)
	var sent: PackedInt32Array = _throws(_held(w + 4))
	assert_eq(sent, PackedInt32Array([w - 1]), "one bottle, on the wind-up's last tick")
	assert_eq(_pilot.throw.winds, 1)


func test_a_tap_commits_the_whole_windup() -> void:
	var table: ArsenalTable = ArsenalTable.shipped()
	var w: int = table.grips[&"thrown"].windup_ticks
	_carry(table)
	var taps: Array[bool] = [true]
	taps.append_array(_held(w + 4, false))
	assert_eq(_throws(taps), PackedInt32Array([w - 1]), "released at once, still thrown")


func test_planted_fault_no_windup_throws_on_the_press() -> void:
	var table: ArsenalTable = ArsenalTable.shipped()
	table.grips[&"thrown"].windup_ticks = 0
	_carry(table)
	assert_eq(_throws(_held(6)), PackedInt32Array([0]), "windup 0: the bottle leaves at once")
