class_name QuestObjective
extends RefCounted
## One beat's objective while it runs (the spike's quest_verbs start/check, on ticks). start()
## readies the world (parks the job's vehicle, spawns the target); check() runs once per tick
## and answers RUNNING, DONE or a fail code from quest_rules.json `fail_rules`.

const RUNNING: StringName = &""
const DONE: StringName = &"done"

var beat: QuestBeat
var ticks: int = 0
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
	return o


## Where the objective marker points, or Vector2.INF when there is nothing to point at.
func marker_position(world: QuestWorld) -> Vector2:
	match beat.handler:
		QuestRules.Handler.REACH, QuestRules.Handler.ESCORT:
			return _marker.at
		QuestRules.Handler.KILL:
			return (
				Vector2.INF if world.actor_dead(beat.target) else world.actor_position(beat.target)
			)
	return Vector2.INF


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
	return _check_escort(world, pkg)


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
