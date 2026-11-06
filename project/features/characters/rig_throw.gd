class_name RigThrow
extends RefCounted
## n7-ranged (audit row 10, the molotov's anticipation): the throw had no wind-up; the bottle left
## a claw already held out at the aim. Now a ready bottle is held cocked, back past the gun
## shoulder and up (the class's windup_px, held_classes.json); the throw (the rig's negative
## recoil, arena.json rig_kick) whips the claw out to its aim, eases back to the chest as the
## recoil decays, and the next bottle comes up there and cocks again in the reload's cock phase.
## windup_px 0 or `--throw-windup=off` = held out at the aim (the before). Render only: the release
## tick is the sim's; this poses the claw around it.

## The cocked claw sits this share of the gun shoulder's offset out to the side, and this high
## (part px, z up): by the helmet, the lit bottle over the shoulder.
const OUT_K: float = 1.5
const UP_PX: float = 40.0

## A reload phase this young (out phase share) still counts as the release's first frame.
const LAG_K: float = 0.2

static var on: bool = not OS.get_cmdline_user_args().has("--throw-windup=off")


## The aimed claw of a ready bottle: cocked, out to `aimed` (the arm's aim target) while a
## throw's release lasts.
static func held_ready(rig: CutRig, hold: HeldTable.Hold, aimed: Vector3) -> Vector3:
	var px: float = windup_px(hold)
	if px <= 0.0:
		return aimed
	return _back(rig, px).lerp(aimed, release(rig))


## The aimed claw in the reload: at `chest` until the cock phase draws it back; a release still
## showing holds it out at `aimed` first.
static func in_reload(rig: CutRig, hold: HeldTable.Hold, chest: Vector3, aimed: Vector3) -> Vector3:
	var px: float = windup_px(hold)
	if px <= 0.0:
		return chest
	var h: Vector3 = chest
	if rig.reload_k >= 2.0:
		h = chest.lerp(_back(rig, px), smoothstep(0.0, 1.0, clampf(rig.reload_k - 2.0, 0.0, 1.0)))
	return h.lerp(aimed, release(rig))


## The frame the throw's reload starts before the rig has posed the release (it posed with last
## frame's state): the bottle stays drawn in the cocked claw, so it never leaves from behind.
static func lag_frame(rig: CutRig) -> bool:
	return on and rig.reload_k >= 0.0 and rig.reload_k < LAG_K and release(rig) <= 0.0


## The class's wind-up (part px), 0 when off.
static func windup_px(hold: HeldTable.Hold) -> float:
	return hold.windup_px if on and hold != null else 0.0


## How far a throw's release holds the claw out (1 for the first 0.1 s, to 0 as the recoil fades).
static func release(rig: CutRig) -> float:
	return clampf(-rig.c_recoil, 0.0, 1.0)


static func _back(rig: CutRig, px: float) -> Vector3:
	var gs: Vector3 = rig.plan.shoulder[rig.plan.gun_arm]
	return Vector3(gs.x - px, gs.y * OUT_K, UP_PX)
