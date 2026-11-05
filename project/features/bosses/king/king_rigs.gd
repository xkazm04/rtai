class_name KingRigs
extends Node2D
## King and his gang on the cutout rigs (render only, SIM-03: posed from the fights every frame).
## King is KingPlan (Rivet's skeleton, King's parts, art/d5/king) at boss size: enthroned on the
## car in phases 1-2 (seated: no stride, facing the car's nose), on foot in phase 3. The gang is the
## robot thug's rig in the rich dress (GangPlan): four push the throne-car from its corners in
## phase 1 (they stride with the car), then the adds fight on foot. A hit shoves the frame (never
## cancels an attack); the active window plays the strike; a downed add powers down on its rig.
## Child of KingBodyView, so it draws over the car (the parent's own _draw).

## King's boss scale over Rivet's skeleton (target: about 1.6x Rivet's bulk; KingPlan.SIZE_K 1.3).
const KING_SIZE_K: float = 1.55
const HIT_SHOVE: float = 30.0
## The gang's places on the car in phase 1, metres from its centre along (nose, right).
const RIDERS: Array[Vector2] = [
	Vector2(-2.9, -1.55), Vector2(-2.9, 1.55), Vector2(2.0, -1.55), Vector2(2.0, 1.55)
]
## Where King sits on the car (the throne), metres back from its centre.
const THRONE_M: float = -0.55
const RIDER_ID: int = 9190
## Pose steps caught up in one frame at most (a hitch never fast-forwards a long clip).
const MAX_STEPS: int = 4

var _rigs: Dictionary[int, CutRig] = {}
var _last: Dictionary[int, Vector2] = {}
var _hurt_seen: Dictionary[int, int] = {}
var _was: Dictionary[int, int] = {}
var _tick: int = -1
var _steps: int = 0


## Poses every body for this frame, one drive step per sim tick since the last frame;
## `windup_px` is the car's tell offset (KingBodyView).
func pose(fight: BossFight, adds: BossAdds, windup_px: Vector2) -> void:
	_steps = 0 if _tick < 0 else clampi(fight.now() - _tick, 0, MAX_STEPS)
	_tick = fight.now()
	var b: Fighter = fight.body
	var on_car: bool = fight.phase <= 1
	var at: Vector2 = Ink.px(b.pos) + windup_px
	if on_car:
		at += b.facing * THRONE_M * Ink.PX_PER_M
	var king: CutRig = _rig(b.id, true, at, b.facing)
	_place(king, b.id, at, b.facing, Vector2.ZERO if on_car else Vector2.INF)
	_react(king, b, fight)
	for i: int in RIDERS.size():
		var id: int = RIDER_ID + i
		var ride: Vector2 = b.facing * RIDERS[i].x + b.facing.orthogonal() * RIDERS[i].y
		var r_at: Vector2 = Ink.px(b.pos + ride) + windup_px
		var r: CutRig = _rig(id, false, r_at, b.facing)
		r.visible = fight.phase == 0
		_place(r, id, r_at, b.facing, Vector2.INF)
	for f: BossFight in adds.fights if adds != null else []:
		var g: CutRig = _rig(f.body.id, false, Ink.px(f.body.pos), f.body.facing)
		_place(g, f.body.id, Ink.px(f.body.pos), f.body.facing, Vector2.INF)
		_react(g, f.body, f)


func _rig(id: int, is_king: bool, at: Vector2, facing: Vector2) -> CutRig:
	if not _rigs.has(id):
		var rig: CutRig = CutRig.new()
		add_child(rig)
		rig.setup(KingPlan.build(KING_SIZE_K) if is_king else GangPlan.build(), RigVariant.rivet())
		rig.actor_id = id
		rig.position = at
		rig.snap_facing(facing.angle())
		_rigs[id] = rig
		_last[id] = at
	return _rigs[id]


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


## A new hurt tick shoves the frame; the active window's first frame strikes; death powers down.
func _react(rig: CutRig, body: Fighter, f: BossFight) -> void:
	if body.hurt_tick > _hurt_seen.get(body.id, body.hurt_tick) and body.alive():
		rig.hit(-body.facing, HIT_SHOVE)
	_hurt_seen[body.id] = body.hurt_tick
	if f.state == BossFight.State.ACTIVE and _was.get(body.id, -1) != BossFight.State.ACTIVE:
		rig.clips.punch(body.id % 2)
	_was[body.id] = f.state
	if f.state == BossFight.State.DEFEATED and not rig.clips.down:
		rig.clips.down = true
		rig.clips.die(false)
