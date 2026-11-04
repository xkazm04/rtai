class_name CrowdReact
extends RefCounted
## Pedestrians under fire (lane human-reactions): a person whose FLEE flag comes on (the city
## sim scared them: a round killed someone near, a riot, a car strike) first cowers (ReactPose
## `cower`: ducks, hands over the head, a hop away from the bang) on its full rig, then the flight
## runs on (the sim already runs them away from the shot; RigClips raises the hands while
## fleeing). The hop waits DELAY_TICKS so the sim has turned the body away from the shot and the
## feed's velocity names the direction. Render only: reads the RigFeed, no RNG, never hashed.

const DELAY_TICKS: int = 3
const COWER: StringName = &"cower"

var table: ReactTable
var cowers: int = 0
## Each person's FLEE flag at the last observed tick, by actor id.
var _fleeing: Dictionary[int, bool] = {}
## People who just started fleeing: actor id -> ticks left before the cower plays.
var _due: Dictionary[int, int] = {}


static func make(p_table: ReactTable = null) -> CrowdReact:
	var c: CrowdReact = CrowdReact.new()
	c.table = p_table if p_table != null else ReactTable.shipped()
	return c


## One call per sim tick that reached the rigs, after the feed is filled and before they pose.
func observe(rigs: CharacterRigs, ticks: int = 1) -> void:
	var feed: RigFeed = rigs.feed
	var seen: Dictionary[int, bool] = {}
	for i: int in feed.count:
		if feed.kinds[i] != BodyPlan.Kind.PED:
			continue
		var id: int = feed.ids[i]
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
