extends GutTest
## rivet-arsenal: the evening's motion and claw combo in the live pilot (StagePilot, used by quest
## 1, the arena and the city block): the combo chains three hits on a mash and the finisher shoves,
## the cadence is the table's, the roll's i-frames close Rivet to damage, the sprint crosses the
## tackle line. Planted faults: a zero-reach table never lands; i-frames past the roll are refused.

const MASH_EVERY: int = 4

var _stage: CollectCallStage
var _pilot: StagePilot
var _last_by: Vector2 = Vector2.ZERO


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_stage = CollectCallStage.new(StageLayout.shipped())
	_stage.setup(World.build_context(bus, data, 1))
	_pilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = _pilot
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)


func _drive(buttons: int, move_x: int = 0) -> void:
	_pilot.drive(_stage, TickInput.new(buttons, move_x, 0))
	_last_by = _stage.intent.move_by
	_stage.intent.clear()


func _bit(action: StringName) -> int:
	return 1 << _pilot.actions.bit(action)


## A tough guard straight ahead (Rivet faces +y at the start).
func _cop_ahead(dist_m: float) -> Fighter:
	var g: Fighter = _stage.arena.spawn_guard(_stage.arena.rivet.pos)
	g.pos = _stage.arena.rivet.pos + Vector2.DOWN * dist_m
	g.hp = 100.0
	g.max_hp = 100.0
	return g


## Mashes melee every MASH_EVERY ticks; returns the tick the finisher landed (-1: never).
func _mash(ticks: int) -> int:
	for t: int in ticks:
		_drive(_bit(&"melee") if t % MASH_EVERY == 0 else 0)
		if _pilot.melee.last_land_index == 3 and _pilot.melee.landed == 3:
			return t
	return -1


func test_a_mash_chains_three_claws_and_the_finisher_shoves() -> void:
	var cop: Fighter = _cop_ahead(1.2)
	var start: Vector2 = cop.pos
	var finisher_at: int = _mash(60)
	assert_gt(finisher_at, 0, "the finisher landed")
	assert_eq(_pilot.melee.landed, 3, "jab, backhand, slam")
	assert_almost_eq(cop.hp, 100.0 - 4.0, 0.001, "1 + 1 + 2 damage")
	for t: int in 12:
		_drive(0)
	assert_gt(cop.pos.distance_to(start), 2.0, "the slam slid the cop back")


func test_combo_cadence_is_the_tables() -> void:
	@warning_ignore("return_value_discarded")
	_cop_ahead(1.2)
	var finisher_at: int = _mash(60)
	var t: MeleeTable = MeleeTable.shipped()
	var h1: MeleeHit = t.hits[0]
	var h2: MeleeHit = t.hits[1]
	var h3: MeleeHit = t.hits[2]
	# buffered: hit 2 starts at hit 1's windup + active + cancel, hit 3 likewise after hit 2; the
	# combo's first step runs on the press tick (tick 0), so the landing tick is one less
	var expect: int = h1.windup + h1.active + t.cancel_ticks
	expect += h2.windup + h2.active + t.cancel_ticks + h3.windup - 1
	assert_eq(finisher_at, expect, "finisher tick (%.0f ms)" % (finisher_at * 1000.0 / 60.0))


func test_planted_zero_reach_never_lands() -> void:
	var t: MeleeTable = MeleeTable.shipped()
	for h: MeleeHit in t.hits:
		h.reach_m = 0.0
	_pilot.melee = PlayerMelee.new(t)
	@warning_ignore("return_value_discarded")
	_cop_ahead(1.2)
	assert_eq(_mash(60), -1, "the planted fault: a zero-reach claw must never land")
	assert_gt(_pilot.melee.whiffs, 0)


func test_roll_iframes_close_rivet_to_damage() -> void:
	var r: Fighter = _stage.arena.rivet
	_drive(_bit(&"roll"), 127)
	for t: int in 4:
		_drive(0, 127)
	assert_false(r.exposed, "inside the i-frame window")
	var hp: float = r.hp
	_stage.arena.damage(r, 1.0, 99, &"pistol")
	assert_eq(r.hp, hp, "no damage on an i-frame")
	for t: int in 40:
		_drive(0, 0)
	assert_true(r.exposed, "exposed again after the roll")


func test_planted_iframes_past_the_roll_are_refused() -> void:
	var t: DataTable = DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
	var roll: Dictionary = t.raw["roll"]
	var ticks: float = roll["roll_ticks"]
	roll["iframe_to"] = ticks + 5.0
	assert_false(PlayerMotion.from_table(t).errors.is_empty(), "the planted fault is caught")


func test_sprint_crosses_the_tackle_line_and_walk_does_not() -> void:
	for t: int in 40:
		_drive(0, 127)
	assert_lt(
		_last_by.length() / SimClock.TICK_DT, 5.0, "walking stays under the 5 m/s tackle line"
	)
	for t: int in 40:
		_drive(_bit(&"sprint"), 127)
	assert_gt(_last_by.length() / SimClock.TICK_DT, 5.0, "the sprint crosses it")
