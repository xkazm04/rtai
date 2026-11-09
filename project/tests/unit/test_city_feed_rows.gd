extends GutTest
## The C++ feed fill against the script's loop, and what the script's rows mean.

const FOCUS: Vector2 = Vector2(10.0, 20.0)
const AIM: Vector2 = Vector2(640.0, 960.0)
const LIVE_AT: Vector2 = Vector2(305.0, 300.0)

var _s: PackedFloat64Array = PackedFloat64Array()


func _rec(slot: int, kind: int, mode: int, at: Vector2, t1: float = 0.0) -> void:
	var r: int = _s.size()
	@warning_ignore("return_value_discarded")
	_s.resize(r + SimConst.SNAP_STRIDE)
	for k: int in SimConst.SNAP_STRIDE:
		_s[r + k] = 0.0
	_s[r] = slot
	_s[r + 1] = kind
	_s[r + 2] = mode
	_s[r + 4] = at.x
	_s[r + 5] = at.y
	_s[r + 6] = 0.6
	_s[r + 7] = -0.8
	_s[r + 8] = 1.7
	_s[r + 10] = t1


## Every mode of a ped and a cop, a car, one person past the radius, projectiles at the tail.
func _snapshot() -> PackedFloat64Array:
	_s = PackedFloat64Array()
	var near: Vector2 = FOCUS + Vector2(1.25, -2.5)
	_rec(3, SimConst.K_PED, 0, near)
	_rec(4, SimConst.K_PED, SimConst.M_FLEE, near)
	_rec(5, SimConst.K_PED, SimConst.M_DEAD, near)
	_rec(6, SimConst.K_PED, SimConst.M_DOWN, near)
	_rec(7, SimConst.K_PED, SimConst.M_RIOT, near)
	_rec(8, SimConst.K_COP, 0, near)
	_rec(9, SimConst.K_COP, 0, near, 0.5)
	_rec(10, SimConst.K_COP, SimConst.M_DEAD, near, 0.5)
	_rec(11, SimConst.K_COP, SimConst.M_DOWN, near)
	_rec(12, SimConst.K_CAR, 0, near)
	_rec(13, SimConst.K_PED, 0, FOCUS + Vector2(CityFeedRows.FEED_RADIUS_M + 1.0, 0.0))
	_rec(900, SimConst.K_PED, 0, near)  # a slot past the variants: LOOK_AUTO
	for k: int in 3:
		var r: int = _s.size()
		@warning_ignore("return_value_discarded")
		_s.resize(r + SimConst.SNAP_PROJ_STRIDE)
		_s[r] = SimConst.SNAP_PROJ_BASE + k
		_s[r + 1] = near.x
		_s[r + 2] = near.y
	return _s


func _variants() -> PackedByteArray:
	var v: PackedByteArray = PackedByteArray()
	@warning_ignore("return_value_discarded")
	v.resize(20)
	for i: int in v.size():
		v[i] = i * 2 + 1
	return v


func _script_feed() -> RigFeed:
	var feed: RigFeed = RigFeed.new(16)
	CityFeedRows.fill_script(feed, _snapshot(), _variants(), FOCUS, AIM)
	return feed


func test_the_script_rows_mean_what_the_rigs_read() -> void:
	var feed: RigFeed = _script_feed()
	assert_eq(feed.count, 10, "cars, the far ped and projectile records are not rows")
	assert_eq(feed.ids[0], 3)
	assert_eq(feed.kinds[0], BodyPlan.Kind.PED as int)
	assert_eq(feed.looks[0], 7, "the sim's look for slot 3")
	assert_eq(feed.flags[0], 0)
	assert_eq(feed.flags[1], RigFeed.Flag.FLEE as int)
	assert_eq(feed.flags[2], RigFeed.Flag.DEAD as int)
	assert_eq(feed.flags[3], RigFeed.Flag.DOWN as int)
	assert_eq(feed.flags[4], RigFeed.Flag.FLEE as int, "a rioter runs like one fleeing")
	assert_eq(feed.kinds[5], BodyPlan.Kind.COP as int)
	assert_eq(feed.flags[5], RigFeed.Flag.GUN_OUT as int)
	assert_eq(feed.aim[5], AIM, "a cop points at Rivet")
	assert_eq(feed.aim[0], feed.pos[0], "a ped's aim stays its own feet")
	assert_eq(feed.flags[6], (RigFeed.Flag.GUN_OUT | RigFeed.Flag.AIMING) as int)
	assert_eq(feed.flags[7], RigFeed.Flag.DEAD as int, "a dead cop neither points nor aims")
	assert_eq(feed.flags[8], RigFeed.Flag.DOWN as int)
	assert_eq(feed.looks[9], RigFeed.LOOK_AUTO, "a slot past the variants picks its own")


