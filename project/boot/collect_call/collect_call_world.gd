# gdlint: disable=max-public-methods
class_name CollectCallWorld
extends QuestWorld
## The QuestWorld port onto quest 1's stage (the integration the F-12 README promised): what
## the quest reads comes from the stage's features, and what it asks goes through their setters
## (HeatMeter.set_level, Wallet.add, PayphoneRouter.queue_call). No car is drivable yet. The
## barks hear the stage through the typed Events it emits (QuestFacts), never through this port.
## (It implements the whole QuestWorld port, hence the gdlint max-public-methods disable.)

const MADNESS: String = "crowded"
## Where the sabotage target (the TUCK-IN crate stack) stands.
const CRATES_PLACE: String = "Dock 9 vault cage"

## Toner Room allies the quest has brought on stage (for the view).
var allies: Array[String] = []
var stage: CollectCallStage


func _init(p_stage: CollectCallStage) -> void:
	stage = p_stage


func places() -> QuestPlaces:
	return stage.layout.places


func focus_position() -> Vector2:
	return stage.arena.rivet.pos


func in_vehicle() -> bool:
	return false


func player_dead() -> bool:
	return not stage.arena.rivet.alive()


func interact_pressed() -> bool:
	var pressed: bool = stage.press_left
	stage.press_left = false
	return pressed


func wanted_level() -> int:
	return stage.heat.level


func cap_wanted(level: int) -> void:
	stage.heat.set_level(mini(stage.heat.level, level))


## The payout, less Juno's tape bill for every time Rivet was destroyed (fail state 1).
func pay(amount: int) -> void:
	stage.wallet.add(maxi(amount - stage.layout.tape_bill * stage.deaths, 0))


func soul_name() -> String:
	return "rivet"


func madness_band() -> String:
	return MADNESS


func place_vehicle(_tag: String) -> void:
	pass


func vehicle_wrecked(_tag: String) -> bool:
	return false


func spawn_actor(tag: String) -> void:
	if not allies.has(tag):
		allies.append(tag)


func actor_dead(_tag: String) -> bool:
	return false


func actor_position(tag: String) -> Vector2:
	return stage.layout.places.actors[tag].at


func escort_toward(_tag: String, _to: Vector2) -> void:
	pass


func player_id() -> int:
	return stage.arena.rivet.id


## Rivet's weapon as the bark vocabulary names it (`none` when unarmed).
func weapon_name() -> String:
	var held: String = stage.weapon_name()
	return held if held != "" else "none"


## The encounter at `place` comes once Rivet is inside its marker (the stage arms it).
func start_encounter(place: String) -> void:
	stage.arm_encounter(place)


func encounter_cleared(place: String) -> bool:
	return stage.encounter_cleared(place)


## Patch's router: the call waits on the phone and rings only at heat 0 (PayphoneRouter).
func ring_phone(place: String) -> void:
	stage.router.queue_call(place)


func phone_answered(place: String) -> bool:
	return stage.router.connected(place)


## The torch is the stage's (StageActions): the TUCK-IN stack burning at the vault cage.
func sabotage_done(place: String) -> bool:
	return stage.crates_burning and place == CRATES_PLACE
