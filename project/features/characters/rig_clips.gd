class_name RigClips
extends RefCounted
## The authored clips the slice needs, as envelopes on the procedural rig (the spike's clips:
## no AnimationPlayer; the host's timers became these). A host triggers a clip; sample() turns
## the running clips into the rig's c_* parameters every pose step.
##   Rivet: PUNCH (the electroshock melee, combo 1-3), ROLL (the dodge tuck), DEATH (the sprawl)
##   cops:  SHOOT (recoil kick on the gun arm), HIT (shove + twist + flash)
## Durations are the spike pack's (24 fps clips): punch 10 f, third hit 14 f, roll 0.45 s.

enum Clip { NONE, PUNCH, ROLL, DEATH, SHOOT, HIT }

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

var punch_t: float = 0.0
var punch_len: float = PUNCH_S
var roll_t: float = 0.0
var death_t: float = -1.0
var death_amount: float = 1.0
var recoil: float = 0.0
var hit_t: float = 0.0
var fleeing: bool = false
## Set by the host while the body is knocked down (RigFeed.Flag.DOWN); clearing it gets up.
var down: bool = false
var down_amt: float = 0.0


func reset() -> void:
	punch_t = 0.0
	roll_t = 0.0
	death_t = -1.0
	recoil = 0.0
	hit_t = 0.0
	fleeing = false
	down = false
	down_amt = 0.0


func punch(combo: int) -> void:
	punch_len = PUNCH3_S if combo >= 3 else PUNCH_S
	punch_t = punch_len


func roll() -> void:
	roll_t = ROLL_S


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
	rig.c_lean = 0.6 * rig.c_reach
	rig.c_tuck = clampf(sin(PI * (1.0 - roll_t / ROLL_S)) * 1.7, 0.0, 1.0) if roll_t > 0.0 else 0.0
	rig.c_recoil = recoil
	rig.c_hands_up = move_toward(rig.c_hands_up, 0.85 if fleeing else 0.0, dt * 4.0)
	rig.set_tint(hit_t > HIT_TINT_FROM)
	if death_t >= 0.0:
		death_t += dt
		rig.dead = true
		rig.c_sprawl = minf(death_amount, death_t / DEATH_RAMP_S * death_amount)
	else:
		var rate: float = 1.0 / DOWN_FALL_S if down else 1.0 / DOWN_RISE_S
		down_amt = move_toward(down_amt, DOWN_SPRAWL if down else 0.0, dt * rate)
		rig.dead = down_amt > 0.05
		rig.c_sprawl = down_amt
