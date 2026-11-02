class_name QuestRunner
extends RefCounted
## Plays one QuestPackage on the fixed tick (the spike's quest_runner, without main.gd):
##   INACTIVE -> offered (the job's payphone rings) -> ACTIVE (beat i) -> SUCCEEDED | FAILED.
## A contract whose first place has a payphone rings; answering it (interact in range, on foot)
## or start() begins it. One whose first place has none (it picks up from the last scene) begins
## on offer. Starting emits Events.contract_started; the last beat done pays, records the
## unlocks and emits contract_completed. While active, wanted is capped at heatPeak every tick.
## Barks read QuestFacts, which listens to the bus only while the contract is active.
## Deterministic: no frame delta, no RNG draws; time is the tick count (SIM-01).

enum State { INACTIVE, OFFERED, ACTIVE, SUCCEEDED, FAILED }

const STATE_NAMES: PackedStringArray = ["inactive", "offered", "active", "succeeded", "failed"]

var state: State = State.INACTIVE
var beat_index: int = -1
var objective: QuestObjective = null
var active_ticks: int = 0
var heat_clamps: int = 0
var fail_reason: StringName = &""
var vehicle_tag: String = ""
var phone: Vector2 = Vector2.ZERO
var granted_unlocks: Array[String] = []
## Evidence: "<tick> <what>" lines, oldest first.
var timeline: Array[String] = []
var lines: QuestLinePlayer
var facts: QuestFacts
var pkg: QuestPackage
var _world: QuestWorld
var _events: EventBus
var _rules: QuestRules
var _tick: int = 0
var _was_ringing: bool = false
var _was_refused: bool = false
var _held_for_lines: bool = false
var _call_released: bool = false


func _init(p_pkg: QuestPackage, world: QuestWorld, events: EventBus, rules: QuestRules) -> void:
	pkg = p_pkg
	_world = world
	_events = events
	_rules = rules
	lines = QuestLinePlayer.new(pkg, rules)
	facts = QuestFacts.new(rules.seconds_to_ticks(rules.tuning["event_window_s"]))


## The phone rings at the first beat's place when its marker has one; otherwise the contract
## begins at once. The job's vehicle is parked first.
func offer() -> void:
	if state != State.INACTIVE:
		return
	for beat: QuestBeat in pkg.beats:
		if beat.handler == QuestRules.Handler.ENTER_VEHICLE:
			_use_vehicle(beat.target)
			break
	var first: QuestBeat = pkg.beats[0]
	var places: QuestPlaces = _world.places()
	_go(State.OFFERED)
	if places.markers.has(first.location) and places.markers[first.location].has_phone:
		phone = places.markers[first.location].phone
	else:
		_log("no payphone at '%s': begins on offer" % first.location)
		start()


## Answering the phone; also the scripted start for tests and debug.
func start() -> void:
	if state != State.OFFERED:
		return
	_go(State.ACTIVE)
	facts.attach(_events, _world)
	_events.contract_started.emit(pkg.id)
	_begin_beat(0)


func step(tick: int) -> void:
	_tick = tick
	facts.begin_tick(tick, _world)
	match state:
		State.OFFERED:
			if _answering():
				start()
		State.ACTIVE:
			_step_active()
	lines.step(tick, beat_index, facts, state == State.ACTIVE)


func state_name() -> String:
	return STATE_NAMES[state]


func current_beat() -> QuestBeat:
	return objective.beat if objective != null else null


## Every value a replay must reproduce, in a fixed order (SIM-05).
func write_state(out: StreamPeerBuffer) -> void:
	out.put_8(state)
	out.put_32(beat_index)
	out.put_32(objective.ticks if objective != null else -1)
	out.put_32(active_ticks)
	out.put_32(heat_clamps)
	out.put_utf8_string(String(fail_reason))
	lines.write_state(out)
	facts.write_state(out)


func _answering() -> bool:
	var near: bool = _world.focus_position().distance_to(phone) < _rules.tuning["answer_radius_m"]
	return near and not _world.in_vehicle() and _world.interact_pressed()


