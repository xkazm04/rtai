extends GutTest
## n31 melee 03: the gauntlet street feeds signature kills. A held chainsaw grinds a shieldless
## patrol cop to death in a headless street session with the feed installed: the kill plays
## `chainsaw_grind` (owner rule) and the victim is consumed. With reduced gore (`--gore=reduced`)
## the same kill is the standard death and nothing is consumed.
## Planted fault: a feed whose hook is not stepped by the stage records no kill.

var session: GauntletSession
var arena: CombatArena
var rows: Array[StringName] = []


func before_each() -> void:
	var run: GauntletRun = GauntletRun.new()
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	session = GauntletSession.open_street(bus, data, run)
	arena = session.stage.arena
	rows.clear()


func after_each() -> void:
	session.close()


func _on_killed(_id: int, _serial: int, row: SignatureKill, _at: Vector2, _dir: Vector2) -> void:
	rows.append(row.id)


func _feed(gore_full: bool) -> BrutalityHook:
	var hook: BrutalityHook = session.install_kills()
	hook.kills.table.gore_full = gore_full
	@warning_ignore("return_value_discarded")
	hook.kills.killed.connect(_on_killed)
	return hook


func _carry_chainsaw() -> void:
	var carry: RivetCarry = RivetCarry.new(
		WeaponTable.shipped(),
		ArsenalTable.shipped(),
		session.world.context().rng.stream(&"gunplay")
	)
	var slot: int = carry.add(&"chainsaw")
	assert_gte(slot, 0, "the chainsaw rides in a slot")
	PilotWeaponFixture.draw(session.stage, carry, slot)


## Holds fire aimed down for `ticks`, stepping the stage's hooks as the world does; returns the
## tick the cop died (-1: alive).
func _grind(cop: Fighter, ticks: int) -> int:
	var died: int = -1
	var bits: int = 1 << session.actions.bit(&"fire")
	for t: int in ticks:
		var aim: int = PlayerCommand.pack_aim(Vector2.DOWN, session.actions)
		session.pilot.drive(session.stage, TickInput.new(bits | aim))
		session.stage.intent.clear()
		for hook: ArenaHook in session.stage.hooks:
			if hook is BrutalityHook:
				hook.step(session.stage, t)
		if died < 0 and not cop.alive():
			died = t
	return died


func _cop() -> Fighter:
	var at: Vector2 = arena.rivet.pos + Vector2.DOWN * 1.2
	var cop: Fighter = arena.squad_ai.spawn_member(arena, at, &"patrol_cop")
	cop.pos = at
	return cop


func test_the_chainsaw_kills_a_patrol_cop_with_chainsaw_grind() -> void:
	var hook: BrutalityHook = _feed(true)
	assert_true(session.stage.hooks.has(hook), "the stage steps and hashes the feed")
	_carry_chainsaw()
	var cop: Fighter = _cop()
	var died: int = _grind(cop, 180)
	assert_gt(died, 0, "the grind killed the cop")
	assert_eq(rows.size(), 1, "one signature kill")
	# the patrol cop takes the row's victim variant `chainsaw_grind_patrol_cop`
	assert_eq(rows[0] if not rows.is_empty() else &"", &"chainsaw_grind_patrol_cop")
	assert_true(hook.kills.consumed.has(cop.id), "the cop's body is consumed by the kill")
	assert_true(hook.kills.by_style.has(&"split"), "by_style counts the saw split")


func test_reduced_gore_leaves_the_standard_death() -> void:
	var hook: BrutalityHook = _feed(false)
	_carry_chainsaw()
	var cop: Fighter = _cop()
	assert_gt(_grind(cop, 180), 0, "the grind still kills")
	assert_true(rows.is_empty(), "no signature kill row at reduced gore")
	assert_true(hook.kills.consumed.is_empty())


func test_the_feed_is_off_by_default() -> void:
	assert_null(session.kills_hook, "flag off: the street digests stay as pinned")
	for hook: ArenaHook in session.stage.hooks:
		assert_false(hook is BrutalityHook)
