class_name MeleeHit
extends RefCounted
## One melee hit's timing (60 Hz ticks) and effect, a row of MeleeTable.

var id: StringName = &""
var windup: int = 1
var active: int = 1
var recovery: int = 0
var reach_m: float = 1.0
var cone_dot: float = 0.5
var damage: float = 1.0
var knockback_m: float = 0.0


func length() -> int:
	return windup + active + recovery
