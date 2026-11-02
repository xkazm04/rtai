class_name QuestObjective
extends RefCounted
## One beat's objective while it runs (the spike's quest_verbs start/check, on ticks, grown for
## collect-call's evade/answer/meet/fight/sabotage). start() readies the world (parks the job's
## vehicle, spawns the target, starts the place's encounter); check() runs once per tick and
## answers RUNNING, DONE or a fail code from quest_rules.json `fail_rules`.
## arrived_hot is a gate, not a failure: answer, meet and a payphone evade wait for wanted 0.
## A call (answer, or evade at a place with a payphone) is done once the world's payphone router
## connects it, and the runner then holds the beat for the call's lines. A meet whose place has
## actors voicing the beat's speakers (places.actors[].speaker) is done once Rivet has met each
## of them with an interact press in reach; with none, arriving cold is the meeting.

const RUNNING: StringName = &""
const DONE: StringName = &"done"

var beat: QuestBeat
var ticks: int = 0
## The payphone at the objective's place is ringing (answer, or evade once cold).
var ringing: bool = false
## A gated objective was held back because Rivet was hot (Patch dropped the call).
var refused_hot: bool = false
## A call: the world connected it (latched; the runner then releases the call's lines).
var connected: bool = false
## A meet: the places' actors who voice the beat's speakers, their speakers, and who is met.
var meet_tags: Array[String] = []
var held_speakers: Array[String] = []
var met: Array[String] = []
## Met since the runner last looked (it plays their lines and clears this).
var newly_met: Array[String] = []
var _rang: bool = false
var _marker: QuestPlaces.Marker = null
var _rules: QuestRules


static func start(
	p_beat: QuestBeat, world: QuestWorld, rules: QuestRules, pkg: QuestPackage
) -> QuestObjective:
	var o: QuestObjective = QuestObjective.new()
	o.beat = p_beat
	o._rules = rules
	var places: QuestPlaces = world.places()
	if places.markers.has(p_beat.location):
		o._marker = places.markers[p_beat.location]
	match p_beat.handler:
		QuestRules.Handler.ENTER_VEHICLE:
			world.place_vehicle(p_beat.target)
		QuestRules.Handler.KILL, QuestRules.Handler.ESCORT:
			world.spawn_actor(p_beat.target)
		QuestRules.Handler.FIGHT, QuestRules.Handler.SABOTAGE:
			world.start_encounter(p_beat.location)
		QuestRules.Handler.MEET:
			o._find_meet(places, pkg)
			for tag: String in o.meet_tags:
				world.spawn_actor(tag)
	return o


## A call beat: its lines are the call, held until it connects (QuestRunner).
func is_call() -> bool:
	if beat.handler == QuestRules.Handler.ANSWER:
		return true
	return beat.handler == QuestRules.Handler.EVADE and _marker != null and _marker.has_phone


## Where the objective marker points, or Vector2.INF when there is nothing to point at.
func marker_position(world: QuestWorld) -> Vector2:
	if ringing:
		return _marker.phone
	match beat.handler:
		QuestRules.Handler.KILL:
			return (
				Vector2.INF if world.actor_dead(beat.target) else world.actor_position(beat.target)
			)
		QuestRules.Handler.ENTER_VEHICLE, QuestRules.Handler.TIMER, QuestRules.Handler.EVADE:
			return Vector2.INF
	return _marker.at


func check(world: QuestWorld, pkg: QuestPackage) -> StringName:
	ticks += 1
	match beat.handler:
		QuestRules.Handler.REACH:
			return DONE if _arrived(world.focus_position()) else RUNNING
		QuestRules.Handler.ENTER_VEHICLE:
			return DONE if world.in_vehicle() else RUNNING
		QuestRules.Handler.KILL:
			return _check_kill(world, pkg)
		QuestRules.Handler.TIMER:
			return DONE if ticks >= beat.length_ticks else RUNNING
		QuestRules.Handler.ESCORT:
			return _check_escort(world, pkg)
	return _check_contract_verb(world, pkg)


