extends GutTest
## Incapacitation beats shooting and locomotion. One-shots hold; idle and strides loop.

var _state: CitySimState


func before_each() -> void:
	_state = CitySimState.new()
	_state.mode = PackedByteArray([SimConst.M_WALK, SimConst.M_WALK, SimConst.M_WALK])
	_state.kind = PackedByteArray([SimConst.K_PED, SimConst.K_PED, SimConst.K_PED])
	_state.v = PackedFloat64Array([1.0, 1.0, 1.0])
	_state.t1 = PackedFloat64Array([0.0, 0.0, 0.0])
	_state.t2 = PackedFloat64Array([0.0, 0.0, 0.0])
	_state.phase = PackedFloat64Array([0.0, 0.0, 0.0])
	_state.time = 0.0


func test_clip_ids_match_the_documented_animation_order() -> void:
	assert_eq(
		[
			CitySimClips.IDLE,
			CitySimClips.WALK,
			CitySimClips.RUN,
			CitySimClips.HIT,
			CitySimClips.DEATH,
			CitySimClips.SHOOT
		],
		[0, 1, 2, 3, 4, 5]
	)


func test_dead_and_downed_people_cannot_shoot_or_run() -> void:
	for kind: int in [SimConst.K_PED, SimConst.K_COP]:
		_state.kind[1] = kind
		_state.v[1] = 5.0
		_state.t1[1] = 0.125
		_state.mode[1] = SimConst.M_DEAD
		assert_eq(CitySimClips.clip_of(_state, 1), CitySimClips.DEATH)
		_state.mode[1] = SimConst.M_DOWN
		assert_eq(CitySimClips.clip_of(_state, 1), CitySimClips.HIT)


func test_only_a_cop_with_an_active_shot_timer_shoots() -> void:
	_state.kind[1] = SimConst.K_COP
	for speed: float in [0.0, 5.0]:
		_state.v[1] = speed
		_state.t1[1] = 0.001
		assert_eq(CitySimClips.clip_of(_state, 1), CitySimClips.SHOOT)
	_state.t1[1] = 0.0
	assert_eq(CitySimClips.clip_of(_state, 1), CitySimClips.RUN, "shot timer expired")
	_state.t1[1] = -0.1
	assert_eq(CitySimClips.clip_of(_state, 1), CitySimClips.RUN, "timer can tick past zero")
	_state.kind[1] = SimConst.K_PED
	_state.t1[1] = 0.125
	_state.v[1] = 1.0
	assert_eq(CitySimClips.clip_of(_state, 1), CitySimClips.WALK, "ped timer is not a shot")


func test_stationary_people_idle_even_when_fleeing_rioting_or_police() -> void:
	for mode: int in [SimConst.M_WALK, SimConst.M_FLEE, SimConst.M_RIOT]:
		_state.mode[1] = mode
		for kind: int in [SimConst.K_PED, SimConst.K_COP]:
			_state.kind[1] = kind
			for speed: float in [0.0]:
				_state.v[1] = speed
				assert_eq(CitySimClips.clip_of(_state, 1), CitySimClips.IDLE)


func test_flee_riot_and_cops_run_at_walking_speed() -> void:
	_state.v[1] = 0.2
	for mode: int in [SimConst.M_FLEE, SimConst.M_RIOT]:
		_state.mode[1] = mode
		assert_eq(CitySimClips.clip_of(_state, 1), CitySimClips.RUN)
	_state.mode[1] = SimConst.M_WALK
	_state.kind[1] = SimConst.K_COP
	assert_eq(CitySimClips.clip_of(_state, 1), CitySimClips.RUN)


func test_ordinary_pedestrians_walk_at_a_walk_and_run_at_a_sprint() -> void:
	_state.v[1] = 1.0
	assert_eq(CitySimClips.clip_of(_state, 1), CitySimClips.WALK)
	_state.v[1] = 50.0
	assert_eq(CitySimClips.clip_of(_state, 1), CitySimClips.RUN)


func test_death_advances_with_its_timer_and_holds_the_last_frame() -> void:
	var clip: Vector2i = Vector2i(4, 8)
	for elapsed: float in [0.0, 0.124]:
		_state.t2[1] = elapsed
		assert_eq(CitySimClips.frame_of(_state, 1, CitySimClips.DEATH, clip), 0)
	_state.t2[1] = 0.125
	assert_eq(CitySimClips.frame_of(_state, 1, CitySimClips.DEATH, clip), 1)
	_state.t2[1] = 0.25
	assert_eq(CitySimClips.frame_of(_state, 1, CitySimClips.DEATH, clip), 2)
	for elapsed: float in [0.375, 0.5, 20.0]:
		_state.t2[1] = elapsed
		assert_eq(CitySimClips.frame_of(_state, 1, CitySimClips.DEATH, clip), clip.x - 1)
	_state.t2[1] = 0.125
	assert_eq(CitySimClips.frame_of(_state, 1, CitySimClips.DEATH, Vector2i(4, 16)), 2)


