extends GutTest
## rivet-arsenal: a carried melee weapon in the live pilot. With the katana drawn (RivetCarry slot
## 2), a held fire swings its combo (melee_weapons.json): the 2.1 m slash reaches a cop at 2.3 m
## that the claw (1.6 m slam) cannot, the hits are dealt as `katana`, no gun fires, and nothing
## swings during the draw.
## Planted fault: the bare claw at the same distance never lands.

const COP_M: float = 2.3

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


func _carry_katana() -> void:
	var carry: RivetCarry = RivetCarry.new(
		WeaponTable.shipped(), ArsenalTable.shipped(), _ctx.rng.stream(&"gunplay")
	)
	assert_eq(carry.add(&"katana"), 1, "the katana rides in the long slot")
	carry.select(1, _stage.arena)
	_pilot.carry = carry


## Holds fire (aimed down at the cop) for `ticks`; returns the first tick a hit landed (-1: none).
func _hold_fire(ticks: int) -> int:
	var bits: int = 1 << _pilot.actions.bit(&"fire")
	bits |= PlayerCommand.pack_aim(Vector2.DOWN, _pilot.actions)
	var first: int = -1
	for t: int in ticks:
		_pilot.drive(_stage, TickInput.new(bits, 0, 0))
		_stage.arena.rivet.pos += _stage.intent.move_by
		_stage.intent.clear()
		if first < 0 and _pilot.melee.landed > 0:
			first = t
	return first


func _cop() -> Fighter:
	var g: Fighter = _stage.arena.spawn_guard(_stage.arena.rivet.pos)
	g.pos = _stage.arena.rivet.pos + Vector2.DOWN * COP_M
	g.hp = 100.0
	g.max_hp = 100.0
	return g


func test_the_katana_reaches_and_cuts_as_katana() -> void:
	_carry_katana()
	var cop: Fighter = _cop()
	var first: int = _hold_fire(90)
	assert_true(_pilot.wielding(), "the katana is in the claw")
	assert_eq(_pilot.melee.weapon_id, &"katana", "the katana's combo plays")
	assert_gt(first, 0, "a slash landed at %.1f m" % COP_M)
	var draw: int = ArsenalTable.shipped().grip_of(&"katana").draw_ticks
	assert_gte(first, draw, "nothing swings before the draw ends")
	assert_lt(cop.hp, 100.0, "the cop took katana damage")
	assert_null(_stage.arena.gun, "the gun is put away")
	assert_eq(_stage.arena.shots.size(), 0, "no round left the claw")
	gut.p("katana: first slash landed at tick %d (draw %d), cop hp %.1f" % [first, draw, cop.hp])


func test_planted_fault_the_bare_claw_does_not_reach() -> void:
	var cop: Fighter = _cop()
	for t: int in 90:
		var bits: int = (1 << _pilot.actions.bit(&"melee")) if t % 5 == 0 else 0
		_pilot.drive(_stage, TickInput.new(bits, 0, 0))
		_stage.intent.clear()
	assert_eq(_pilot.melee.landed, 0, "the claw at %.1f m whiffs" % COP_M)
	assert_eq(cop.hp, 100.0)
