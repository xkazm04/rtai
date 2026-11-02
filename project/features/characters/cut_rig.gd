class_name CutRig
extends Node2D
## A cutout (2D skeletal) character for the straight-down camera, ported from the spike
## (gtai-spike evolve/project/game/cutrig.gd, the cutout lane's v2 rig) for Rivet, cops and peds.
## The HOST owns movement and rules; the rig turns its velocity, facing, aim and clip triggers
## into a pose: speed-driven gait with world-planted feet (RigGait), torso counter-sway, a facing
## spring and hit springs (RigPose), aim IK and end-on arm cells (RigArm), the torch hose
## (RigHose), and the authored clip envelopes (RigClips). Parts are plain Sprite2D children with
## shared materials. Scale: 1 part px = 0.1 world px, the same for every body plan.
## Render-side only: never sim state, never hashed, no RNG.

const SC: float = 0.1
const WALK_SPEED: float = 64.0
const RUN_SPEED: float = 160.0
const STRIDE_WALK: float = 54.0
const STRIDE_RUN: float = 92.0
const COLLAR_K: float = 0.22

var plan: BodyPlan = null
var lib: PartLibrary = null
var variant: RigVariant = null
var actor_id: int = -1
var clips: RigClips = RigClips.new()

var vel_in: Vector2 = Vector2.ZERO
var face_to: float = 0.0
var aiming: bool = false
var aim_at: Vector2 = Vector2.ZERO
var gun_out: bool = false
var dead: bool = false

var c_tuck: float = 0.0
var c_sprawl: float = 0.0
var c_reach: float = 0.0
var c_recoil: float = 0.0
var c_lean: float = 0.0
var c_kick: float = 0.0
var c_hands_up: float = 0.0

var facing: float = 0.0
var face_w: float = 0.0
var turn_k: float = 260.0
var phase: float = 0.0
var run_blend: float = 0.0
var twist: float = 0.0
var twist_v: float = 0.0
var speed_now: float = 0.0
var t_alive: float = 0.0
var shove: Vector2 = Vector2.ZERO
var shove_v: Vector2 = Vector2.ZERO
## The rig's global transform and its inverse, cached once per pose step (hot path).
var xf: Transform2D = Transform2D.IDENTITY
var xf_inv: Transform2D = Transform2D.IDENTITY

var body: Node2D = null
var torso: Node2D = null
var pelvis: Node2D = null
var head: Node2D = null
var torso_spr: Sprite2D = null
var head_spr: Sprite2D = null
var pelvis_spr: Sprite2D = null
var collar_spr: Sprite2D = null
var sides: Array[RigLimbs] = [RigLimbs.new(), RigLimbs.new()]
var sprites: Array[Sprite2D] = []
var sprite_kinds: PackedInt32Array = PackedInt32Array()
var sprite_swaps: PackedInt32Array = PackedInt32Array()
var halos: Array[Sprite2D] = []
var halo_limb: PackedByteArray = PackedByteArray()
var hose: Line2D = null
var hose_pts: PackedVector2Array = PackedVector2Array()
var hose_prev: PackedVector2Array = PackedVector2Array()

var _tint: bool = false
var _last_px: float = -1.0


## Builds the parts once; a pooled rig then only changes variant (apply_variant).
func setup(p_plan: BodyPlan, p_variant: RigVariant) -> void:
	plan = p_plan
	lib = PartLibrary.of(p_plan.art_dir)
	variant = p_variant
	scale = Vector2.ONE * SC * plan.size_k
	RigBuild.build(self)
	apply_variant(p_variant)
	reset_state(0.0)


## Texture swaps only (head, torso, shield): no re-plan, no new nodes.
func apply_variant(v: RigVariant) -> void:
	variant = v
	if v.head != "":
		set_part_tex(head_spr, v.head)
	if v.torso != "":
		set_part_tex(torso_spr, v.torso)
	var shield: Sprite2D = sides[BodyPlan.L].shield
	if shield != null:
		shield.visible = v.shield