func _step_active() -> void:
	active_ticks += 1
	if _world.wanted_level() > pkg.heat_peak:
		_log("heat clamp %d -> %d" % [_world.wanted_level(), pkg.heat_peak])
		_world.cap_wanted(pkg.heat_peak)
		heat_clamps += 1
	var result: StringName = _hold_for_lines(_release_lines(objective.check(_world, pkg)))
	_log_objective_changes()
	if result == QuestObjective.RUNNING:
		result = _global_fail()
	if result == QuestObjective.DONE:
		_log("beat %s done" % objective.beat.id)
		facts.note("quest:%s_done" % objective.beat.verb)
		if beat_index + 1 < pkg.beats.size():
			_begin_beat(beat_index + 1)
		else:
			_succeed()
	elif result != QuestObjective.RUNNING:
		_fail(result)


## Held lines join the queue as their moment comes: each ally's once Rivet meets them, a call's
## once it connects (that tick's DONE then waits for them in _hold_for_lines).
func _release_lines(result: StringName) -> StringName:
	for tag: String in objective.newly_met:
		_log("met %s" % tag)
		lines.play_spoken(objective.beat, _world.places().actors[tag].speaker)
	objective.newly_met.clear()
	if objective.connected and not _call_released:
		_call_released = true
		_log("%s: call connected" % objective.beat.id)
		lines.play_spoken(objective.beat)
	return result


## A verb that waits for its lines (meet: the meeting is the conversation) and a call (the beat
## ends when the call does) hold DONE until the line player is idle.
func _hold_for_lines(result: StringName) -> StringName:
	var waits: bool = _rules.verbs[objective.beat.verb].waits_for_lines or objective.is_call()
	if result != QuestObjective.DONE or not waits:
		return result
	if not lines.busy():
		return result
	if not _held_for_lines:
		_held_for_lines = true
		_log("%s: arrived, waiting for the lines" % objective.beat.id)
	return QuestObjective.RUNNING


func _log_objective_changes() -> void:
	if objective.ringing != _was_ringing:
		_was_ringing = objective.ringing
		var quiet: String = "answered" if objective.connected else "silent (hot)"
		_log("payphone %s" % ("ringing" if _was_ringing else quiet))
	if objective.refused_hot and not _was_refused:
		_was_refused = true
		_log("%s: held back, Rivet is hot" % objective.beat.id)


## Quest-wide fail states, not tied to the beat's verb.
func _global_fail() -> StringName:
	if pkg.has_fail(&"rivet_wasted") and _world.player_dead():
		return &"rivet_wasted"
	if pkg.has_fail(&"car_destroyed") and vehicle_tag != "" and _world.vehicle_wrecked(vehicle_tag):
		return &"car_destroyed"
	var limit: int = pkg.time_limit_ticks
	if pkg.has_fail(&"timer_expired") and limit != QuestPackage.NO_TIME_LIMIT:
		if active_ticks > limit:
			return &"timer_expired"
	return QuestObjective.RUNNING


func _begin_beat(i: int) -> void:
	beat_index = i
	var beat: QuestBeat = pkg.beats[i]
	if beat.handler == QuestRules.Handler.ENTER_VEHICLE:
		vehicle_tag = beat.target
	objective = QuestObjective.start(beat, _world, _rules, pkg)
	_was_ringing = false
	_was_refused = false
	_held_for_lines = false
	_call_released = false
	lines.play_beat(beat, objective.held_speakers, objective.is_call())
	_log("beat %d %s (%s)" % [i, beat.id, beat.verb])


func _use_vehicle(tag: String) -> void:
	vehicle_tag = tag
	_world.place_vehicle(tag)


func _succeed() -> void:
	_go(State.SUCCEEDED)
	_world.pay(pkg.reward_cash)
	granted_unlocks = pkg.unlocks.duplicate()
	_log("reward: cash +%d, unlocks %s" % [pkg.reward_cash, granted_unlocks])
	facts.detach()
	_events.contract_completed.emit(pkg.id)


func _fail(code: StringName) -> void:
	fail_reason = code
	facts.detach()
	_go(State.FAILED)
	_log("failed: %s" % code)


func _go(next: State) -> void:
	state = next
	_log("-> %s" % STATE_NAMES[next])


func _log(what: String) -> void:
	timeline.append("%d %s" % [_tick, what])
