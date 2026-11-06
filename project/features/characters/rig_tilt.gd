class_name RigTilt
extends RefCounted
## View lab (docs/view-lab/PLAN.md): the 2.5D cutout under a tilted --view. Every joint keeps its
## top-down art and is lifted up the screen by its height:
## screen = (x, y sin(pitch) - z cos(pitch)), where the camera does the sin(pitch)
## (ViewMode.zoom_of) and this does the z (ViewMode.lift_k).
## The legs are already a 3D chain (RigGait: hip at hip_z, the knee from ik3, the foot's lift), so
## hip, knee and foot each draw at their own height and the legs stand up; the body lifts to the
## hips, the torso and the head above them. rig.tilt_up is the screen-up direction in the rig's own
## part space per part px of height (ZERO straight down: nothing here runs, bit-identical).
## Render only: the feet still plant on the ground point (CutRig.hip_local subtracts the lift).

## The chest's height above the hips and the head's above the chest, in hip heights.
const TORSO_ABOVE_HIP: float = 0.55
const HEAD_ABOVE_TORSO: float = 0.45


## Once per pose step after the facing is set: the rig's screen-up per part px of height.
static func aim_up(rig: CutRig) -> void:
	var k: float = ViewMode.shared().lift_k()
	if k == 0.0:
		rig.tilt_up = Vector2.ZERO
		return
	var up: Vector2 = Vector2(0.0, -k / ViewMode.shared().ground_k())
	rig.tilt_up = up.rotated(-rig.global_rotation)


## The body node's lift (to the hips).
static func body_lift(rig: CutRig) -> Vector2:
	return rig.tilt_up * hip_h(rig)


static func hip_h(rig: CutRig) -> float:
	var p: BodyPlan = rig.plan
	return p.hip_z * (1.0 - 0.75 * rig.c_sprawl) * (1.0 - 0.35 * rig.c_tuck)


## After RigPose: the torso over the hips and the head over the chest (torso.position is set
## once at build, so it is set here, not added).
static func lift_upper(rig: CutRig) -> void:
	var h: float = hip_h(rig)
	rig.torso.position = rig.plan.torso_pos + rig.tilt_up * h * TORSO_ABOVE_HIP
	rig.head.position += rig.tilt_up * h * HEAD_ABOVE_TORSO
