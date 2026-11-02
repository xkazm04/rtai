class_name QuestObjective
extends RefCounted
## One beat's objective while it runs (the spike's quest_verbs start/check, on ticks, grown for
## collect-call's evade/answer/meet/fight/sabotage). start() readies the world (parks the job's
## vehicle, spawns the target, starts the place's encounter); check() runs once per tick and
## answers RUNNING, DONE or a fail code from quest_rules.json `fail_rules`.
## arrived_hot is a gate, not a failure: answer, meet and a payphone evade wait for wanted 0.

const RUNNING: StringName = &""
const DONE: StringName = &"done"

var beat: QuestBeat
var ticks: int = 0
## The payphone at the objective's place is ringing (answer, or evade once cold).
var ringing: bool = false
## A gated objective was held back because Rivet was hot (Patch dropped the call).
var refused_hot: bool = false
var _marker: QuestPlaces.Marker = null
var _rules: QuestRules


static func start(p_beat: QuestBeat, world: QuestWorld, rules: QuestRules) -> QuestObjective:
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
	return o


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
			ringing = not _hot_gated(world, pkg)
			return DONE if ringing and _answered(world) else RUNNING
		QuestRules.Handler.MEET:
			var there: bool = _arrived(world.focus_position())
			return DONE if there and not _hot_gated(world, pkg) else RUNNING
		QuestRules.Handler.FIGHT:
			return DONE if world.encounter_cleared(beat.location) else RUNNING
	return _check_sabotage(world)


## Done at wanted 0; at a place with a payphone it then rings and must be answered.
func _check_evade(world: QuestWorld) -> StringName:
	if world.wanted_level() > 0:
		return RUNNING
	if not _marker.has_phone:
		return DONE
	ringing = true
	return DONE if _answered(world) else RUNNING


## The encounter first, then an interact at the marker on foot (the torch).
func _check_sabotage(world: QuestWorld) -> StringName:
	if not world.encounter_cleared(beat.location):
		return RUNNING
	var at_marker: bool = _arrived(world.focus_position()) and not world.in_vehicle()
	return DONE if at_marker and world.interact_pressed() else RUNNING


## True while the package's arrived_hot rule holds Rivet back (and remembers that it did).
func _hot_gated(world: QuestWorld, pkg: QuestPackage) -> bool:
	var gated: bool = pkg.has_fail(&"arrived_hot") and world.wanted_level() > 0
	refused_hot = refused_hot or gated
	return gated


func _answered(world: QuestWorld) -> bool:
	if world.in_vehicle():
		return false
	var near: float = world.focus_position().distance_to(_marker.phone)
	return near < _rules.tuning["answer_radius_m"] and world.interact_pressed()


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