func test_downed_people_hold_the_last_hit_pose_regardless_of_timers() -> void:
	for value: float in [0.0, 0.125, 10.0]:
		_state.time = value
		_state.t1[1] = value
		_state.t2[1] = value
		_state.phase[1] = value
		for count: int in [1, 3, 7]:
			assert_eq(
				CitySimClips.frame_of(_state, 1, CitySimClips.HIT, Vector2i(count, 8)), count - 1
			)


func test_shoot_starts_at_its_first_frame_advances_and_holds_the_last() -> void:
	var clip: Vector2i = Vector2i(3, 5)
	_state.t1[1] = 0.25
	assert_eq(CitySimClips.frame_of(_state, 1, CitySimClips.SHOOT, clip), 0, "a fresh shot")
	var previous: int = 0
	for left: float in [0.2, 0.15, 0.1, 0.05, 0.001]:
		_state.t1[1] = left
		var frame: int = CitySimClips.frame_of(_state, 1, CitySimClips.SHOOT, clip)
		assert_gte(frame, previous, "a shot never plays backwards")
		assert_lt(frame, clip.x, "a shot stays inside its clip")
		previous = frame
	assert_eq(previous, clip.x - 1, "the end of the timer reaches the last frame")


func test_idle_loops_at_clip_fps_and_staggers_people_by_slot() -> void:
	var clip: Vector2i = Vector2i(5, 4)
	assert_eq(CitySimClips.frame_of(_state, 0, CitySimClips.IDLE, clip), 0)
	assert_ne(
		CitySimClips.frame_of(_state, 1, CitySimClips.IDLE, clip),
		CitySimClips.frame_of(_state, 0, CitySimClips.IDLE, clip),
		"neighbours do not idle in lockstep"
	)
	_state.time = 0.249
	assert_eq(CitySimClips.frame_of(_state, 0, CitySimClips.IDLE, clip), 0)
	_state.time = 0.25
	assert_eq(CitySimClips.frame_of(_state, 0, CitySimClips.IDLE, clip), 1)
	_state.time = 1.25
	assert_eq(CitySimClips.frame_of(_state, 0, CitySimClips.IDLE, clip), 0)
	_state.time = 1.5
	assert_eq(CitySimClips.frame_of(_state, 0, CitySimClips.IDLE, clip), 1)
	assert_eq(CitySimClips.frame_of(_state, 0, CitySimClips.IDLE, Vector2i(5, 8)), 2)


func test_walk_and_run_follow_distance_and_stay_inside_their_clip() -> void:
	var clip: Vector2i = Vector2i(8, 4)
	assert_eq(CitySimClips.frame_of(_state, 1, CitySimClips.WALK, clip), 0)
	assert_eq(CitySimClips.frame_of(_state, 1, CitySimClips.RUN, clip), 0)
	_state.phase[1] = 0.5
	assert_gt(
		CitySimClips.frame_of(_state, 1, CitySimClips.WALK, clip), 0, "distance moves the walk"
	)
	assert_gt(CitySimClips.frame_of(_state, 1, CitySimClips.RUN, clip), 0, "distance moves the run")
	for distance: float in [1.0, 2.0, 7.3, 100.0]:
		_state.phase[1] = distance
		for cl: int in [CitySimClips.WALK, CitySimClips.RUN]:
			var frame: int = CitySimClips.frame_of(_state, 1, cl, clip)
			assert_true(frame >= 0 and frame < clip.x, "strides wrap inside the clip")


func test_one_frame_clips_always_show_their_only_frame() -> void:
	_state.time = 10.0
	_state.phase[1] = 10.0
	_state.t2[1] = 10.0
	_state.t1[1] = 0.125
	for cl: int in [
		CitySimClips.IDLE,
		CitySimClips.WALK,
		CitySimClips.RUN,
		CitySimClips.HIT,
		CitySimClips.DEATH,
		CitySimClips.SHOOT
	]:
		assert_eq(CitySimClips.frame_of(_state, 1, cl, Vector2i(1, 8)), 0)
