class_name MeleeHit
extends RefCounted
## One melee hit's timing (60 Hz ticks) and effect, a row of MeleeTable. The claw rows leave the
## weapon-only fields at 0: stun_ticks (a hit stun), chain_hops (arcs to metal targets within the
## weapon's chain_radius_m), lunge_m (Rivet travels this far over windup + active) and grind_ticks
## (the chainsaw: while the attack is held the last active tick holds and lands every grind_ticks).

## n31 melee 02: `--melee-sweep` (MeleeSweep.on reads and sets it): the hit follows the drawn blade.
static var sweep: bool = OS.get_cmdline_user_args().has("--melee-sweep")

var id: StringName = &""
var windup: int = 1
var active: int = 1
var recovery: int = 0
var reach_m: float = 1.0
var cone_dot: float = 0.5
var damage: float = 1.0
var knockback_m: float = 0.0
var stun_ticks: int = 0
var stun_look: StringName = &"electric"
var chain_hops: int = 0
var lunge_m: float = 0.0
## n17 rivet-strike: > 0 = the lunge travels over the lunge_ticks ticks just before the contact
## tick (the body arrives as the hit lands, the feet planted through the wind-up before it);
## 0 = the before (lunge_m spread evenly over windup + active).
var lunge_ticks: int = 0
var grind_ticks: int = 0
## The bite always holds this long, held or not (a tap of the chainsaw still grinds).
var grind_min_ticks: int = 0
## n31 melee 02p3 (flag on): the drawn blade's angle range off the aim (rad, in the swing's side
## frame) the sweep's sector is clamped to (`sweep_arc_deg`); the default clamps nothing.
var sweep_arc: Vector2 = Vector2(-TAU, TAU)


func length() -> int:
	return windup + active + recovery


## n31 melee 02 part 2: a swing row's drawn geometry, adopted only with the flag on (off = the
## table's reach_m / lunge_ticks / recovery_ticks): `sweep_reach_m` where the drawn blade (grip
## offset + length_m) is shorter than reach_m, `sweep_lunge_ticks` so a lunge has arrived at
## contact, `sweep_recovery_ticks` to pay back a sweep that made the weapon stronger.
func adopt_sweep(t: DataTable, row: Dictionary) -> void:
	if row.has("sweep_reach_m"):
		reach_m = t.num(row, "sweep_reach_m")
	if row.has("sweep_lunge_ticks"):
		lunge_ticks = mini(t.integer(row, "sweep_lunge_ticks"), maxi(windup - 1, 0))
	if row.has("sweep_arc_deg"):
		sweep_arc = t.vec(row, "sweep_arc_deg") * (PI / 180.0)
	if row.has("sweep_recovery_ticks"):
		recovery = t.integer(row, "sweep_recovery_ticks")
