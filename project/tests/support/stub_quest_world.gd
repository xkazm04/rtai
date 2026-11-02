# gdlint: disable=max-public-methods
class_name StubQuestWorld
extends QuestWorld
## A minimal world for quest tests (F-12: the city is integrated later). Rivet is a point that
## walks or drives in a straight line, vehicles and actors sit at their places, and every outcome
## the quest asks about is a field a test sets. Movement is per tick, never per frame.
## (It implements the whole QuestWorld port plus two movement helpers, hence the gdlint
## max-public-methods disable above.)

const WALK_M_PER_TICK: float = 4.0 / SimClock.TICK_RATE
const DRIVE_M_PER_TICK: float = 12.0 / SimClock.TICK_RATE
const ESCORT_M_PER_TICK: float = 3.0 / SimClock.TICK_RATE
const ENTER_RANGE_M: float = 2.5
const PLAYER_ID: int = 1
## The reach of a payphone pick-up (as quest_rules.json answer_radius_m).
const ANSWER_RANGE_M: float = 1.7

var rivet: Vector2 = Vector2.ZERO
var driving: String = ""
var dead: bool = false
## Consumed by the next interact_pressed() (one press, one tick).
var interact: bool = false
var wanted: int = 0
var cash: int = 0
var soul: String = "rivet"
var madness: String = "lucid"
var weapon: String = "none"
## Encounters the quest started, in order, and the ones a test (or script) has cleared.
var encounters_started: Array[String] = []
var cleared: Dictionary[String, bool] = {}
## Payphones the quest put a call on, calls answered, and places sabotaged (by place).
var rung: Dictionary[String, bool] = {}
var answered: Dictionary[String, bool] = {}
var sabotaged: Dictionary[String, bool] = {}
var vehicle_at: Dictionary[String, Vector2] = {}
var wrecked: Dictionary[String, bool] = {}
var actor_at: Dictionary[String, Vector2] = {}
var killed: Dictionary[String, bool] = {}
var calls: Array[String] = []
## When set, every wanted change goes out as Events.wanted_changed (the police setter, ARC-08).
var events: EventBus = null
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
	set_wanted(mini(wanted, level))


## The one wanted setter of the stub (ARC-08): emits when a bus is attached.
func set_wanted(level: int) -> void:
	if level == wanted:
		return
	wanted = level
	if events != null:
		events.wanted_changed.emit(level)


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


func player_id() -> int:
	return PLAYER_ID


func weapon_name() -> String:
	return weapon


func start_encounter(place: String) -> void:
	calls.append("encounter %s" % place)
	encounters_started.append(place)


func encounter_cleared(place: String) -> bool:
	return cleared.get(place, false)


## The stub router: a rung phone connects on an interact press on foot within reach of it.
func ring_phone(place: String) -> void:
	calls.append("ring %s" % place)
	rung[place] = true


func phone_answered(place: String) -> bool:
	if not answered.get(place, false) and rung.get(place, false):
		var near: bool = rivet.distance_to(_places.markers[place].phone) < ANSWER_RANGE_M
		answered[place] = near and driving == "" and interact_pressed()
	return answered.get(place, false)


## The stub sabotage: an interact press on foot inside the place's marker.
func sabotage_done(place: String) -> bool:
	if not sabotaged.get(place, false):
		var m: QuestPlaces.Marker = _places.markers[place]
		var inside: bool = rivet.distance_to(m.at) <= m.radius_m
		sabotaged[place] = inside and driving == "" and interact_pressed()
	return sabotaged.get(place, false)
