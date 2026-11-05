extends GutTest
## Phase 3's kamikaze drones (ServoDive): each strike point tracks the target, locks, and the dive
## blasts the locked point. A target that stands is caught; one that steps 4 m off at the lock
## (the dodge cue) is not; a dive drone is spent (it never docks).

const MARK: Vector2 = Vector2(12.0, 0.0)


func _swarm() -> ServoSwarm:
	var s: ServoSwarm = ServoSwarm.new()
	s.setup(ServoTuning.shipped(), RngRegistry.new(7).stream(ServoSwarm.STREAM))
	s.phase = 3
	return s


## Runs a dive wave on a target at MARK; `dodge` steps it 4 m on (one way, off every locked
## strike) at each new lock (each drone tracks on its own, so each lock is its own cue).
## Returns [blasts that caught the target, blasts in total].
func _dive(dodge: bool) -> Array[int]:
	var s: ServoSwarm = _swarm()
	var at: Vector2 = MARK
	assert_gt(s.launch_dives(MARK), 0, "the dives launched")
	var caught: int = 0
	var total: int = 0
	var locks: int = 0
	for i: int in 600:
		var now: int = (
			s.drones.filter(func(d: ServoDrone) -> bool: return ServoDive.locked(s, d)).size()
		)
		if dodge and now > locks:
			at += Vector2(0.0, 4.0)
		locks = maxi(locks, now) if now > 0 else 0
		s.aim_at = at
		s.step()
		for b: ServoParcels.Blast in s.parcels.blasts:
			total += 1
			caught += 1 if b.pos.distance_to(at) <= b.radius_m + 0.6 else 0
	return [caught, total]


func test_standing_target_is_caught() -> void:
	var r: Array[int] = _dive(false)
	assert_gt(r[1], 0, "the dives blew")
	assert_eq(r[0], r[1], "every dive caught the standing target")


func test_stepping_off_at_the_lock_dodges() -> void:
	var r: Array[int] = _dive(true)
	assert_gt(r[1], 0, "the dives blew")
	assert_eq(r[0], 0, "a 4 m step at the lock clears the 2.2 m blast")


func test_dive_drones_are_spent() -> void:
	var s: ServoSwarm = _swarm()
	var n: int = s.launch_dives(MARK)
	for i: int in 600:
		s.aim_at = MARK
		s.step()
	assert_eq(s.alive(), 0)
	assert_eq(s.parcels.landed_total, 0, "kamikazes carry no parcel")
	assert_gt(n, 0)
