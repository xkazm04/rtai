class_name KingRigs
extends Node2D
## King and his gang on the cutout rigs (render only, SIM-03: posed from the fights every frame).
## King is KingPlan (Rivet's skeleton, King's parts, art/d5/king) at boss size: enthroned on the
## car in phases 1-2 (seated: no stride, facing the car's nose), on foot in phase 3. The gang is the
## robot thug's rig in the rich dress (GangPlan): two push the throne-car, two ride its sides in
## phase 1 (they stride with the car), then the adds fight on foot. A hit shoves the frame (never
## cancels an attack); the active window plays the strike; a downed add powers down on its rig.
## Child of KingBodyView, so it draws over the car (the parent's own _draw).

## King's boss scale over Rivet's skeleton (target: about 1.6x Rivet's bulk; KingPlan.SIZE_K 1.3).
const KING_SIZE_K: float = 1.55
const HIT_SHOVE: float = 30.0
## The gang's places on the car in phase 1, metres from its centre along (nose, right): two push
## from the back corners (they stride with the car), two ride the running boards mid-car, still and
## facing out to the street (the target's gang hanging off the sides).
const RIDERS: Array[Vector2] = [
	Vector2(-2.9, -1.55), Vector2(-2.9, 1.55), Vector2(0.7, -1.6), Vector2(0.7, 1.6)
]
const RIDING: Array[bool] = [false, false, true, true]
## Where King sits on the car (the throne), metres back from its centre.
const THRONE_M: float = -0.55
const RIDER_ID: int = 9190
## King's gold leaf (print_part swap 5) on his chest and press arms: the target's gold-leafed
## plates, kept at 32 px/m where the part art's own gold is lost to the flat stickers. -1 = the
## plain cream-and-steel d5 King (the iteration-2 look).
const GOLD_SWAP: int = 5
## The target's flat press plates (tools/art/king_press_parts.py): the left hand cell and the right
## forearm's end. false = Rivet's claw (left) and the megaphone forearm (right), iterations 1-7.
const PRESS_PLATES: bool = true
## The target's shoulder megaphone (the horn cut from the old megaphone forearm), on the right
## shoulder pointing forward and a touch out, over the arms: rig px, radians, scale, z.
const HORN_AT: Vector2 = Vector2(10.0, 215.0)
const HORN_TURN: float = 0.35
## n7-king it12: 2.2 (was 1.6, a dark smudge under the plate at 32 px/m; 2.6 covers the plate).
const HORN_K: float = 2.2
const HORN_Z: int = 40
## Which arm strikes per attack (BodyPlan.L / R, 2 = both press plates); others: by body id.
const ATTACK_ARMS: Dictionary[StringName, int] = {
	&"press_slam": 2, &"charge": BodyPlan.L, &"decree": BodyPlan.R, &"coin_fan": BodyPlan.L
}
## Attacks whose tell lifts both arms over the head (the press plates up before the slam).
const RAISE_IN_TELL: Array[StringName] = [&"press_slam"]
## A downed add lies this long, then inks out and sinks into its oil over ADD_FADE_S (the
## arena's CorpseFade look: never alpha, the part print discards it), then leaves the floor.
const ADD_LINGER_S: float = 6.0
const ADD_FADE_S: float = 1.5
## Pose steps caught up in one frame at most (a hitch never fast-forwards a long clip).
const MAX_STEPS: int = 4

var _rigs: Dictionary[int, CutRig] = {}
var _last: Dictionary[int, Vector2] = {}
var _hurt_seen: Dictionary[int, int] = {}
var _was: Dictionary[int, int] = {}
var _down_at: Dictionary[int, int] = {}
var _tick: int = -1
var _steps: int = 0


## Poses every body for this frame, one drive step per sim tick since the last frame;
## `windup_px` is the car's tell offset (KingBodyView).
func pose(fight: BossFight, adds: BossAdds, windup_px: Vector2) -> void:
	_steps = 0 if _tick < 0 else clampi(fight.now() - _tick, 0, MAX_STEPS)
	_tick = fight.now()
	var b: Fighter = fight.body
	var on_car: bool = fight.phase <= 1 and KingBeats.step_k(fight) <= 0.0
	var at: Vector2 = KingBeats.king_px(fight, windup_px)  # the throne, the step-down, on foot
	if fight.phase <= 1:  # view lab: on the car's roof under a tilt, down with the step
		var roof: Vector2 = ViewMode.shared().lift_at(to_global(at), KingCarStack.ROOF_M)
		at += roof * (1.0 - KingBeats.step_k(fight))
	var king: CutRig = _rig(b.id, true, at, b.facing)
	_place(king, b.id, at, b.facing, Vector2.ZERO if on_car else Vector2.INF)
	_react(king, b, fight)
	for i: int in RIDERS.size():
		var id: int = RIDER_ID + i
		var ride: Vector2 = b.facing * RIDERS[i].x + b.facing.orthogonal() * RIDERS[i].y
		var r_at: Vector2 = Ink.px(b.pos + ride) + windup_px
		var out: Vector2 = b.facing.orthogonal() * signf(RIDERS[i].y)
		var r_face: Vector2 = out if RIDING[i] else b.facing
		var r: CutRig = _rig(id, false, r_at, r_face)
		r.visible = fight.phase == 0
		_place(r, id, r_at, r_face, Vector2.ZERO if RIDING[i] else Vector2.INF)
	for f: BossFight in adds.fights if adds != null else []:
		var g: CutRig = _rig(f.body.id, false, Ink.px(f.body.pos), f.body.facing)
		_place(g, f.body.id, Ink.px(f.body.pos), f.body.facing, Vector2.INF)
		_react(g, f.body, f)
		_fade_down(g, f, fight.now())  # a downed add is no longer stepped: the boss's clock
	if not ViewMode.shared().is_flat():  # view lab: far-side bodies behind the car
		KingCarStack.sort_rigs(_rigs, b.id, fight)


