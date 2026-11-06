class_name ShotLift
extends RefCounted
## d8-weapons: under a tilted --view a round flies at gun height, not along the floor. The sim's
## shot line is a ground line; the drawn round (tracer, bolt, ray, rocket), a body or metal hit
## and an enemy's muzzle star are lifted up the screen by GUN_H_M (ViewMode.lift_px), so the
## tracer leaves the drawn barrel tip and lands on the chest. A faint ink shadow line stays on
## the ground under a tracer (its height reads). Ground hits (dust, scuffs) stay on the ground.
## Straight down (`top`) lift_px is ZERO: nothing moves, bit-identical. `--shot-lift=off` = the
## before. Render only: reads the sim, never writes it.

## Rivet's held gun and a cop's sidearm sit about a metre up (Rivet's hip 0.78 m + the arm).
const GUN_H_M: float = 1.0
const SHADOW: Color = Color(0.090, 0.075, 0.106, 0.38)
const SHADOW_PX: float = 5.0


## The lift of a point at gun height, in metres of the FX layer (ZERO straight down or off).
static func up_m() -> Vector2:
	if LaunchArgs.value("--shot-lift") == "off":
		return Vector2.ZERO
	return ViewMode.shared().lift_px(GUN_H_M) / SimConst.PX_PER_M


## A hit at `at` of `kind` (GunFx.Hit): a body, metal or Rivet's plating at gun height; ground
## hits (dust, scuffs) stay on the ground.
static func hit_at(at: Vector2, kind: int) -> Vector2:
	return at if kind == GunFx.Hit.GROUND else at + up_m()


## An enemy muzzle star (GunFx.enemy_flashes: x, y = the ground point) at the cop's gun height.
static func star_at(ef: Vector4) -> Vector2:
	return Vector2(ef.x, ef.y) + up_m()


## Lays a round's ground shadow (tail..head, metres; only when lifted) and returns the lift.
static func line(ci: CanvasItem, tail_m: Vector2, head_m: Vector2) -> Vector2:
	var up: Vector2 = up_m()
	if up != Vector2.ZERO:
		ci.draw_line(Ink.px(tail_m), Ink.px(head_m), SHADOW, SHADOW_PX)
	return up


## Rivet's drawn round at `at` (metres), `flown` metres past the clear zone: lifted with a ground
## shadow up to a metre long. Thrown rounds arc on their own; a cone jet leaves the drawn tip.
static func round_at(ci: CanvasItem, s: Shot, at: Vector2, flown: float) -> Vector2:
	if s.spec.kind == WeaponSpec.Kind.THROWN or s.spec.kind == WeaponSpec.Kind.CONE:
		return at
	var dir: Vector2 = s.vel.normalized()
	return at + line(ci, at - dir * clampf(flown, 0.0, 1.0), at)
