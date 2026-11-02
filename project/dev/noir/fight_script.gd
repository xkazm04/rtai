class_name NoirFightScript
extends RefCounted
## The noir showcase fight's choreography (lane noir, dev only): Rivet against two cops at the
## junction, as beats on a live-tick clock (the host does not step it while the world is held).
## step() moves the three bodies (metres, relative to the junction), writes their RigFeed rows
## (world px) and returns this tick's cues: ["shot", shooter], ["hit", shooter], ["kill", victim].
## No RNG: the fight is the same every run.

const RIVET: int = 1
const COP_A: int = 101
const COP_B: int = 102
const WALK: float = 1.3
const DASH: float = 4.4
const ROLL: float = 3.8
const REACH: float = 1.9
const STAND_OFF: float = 4.5
const KNOCK: float = 6.0
const KNOCK_DECAY: float = 0.88
const PUNCH_TICKS: int = 12
const ROLL_TICKS: int = 27
## tick -> the cop who fires; HITS are the rounds that land on Rivet.
const SHOTS: Dictionary[int, int] = {
	64: COP_A, 104: COP_A, 150: COP_B, 186: COP_B, 222: COP_B, 262: COP_B
}
const HITS: PackedInt32Array = [104, 222]
const GO_A: int = 112
const ROLL_AT: int = 190
const GO_B: int = 236

var origin: Vector2 = Vector2.ZERO
var pos: Dictionary[int, Vector2] = {
	RIVET: Vector2(0.0, 0.4), COP_A: Vector2(7.0, -2.6), COP_B: Vector2(-6.2, 3.0)
}
var dead: Dictionary[int, bool] = {COP_A: false, COP_B: false}
var _knock: Dictionary[int, Vector2] = {COP_A: Vector2.ZERO, COP_B: Vector2.ZERO}
var _punch_t: int = -1
var _goal: int = -1
var _roll_t: int = 0
var _rivet_v: Vector2 = Vector2.ZERO


## One live tick: moves everyone, fills `feed` (3 rows), returns the cues.
func step(t: int, feed: RigFeed) -> Array[Array]:
	var cues: Array[Array] = []
	var rivet_clip: int = _rivet(t, cues)
	for cop: int in [COP_A, COP_B]:
		_cop(cop)
	if SHOTS.has(t) and not dead[SHOTS[t]]:
		cues.append(["shot", SHOTS[t]])
		if HITS.has(t):
			cues.append(["hit", SHOTS[t]])
	_fill(feed, rivet_clip, cues)
	return cues


## Rivet: stands, dashes at cop A, punches (the kill lands PUNCH_TICKS later), rolls clear of
## cop B's fire, dashes at cop B, punches.
func _rivet(t: int, cues: Array[Array]) -> int:
	var clip: int = RigClips.Clip.NONE
	_rivet_v = Vector2.ZERO
	if t == ROLL_AT:
		_roll_t = ROLL_TICKS
		clip = RigClips.Clip.ROLL
	if _punch_t >= 0:
		_punch_t += 1
		if _punch_t == PUNCH_TICKS:
			_kill(_goal, cues)
			_punch_t = -1
		return clip
	if _roll_t > 0:
		_roll_t -= 1
		_rivet_v = Vector2(-0.35, 1.0).normalized() * ROLL
	else:
		_goal = COP_A if t >= GO_A and not dead[COP_A] else -1
		if _goal < 0 and t >= GO_B and not dead[COP_B]:
			_goal = COP_B
		if _goal >= 0:
			var d: Vector2 = pos[_goal] - pos[RIVET]
			if d.length() > REACH:
				_rivet_v = d.normalized() * DASH
			else:
				_punch_t = 0
				clip = RigClips.Clip.PUNCH
	pos[RIVET] += _rivet_v * SimClock.TICK_DT
	return clip


func _cop(cop: int) -> void:
	if dead[cop]:
		pos[cop] += _knock[cop] * SimClock.TICK_DT
		_knock[cop] *= KNOCK_DECAY
		return
	var d: Vector2 = pos[RIVET] - pos[cop]
	if d.length() > STAND_OFF:
		pos[cop] += d.normalized() * WALK * SimClock.TICK_DT


func _kill(victim: int, cues: Array[Array]) -> void:
	if victim < 0:
		return
	dead[victim] = true
	_knock[victim] = (pos[victim] - pos[RIVET]).normalized() * KNOCK
	cues.append(["kill", victim])


func _fill(feed: RigFeed, rivet_clip: int, cues: Array[Array]) -> void:
	feed.count = 0
	var px: float = SimConst.PX_PER_M
	var r: int = feed.put(0, RIVET, BodyPlan.Kind.RIVET, (origin + pos[RIVET]) * px, _rivet_v * px)
	var look_at: int = _goal if _goal >= 0 else (COP_B if not dead[COP_B] else COP_A)
	feed.face[r] = (pos[look_at] - pos[RIVET]).angle()
	feed.clip[r] = rivet_clip
	feed.clip_arg[r] = 3.0
	var row: int = 1
	for cop: int in [COP_A, COP_B]:
		var at: Vector2 = (origin + pos[cop]) * px
		var i: int = feed.put(row, cop, BodyPlan.Kind.COP, at, Vector2.ZERO)
		feed.looks[i] = 5 + row - 1
		feed.face[i] = (pos[RIVET] - pos[cop]).angle()
		feed.aim[i] = (origin + pos[RIVET]) * px
		feed.flags[i] = RigFeed.Flag.GUN_OUT | RigFeed.Flag.AIMING
		if dead[cop]:
			feed.flags[i] = RigFeed.Flag.DEAD
			feed.face[i] = (pos[RIVET] - pos[cop]).angle()
		for c: Array in cues:
			if c[0] == "shot" and c[1] == cop:
				feed.clip[i] = RigClips.Clip.SHOOT
			elif c[0] == "kill" and c[1] == cop:
				feed.clip[i] = RigClips.Clip.HIT
				feed.clip_arg[i] = (pos[cop] - pos[RIVET]).angle()
		row += 1
