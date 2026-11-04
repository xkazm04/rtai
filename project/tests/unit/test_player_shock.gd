extends GutTest
## rivet-arsenal: the charged electroshock in the live pilot (StagePilot.shock). A press still
## plays the claw jab on its edge; keeping melee down after the jab charges; the release stuns the
## struck body and arcs on; a full charge kills the body it strikes first. A mash never charges.
## Planted fault: a charge that also counts during the jab discharges early, and the test sees it.

var _stage: CollectCallStage
var _pilot: StagePilot
var _jab: int = 0


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_stage = CollectCallStage.new(StageLayout.shipped())
	_stage.setup(World.build_context(bus, data, 1))
	_pilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = _pilot
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)
	_jab = _jab_ticks()  # measured on the open ground, before any cop stands there
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)


func _drive(down: bool) -> void:
	var bits: int = (1 << _pilot.actions.bit(&"melee")) if down else 0
	_pilot.drive(_stage, TickInput.new(bits, 0, 0))
	_stage.arena.rivet.pos += _stage.intent.move_by
	_stage.intent.clear()


func _cop(at: Vector2, hp: float) -> Fighter:
	var g: Fighter = _stage.arena.spawn_guard(_stage.arena.rivet.pos)
	g.pos = at
	g.hp = hp
	g.max_hp = hp
	return g


## Holds melee for `ticks`, then releases; returns the tick (from the press) a discharge left, -1.
func _hold(ticks: int) -> int:
	for t: int in ticks + 4:
		var before: int = _pilot.shock.discharges
		_drive(t < ticks)
		if _pilot.shock.discharges != before:
			return t
	return -1


## The tick the jab's claw hit ends (melee idle again) when the press is held.
func _jab_ticks() -> int:
	var probe: StagePilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = probe
	var p: StagePilot = _pilot
	_pilot = probe
	var t: int = 0
	_drive(true)
	while _pilot.melee.busy() and t < 200:
		_drive(true)
		t += 1
	_pilot = p
	_stage.pilot = p
	return t + 1


func test_a_full_charge_stuns_arcs_and_kills_the_first_body() -> void:
	var rivet: Vector2 = _stage.arena.rivet.pos
	var first: Fighter = _cop(rivet + Vector2.DOWN * 1.2, 2.0)
	var second: Fighter = _cop(rivet + Vector2.DOWN * 1.2 + Vector2.RIGHT * 2.0, 1.0)
	var jab: int = _jab
	var full: int = _pilot.shock.shock.charge_full
	var at: int = _hold(jab + full)
	assert_eq(at, jab + full, "the release discharges on its tick")
	assert_eq(_pilot.melee.landed, 1, "the press played the jab first")
	assert_false(first.alive(), "jab 1 + full shock 1 drops a 2 hp body")
	var e: FighterFx = _stage.arena.areas.effect(second)
	assert_not_null(e, "the arc hopped to the second body")
	assert_eq(e.stun_ticks, _pilot.shock.shock.stun_full, "full stun on the chained body")
	assert_true(second.alive(), "a chained body is stunned, not killed")
	assert_gte(_stage.arena.areas.chain_arcs.size(), 2, "two arcs for the view")


func test_a_half_charge_stuns_without_a_kill() -> void:
	var rivet: Vector2 = _stage.arena.rivet.pos
	var cop: Fighter = _cop(rivet + Vector2.DOWN * 1.2, 2.0)
	var jab: int = _jab
	var s: MeleeShock = _pilot.shock.shock
	var at: int = _hold(jab + s.charge_min + (s.charge_full - s.charge_min) / 2)
	assert_gt(at, 0, "discharged")
	assert_true(cop.alive(), "a part charge does not kill")
	var stun: int = _stage.arena.areas.effect(cop).stun_ticks
	assert_between(stun, s.stun_min + 1, s.stun_full - 1, "the stun scales with the charge")


func test_a_mash_and_a_short_hold_never_discharge() -> void:
	@warning_ignore("return_value_discarded")
	_cop(_stage.arena.rivet.pos + Vector2.DOWN * 1.2, 100.0)
	for t: int in 120:
		_drive(t % 4 == 0)
	assert_eq(_pilot.shock.discharges, 0, "the combo keeps the taps")
	assert_eq(_pilot.melee.landed, 3, "the mash chained the claw combo")
	assert_eq(_hold(_jab + _pilot.shock.shock.charge_min - 2), -1, "under the threshold")


func test_planted_fault_charge_during_the_jab_is_caught() -> void:
	var jab: int = _jab
	var full: int = _pilot.shock.shock.charge_full
	var broken: PlayerShock = PlayerShock.shipped()
	var at: int = -1
	for t: int in jab + full + 4:  # the broken host ignores the jab (idle always true)
		if broken.step(_stage.arena, t < full, true, Vector2.DOWN):
			at = t
			break
	assert_ne(at, jab + full, "a charge that ignores the jab discharges early: caught")
	assert_eq(at, full, "it fires `jab` ticks too soon")
