extends Node
## Events autoload (ARC-06): typed, past-tense, low-frequency domain events that cross features.
## Stateless. Every signal is registered in res://data/schemas/events.json (cap 40).
## Gameplay only emits; AchievementTracker (owned by Platform) listens (ACH-07).

@warning_ignore("unused_signal")
signal tutorial_completed
@warning_ignore("unused_signal")
signal soul_swapped(soul_index: int)
@warning_ignore("unused_signal")
signal vehicle_hijacked(vehicle_kind: StringName)
