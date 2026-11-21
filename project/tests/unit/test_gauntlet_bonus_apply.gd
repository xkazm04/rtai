extends GutTest


class WalkEast:
	extends InputSource

	func sample(_tick: int) -> TickInput:
		return TickInput.new(0, TickInput.AXIS_MAX, 0)


var run: GauntletRun
var session: GauntletSession
var draw: GauntletDraw


func _open(state: GauntletRun) -> GauntletSession:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	return GauntletSession.open_street(bus, data, state, WalkEast.new())


func before_each() -> void:
	run = GauntletRun.new()
	session = _open(run)
	draw = GauntletDraw.new(session.world.context().rng)


func after_each() -> void:
	session.close()


func _take(id: StringName) -> void:
	assert_true(session.bonuses.apply(draw.rows[id]))


func test_speed_and_repair_apply_from_base_and_are_private_to_the_run() -> void:
	var control: GauntletSession = _open(GauntletRun.new())
	_take(&"stat_speed_25")
	_take(&"stat_regen_25")
	var arena: CombatArena = session.stage.arena
	var start: float = arena.rivet.pos.x
	for tick: int in 60:
		session.step()
		control.step()
	var ordinary: float = control.stage.arena.rivet.pos.x - start
	var boosted: float = arena.rivet.pos.x - start
	Log.info("gauntlet-test", "60 ticks walk %.3f m, boosted %.3f m" % [ordinary, boosted])
	assert_gt(boosted, ordinary * 1.15)
	assert_ne(arena.tuning, control.stage.arena.tuning)
	assert_eq(arena.tuning.rivet["walk_mps"], 8.4375)
	assert_eq(arena.tuning.rivet["repair_per_s"], 12.5)
	assert_eq(control.stage.arena.tuning.rivet["walk_mps"], 6.75)
	assert_eq(control.stage.arena.tuning.rivet["repair_per_s"], 10.0)
	control.close()


func test_hp_grants_preserve_existing_wounds_and_guard_meter_is_recorded() -> void:
	var guard: PlayerGuard = PlayerGuard.new()
	session.pilot.guard = guard
	var rivet: Fighter = session.stage.arena.rivet
	rivet.hp -= 8.0
	_take(&"stat_hp_max_25")
	assert_eq(rivet.max_hp, 125.0)
	assert_eq(rivet.hp, 117.0)
	_take(&"stat_guard_meter_10")
	assert_eq(rivet.hp, 117.0)
	assert_eq(run.mods.value(&"guard_meter"), 1.1)
	guard._drain(guard.tuning.meter_max)
	assert_almost_eq(guard.meter(), 1.0 - 1.0 / 1.1, 0.00001)
	assert_false(guard.broken())


func test_latest_weapon_is_drawn_and_the_ghost_lock_opens() -> void:
	var arena: CombatArena = session.stage.arena
	_take(&"weapon_pistol")
	assert_eq(arena.rivet.weapon, &"pistol")
	assert_not_null(arena.gun)
	_take(&"weapon_katana")
	assert_eq(arena.rivet.weapon, &"katana")
	assert_null(arena.gun)
	assert_has(session.pilot.carry.slots, &"pistol")
	var forms: GhostForms = session.pilot.ghosts.forms
	assert_false(forms.locks.allows(forms.table, &"ohm"))
	_take(&"ghost_ohm")
	assert_true(forms.locks.allows(forms.table, &"ohm"))
	assert_eq(forms.selected, &"ohm")


func test_spawned_hostile_takes_scaled_damage_and_armour_still_applies() -> void:
	var arena: CombatArena = session.stage.arena
	_take(&"stat_damage_25")
	var foe: Fighter = arena.squad_ai.spawn_member(arena, Vector2(8, 0), &"robot_thug")
	var before: float = foe.hp
	arena.damage(foe, 2.0, arena.rivet.id, &"claw")
	assert_eq(before - foe.hp, 2.5)
	var shield: Fighter = arena.squad_ai.spawn_member(arena, Vector2(7, 0), &"shield_robot")
	shield.facing = shield.pos.direction_to(arena.rivet.pos)
	session.step()
	var arch: EnemyRoster.Archetype = arena.squad_ai.pit.roster.archetype(&"shield_robot")
	assert_eq(shield.damage_k, 1.25 * arch.shield_front_mult)


func _hold_trigger(arena: CombatArena) -> int:
	var target: Vector2 = arena.rivet.pos + Vector2.RIGHT * 3.0
	for tick: int in 60:
		@warning_ignore("return_value_discarded")
		arena.gun.pull(arena.rivet, target)
		arena.gun.settle()
	return arena.gun.shots_fired


func test_granted_pistol_retaps_for_a_bot_and_waits_for_a_human_press() -> void:
	_take(&"weapon_pistol")
	var bot_run: GauntletRun = GauntletRun.new()
	bot_run.profile = &"average"
	var bot: GauntletSession = _open(bot_run)
	assert_true(bot.bonuses.apply(draw.rows[&"weapon_pistol"]))
	assert_eq(_hold_trigger(session.stage.arena), 1)
	assert_gt(_hold_trigger(bot.stage.arena), 1)
	bot.close()


func test_sidearm_replaces_slot_zero_and_an_unknown_grant_preserves_it() -> void:
	_take(&"weapon_pistol")
	_take(&"weapon_hand_cannon")
	var carry: RivetCarry = session.pilot.carry
	assert_eq(carry.current, 0)
	assert_eq(carry.slots[0], &"hand_cannon")
	assert_eq(session.stage.arena.rivet.weapon, &"hand_cannon")
	assert_false(session.bonuses.apply({"kind": "weapon", "ref": &"unknown_sidearm"}))
	assert_eq(carry.weapon(), &"hand_cannon")
	assert_eq(session.stage.arena.rivet.weapon, &"hand_cannon")