## evade, answer, meet, fight, sabotage.
func _check_contract_verb(world: QuestWorld, pkg: QuestPackage) -> StringName:
	match beat.handler:
		QuestRules.Handler.EVADE:
			return _check_evade(world)
		QuestRules.Handler.ANSWER:
			ringing = not connected and not _hot_gated(world, pkg)
			connected = connected or (ringing and _answered(world))
			return DONE if connected else RUNNING
		QuestRules.Handler.MEET:
			return _check_meet(world, pkg)
		QuestRules.Handler.FIGHT:
			return DONE if world.encounter_cleared(beat.location) else RUNNING
	return _check_sabotage(world)


## Done at wanted 0; at a place with a payphone it then rings and must be answered.
func _check_evade(world: QuestWorld) -> StringName:
	if connected:
		return DONE
	if world.wanted_level() > 0:
		return RUNNING
	if not _marker.has_phone:
		return DONE
	ringing = true
	connected = _answered(world)
	ringing = not connected
	return DONE if connected else RUNNING


## Cold, every listed ally met in turn (or, with none at the place, a cold arrival).
func _check_meet(world: QuestWorld, pkg: QuestPackage) -> StringName:
	var cold: bool = not _hot_gated(world, pkg)
	if meet_tags.is_empty():
		return DONE if cold and _arrived(world.focus_position()) else RUNNING
	if cold:
		_meet_nearest(world)
	return DONE if met.size() == meet_tags.size() else RUNNING


## One interact press on foot meets the nearest unmet ally within answer_radius_m.
func _meet_nearest(world: QuestWorld) -> void:
	var here: Vector2 = world.focus_position()
	var best: String = ""
	var best_d: float = _rules.tuning["answer_radius_m"]
	for tag: String in meet_tags:
		var d: float = world.actor_position(tag).distance_to(here)
		if not met.has(tag) and d <= best_d:
			best = tag
			best_d = d
	if best != "" and not world.in_vehicle() and world.interact_pressed():
		met.append(best)
		newly_met.append(best)


## The places' actors (in tag order) whose speaker voices one of the beat's spoken lines.
func _find_meet(places: QuestPlaces, pkg: QuestPackage) -> void:
	var speakers: Array[String] = []
	for line_id: String in beat.line_ids:
		if not pkg.line(line_id).is_bark():
			speakers.append(pkg.line(line_id).speaker)
	var tags: Array[String] = []
	tags.assign(places.actors.keys())
	tags.sort()
	for tag: String in tags:
		var speaker: String = places.actors[tag].speaker
		if speaker != "" and speakers.has(speaker):
			meet_tags.append(tag)
			held_speakers.append(speaker)


## The encounter first, then the world's sabotage act at the place (the torch).
func _check_sabotage(world: QuestWorld) -> StringName:
	if not world.encounter_cleared(beat.location):
		return RUNNING
	return DONE if world.sabotage_done(beat.location) else RUNNING


## True while the package's arrived_hot rule holds Rivet back (and remembers that it did).
func _hot_gated(world: QuestWorld, pkg: QuestPackage) -> bool:
	var gated: bool = pkg.has_fail(&"arrived_hot") and world.wanted_level() > 0
	refused_hot = refused_hot or gated
	return gated


## The call goes on the place's payphone once; the world's router says when it connects.
func _answered(world: QuestWorld) -> bool:
	if not _rang:
		_rang = true
		world.ring_phone(beat.location)
	return world.phone_answered(beat.location)


func _check_kill(world: QuestWorld, pkg: QuestPackage) -> StringName:
	if world.actor_dead(beat.target):
		return DONE
	var away: float = world.actor_position(beat.target).distance_to(world.focus_position())
	if pkg.has_fail(&"target_escapes") and away > _rules.tuning["escape_m"]:
		return &"target_escapes"
	return RUNNING


## An escort whose death the package does not name as a fail state stalls the beat (spike).
func _check_escort(world: QuestWorld, pkg: QuestPackage) -> StringName:
	if world.actor_dead(beat.target):
		return &"escort_dies" if pkg.has_fail(&"escort_dies") else RUNNING
	world.escort_toward(beat.target, world.focus_position())
	return DONE if _arrived(world.actor_position(beat.target)) else RUNNING


func _arrived(at: Vector2) -> bool:
	return at.distance_to(_marker.at) <= _marker.radius_m
