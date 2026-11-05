class_name RigClips
extends RefCounted
## The authored clips the slice needs, as envelopes on the procedural rig (the spike's clips:
## no AnimationPlayer; the host's timers became these). A host triggers a clip; sample() turns
## the running clips into the rig's c_* parameters every pose step.
##   Rivet: PUNCH (the electroshock melee, combo 1-3), ROLL (the dodge tuck), DEATH (the sprawl)
##   cops:  SHOOT (recoil kick on the gun arm), HIT (shove + twist + flash)
## Durations are the spike pack's (24 fps clips): punch 10 f, third hit 14 f, roll 0.45 s.

## STRIKE (rivet-arsenal): a timed claw or weapon swing fed from the live pilot (RigInput packs it).
enum Clip { NONE, PUNCH, ROLL, DEATH, SHOOT, HIT, STRIKE }

const PUNCH_S: float = 0.42
const PUNCH3_S: float = 0.58
const ROLL_S: float = 0.45
const DEATH_RAMP_S: float = 0.42
const RECOIL_DECAY: float = 6.0
const HIT_S: float = 0.18
const HIT_TINT_FROM: float = 0.10
const HIT_SHOVE: float = 90.0
## Knockdown (features/bodies): the sprawl a tackled body falls into, and how fast it falls / rises.
const DOWN_SPRAWL: float = 0.9
const DOWN_FALL_S: float = 0.22
const DOWN_RISE_S: float = 0.45
## The faller stays upright this long while the knock slide opens a gap, then sprawls.
const DOWN_DELAY_S: float = 0.12
## combat-notes: the sim lands a strike on its first active tick, where the night's curve left the
## claw cocked under the hit-stop; the jab starts JAB_TICKS before the windup ends and is out at
## full reach on the hit tick, then holds through the active frames.
const JAB_TICKS: float = 2.0
## False (`--soft-swing`): the night's curve (the A/B's before).
static var jab_early: bool = not OS.get_cmdline_user_args().has("--soft-swing")

var punch_t: float = 0.0
var punch_len: float = PUNCH_S
## A timed strike (rivet-motion's claw combo): [windup, active, recovery] seconds; overrides the
## punch's sine with anticipation (the torso cocks back), a fast extension on the active frames
## and an eased return. strike_t counts up; < 0 = no strike.
var strike_t: float = -1.0
var strike_ph: Vector3 = Vector3.ZERO
var roll_t: float = 0.0
## The running roll's length (rivet-motion: PlayerMotion's roll_ticks); the spike's 0.45 s default.
var roll_len: float = ROLL_S
var death_t: float = -1.0
var death_amount: float = 1.0
var recoil: float = 0.0
var hit_t: float = 0.0
var fleeing: bool = false
## Set by the host while the body is knocked down (RigFeed.Flag.DOWN); clearing it gets up.
var down: bool = false
var down_amt: float = 0.0
var down_t: float = 0.0


func reset() -> void:
	punch_t = 0.0
	roll_t = 0.0
	death_t = -1.0
	recoil = 0.0
	hit_t = 0.0
	fleeing = false
	down = false
	down_amt = 0.0
	down_t = 0.0


func punch(combo: int) -> void:
	punch_len = PUNCH3_S if combo >= 3 else PUNCH_S
	punch_t = punch_len


## arm: BodyPlan.L / R, or 2 = both hands (the finisher's slam).
func strike(rig: CutRig, windup_s: float, active_s: float, recovery_s: float, arm: int) -> void:
	strike_t = 0.0
	strike_ph = Vector3(windup_s, active_s, recovery_s)
	rig.strike_arm = arm


func roll(duration_s: float = ROLL_S) -> void:
	roll_len = maxf(duration_s, 0.05)
	roll_t = roll_len


## blown = an explosion death: a wider sprawl.
func die(blown: bool) -> void:
	if death_t < 0.0:
		death_t = 0.0
		death_amount = 1.25 if blown else 1.0


