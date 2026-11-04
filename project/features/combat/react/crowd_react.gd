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
## body (in a riot everyone already flees, so this is the crowd's reaction to each kill). The
## fight's dead drawn on another rig set (extra_bodies) startle the street the same way.

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
## The live radii (metres); the consts are the shipped values, a scenario plants 0 as a fault.
var startle_m: float = STARTLE_M
## Wall time spent in observe (usec: the total, the worst call, the calls): render cost evidence
## (showcase REQUEST 23); read only by city_bench's exit log, never by the sim.
var cost_us: int = 0
var cost_max_us: int = 0
var cost_calls: int = 0
var trip_m: float = TRIP_M
## Bodies drawn outside this feed (the fight's dead on another rig set), world px by a key that
## no feed id uses (ArenaRigs: -1 - fighter id); the host refills it each frame.
var extra_bodies: Dictionary[int, Vector2] = {}
## The extra bodies already seen (a new key is a fresh death in the fight: it startles too).
var _extra_seen: Dictionary[int, bool] = {}
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
	var t0: int = Time.get_ticks_usec()
	_observe(rigs, ticks)
	var dt: int = Time.get_ticks_usec() - t0
	cost_us += dt
	cost_max_us = maxi(cost_max_us, dt)
	cost_calls += 1


func _observe(rigs: CharacterRigs, ticks: int) -> void:
	var feed: RigFeed = rigs.feed
	var ids: PackedInt32Array = feed.ids
	var kinds: PackedByteArray = feed.kinds
	var flags: PackedByteArray = feed.flags
	var seen: Dictionary[int, bool] = {}
	var dead: Dictionary[int, bool] = {}
	var bodies: Dictionary[int, Vector2] = extra_bodies.duplicate()
	for i: int in feed.count:
		var id: int = ids[i]
		if kinds[i] == BodyPlan.Kind.RIVET:
			continue
		var is_dead: bool = (flags[i] & RigFeed.Flag.DEAD) != 0
		dead[id] = is_dead
		if is_dead:
			bodies[id] = feed.pos[i]
			if not _dead.get(id, true):
				_die(rigs.rig_for(id), feed.vel[i])
				_startle(rigs, feed.pos[i], i)
		if kinds[i] != BodyPlan.Kind.PED:
			continue
		var now: bool = (flags[i] & RigFeed.Flag.FLEE) != 0
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
	_startle_extra(rigs)
	_trip_over(rigs, bodies)


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


## A fight death drawn on another rig set (a new extra body) startles the street like a feed death.
func _startle_extra(rigs: CharacterRigs) -> void:
	var seen: Dictionary[int, bool] = {}
	for key: int in extra_bodies:
		seen[key] = true
		if not _extra_seen.has(key):
			_startle(rigs, extra_bodies[key], -1)
	_extra_seen = seen


## The living pedestrians within startle_m of `at` (world px; feed row `body` just died there, -1
## for a body drawn elsewhere) cower away from it.
func _startle(rigs: CharacterRigs, at: Vector2, body: int) -> void:
	var feed: RigFeed = rigs.feed
	var reach: float = startle_m * SimConst.PX_PER_M
	for j: int in feed.count:
		if j == body or feed.kinds[j] != BodyPlan.Kind.PED:
			continue
		if feed.has_flag(j, RigFeed.Flag.DEAD) or feed.has_flag(j, RigFeed.Flag.DOWN):
			continue
		var away: Vector2 = feed.pos[j] - at
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


## Fleeing people within TRIP_M of a body trip over it (once per body), along their flight. Only a
## person on a full rig can play the trip, so the rest of the crowd is skipped before the body
## scan (it was every fleeing person against every body, each tick: 1.7 ms a tick in a riot).
func _trip_over(rigs: CharacterRigs, bodies: Dictionary[int, Vector2]) -> void:
	if bodies.is_empty():
		return
	var feed: RigFeed = rigs.feed
	var reach2: float = pow(trip_m * SimConst.PX_PER_M, 2.0)
	var flee: int = RigFeed.Flag.FLEE
	for i: int in feed.count:
		if feed.kinds[i] != BodyPlan.Kind.PED or (feed.flags[i] & flee) == 0:
			continue
		var rig: CutRig = rigs.rig_for(feed.ids[i])
		if rig == null:
			continue
		for b: int in bodies:
			if b == feed.ids[i] or feed.pos[i].distance_squared_to(bodies[b]) >= reach2:
				continue
			var key: Vector2i = Vector2i(feed.ids[i], b)
			if not _tripped.has(key) and _trip(rig, feed.vel[i]):
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