func test_the_native_fill_writes_the_script_rows() -> void:
	var rows: CityFeedRows = CityFeedRows.new()
	if not rows.native:
		pending("no CitySim.fill_feed_rows in this DLL")
		return
	var expected: RigFeed = _script_feed()
	var feed: RigFeed = RigFeed.new(1)
	rows.fill(feed, _snapshot(), _variants(), FOCUS, AIM)
	_assert_same_rows(feed, expected)


## Real snapshots: a scared crowd of peds and cops walking a plaza, compared every 20 ticks.
func test_the_native_fill_matches_the_script_on_a_live_sim() -> void:
	var rows: CityFeedRows = CityFeedRows.new()
	if not rows.native:
		pending("no CitySim.fill_feed_rows in this DLL")
		return
	var sim: CitySimRef = _plaza()
	var compared: int = 0
	for t: int in 200:
		sim.step(SimClock.TICK_DT, LIVE_AT.x, LIVE_AT.y, LIVE_AT.x, LIVE_AT.y)
		if t == 40:
			sim.scare(LIVE_AT.x, LIVE_AT.y)
		if t % 20 != 0:
			continue
		var snap: PackedFloat64Array = sim.snapshot()
		var expected: RigFeed = RigFeed.new(16)
		var feed: RigFeed = RigFeed.new(1)
		CityFeedRows.fill_script(expected, snap, sim.get_variants(), LIVE_AT, AIM)
		rows.fill(feed, snap, sim.get_variants(), LIVE_AT, AIM)
		compared += expected.count
		_assert_same_rows(feed, expected)
	assert_gt(compared, 100, "the compare saw real rows")


func _assert_same_rows(feed: RigFeed, expected: RigFeed) -> void:
	assert_eq(feed.count, expected.count)
	for i: int in expected.count:
		assert_eq(feed.ids[i], expected.ids[i], "ids %d" % i)
		assert_eq(feed.kinds[i], expected.kinds[i], "kinds %d" % i)
		assert_eq(feed.looks[i], expected.looks[i], "looks %d" % i)
		assert_eq(feed.flags[i], expected.flags[i], "flags %d" % i)
		assert_eq(feed.pos[i], expected.pos[i], "pos %d" % i)
		assert_eq(feed.vel[i], expected.vel[i], "vel %d" % i)
		assert_eq(feed.aim[i], expected.aim[i], "aim %d" % i)
		assert_almost_eq(feed.face[i], expected.face[i], 1e-5, "face %d" % i)
		assert_eq(feed.clip[i], RigClips.Clip.NONE as int, "clip %d" % i)
		assert_eq(feed.clip_arg[i], 0.0, "clip_arg %d" % i)


static func _plaza() -> CitySimRef:
	var sim: CitySimRef = CitySimRef.new()
	sim.init(11)
	var tiles: PackedByteArray = CityChunk.zeros(CityChunk.TILES)
	tiles.fill(SimConst.T_PLAZA)
	var cells: PackedByteArray = CityChunk.zeros(CityChunk.CELLS)
	cells.fill(SimConst.C_WALK)
	sim.stamp_chunk(2, 2, tiles, cells)
	for n: int in 40:
		var at: Vector2 = LIVE_AT + Vector2(float(n % 8) * 2.0 - 7.0, float(n / 8) * 2.0 - 4.0)
		var kind: int = SimConst.K_COP if n % 5 == 0 else SimConst.K_PED
		@warning_ignore("return_value_discarded")
		sim.spawn(PackedFloat64Array([kind, at.x, at.y, 0.0, 1.0, 7, 0, 1.4, 0.0, 0]))
	return sim


func test_the_native_fill_leaves_room_for_rivet() -> void:
	var rows: CityFeedRows = CityFeedRows.new()
	if not rows.native:
		pending("no CitySim.fill_feed_rows in this DLL")
		return
	var feed: RigFeed = RigFeed.new(1)
	rows.fill(feed, _snapshot(), _variants(), FOCUS, AIM)
	assert_true(feed.ids.size() > feed.count, "the row after the people exists")
	var kept: int = feed.ids.size()
	var row: int = feed.put(feed.count, 1 << 20, BodyPlan.Kind.RIVET, AIM, Vector2.ZERO)
	assert_eq(row, 10)
	assert_eq(feed.count, 11)
	assert_eq(feed.ids.size(), kept, "Rivet's row did not grow ten arrays")
	assert_eq(feed.ids[9], 900, "the last person stays")
