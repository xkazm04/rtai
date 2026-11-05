class_name KingBeats
extends RefCounted
## King's phase beats (render only, posed on the fight's own ticks, no RNG): the throne-car
## stalls into the court with smoke from the hood; at the court's end King steps down off the
## car's right side (the step starts STEP_FROM_K into the transition) and the car stays where it
## stalled, steaming, for the rest of the fight; on the defeat his crown falls off and rolls.

const STEP_FROM_K: float = 0.45
const PUFFS: int = 7
const SMOKE: Color = Color("#EFE6D2")
const CROWN_FALL_S: float = 0.8
const CROWN_ROLL_M: float = 1.4


## Where King's body is drawn (cast px): the throne on the car, the step-down, then on foot.
static func king_px(f: BossFight, windup_px: Vector2) -> Vector2:
	var b: Fighter = f.body
	var at: Vector2 = Ink.px(b.pos) + windup_px
	if f.phase >= 2:
		return at
	var dir: Vector2 = car_dir(f)
	var throne: Vector2 = at + dir * KingRigs.THRONE_M * Ink.PX_PER_M
	var s: float = step_k(f)
	return throne.lerp(Ink.px(b.pos + KingMoves.step_down(dir)), s) if s > 0.0 else throne


## The car's heading: the body's while it drives, the stall's once it stops (the court).
static func car_dir(f: BossFight) -> Vector2:
	var km: KingMoves = f.moves as KingMoves
	if f.phase >= 1 and km != null and km.stall_facing != Vector2.INF:
		return km.stall_facing
	return f.body.facing


## 0..1 through the step-down (court -> on foot); 0 outside it.
static func step_k(f: BossFight) -> float:
	if f.phase != 1 or f.state != BossFight.State.TRANSITION or f.spec.phases.size() < 3:
		return 0.0
	var k: float = float(f.t) / float(maxi(f.spec.phases[2].transition, 1))
	return smoothstep(STEP_FROM_K, 1.0, k)


## How hard the car smokes: building through the stall, steady in the court, low as a wreck.
static func smoke_amount(f: BossFight) -> float:
	if f.phase == 0 and f.state == BossFight.State.TRANSITION:
		return clampf(float(f.t) / float(maxi(f.spec.phases[1].transition, 1)) * 1.5, 0.0, 1.0)
	return 0.0 if f.phase == 0 else (0.7 if f.phase == 1 else 0.4)


## Smoke puffs rising off `at` (cast px), drifting along `drift`; `now` the sim tick.
static func smoke(ci: CanvasItem, at: Vector2, drift: Vector2, now: int, amount: float) -> void:
	if amount <= 0.0:
		return
	for i: int in PUFFS:
		var life: float = fposmod(float(now) * 0.012 + float(i) / float(PUFFS), 1.0)
		var side: float = (fposmod(float(i) * 0.618034, 1.0) - 0.5) * 18.0
		var c: Vector2 = at + drift * life * 46.0 + drift.orthogonal() * side * (0.4 + life)
		var r: float = (5.0 + 13.0 * life) * (0.6 + 0.4 * amount)
		var a: float = (1.0 - life) * amount
		ci.draw_circle(c, r + 1.5, Color(Ink.INK, a * 0.8))
		ci.draw_circle(c, r, Color(SMOKE, a))


## The crown's fall on the defeat: offset (px) and spin from the head over CROWN_FALL_S.
static func crown_fall(f: BossFight, defeated_at: int) -> Vector3:
	var s: float = clampf(float(f.now() - defeated_at) * SimClock.TICK_DT / CROWN_FALL_S, 0.0, 1.0)
	var ease_out: float = 1.0 - (1.0 - s) * (1.0 - s)
	var off: Vector2 = f.body.facing.orthogonal() * CROWN_ROLL_M * Ink.PX_PER_M * ease_out
	return Vector3(off.x, off.y, ease_out * TAU * 1.5)