func reset_state(at_facing: float) -> void:
	dead = false
	gun_out = false
	aiming = false
	vel_in = Vector2.ZERO
	clips.reset()
	shove = Vector2.ZERO
	shove_v = Vector2.ZERO
	twist = 0.0
	twist_v = 0.0
	phase = 0.0
	t_alive = 0.0
	hose_pts.clear()
	set_tint(false)
	snap_facing(at_facing)
	face_to = at_facing
	if body != null:
		for s: int in 2:
			sides[s].plant(hip_world(s))


## One pose step of dt seconds (the manager calls it on the 60 Hz tick).
func drive(dt: float) -> void:
	t_alive += dt
	speed_now = vel_in.length()
	clips.sample(self, dt)
	if not dead:
		var dfa: float = wrapf(face_to - facing, -PI, PI)
		face_w += (turn_k * dfa - 2.0 * sqrt(turn_k) * face_w) * dt
		facing += face_w * dt
	rotation = facing
	shove_v += (-120.0 * shove - 2.0 * sqrt(120.0) * shove_v) * dt
	shove += shove_v * dt
	RigGait.step(self, dt)
	RigPose.step(self, dt)
	if hose != null:
		RigHose.step(self, dt)
	if absf(PartMaterials.view_px - _last_px) > 0.002:
		_on_view(PartMaterials.view_px)


func hit(from_dir: Vector2, strength: float) -> void:
	var d: Vector2 = from_dir.normalized().rotated(-facing)
	shove_v += d * strength
	var side: float = signf(d.y)
	twist_v += (0.9 if side == 0.0 else side) * strength * 0.012


func set_tint(on: bool) -> void:
	if on == _tint:
		return
	_tint = on
	for i: int in sprites.size():
		var kind: PartMaterials.PartKind = sprite_kinds[i] as PartMaterials.PartKind
		sprites[i].material = PartMaterials.get_mat(kind, on, sprite_swaps[i])
	if hose != null:
		hose.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, on, 0)


func snap_facing(a: float) -> void:
	facing = a
	face_w = 0.0
	rotation = a


## The muzzle in the parent's space (the host draws its flash there).
func muzzle_local() -> Vector2:
	if plan.gun_arm < 0:
		return Vector2.ZERO
	var side: RigLimbs = sides[plan.gun_arm]
	var spr: Sprite2D = side.hand if side.hand != null else side.fore
	var ts: Vector2 = spr.texture.get_size()
	var tip: Vector2 = Vector2(ts.x + spr.offset.x, ts.y * 0.5 + spr.offset.y)
	var host: Node2D = get_parent() as Node2D
	var at: Vector2 = spr.global_transform * tip
	return host.to_local(at) if host != null else at


func fwd() -> Vector2:
	return Vector2.RIGHT.rotated(facing)


func hip_local(s: int) -> Vector2:
	var y: float = plan.hip_y * plan.side_sign(s)
	return body.transform * (pelvis.position + Vector2(0, y).rotated(pelvis.rotation))


func hip_world(s: int) -> Vector2:
	return global_transform * hip_local(s)


func set_part_tex(spr: Sprite2D, part: String) -> void:
	RigBuild.set_tex(self, spr, part)


func _on_view(px: float) -> void:
	_last_px = px
	var hk: float = 1.0 - smoothstep(0.12, 0.3, px)
	if collar_spr != null:
		collar_spr.scale = Vector2.ONE * (1.0 + COLLAR_K * (1.0 - smoothstep(0.11, 0.14, px)))
	for i: int in halos.size():
		halos[i].visible = hk > 0.01
		if halo_limb[i] == 1:
			halos[i].scale = Vector2(1.0 + 0.04 * hk, 1.0 + 0.45 * hk)
		else:
			halos[i].scale = Vector2.ONE * (1.0 + 0.22 * hk)
