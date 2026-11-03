class_name MeleeHit
extends RefCounted
## One melee hit's timing (60 Hz ticks) and effect, a row of MeleeTable. The claw rows leave the
## weapon-only fields at 0: stun_ticks (a hit stun), chain_hops (arcs to metal targets within the
## weapon's chain_radius_m) and lunge_m (Rivet travels this far over windup + active).

var id: StringName = &""
var windup: int = 1
var active: int = 1
var recovery: int = 0
var reach_m: float = 1.0
var cone_dot: float = 0.5
var damage: float = 1.0
var knockback_m: float = 0.0
var stun_ticks: int = 0
var chain_hops: int = 0
var lunge_m: float = 0.0


func length() -> int:
	return windup + active + recovery
