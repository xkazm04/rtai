class_name StageIntent
extends RefCounted
## What Rivet means to do on this tick, filled by a bot or by StagePilot (the bound input):
## where to walk, one interact press, where to shoot. Never raw keys (GDS-08).

var move_to: Vector2 = Vector2.INF
var interact: bool = false
var fire_at: Vector2 = Vector2.INF
## A player's displacement for this tick (StagePilot's mover), used when move_to is unset.
var move_by: Vector2 = Vector2.ZERO


func clear() -> void:
	move_to = Vector2.INF
	interact = false
	fire_at = Vector2.INF
	move_by = Vector2.ZERO
