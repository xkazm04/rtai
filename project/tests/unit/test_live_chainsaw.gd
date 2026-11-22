extends GutTest
## rivet-arsenal: the chainsaw's grind and the plasma sword's spin in the live pilot. A held attack
## with the chainsaw drawn holds its rev-in thrust: the chain bites every grind_ticks, each bite
## locks the human (stun_ticks) and the third bite kills (0.34 x 3). A tap swings once. The plasma
## sword sweeps across the front and leaves a cop behind Rivet untouched. A tap commits the bite
## for grind_min_ticks (three bites).
## Planted fault: the same chainsaw row without grind_ticks bites once however long it is held.

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
	var slot: int = carry.add(id)
	assert_gte(slot, 0, "%s rides in a slot" % id)
	PilotWeaponFixture.draw(_stage, carry, slot)


func _cop(offset: Vector2) -> Fighter:
	var g: Fighter = _stage.arena.spawn_guard(_stage.arena.rivet.pos)
	g.pos = _stage.arena.rivet.pos + offset
	return g


## Drives `ticks` with `bits` (aimed down); returns the tick `cop` died (-1: alive).
func _drive(bits: int, ticks: int, cop: Fighter) -> int:
	var died: int = -1
	for t: int in ticks:
		var aim: int = PlayerCommand.pack_aim(Vector2.DOWN, _pilot.actions)
		_pilot.drive(_stage, TickInput.new(bits | aim, 0, 0))
		_stage.intent.clear()
		if died < 0 and cop != null and not cop.alive():
			died = t
	return died


func test_a_held_chainsaw_grinds_and_kills_on_the_third_bite() -> void:
	_carry(&"chainsaw")
	var cop: Fighter = _cop(Vector2.DOWN * 1.2)
	var died: int = _drive(1 << _pilot.actions.bit(&"fire"), 120, cop)
	assert_eq(_pilot.melee.weapon_id, &"chainsaw")
	assert_gt(died, 0, "the grind killed the cop")
	assert_eq(_pilot.melee.landed, 3, "three bites: the first lands, two more while held")
	var h: MeleeHit = _pilot.melee.combo.table.hits[0]
	gut.p(
		"chainsaw: dead at tick %d, %d bites every %d" % [died, _pilot.melee.landed, h.grind_ticks]
	)


func test_the_bite_locks_the_cop_between_bites() -> void:
	_carry(&"chainsaw")
	var cop: Fighter = _cop(Vector2.DOWN * 1.2)
	cop.hp = 100.0
	cop.max_hp = 100.0
	@warning_ignore("return_value_discarded")
	_drive(1 << _pilot.actions.bit(&"fire"), 90, cop)
	assert_gt(_pilot.melee.landed, 4, "the grind keeps biting while held")
	assert_gt(_pilot.melee.combo.ground, 0, "still grinding")
	assert_gt(_stage.arena.areas.effect(cop).stun_ticks, 0, "held in the teeth")


func test_planted_fault_no_grind_ticks_bites_once() -> void:
	var t: MeleeTable = MeleeTable.weapon(&"chainsaw")
	t.hits[0].grind_ticks = 0
	var combo: MeleeCombo = MeleeCombo.new(t)
	combo.holding = true
	combo.press()
	var lands: int = 0
	for i: int in 90:
		combo.step()
		lands += 1 if combo.lands() else 0
	assert_eq(lands, 1, "without grind_ticks the held thrust lands once")
	var grind: MeleeCombo = MeleeCombo.new(MeleeTable.weapon(&"chainsaw"))
	grind.holding = true
	grind.press()
	var bites: int = 0
	for i: int in 90:
		grind.step()
		bites += 1 if grind.lands() else 0
	assert_gt(bites, 5, "the shipped row grinds (%d bites in 90 ticks)" % bites)


func test_a_tap_still_bites_three_times() -> void:
	var combo: MeleeCombo = MeleeCombo.new(MeleeTable.weapon(&"chainsaw"))
	combo.press()
	var bites: int = 0
	for i: int in 80:
		combo.step()
		bites += 1 if combo.lands() else 0
	assert_eq(bites, 3, "the committed bite: grind_min_ticks 16 at grind_ticks 8")
	assert_eq(combo.hit_index, 0, "then it runs out")


func test_a_released_grind_runs_out_and_does_not_lunge() -> void:
	var combo: MeleeCombo = MeleeCombo.new(MeleeTable.weapon(&"chainsaw"))
	combo.holding = true
	combo.press()
	var lunge: float = 0.0
	for i: int in 60:
		combo.step()
		lunge += combo.lunge_step_m()
	var step_in: float = combo.table.hits[0].lunge_m
	assert_lte(lunge, step_in + 0.001, "the step-in only, never again per bite")
	assert_gt(lunge, step_in * 0.8, "the rev-in stepped in (%.3f m)" % lunge)
	combo.holding = false
	for i: int in 40:
		combo.step()
	assert_eq(combo.hit_index, 0, "the release lets the hit run into its recovery and end")


func test_the_plasma_sweep_cuts_the_flank_and_spares_the_rear() -> void:
	_carry(&"plasma_sword")
	var behind: Fighter = _cop(Vector2.UP * 1.5)
	var flank: Fighter = _cop(Vector2.DOWN.rotated(deg_to_rad(100)) * 1.5)
	var outside: Fighter = _cop(Vector2.DOWN.rotated(deg_to_rad(-104)) * 1.5)
	@warning_ignore("return_value_discarded")
	_drive(0, 30, null)
	@warning_ignore("return_value_discarded")
	_drive(1 << _pilot.actions.bit(&"fire"), 1, null)
	var died: int = _drive(0, 30, flank)
	assert_gte(died, 0)
	assert_eq(behind.hp, behind.max_hp)
	assert_eq(outside.hp, outside.max_hp)
