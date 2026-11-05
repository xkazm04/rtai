extends GutTest
## Servo's drone swarm on its own (before the boss framework): the shipped table reads, a wave
## flies, hovers over its rings and drops, the alive cap holds, a shot drone drops early and its
## cell refills, the drones keep apart, and the same seed gives the same swarm.

const MARK: Vector2 = Vector2(12.0, 0.0)


func _swarm(seed_value: int) -> ServoSwarm:
	var s: ServoSwarm = ServoSwarm.new()
	s.setup(ServoTuning.shipped(), RngRegistry.new(seed_value).stream(ServoSwarm.STREAM))
	return s


func _run(s: ServoSwarm, ticks: int) -> void:
	for i: int in ticks:
		s.step()


func test_table_reads_clean() -> void:
	var t: ServoTuning = ServoTuning.shipped()
	assert_eq(t.errors, [] as Array[String])
	assert_eq(t.phases.size(), 3)
	assert_eq(t.cells, 12)


func test_wave_drops_on_its_rings_then_docks() -> void:
	var s: ServoSwarm = _swarm(7)
	assert_eq(s.launch_wave(MARK), 3)
	var goals: Array[Vector2] = []
	for d: ServoDrone in s.drones:
		goals.append(d.goal)
	var first_land: int = -1
	for i: int in 600:
		s.step()
		if first_land < 0 and s.parcels.landed_total > 0:
			first_land = i
	# The rings show from launch: the first parcel lands no sooner than launch + hover + fall.
	var t: ServoTuning = s.tuning
	assert_gte(first_land, t.launch_ticks + t.hover_ticks + t.fall_ticks - 1)
	assert_eq(s.parcels.landed_total, 3)
	assert_eq(s.alive(), 0, "every drone flew home and docked")
	assert_eq(s.rack.count(ServoRack.Cell.FULL), 12)
	for c: ServoParcels.Parcel in s.parcels.crates:
		assert_true(goals.has(c.pos), "a crate lands exactly on its drop ring")


func test_alive_cap_per_phase() -> void:
	var s: ServoSwarm = _swarm(7)
	var n: int = 0
	for k: int in 5:
		n += s.launch_wave(MARK + Vector2(0.0, k * 3.0))
	assert_eq(n, 6, "phase 1 caps at 6 alive")
	s.phase = 2
	n += s.launch_wave(MARK)
	assert_eq(n, 8)
	assert_eq(s.alive(), 8, "phase 2 caps at 8")


func test_shot_drone_drops_early_and_cell_refills() -> void:
	var s: ServoSwarm = _swarm(7)
	assert_eq(s.launch_wave(MARK), 3)
	_run(s, 20)
	var d: ServoDrone = s.drones[0]
	var where: Vector2 = d.pos
	s.kill(d)
	assert_eq(s.parcels.falling.size(), 1)
	assert_eq(s.parcels.falling[0].pos, where, "the parcel falls where the drone was shot")
	s.step()
	assert_eq(s.alive(), 2)
	assert_eq(s.rack.count(ServoRack.Cell.REFILL), 1)
	_run(s, s.tuning.refill_ticks + 1)
	assert_eq(s.rack.count(ServoRack.Cell.REFILL), 0)


func test_drones_keep_apart_in_flight() -> void:
	var s: ServoSwarm = _swarm(3)
	s.phase = 2
	assert_eq(s.launch_wave(MARK), 5)
	var closest: float = 99.0
	for i: int in 90:
		s.step()
		for a: ServoDrone in s.drones:
			for b: ServoDrone in s.drones:
				# Out of the rack (its cells sit 0.5 m apart): in open flight.
				var out: bool = a.pos.length() > 3.0 and b.pos.length() > 3.0
				if a.id < b.id and out:
					closest = minf(closest, a.pos.distance_to(b.pos))
	assert_gt(closest, 0.5, "no two drones stack into one blob")


func test_same_seed_same_swarm() -> void:
	assert_eq(_hash(11), _hash(11))
	assert_ne(_hash(11), _hash(12))


func _hash(seed_value: int) -> PackedByteArray:
	var s: ServoSwarm = _swarm(seed_value)
	s.phase = 2
	var a: int = s.launch_wave(MARK)
	_run(s, 40)
	a += s.launch_wave(MARK * 0.5)
	_run(s, 200)
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	s.write_state(out)
	out.put_32(a)
	return out.data_array
