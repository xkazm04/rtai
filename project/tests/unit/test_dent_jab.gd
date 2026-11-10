extends GutTest
## n15 hero h-4: Dent's fallback arm jab (DentJab, ghost_attacks.json dent.jab) on quest 1's stage
## through the bound pilot. With no car seized, a melee press as Dent winds up, then strikes the
## body in front of him (not one behind or out of reach), one jab per jab_gap_s; the shipped jab is
## never stronger than Rivet's claw jab; jab 0 is the before (the press does nothing).

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


func _wait(ticks: int) -> void:
	for i: int in ticks:
		_press(&"")


func _guard(off: Vector2, hp: float) -> Fighter:
	var g: Fighter = _stage.arena.spawn_guard(_stage.arena.rivet.pos)
	g.pos = _stage.arena.rivet.pos + off
	g.max_hp = hp
	g.hp = hp
	return g


## G picks Dent (Tonnage first), Q transforms, the jab waits for the settled form.
func _take_dent() -> void:
	while _pilot.ghosts.forms.selected != DentStage.GHOST:
		_press(&"power_gearbox")
		_press(&"")
	_press(&"power_hauler")
	_wait(_pilot.ghosts.forms.table.form(DentStage.GHOST).enter_ticks + 1)
	assert_true(_pilot.ghosts.settled_in(DentStage.GHOST), "Dent is settled")


func _windup() -> int:
	return roundi(_pilot.ghosts.jab.num(&"jab_windup_s") / SimClock.TICK_DT)


func test_the_jab_winds_up_then_strikes_the_body_in_front() -> void:
	var front: Fighter = _guard(Vector2(1.0, 0.0), 5.0)
	var behind: Fighter = _guard(Vector2(-1.0, 0.0), 5.0)
	var far: Fighter = _guard(Vector2(4.0, 0.0), 5.0)
	_take_dent()
	var x0: float = front.pos.x
	_press(&"melee")
	assert_true(_pilot.ghosts.jab.winding(), "the press winds up first")
	assert_eq(front.hp, 5.0, "no damage in the wind-up")
	_wait(_windup())
	assert_eq(front.hp, 5.0 - _pilot.ghosts.jab.num(&"jab_damage"), "the jab lands")
	assert_gt(front.pos.x, x0, "shoved away along the jab")
	assert_eq(behind.hp, 5.0, "a body behind him is not struck")
	assert_eq(far.hp, 5.0, "out of reach")
	assert_eq(_pilot.ghosts.jab.landed, 1)
	assert_true(_pilot.ghosts.owns_melee(), "the claw still never swings in Dent's form")


func test_one_jab_per_gap() -> void:
	var front: Fighter = _guard(Vector2(1.0, 0.0), 9.0)
	_take_dent()
	_press(&"melee")
	_press(&"")
	_press(&"melee")  # inside jab_gap_s: refused
	_wait(_windup() + 2)
	assert_eq(_pilot.ghosts.jab.presses, 1, "a mash inside the gap starts no second jab")
	_wait(roundi(_pilot.ghosts.jab.num(&"jab_gap_s") / SimClock.TICK_DT))
	_press(&"melee")
	_wait(_windup() + 1)
	assert_eq(_pilot.ghosts.jab.swings, 2)
	assert_eq(front.hp, 9.0 - 2.0 * _pilot.ghosts.jab.num(&"jab_damage"))


func test_the_jab_is_never_stronger_than_rivets_claw_jab() -> void:
	var jab: DentJab = DentJab.new()
	var claw: MeleeHit = MeleeTable.shipped().hits[0]
	assert_true(jab.on(), "shipped on (the owner's Call)")
	assert_lte(jab.num(&"jab_damage"), claw.damage)
	assert_lte(jab.num(&"jab_reach_m"), claw.reach_m)
	assert_gte(jab.num(&"jab_cone_dot"), claw.cone_dot, "a cone no wider")
	assert_lte(jab.num(&"jab_knock_m"), claw.knockback_m)
	assert_gte(_windup(), claw.windup, "no faster to land")


func test_jab_off_is_the_before() -> void:
	var off: GhostAttacks = GhostAttacks.new()
	var dent: Dictionary = GhostAttacks.shipped().block(DentStage.GHOST).duplicate()
	dent["jab"] = 0
	off.blocks[DentStage.GHOST] = dent
	_pilot.ghosts.jab = DentJab.new(off)
	var front: Fighter = _guard(Vector2(1.0, 0.0), 5.0)
	_take_dent()
	_press(&"melee")
	_wait(_windup() + 2)
	assert_eq(front.hp, 5.0, "jab 0: the press does nothing")
	assert_eq(_pilot.ghosts.jab.presses, 0)
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	_pilot.ghosts.jab.write_state(out)
	assert_eq(out.get_size(), 0, "no jab pressed: no state bytes (the old replay hash)")
