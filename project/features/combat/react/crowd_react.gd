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
## A fleeing pedestrian that runs within TRIP_M of a body trips over it (ReactPose `trip`), once
## per body. A death startles the living pedestrians within STARTLE_M: they cower away from the
## body (in a riot everyone already flees, so this is the crowd's reaction to each kill).

const DELAY_TICKS: int = 3
const COWER: StringName = &"cower"
const TRIP: StringName = &"trip"
## A fleeing person this close to a body (metres) runs over it.
const TRIP_M: float = 0.6
## Living pedestrians this close to a death (metres) cower away from the body.
const STARTLE_M: float = 2.5
## A body the sim sends sliding faster than this (m/s) was hit by a car: thrown (blast death).
const CAR_SPEED_MPS: float = 4.0
## The sim slides the body itself: the drawn carry only adds a little.
const DEATH_CARRY: float = 0.3

var table: ReactTable
var cowers: int = 0
var trips: int = 0
var deaths: int = 0
var startles: int = 0
var pipe: DeathPipe
## Bodies drawn outside this feed (the fight's dead on another rig set), world px by a key that
## no feed id uses (ArenaRigs: -1 - fighter id); the host refills it each frame.
var extra_bodies: Dictionary[int, Vector2] = {}
## Each person's DEAD flag at the last observed tick, by actor id.
var _dead: Dictionary[int, bool] = {}
## Each person's FLEE flag at the last observed tick, by actor id.
var _fleeing: Dictionary[int, bool] = {}
## People who just started fleeing: actor id -> ticks left before the cower plays.
var _due: Dictionary[int, int] = {}
## Who already tripped over which body: (person id, body id).
var _tripped: Dictionary[Vector2i, bool] = {}


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
				_startle(rigs, i)
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
	_trip_over(rigs, dead)


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


## The living pedestrians within STARTLE_M of feed row `body` (just died) cower away from it.
func _startle(rigs: CharacterRigs, body: int) -> void:
	var feed: RigFeed = rigs.feed
	var reach: float = STARTLE_M * SimConst.PX_PER_M
	for j: int in feed.count:
		if j == body or feed.kinds[j] != BodyPlan.Kind.PED:
			continue
		if feed.has_flag(j, RigFeed.Flag.DEAD) or feed.has_flag(j, RigFeed.Flag.DOWN):
			continue
		var away: Vector2 = feed.pos[j] - feed.pos[body]
		if away.length_squared() < reach * reach:
			var before: int = cowers
			_cower(rigs.rig_for(feed.ids[j]), away)
			startles += cowers - before


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


## Fleeing people within TRIP_M of a body trip over it (once per body), along their flight.
func _trip_over(rigs: CharacterRigs, dead: Dictionary[int, bool]) -> void:
	var feed: RigFeed = rigs.feed
	var bodies: Dictionary[int, Vector2] = extra_bodies.duplicate()
	for i: int in feed.count:
		if dead.get(feed.ids[i], false):
			bodies[feed.ids[i]] = feed.pos[i]
	if bodies.is_empty():
		return
	var reach: float = TRIP_M * SimConst.PX_PER_M
	for i: int in feed.count:
		if feed.kinds[i] != BodyPlan.Kind.PED or not feed.has_flag(i, RigFeed.Flag.FLEE):
			continue
		for b: int in bodies:
			var key: Vector2i = Vector2i(feed.ids[i], b)
			var near: bool = feed.pos[i].distance_squared_to(bodies[b]) < reach * reach
			if b != feed.ids[i] and near and not _tripped.has(key):
				if _trip(rigs.rig_for(feed.ids[i]), feed.vel[i]):
					_tripped[key] = true  # a busy body (mid-cower) trips on a later tick


func _trip(rig: CutRig, along: Vector2) -> bool:
	if rig == null or along.length_squared() < 1.0:
		return false
	var r: HumanReact = HumanReact.on(rig)
	if r.dying or (r.active() and r.progress() < 1.0):
		return false
	r.carry = 0.0
	r.play(rig, TRIP, along, table)
	trips += 1
	return true
