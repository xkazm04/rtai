class_name MeleeSwing
extends RefCounted
## combat-notes (owner note 2026-11-04, "player's hold and animation of melee weapons"): the
## blade's angle off the aim line through one strike, in the strike clip's phases (windup,
## active, recovery). Anticipation: the blade cocks past the hit's arc (ANTIC) and settles there;
## the cut throws it across fast, through the aim line on the hit tick, to an overshoot (FOLLOW)
## on the far side; the follow-through holds there for HOLD of the recovery, then eases home.
## The smear (MeleeSmearView) fills the cut. View only: the sim's windup/active/recovery stay.
## `--soft-swing` = the night's linear sweep with no smear (the A/B's before). No RNG.

const ANTIC: float = 1.3
const FOLLOW: float = 1.35
const HOLD: float = 0.35
## Ticks of the cut before the hit tick (the blade's travel into the target).
const CUT_TICKS: float = 2.0
## The held chainsaw's idle shake (rad at the extreme step).
const IDLE_JUDDER: float = 0.04
## The melee weapons held in both claws (the claw's own blades and the baton stay one-handed).
const TWO_HAND: Array[StringName] = [&"katana", &"plasma_sword", &"chainsaw"]

## False (`--soft-swing`): the night's sweep (RivetHeldView before), no smear.
static var sharp: bool = not OS.get_cmdline_user_args().has("--soft-swing")
## True (`--two-hand-grip`): the off claw rides a two-handed melee hilt (RigGrip.melee_hilt).
static var grip_on: bool = OS.get_cmdline_user_args().has("--two-hand-grip")


## The angle (rad, signed by `side`) at clip time `t` (s) of a strike with phases `ph`
## (windup, active, recovery, s) and half-arc `arc`. The cut starts CUT_TICKS before the
## windup ends, so the blade crosses the aim line on the hit tick (the sim lands the hit on the
## first active tick; its hit-stop then holds the blade in the target, the smear behind it).
static func angle(t: float, ph: Vector3, side: float, arc: float) -> float:
	if not sharp:
		return _night(t, ph, side, arc)
	var c0: float = cut_start(ph)
	if t < c0:  # anticipation: cock back fast, settle past the arc
		var w: float = t / maxf(c0, 0.001)
		return side * arc * ANTIC * (1.0 - (1.0 - w) * (1.0 - w))
	if t < ph.x:  # the cut, into the target: on the aim line at the hit tick
		return side * arc * ANTIC * (1.0 - (t - c0) / maxf(ph.x - c0, 0.001))
	if t < ph.x + ph.y:  # through it, easing out to the overshoot
		var k: float = (t - ph.x) / maxf(ph.y, 0.001)
		return -side * arc * FOLLOW * (1.0 - (1.0 - k) * (1.0 - k))
	var r: float = (t - ph.x - ph.y) / maxf(ph.z, 0.001)
	if r < HOLD:  # follow-through: the blade stays out past the target
		return -side * arc * FOLLOW
	return -side * arc * FOLLOW * (1.0 - smoothstep(0.0, 1.0, (r - HOLD) / (1.0 - HOLD)))


## The chainsaw's idle judder while it is held and not biting (the engine running): a
## tick-locked shake off rhythm with itself, (rotation rad, sideways px); zero under --soft-swing.
static func idle_judder(tick: int) -> Vector2:
	if not sharp:
		return Vector2.ZERO
	var a: int = tick % 5 - 2
	var b: int = (tick % 3) - 1
	return Vector2(IDLE_JUDDER * float(a) * 0.5, float(b))


## True for a melee weapon both claws hold (the off claw on the hilt). Off unless
## `--two-hand-grip`: the off wrist closes on the hilt (test_two_hand_hilt), but Rivet's off arm
## ends in a torch tool, not a claw, which draws across the blade (dev/combat_notes/hilt_probe.gd);
## it waits for the redesigned rig's off hand (combat-notes iteration 4).
static func two_handed(weapon: StringName) -> bool:
	return sharp and grip_on and weapon in TWO_HAND


## When the cut starts (s): CUT_TICKS before the windup ends, never before half of it.
static func cut_start(ph: Vector3) -> float:
	return ph.x - minf(CUT_TICKS * SimClock.TICK_DT, ph.x * 0.5)


## True while the blade is in its cut (the smear runs), to just past the active ticks.
static func cutting(t: float, ph: Vector3) -> bool:
	return sharp and t >= cut_start(ph) and t < ph.x + ph.y + ph.z * 0.12


## The night's sweep (rivet-arsenal): smoothstep windup to the arc, linear across, ease home.
static func _night(t: float, ph: Vector3, side: float, arc: float) -> float:
	if t < ph.x:
		return side * arc * smoothstep(0.0, 1.0, t / maxf(ph.x, 0.001))
	if t < ph.x + ph.y:
		var k: float = (t - ph.x) / maxf(ph.y, 0.001)
		return side * arc * (1.0 - 2.0 * k)
	var r: float = (t - ph.x - ph.y) / maxf(ph.z, 0.001)
	return -side * arc * (1.0 - smoothstep(0.0, 1.0, r))