## The visible car riders' places for the accents: (x px, y px, facing angle).
func rider_marks() -> Array[Vector3]:
	var out: Array[Vector3] = []
	for i: int in RIDERS.size():
		var rig: CutRig = _rigs.get(RIDER_ID + i)
		if rig != null and rig.visible:
			out.append(Vector3(rig.position.x, rig.position.y, rig.face_to))
	return out


func _rig(id: int, is_king: bool, at: Vector2, facing: Vector2) -> CutRig:
	if not _rigs.has(id):
		var rig: CutRig = CutRig.new()
		add_child(rig)
		rig.setup(king_plan() if is_king else GangPlan.build(), RigVariant.rivet())
		if is_king and PRESS_PLATES:
			_horn(rig)
		rig.actor_id = id
		rig.position = at
		rig.snap_facing(facing.angle())
		_rigs[id] = rig
		_last[id] = at
	return _rigs[id]


## A downed add inks out and sinks after ADD_LINGER_S, then hides.
func _fade_down(rig: CutRig, f: BossFight, now: int) -> void:
	if f.state != BossFight.State.DEFEATED:
		return
	var at: int = _down_at.get(f.body.id, -1)
	if at < 0:
		_down_at[f.body.id] = now
		return
	var k: float = (float(now - at) * SimClock.TICK_DT - ADD_LINGER_S) / ADD_FADE_S
	if k <= 0.0:
		return
	rig.visible = k < 1.0
	rig.modulate = Color.WHITE.lerp(Ink.INK, clampf(k, 0.0, 1.0))
	rig.scale = Vector2.ONE * CutRig.SC * rig.plan.size_k * lerpf(1.0, 0.45, clampf(k, 0.0, 1.0))


## King's boss plan: KingPlan at boss size with the gold leaf (KingPlan itself stays the plain
## robot the enemy-ai thug is built from).
static func king_plan() -> BodyPlan:
	var p: BodyPlan = KingPlan.build(KING_SIZE_K)
	p.torso_swap = GOLD_SWAP
	p.arm_swap = GOLD_SWAP
	if PRESS_PLATES:
		p.hand_open = "press_plate"
		p.hand_closed = "press_plate"
		p.hand_pistol = "press_plate"
		p.fore_part[BodyPlan.R] = "r_forearm_press"
	return p


## The shoulder megaphone: a gilded rig part on the torso (tinted with the rest on a hit flash).
static func _horn(rig: CutRig) -> void:
	var spr: Sprite2D = Sprite2D.new()
	spr.texture = PartLibrary.texture(rig.plan.art_dir, "megaphone")
	spr.centered = false
	spr.offset = -PartLibrary.of(rig.plan.art_dir).pivot("megaphone", spr.texture)
	spr.position = HORN_AT
	spr.rotation = HORN_TURN
	spr.scale = Vector2.ONE * HORN_K
	spr.z_index = HORN_Z
	spr.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, GOLD_SWAP)
	rig.torso.add_child(spr)
	rig.sprites.append(spr)
	@warning_ignore_start("return_value_discarded")
	rig.sprite_kinds.append(int(PartMaterials.PartKind.PART))
	rig.sprite_swaps.append(GOLD_SWAP)
	@warning_ignore_restore("return_value_discarded")


## `vel` INF = the stride from the frame's own motion; a given vel overrides it (seated: zero).
func _place(rig: CutRig, id: int, at: Vector2, facing: Vector2, vel: Vector2) -> void:
	if _steps <= 0:
		return
	var moved: Vector2 = (at - _last.get(id, at)) / (SimClock.TICK_DT * float(_steps))
	_last[id] = at
	rig.position = at
	rig.vel_in = moved if vel == Vector2.INF else vel
	rig.face_to = facing.angle()
	rig.aim_at = at + facing * 4.0 * Ink.PX_PER_M
	for _k: int in _steps:
		rig.drive(SimClock.TICK_DT)
	RigDetail.sync(rig)


## A new hurt tick shoves the frame (never cancels the attack); each attack plays on the rig from
## its windup: the arm twists back through the tell, strikes on the active window and eases back
## over the recovery (RigClips.strike on the attack's own timing); the slam raises both press
## plates over the head through its tell; death powers down.
func _react(rig: CutRig, body: Fighter, f: BossFight) -> void:
	if body.hurt_tick > _hurt_seen.get(body.id, body.hurt_tick) and body.alive():
		rig.hit(-body.facing, HIT_SHOVE)
	_hurt_seen[body.id] = body.hurt_tick
	if f.state == BossFight.State.WINDUP and _was.get(body.id, -1) != BossFight.State.WINDUP:
		var a: BossAttack = f.attack
		var dt: float = SimClock.TICK_DT
		var arm: int = ATTACK_ARMS.get(a.id, body.id % 2)
		rig.clips.strike(rig, a.windup * dt, a.active * dt, a.recovery * dt, arm)
	rig.clips.fleeing = (
		f.state == BossFight.State.WINDUP and f.attack != null and RAISE_IN_TELL.has(f.attack.id)
	)
	_was[body.id] = f.state
	if f.state == BossFight.State.DEFEATED and not rig.clips.down:
		rig.clips.down = true
		rig.clips.die(false)
