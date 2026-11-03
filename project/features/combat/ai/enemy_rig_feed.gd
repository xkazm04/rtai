class_name EnemyRigFeed
extends RefCounted
## The pit's enemies as RigFeed rows, so the cast rigs (features/characters, RigInput) draw and
## animate them: position and velocity in pixels, facing, aim point, state flags (gun out and
## aiming in the tell and the shot, fleeing in a panic, down, dead) and the clip started this
## tick (SHOOT recoil or a swing, HIT shoved along the blow, DEATH). One call per sim tick, after
## pit.step(). Robots use the COP rig until a robot body kind exists (JOURNAL NEXT 3).

const AIM_LEAD_M: float = 6.0
const SWING_COMBO: float = 1.0


## Writes every enemy of `pit` from feed row `first`; returns the number of rows written.
static func write(pit: EnemyPit, feed: RigFeed, first: int, ppm: float) -> int:
	var n: int = 0
	for e: EnemyAgent in pit.agents:
		var i: int = feed.put(first + n, e.id, BodyPlan.Kind.COP, e.pos * ppm, e.vel * ppm)
		feed.face[i] = e.facing.angle()
		feed.aim[i] = (e.pos + e.aim * AIM_LEAD_M) * ppm
		feed.flags[i] = flags(e)
		_clip(e, pit.tick, feed, i)
		n += 1
	return n


static func flags(e: EnemyAgent) -> int:
	if not e.alive():
		return RigFeed.Flag.DEAD
	var f: int = 0
	var s: EnemyAgent.State = e.state
	if not e.melee() and s != EnemyAgent.State.PANIC and s != EnemyAgent.State.DOWN:
		f |= RigFeed.Flag.GUN_OUT
		if s == EnemyAgent.State.WINDUP or s == EnemyAgent.State.FIRE:
			f |= RigFeed.Flag.AIMING
	if s == EnemyAgent.State.PANIC:
		f |= RigFeed.Flag.FLEE
	if s == EnemyAgent.State.DOWN:
		f |= RigFeed.Flag.DOWN
	return f


static func _clip(e: EnemyAgent, now: int, feed: RigFeed, i: int) -> void:
	if e.died_tick == now:
		feed.clip[i] = RigClips.Clip.DEATH
	elif e.hurt_tick == now:
		feed.clip[i] = RigClips.Clip.HIT
		feed.clip_arg[i] = e.hurt_dir.angle()
	elif e.shot_tick == now:
		feed.clip[i] = RigClips.Clip.PUNCH if e.melee() else RigClips.Clip.SHOOT
		feed.clip_arg[i] = SWING_COMBO if e.melee() else 1.0
