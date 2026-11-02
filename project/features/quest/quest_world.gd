# gdlint: disable=max-public-methods
@abstract class_name QuestWorld
extends RefCounted
## The quest runtime's port onto the world (LAY-05): everything a quest reads or asks for, and
## nothing else. The composition root injects an implementation backed by the real systems
## (player, vehicles, police, economy, souls); tests inject a stub. Positions are metres.
## Shared state changes only through the owning feature's one setter (ARC-08): the quest asks
## (cap_wanted, pay), it never writes a field. (The port is the whole contract surface, 23
## methods; hence the gdlint max-public-methods disable above.)

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

## Rivet's runtime actor id (Events.actor_killed.killer_id when he made the kill).
@abstract func player_id() -> int

## The weapon in Rivet's hands (quest_rules.json `weapon` values; `none` = unarmed).
@abstract func weapon_name() -> String

## Starts the combat encounter held at `place` (places.encounters): waves, enemies, a boss.
@abstract func start_encounter(place: String) -> void

## True once every enemy of the encounter at `place`, its boss included, is down.
@abstract func encounter_cleared(place: String) -> bool

## Puts the job's call on the payphone at `place` (once per beat). The world's payphone router
## rings it when it can: Patch's router rings only at wanted 0 and refuses a hot pick-up.
@abstract func ring_phone(place: String) -> void

## True once Rivet picked up the ringing payphone at `place` on foot and the call connected.
@abstract func phone_answered(place: String) -> bool

## True once the sabotage target at `place` is done. The world owns the act (the torch, a
## charge); the quest only asks, after the place's encounter is cleared.
@abstract func sabotage_done(place: String) -> bool
