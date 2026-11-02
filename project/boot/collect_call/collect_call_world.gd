class_name CollectCallWorld
extends QuestWorld
## The QuestWorld port onto quest 1's stage (the integration the F-12 README promised): what
## the quest reads comes from the stage's features, and what it asks goes through their setters
## (HeatMeter.set_level, Wallet.add, PayphoneRouter.queue_call). No car is drivable yet.

const MADNESS: String = "crowded"

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


func cue_raised(tag: String) -> bool:
	return stage.cues.get(tag, false)


func weapon_name() -> String:
	return stage.weapon_name()


func ask(what: QuestWorld.Ask, location: String) -> void:
	match what:
		QuestWorld.Ask.RING_PHONE:
			stage.router.queue_call(location)
		QuestWorld.Ask.START_ENCOUNTER:
			stage.arm_encounter(location)


func reached(goal: QuestWorld.Goal, location: String) -> bool:
	match goal:
		QuestWorld.Goal.PHONE_CONNECTED:
			return stage.router.connected(location)
		QuestWorld.Goal.ENCOUNTER_CLEARED:
			return stage.encounter_cleared(location)
	return stage.crates_burning and location == "Dock 9 vault cage"
