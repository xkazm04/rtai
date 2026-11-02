@abstract class_name QuestWorld
extends RefCounted
## The quest runtime's port onto the world (LAY-05): everything a quest reads or asks for, and
## nothing else. The composition root injects an implementation backed by the real systems
## (player, vehicles, police, economy, souls); tests inject a stub. Positions are metres.
## Shared state changes only through the owning feature's one setter (ARC-08): the quest asks
## (cap_wanted, pay), it never writes a field.

## What a job beat asks the world to do at a marker (ask()).
enum Ask { RING_PHONE, START_ENCOUNTER }
## What a job beat waits for at a marker (reached()).
enum Goal { PHONE_CONNECTED, ENCOUNTER_CLEARED, SABOTAGED }

## The named places and things this world resolves (gtai.questMarkers/1).
@abstract func places() -> QuestPlaces

## Rivet's position, or his vehicle's while he drives.
@abstract func focus_position() -> Vector2

@abstract func in_vehicle() -> bool

@abstract func player_dead() -> bool

## Rivet pressed the interact action on this tick (the input feature owns the binding).
@abstract func interact_pressed() -> bool

@abstract func wanted_level() -> int

## Lowers the wanted level to `level` through the police feature's setter.
@abstract func cap_wanted(level: int) -> void

## Pays `amount` through the economy feature's setter.
@abstract func pay(amount: int) -> void

## The name of the soul in control (`rivet`, `hauler`, ... as in quest_rules.json `souls`).
@abstract func soul_name() -> String

## The current madness band (quest_rules.json `madness_bands`).
@abstract func madness_band() -> String

## Parks the tagged vehicle at its place, unless Rivet is already driving.
@abstract func place_vehicle(tag: String) -> void

@abstract func vehicle_wrecked(tag: String) -> bool

## Spawns the tagged actor at its place (once; a second call keeps the first).
@abstract func spawn_actor(tag: String) -> void

@abstract func actor_dead(tag: String) -> bool

@abstract func actor_position(tag: String) -> Vector2

## Steers an escorted ally toward `to` for this tick.
@abstract func escort_toward(tag: String, to: Vector2) -> void

# Job-quest additions (quest 1 collect-call, docs/decisions.md). Not abstract: a world without
# the system answers "nothing here", so older worlds and stubs keep compiling unchanged.


## A bare bark cue (quest_rules.json `cues`) the world raised on this tick, or holds now.
func cue_raised(_tag: String) -> bool:
	return false


## The id of the weapon in Rivet's hands (quest_rules.json `weapons`), "" for none.
func weapon_name() -> String:
	return ""


## RING_PHONE: the payphone router rings the marker's phone (it rings only while heat is 0).
## START_ENCOUNTER: the hostiles staged at the marker (waves, a boss) come, once.
func ask(_what: Ask, _location: String) -> void:
	pass


## PHONE_CONNECTED: Rivet answered the marker's phone and Patch connected the call.
## ENCOUNTER_CLEARED: every hostile staged there is down. SABOTAGED: the target there is done.
func reached(_goal: Goal, _location: String) -> bool:
	return false
