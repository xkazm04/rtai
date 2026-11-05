class_name ArenaRobotRigs
extends Node2D
## Lane ghost-powers: the arena's robot (CombatArena's BOSS brain: the robot thug that the Kerf
## and Ohm beats spawn) drawn on the robot thug's own rig (ThugPlan: gunmetal parts, one round
## optic, no red, no vermilion) in place of a cop rig, so the ghosts' machine multipliers land on a
## machine on screen. Render only: reads the arena every frame, owns one CutRig per robot and poses
## it on CharacterRigs' own tick count; a hit shoves it, its death is the power-down
## (DeathPipe.kill_robot). Dev A/B: `--no-robot-rig` keeps the old cop rig (ArenaRigs reads it).

const DOWN_FLAGS: int = RigFeed.Flag.DEAD | RigFeed.Flag.DOWN
## A hit's shove on the heavy frame (CutRig.hit strength; a cop's flinch is about 60).
const HIT_SHOVE: float = 40.0
## Pose steps caught up in one frame at most (a hitch never fast-forwards a long clip).
const MAX_STEPS: int = 4

var arena: CombatArena = null
var rigs: CharacterRigs = null
var pipe: DeathPipe = null
## The view's blood: each robot's id is told to it (its death leaks oil, not red).
var blood: CombatBlood = null
## ArenaRigs' consumed (signature kill) and decayed bodies, shared by reference.
var consumed: Dictionary[int, bool] = {}
var gone: Dictionary[int, bool] = {}
var _by_id: Dictionary[int, CutRig] = {}
var _feed: RigFeed = RigFeed.new(1)
var _last: Dictionary[int, Vector2] = {}
var _hurt_seen: Dictionary[int, int] = {}
var _dead: Dictionary[int, bool] = {}
var _ticks: int = -1


## True for the fighters this view draws (ArenaRigs leaves them out of the cop feed).
static func takes(h: Fighter) -> bool:
	return h.kind == Fighter.Kind.BOSS and not OS.get_cmdline_user_args().has("--no-robot-rig")


## The robot rig for fighter `id` (null when it has none yet).
func rig_for(id: int) -> CutRig:
	return _by_id.get(id, null)


func _process(_delta: float) -> void:
	if arena == null or rigs == null:
		return
	var steps: int = 0 if _ticks < 0 else mini(rigs.ticks_stepped - _ticks, MAX_STEPS)
	_ticks = rigs.ticks_stepped
	for h: Fighter in arena.hostiles:
		if not takes(h):
			continue
		var rig: CutRig = _rig(h)
		rig.visible = not consumed.has(h.id) and not gone.has(h.id)
		_row(h)
		RigInput.apply(rig, _feed, 0)
		_react(h, rig)
		for _k: int in steps:
			rig.drive(SimClock.TICK_DT)
		RigDetail.sync(rig)


func _rig(h: Fighter) -> CutRig:
	if not _by_id.has(h.id):
		var rig: CutRig = CutRig.new()
		add_child(rig)
		rig.setup(ThugPlan.build(), RigVariant.rivet())  # its own gunmetal parts (ART_DIR thug)
		rig.actor_id = h.id
		rig.position = h.pos * SimConst.PX_PER_M
		rig.snap_facing(h.facing.angle())
		_by_id[h.id] = rig
		if blood != null:
			blood.robot_ids[h.id] = true
	return _by_id[h.id]


## Feed row 0: the robot's place, velocity and facing; its claws are its weapon (no gun drawn).
func _row(h: Fighter) -> void:
	var at: Vector2 = h.pos * SimConst.PX_PER_M
	var vel: Vector2 = (at - _last.get(h.id, at)) * float(SimClock.TICK_RATE)
	_last[h.id] = at
	_feed.count = 0
	@warning_ignore("return_value_discarded")
	_feed.put(0, h.id, BodyPlan.Kind.COP, at, vel)
	_feed.face[0] = h.facing.angle()
	_feed.aim[0] = at + h.facing * 4.0 * SimConst.PX_PER_M
	_feed.flags[0] = DOWN_FLAGS if not h.alive() else 0


## A new hurt tick shoves the frame away from Rivet; the first dead frame plays the power-down.
func _react(h: Fighter, rig: CutRig) -> void:
	var away: Vector2 = (h.pos - arena.rivet.pos).normalized()
	if h.hurt_tick > _hurt_seen.get(h.id, h.hurt_tick) and h.alive():
		rig.hit(away, HIT_SHOVE)
	_hurt_seen[h.id] = h.hurt_tick
	if not h.alive() and not _dead.has(h.id):
		_dead[h.id] = true
		if pipe != null:
			@warning_ignore("return_value_discarded")
			pipe.kill_robot(rig, away)
