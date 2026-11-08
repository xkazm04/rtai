extends GutTest
## StainCover.cover (perf L23): the x-window search over the sorted walkers answers exactly as
## the old scan of every walker, at the window's edges, with ties in x and with no walkers.


## The pre-L23 _uncovered: every walker measured.
func _brute(at: Vector2, walkers: PackedVector2Array) -> float:
	var a: float = 1.0
	var clear2: float = pow(CorpseStains.CLEAR_M * SimConst.PX_PER_M, 2.0)
	for w: Vector2 in walkers:
		if at.distance_squared_to(w) < clear2:
			var m: float = at.distance_to(w) / SimConst.PX_PER_M
			a = minf(a, smoothstep(CorpseStains.COVER_M, CorpseStains.CLEAR_M, m))
	return a


func _sorted(walkers: PackedVector2Array) -> PackedVector2Array:
	var out: PackedVector2Array = walkers.duplicate()
	out.sort()
	return out


func test_cover_matches_the_full_scan() -> void:
	var k: int = 0
	var partial: int = 0
	for scene: int in 60:
		var walkers: PackedVector2Array = PackedVector2Array()
		for _w: int in (scene * 37) % 301:  # a hashed sweep (0..300 walkers a scene)
			k += 1
			var x: float = snappedf(fmod(k * 73.13, 400.0), 4.0 if scene % 3 == 0 else 0.01)
			@warning_ignore("return_value_discarded")
			walkers.append(Vector2(x, fmod(k * 31.71, 400.0)))
		var by_x: PackedVector2Array = _sorted(walkers)
		for b: int in 20:
			var at: Vector2 = Vector2(
				fmod(b * 97.3 + scene, 440.0) - 20.0, fmod(b * 53.9 + scene * 7.0, 440.0) - 20.0
			)
			var want: float = _brute(at, walkers)
			assert_eq(StainCover.cover(at, by_x), want, "scene %d at %s" % [scene, at])
			partial += 1 if want > 0.0 and want < 1.0 else 0
	assert_gt(partial, 50, "the sweep meets partly covered soaks (not only 0 and 1)")


func test_cover_at_the_window_edges() -> void:
	var reach: float = CorpseStains.CLEAR_M * SimConst.PX_PER_M
	var at: Vector2 = Vector2(100.0, 100.0)
	for dx: float in [
		-reach - 0.001, -reach + 0.001, -12.0, 0.0, 12.0, reach - 0.001, reach + 0.001
	]:
		var walkers: PackedVector2Array = PackedVector2Array(
			[Vector2(at.x + dx, at.y), Vector2(at.x + dx, at.y + 3.0), Vector2(at.x - 300.0, at.y)]
		)
		assert_eq(StainCover.cover(at, _sorted(walkers)), _brute(at, walkers), "dx %f" % dx)
	assert_eq(StainCover.cover(at, PackedVector2Array()), 1.0, "no walkers: whole")
	var on: PackedVector2Array = PackedVector2Array([at])
	assert_eq(StainCover.cover(at, on), 0.0, "a walker on the body hides it")


func test_step_sorts_the_walkers_it_measures() -> void:
	var stains: CorpseStains = CorpseStains.new(4)
	stains.walkers = PackedVector2Array([Vector2(300, 5), Vector2(100, 100), Vector2(-50, 7)])
	stains.step_bodies(1, {} as Dictionary[int, Vector2])
	assert_eq(
		stains._by_x, PackedVector2Array([Vector2(-50, 7), Vector2(100, 100), Vector2(300, 5)])
	)
	assert_eq(stains.walkers[0], Vector2(300, 5), "the host's walkers keep their order")
	stains.free()


func test_step_reads_the_living_rows_as_walkers_and_soaks_the_dead() -> void:
	var stains: CorpseStains = CorpseStains.new(4)
	var feed: RigFeed = RigFeed.new(8)
	var want: PackedVector2Array = PackedVector2Array()
	for r: int in 6:
		var at: Vector2 = Vector2(40.0 * r, 7.0 * r)
		var i: int = feed.put(r, 10 + r, BodyPlan.Kind.PED, at, Vector2.ZERO)
		if r % 3 == 1:
			feed.flags[i] = RigFeed.Flag.DEAD
		else:
			@warning_ignore("return_value_discarded")
			want.append(at)
	feed.count = 6
	stains.on_bled(Vector2(42, 8), Vector2.RIGHT)
	stains.step(5, feed)
	assert_eq(stains.walkers, want, "every living row, in feed order")
	assert_eq(stains.soaked, 1, "the death found the dead row 1 (id 11)")
	assert_eq(stains.nearest_soak(Vector2.ZERO), Vector2(40, 7))
	stains.free()