func shoot(kick: float) -> void:
	recoil = clampf(kick, 0.4, 1.6)


func hit(rig: CutRig, from_dir: Vector2) -> void:
	hit_t = HIT_S
	rig.hit(from_dir if from_dir != Vector2.ZERO else -rig.fwd(), HIT_SHOVE)


func rolling() -> bool:
	return roll_t > 0.0


func active() -> Clip:
	if death_t >= 0.0:
		return Clip.DEATH
	if roll_t > 0.0:
		return Clip.ROLL
	if punch_t > 0.0:
		return Clip.PUNCH
	if hit_t > 0.0:
		return Clip.HIT
	if recoil > 0.0:
		return Clip.SHOOT
	return Clip.NONE


## Advances the clips by dt and writes the envelopes into the rig.
func sample(rig: CutRig, dt: float) -> void:
	punch_t = maxf(0.0, punch_t - dt)
	roll_t = maxf(0.0, roll_t - dt)
	recoil = maxf(0.0, recoil - dt * RECOIL_DECAY)
	hit_t = maxf(0.0, hit_t - dt)
	rig.c_reach = sin((1.0 - punch_t / punch_len) * PI) if punch_t > 0.0 else 0.0
	if strike_t >= 0.0:
		rig.c_reach = _strike_reach()
		strike_t += dt
		if strike_t > strike_ph.x + strike_ph.y + strike_ph.z:
			strike_t = -1.0
			rig.strike_arm = -1
	rig.c_lean = 0.6 * rig.c_reach
	rig.c_tuck = (
		clampf(sin(PI * (1.0 - roll_t / roll_len)) * 1.7, 0.0, 1.0) if roll_t > 0.0 else 0.0
	)
	rig.c_recoil = recoil
	rig.c_plank = 0.0
	rig.plank_feet = -1.0
	rig.c_kick = 0.0  # DeathPose's blast corpse sets it again (a pooled rig must not keep it)
	rig.c_hands_up = move_toward(rig.c_hands_up, 0.85 if fleeing else 0.0, dt * 4.0)
	rig.set_tint(hit_t > HIT_TINT_FROM)
	if death_t >= 0.0:
		death_t += dt
		rig.dead = true
		rig.c_sprawl = minf(death_amount, death_t / DEATH_RAMP_S * death_amount)
	else:
		down_t = down_t + dt if down else 0.0
		var falling: bool = down and down_t >= DOWN_DELAY_S
		var rate: float = 1.0 / DOWN_FALL_S if down else 1.0 / DOWN_RISE_S
		var goal: float = DOWN_SPRAWL if falling else (down_amt if down else 0.0)
		down_amt = move_toward(down_amt, goal, dt * rate)
		rig.dead = down_amt > 0.05
		rig.c_sprawl = down_amt


## The strike's reach: -0.35 at the end of the windup (the torso twists back), 1 by the end of
## the active frames (ease-out), back to 0 over the recovery (smoothstep); jab_early: see JAB_TICKS.
func _strike_reach() -> float:
	var w: float = maxf(strike_ph.x, 0.001)
	var a: float = maxf(strike_ph.y, 0.001)
	var r: float = maxf(strike_ph.z, 0.001)
	if jab_early:
		var c0: float = w - minf(JAB_TICKS * SimClock.TICK_DT, w * 0.5)
		if strike_t < c0:
			return -0.35 * smoothstep(0.0, 1.0, strike_t / c0)
		if strike_t < w + a:
			return lerpf(-0.35, 1.0, minf((strike_t - c0) / (w - c0), 1.0))
		return 1.0 - smoothstep(0.0, 1.0, (strike_t - w - a) / r)
	if strike_t < w:
		return -0.35 * smoothstep(0.0, 1.0, strike_t / w)
	if strike_t < w + a:
		var k: float = (strike_t - w) / a
		return lerpf(-0.35, 1.0, 1.0 - (1.0 - k) * (1.0 - k))
	return 1.0 - smoothstep(0.0, 1.0, (strike_t - w - a) / r)
