class_name CrowdReact
extends RefCounted
## Pedestrians under fire (lane human-reactions): a person whose FLEE flag comes on (the city
## sim scared them: a round killed someone near, a riot, a car strike) first cowers (ReactPose
## `cower`: ducks, hands over the head, a hop away from the bang) on its full rig, then the flight
## runs on (the sim already runs them away from the shot; RigClips raises the hands while
## fleeing). The hop waits DELAY_TICKS so the sim has turned the body away from the shot and the
## feed's velocity names the direction. Render only: reads the RigFeed, no RNG, never hashed.
## The city's own kills (a cop round in a riot, a car) play the standard death on the full rig
## through the DeathPipe (so a signature kill can take it): the sim's heading at death is the
## round's travel (or the car's), and its speed tells a car (thrown) from a round.

const DELAY_TICKS: int = 3
const COWER: StringName = &"cower"
## A body the sim sends sliding faster than this (m/s) was hit by a car: thrown (blast death).
const CAR_SPEED_MPS: float = 4.0
## The sim slides the body itself: the drawn carry only adds a little.
const DEATH_CARRY: float = 0.3

var table: ReactTable
var cowers: int = 0
var deaths: int = 0
var pipe: DeathPipe
## Each person's DEAD flag at the last observed tick, by actor id.
var _dead: Dictionary[int, bool] = {}
## Each person's FLEE flag at the last observed tick, by actor id.
var _fleeing: Dictionary[int, bool] = {}
## People who just started fleeing: actor id -> ticks left before the cower plays.
var _due: Dictionary[int, int] = {}


static func make(p_table: ReactTable = null) -> CrowdReact:
	var c: CrowdReact = CrowdReact.new()
	c.table = p_table if p_table != null else ReactTable.shipped()
	c.pipe = DeathPipe.make(c.table)
	return c


## One call per sim tick that reached the rigs, after the feed is filled and before they pose.
func observe(rigs: CharacterRigs, ticks: int = 1) -> void:
	var feed: RigFeed = rigs.feed
	var seen: Dictionary[int, bool] = {}
	var dead: Dictionary[int, bool] = {}
	for i: int in feed.count:
		var id: int = feed.ids[i]
		if feed.kinds[i] != BodyPlan.Kind.RIVET:
			dead[id] = feed.has_flag(i, RigFeed.Flag.DEAD)
			if dead[id] and not _dead.get(id, true):
				_die(rigs.rig_for(id), feed.vel[i])
		if feed.kinds[i] != BodyPlan.Kind.PED:
			continue
		var now: bool = feed.has_flag(i, RigFeed.Flag.FLEE)
		seen[id] = now
		if now and not _fleeing.get(id, true):
			_due[id] = DELAY_TICKS
		if _due.has(id):
			_due[id] -= ticks
			if _due[id] <= 0:
				@warning_ignore("return_value_discarded")
				_due.erase(id)
				_cower(rigs.rig_for(id), feed.vel[i])
	_fleeing = seen
	_dead = dead


## The standard death on `rig` along the sim's slide `vel` (px/s); a car's speed throws it.
func _die(rig: CutRig, vel: Vector2) -> void:
	if rig == null or vel.length_squared() < 1.0:
		return
	var r: HumanReact = HumanReact.on(rig)
	if r.dying:
		return
	r.carry = DEATH_CARRY
	var car: bool = vel.length() > CAR_SPEED_MPS * SimConst.PX_PER_M
	@warning_ignore("return_value_discarded")
	pipe.kill(rig, &"blast" if car else &"light", vel, &"")
	deaths += 1


## Plays the cower on `rig` away along `away` (skipped with no full rig, or mid-reaction/dying).
func _cower(rig: CutRig, away: Vector2) -> void:
	if rig == null:
		return
	var r: HumanReact = HumanReact.on(rig)
	if r.dying or (r.active() and r.progress() < 1.0):
		return
	var d: Vector2 = away if away.length_squared() > 1.0 else Vector2.from_angle(rig.facing)
	r.carry = 1.0
	r.play(rig, COWER, d, table)
	cowers += 1
