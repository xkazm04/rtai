extends GutTest
## rivet-arsenal: the plasma sword's timed deflect in the live pilot. A cop's round arriving in
## front of Rivet while a slash is in its active ticks goes back at the cop as Rivet's round; the
## same round outside the active window (or behind him) is not touched.
## Planted fault: the katana (no deflect_m) never bats a round back.

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
	carry.select(carry.add(id), _stage.arena)
	_pilot.carry = carry


## A cop 8 m below Rivet and his round 1 m in front of Rivet, flying at him.
func _incoming() -> Array:
	var cop: Fighter = _stage.arena.spawn_guard(_stage.arena.rivet.pos)
	cop.pos = _stage.arena.rivet.pos + Vector2.DOWN * 8.0
	var s: Shot = Shot.new()
	s.pos = _stage.arena.rivet.pos + Vector2.DOWN * 1.0
	s.vel = Vector2.UP * 30.0
	s.from_rivet = false
	s.shooter_id = cop.id
	return [cop, s]


## Holds fire (aimed down) until the melee weapon's first hit is in its active ticks.
func _to_active() -> bool:
	var bits: int = 1 << _pilot.actions.bit(&"fire")
	bits |= PlayerCommand.pack_aim(Vector2.DOWN, _pilot.actions)
	for t: int in 120:
		_pilot.drive(_stage, TickInput.new(bits, 0, 0))
		_stage.intent.clear()
		if _pilot.melee.combo.phase() == MeleeCombo.Phase.ACTIVE:
			return true
	return false


func _deflect_with(id: StringName) -> Shot:
	_carry(id)
	assert_true(_to_active(), "%s reached a slash's active ticks" % id)
	var pair: Array = _incoming()
	var s: Shot = pair[1]
	_stage.arena.shots.append(s)
	var bits: int = 1 << _pilot.actions.bit(&"fire")
	_pilot.drive(
		_stage, TickInput.new(bits | PlayerCommand.pack_aim(Vector2.DOWN, _pilot.actions), 0, 0)
	)
	return s


func test_the_plasma_sword_bats_the_round_back_at_the_cop() -> void:
	var s: Shot = _deflect_with(&"plasma_sword")
	assert_true(s.from_rivet, "the round is Rivet's now")
	assert_gt(s.vel.dot(Vector2.DOWN), 0.0, "it flies back toward the cop")
	assert_eq(_pilot.melee.deflects, 1)


func test_planted_fault_the_katana_does_not_deflect() -> void:
	var s: Shot = _deflect_with(&"katana")
	assert_false(s.from_rivet, "the katana has no deflect_m: the round stays hostile")


func test_a_round_behind_is_not_batted() -> void:
	_carry(&"plasma_sword")
	assert_true(_to_active())
	var s: Shot = _incoming()[1]
	s.pos = _stage.arena.rivet.pos + Vector2.UP * 1.0
	_stage.arena.shots.append(s)
	_pilot.drive(_stage, TickInput.new(1 << _pilot.actions.bit(&"fire"), 0, 0))
	assert_false(s.from_rivet, "only rounds in front of the blade")
