extends GutTest
## Average seed 9, wave 39. Positions are in metres relative to the start of block 39.

const WALL: Rect2 = Rect2(0, 6, 32, 1)
const START: Vector2 = Vector2(19.326, -0.186581)
const FAR_TARGET: Vector2 = Vector2(18.471, 5.486659)

var session: GauntletSession
var arena: CombatArena


func before_each() -> void:
	var run: GauntletRun = GauntletRun.new()
	run.controls = &"wheel"
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	session = GauntletSession.open_street(bus, data, run)
	arena = session.stage.arena
	session.stage.walls.boxes.assign([WALL])
	arena.guard_map = GuardRouteMap.new(
		Rect2(0, -7, 32, 14), session.stage.walls.boxes, null, arena.tuning.human["radius_m"]
	)
	arena.squad_ai.pit.bounds = Rect2(0, -5.55, 31.4, 11.1)
	arena.rivet.pos = START
	session.pilot.ghosts.transform_unlocked = true
	session.pilot.ghosts.forms.apply_locks([&"kerf"])
	_press(&"power_hauler")
	for i: int in session.pilot.ghosts.forms.table.form(&"kerf").enter_ticks:
		session.pilot.drive(session.stage, TickInput.new())
	assert_true(session.pilot.ghosts.settled_in(&"kerf"))


func after_each() -> void:
	session.close()


func _press(action: StringName, aim: Vector2 = Vector2.ZERO) -> void:
	var buttons: int = 1 << session.actions.bit(action)
	buttons |= PlayerCommand.pack_aim(aim, session.actions)
	session.pilot.drive(session.stage, TickInput.new(buttons))


func _foe(at: Vector2, archetype: StringName = &"patrol_cop") -> Fighter:
	var foe: Fighter = arena.squad_ai.spawn_member(arena, at, archetype)
	foe.pos = at
	return foe


func test_player_kerf_slice_keeps_the_street_in_reach() -> void:
	var target: Fighter = _foe(FAR_TARGET)
	var next: Fighter = _foe(START + Vector2.RIGHT * 4.0)
	_press(&"melee", START.direction_to(target.pos))
	if arena.rivet.pos.y >= WALL.end.y:
		pending("NEED melee: keep a player-controlled Kerf blink on the near side of a wall")
		return
	assert_false(session.stage.walls.blocks(arena.rivet.pos, next.pos))
	assert_lte(arena.rivet.pos.y, WALL.position.y - arena.rivet.radius_m)


func test_bot_checks_the_target_its_recorded_aim_will_slice() -> void:
	var far_foe: Fighter = _foe(FAR_TARGET, &"rocket_trooper")
	var near_foe: Fighter = _foe(Vector2(19.530, 1.790448), &"swat")
	var aim: Vector2 = Vector2(-0.014023, 0.999902).normalized()
	var view: BotViewArena = BotViewArena.new(session.stage, session.actions, true)
	view.street_layout = session.street
	view.refresh()
	var input: TickInput = TickInput.new(PlayerCommand.pack_aim(aim, session.actions))
	var recorded: Vector2 = PlayerCommand.decode(input, 0, session.actions).aim
	assert_same(session.pilot.kerf.pick(session.stage, aim), near_foe)
	assert_same(session.pilot.kerf.pick(session.stage, recorded), far_foe)
	assert_false(view.blink_clear(aim), "the recorded ray would take Kerf through the wall")
	var clear_aim: Vector2 = START.direction_to(near_foe.pos)
	assert_true(view.blink_clear(clear_aim))
	var hp: float = near_foe.hp
	_press(&"melee", clear_aim)
	assert_lt(near_foe.hp, hp)
	assert_false(session.stage.walls.blocks(arena.rivet.pos, far_foe.pos))


func test_blink_opening_requires_the_packed_ray_to_pick_its_armoured_target() -> void:
	var shield: Fighter = _foe(START + Vector2(0.02, 2.5), &"shield_robot")
	shield.facing = Vector2.UP
	@warning_ignore("return_value_discarded")
	arena.squad_ai.mind_for(shield)
	var view: BotViewArena = BotViewArena.new(session.stage, session.actions, true)
	view.street_layout = session.street
	view.refresh()
	assert_true(view.hostiles()[0].can_blink, "the rear of the lone shield is clear")
	@warning_ignore("return_value_discarded")
	_foe(Vector2(START.x, FAR_TARGET.y))
	view.refresh()
	assert_false(view.hostiles()[0].can_blink, "the packed ray picks the foe at the wall")
