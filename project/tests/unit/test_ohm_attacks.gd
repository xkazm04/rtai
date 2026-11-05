extends GutTest
## Lane ghost-powers: Ohm's forked bolt (ghost_attacks.json `ohm`) on quest 1's stage through the
## bound pilot: Q takes the soul, the melee press strikes the body in the aim cone and forks to
## the next within fork_radius_m (no farther), each is stunned, a human takes human_damage and a
## robot bolt_damage x machine_k, and the bolts keep bolt_gap_s apart.

var _bus: EventBus
var _data: DataStore
var _stage: CollectCallStage
var _pilot: StagePilot


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_data = autofree(DataStore.new())
	_stage = CollectCallStage.new(StageLayout.shipped())
	_stage.setup(World.build_context(_bus, _data, 1))
	_pilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = _pilot
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)
	_stage.arena.rivet.facing = Vector2.RIGHT


func _press(action: StringName) -> void:
	var buttons: int = 1 << _pilot.actions.bit(action) if action != &"" else 0
	buttons |= PlayerCommand.pack_aim(Vector2.RIGHT, _pilot.actions)
	_pilot.drive(_stage, TickInput.new(buttons, 0, 0))
	_stage.intent.clear()


func _guard(off: Vector2, hp: float) -> Fighter:
	var g: Fighter = _stage.arena.spawn_guard(_stage.arena.rivet.pos)
	g.pos = _stage.arena.rivet.pos + off
	g.max_hp = hp
	g.hp = hp
	return g


## GhostPilot: G picks the ghost (order tonnage, dent, kerf, ohm), Q transforms, and the attack
## waits for the settled form.
func _take() -> void:
	while _pilot.ghosts.forms.selected != OhmStage.GHOST:
		_press(&"power_gearbox")
		_press(&"")
	_press(&"power_hauler")
	for i: int in _pilot.ghosts.forms.table.form(OhmStage.GHOST).enter_ticks + 1:
		_press(&"")


func test_the_bolt_forks_inside_the_radius_and_stuns() -> void:
	var first: Fighter = _guard(Vector2(6.0, 0.0), 5.0)
	var fork: Fighter = _guard(Vector2(8.0, 1.0), 5.0)  # 2.2 m from the first
	var far: Fighter = _guard(Vector2(6.0, -7.0), 5.0)  # outside the cone and the fork radius
	_take()
	_press(&"melee")
	var dmg: float = _pilot.ohm.num(&"human_damage")
	assert_almost_eq(first.hp, 5.0 - dmg, 0.001, "the body in the cone is struck")
	assert_almost_eq(fork.hp, 5.0 - dmg, 0.001, "the bolt forks to the next one")
	assert_almost_eq(far.hp, 5.0, 0.001, "nothing past the fork radius")
	var fx: FighterFx = PlayerShock.areas_of(_stage.arena).fx.get(first.id)
	assert_not_null(fx, "the struck body carries the stun")
	assert_gt(fx.stun_ticks, 0, "stunned")


func test_a_robot_takes_the_machine_multiplier_and_bolts_keep_their_gap() -> void:
	var robot: Fighter = _stage.arena.spawn_boss(_stage.arena.rivet.pos + Vector2(5.0, 0.0))
	robot.max_hp = 20.0
	robot.hp = 20.0
	robot.exposed = true
	_take()
	_press(&"melee")
	var k: float = _pilot.ohm.num(&"bolt_damage") * _pilot.ohm.num(&"machine_k")
	assert_almost_eq(robot.hp, 20.0 - k, 0.001, "bolt_damage x machine_k on a robot")
	robot.exposed = true
	_press(&"melee")
	assert_eq(_pilot.ohm.bolts, 1, "no second bolt inside bolt_gap_s")
