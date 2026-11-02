class_name StubQuestWorld
extends QuestWorld
## A minimal world for quest tests (F-12: the city is integrated later). Rivet is a point that
## walks or drives in a straight line, vehicles and actors sit at their places, and every outcome
## the quest asks about is a field a test sets. Movement is per tick, never per frame.

const WALK_M_PER_TICK: float = 4.0 / SimClock.TICK_RATE
const DRIVE_M_PER_TICK: float = 12.0 / SimClock.TICK_RATE
const ESCORT_M_PER_TICK: float = 3.0 / SimClock.TICK_RATE
const ENTER_RANGE_M: float = 2.5

var rivet: Vector2 = Vector2.ZERO
var driving: String = ""
var dead: bool = false
## Consumed by the next interact_pressed() (one press, one tick).
var interact: bool = false
var wanted: int = 0
var cash: int = 0
var soul: String = "rivet"
var madness: String = "lucid"
var vehicle_at: Dictionary[String, Vector2] = {}
var wrecked: Dictionary[String, bool] = {}
var actor_at: Dictionary[String, Vector2] = {}
var killed: Dictionary[String, bool] = {}
var calls: Array[String] = []
var _places: QuestPlaces


func _init(p_places: QuestPlaces) -> void:
	_places = p_places


func places() -> QuestPlaces:
	return _places


func focus_position() -> Vector2:
	return vehicle_at[driving] if driving != "" else rivet


func in_vehicle() -> bool:
	return driving != ""


func player_dead() -> bool:
	return dead


func interact_pressed() -> bool:
	var pressed: bool = interact
	interact = false
	return pressed


func wanted_level() -> int:
	return wanted


func cap_wanted(level: int) -> void:
	calls.append("cap_wanted %d" % level)
	wanted = mini(wanted, level)


func pay(amount: int) -> void:
	calls.append("pay %d" % amount)
	cash += amount


func soul_name() -> String:
	return soul


func madness_band() -> String:
	return madness


func place_vehicle(tag: String) -> void:
	if driving == "":
		vehicle_at[tag] = _places.vehicles[tag]


func vehicle_wrecked(tag: String) -> bool:
	return wrecked.get(tag, false)


func spawn_actor(tag: String) -> void:
	if not actor_at.has(tag):
		actor_at[tag] = _places.actors[tag].at
		calls.append("spawn %s" % tag)


func actor_dead(tag: String) -> bool:
	return killed.get(tag, false)


func actor_position(tag: String) -> Vector2:
	return actor_at[tag]


func escort_toward(tag: String, to: Vector2) -> void:
	actor_at[tag] = actor_at[tag].move_toward(to, ESCORT_M_PER_TICK)


## One tick of movement toward `to`: walking, or driving the vehicle Rivet is in.
func move_toward(to: Vector2) -> void:
	if driving != "":
		vehicle_at[driving] = vehicle_at[driving].move_toward(to, DRIVE_M_PER_TICK)
	else:
		rivet = rivet.move_toward(to, WALK_M_PER_TICK)


## Gets into the tagged vehicle when it is in reach; true when Rivet is now driving it.
func enter(tag: String) -> bool:
	if vehicle_at.has(tag) and rivet.distance_to(vehicle_at[tag]) <= ENTER_RANGE_M:
		driving = tag
	return driving == tag
