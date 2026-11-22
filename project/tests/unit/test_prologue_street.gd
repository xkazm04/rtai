extends GutTest

const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")
const PHASE_ORDER: Array[String] = [
	"TALK",
	"HANDS",
	"SQUAD_TALK",
	"SQUAD_FIGHT",
	"OUT",
	"VOICES",
	"PHONE",
	"CALL",
	"REQUEST",
	"RING",
	"RADIO",
	"END"
]
var _game: PrologueGame
var _stage: PrologueStage
var _yard: PrologueYard
var _street: PrologueStreet
var _use: int
var _phases: Array[String] = []


func before_each() -> void:
	_game = ENTRY.instantiate() as PrologueGame
	add_child_autofree(_game)
	_game.world.set_process(false)
	_stage = _game.stage as PrologueStage
	_yard = _stage.plan as PrologueYard
	_street = _game.encounter.street
	_use = 1 << _stage.pilot.actions.bit(&"interact")
	_phases.clear()
	_note_phase()
	var patrol: ProloguePatrol = _game.encounter.patrol
	_stage.arena.damage(patrol.dale, 1.0, 0, &"claw")
	_step()
	for officer: ProloguePatrol.Officer in patrol.officers:
		_stage.arena.damage(officer.body, 1.0, 0, &"claw")
	_step()
	var squad: PrologueFormation = _game.encounter.battle.formation
	assert_false(_yard.exit_open)
	for i: int in 200:
		_step(_use if i % 2 else 0)
		if _game.encounter.battle.ranged:
			break
	assert_true(_game.encounter.battle.ranged)
	for h: Fighter in squad.members:
		_stage.arena.damage(h, 99.0, 0, &"claw")
	_stage.arena.damage(squad.boss, 99.0, 0, &"claw")
	_step()
	assert_true(_yard.exit_open)
	assert_eq(_game.encounter.phase, PrologueEncounter.Phase.STREET)


func after_each() -> void:
	PlayerActions.shipped().install()


func _step(buttons: int = 0, dx: int = 0) -> void:
	_stage.step(_stage.tick + 1, TickInput.new(buttons, dx, 0))
	_note_phase()


func _note_phase() -> void:
	var phase: String = PrologueEncounter.Phase.keys()[_game.encounter.phase]
	if _game.encounter.phase == PrologueEncounter.Phase.BEAT_TWO:
		phase = "SQUAD_FIGHT" if _game.encounter.battle.ranged else "SQUAD_TALK"
	elif _game.encounter.phase == PrologueEncounter.Phase.STREET:
		phase = PrologueStreet.Phase.keys()[_street.phase]
	if _phases.is_empty() or _phases.back() != phase:
		_phases.append(phase)


func _ring() -> void:
	_stage.arena.rivet.pos = _yard.gate + Vector2.DOWN * 0.1
	_step()
	assert_eq(_game.lines.current, "b3_l01_rivet_voices")
	_step(_use)
	assert_true(_stage.router.ringing(_street.phone))
	assert_eq(_game.lines.current, "b3_l02_rivet_phone")
	_step()


func _answer() -> void:
	_ring()
	_step(_use)
	assert_eq(_street.answered_tick, -1, "An interact at the gate cannot answer the phone")
	_stage.arena.rivet.pos = _stage.layout.phones[_street.phone]
	_step()
	assert_eq(_street.answered_tick, -1, "Walking into reach cannot answer by itself")
	_step(_use)
	assert_eq(_street.answered_tick, _stage.tick)
	assert_eq(_game.lines.current, "b3_l03_fax_son")


func test_receiver_holds_rivet_and_observes_both_timing_cues() -> void:
	_answer()
	var at: Vector2 = _stage.arena.rivet.pos
	var start: int = _stage.tick
	while _game.lines.current == "b3_l03_fax_son" and _stage.tick < start + 300:
		_step(0, TickInput.AXIS_MAX)
	assert_lt(_stage.tick - start, _game.lines.reading_ticks("b3_l03_fax_son"))
	assert_eq(_game.lines.current, "b3_l04_rivet_interrupts")
	for i: int in 3:
		_step()
		_step(_use, TickInput.AXIS_MAX)
	assert_eq(_game.lines.current, "", "Silence precedes Rivet's quiet line")
	for i: int in PrologueLines.QUIET_TICKS - 1:
		_step(0, TickInput.AXIS_MAX)
	assert_eq(_game.lines.current, "")
	_step()
	assert_eq(_game.lines.current, "b3_l07_rivet_quiet")
	assert_eq(_stage.arena.rivet.pos, at)


func test_channel_waits_for_fresh_press_releases_movement_and_writes_end_card() -> void:
	_answer()
	for i: int in 100:
		_step(_use if i % 2 else 0)
		if _street.phase == PrologueStreet.Phase.REQUEST:
			break
	assert_eq(_street.phase, PrologueStreet.Phase.REQUEST)
	var at: Vector2 = _stage.arena.rivet.pos
	for i: int in 25:
		_step(_use, TickInput.AXIS_MAX)
	assert_eq(_street.accepted_tick, -1, "Holding the last skip cannot accept the channel")
	assert_gt(_stage.arena.rivet.pos.distance_to(at), 0.5)
	_step()
	_step(_use)
	assert_eq(_street.phase, PrologueStreet.Phase.RING)
	assert_eq(_street.accepted_tick, _stage.tick)
	for i: int in PrologueStreet.RING_TICKS:
		_step()
	assert_eq(_game.lines.current, "b3_l11_fax_location")
	assert_string_contains(_game.lines.subtitle.speaker, "Radio")
	assert_string_contains(_game.lines.subtitle.words, "the Toner Room")
	_game.result_path = TestTmp.dir("prologue").path_join("end.json")
	_step(_use)
	assert_eq(_street.end_tick, _stage.tick)
	assert_eq(_phases, PHASE_ORDER)
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(_game.result_path))
	var ended: bool = saved.get("ended", false)
	var end_tick: float = saved.get("end_tick", -1.0)
	assert_true(ended)
	assert_eq(roundi(end_tick), _stage.tick)


func test_street_death_returns_to_gate_and_rings_again() -> void:
	_answer()
	_stage.arena.damage(_stage.arena.rivet, 1000.0, 99, &"rifle")
	for i: int in 150:
		_step()
		if _stage.deaths > 0:
			break
	assert_eq(_game.encounter.deaths, 1)
	assert_eq(_stage.arena.rivet.pos, _yard.gate)
	assert_eq(_street.answered_tick, -1)
	assert_false(_stage.at_receiver)
	assert_eq(_stage.arena.hostiles_alive(), 0)
	assert_eq(_stage.pilot.wheel.order(), [&"hands"])
	assert_eq(_stage.router.state(_street.phone), PayphoneRouter.Phone.QUIET)
	_answer()


func test_voices_start_after_a_fixed_wait_inside_the_gate() -> void:
	_stage.arena.rivet.pos = _yard.gate + Vector2.UP * 2.0
	for i: int in PrologueStreet.IDLE_TICKS - 1:
		_step()
	assert_eq(_game.lines.current, "")
	_step()
	assert_eq(_game.lines.current, "b3_l01_rivet_voices")
