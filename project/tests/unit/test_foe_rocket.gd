extends GutTest

const TROOPER: StringName = &"rocket_trooper"

var arena: CombatArena
var squad: ArenaSquad
var walls: ArenaWalls
var dodges: ArenaDodges
var impacts: Array[Vector2]
var radii: Array[float]
var now: int


func before_each() -> void:
	var rng: RandomNumberGenerator = RngRegistry.new(22).stream(&"combat")
	arena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	squad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	walls = ArenaWalls.new()
	dodges = ArenaDodges.new()
	impacts = []
	radii = []
	now = 0
	@warning_ignore("return_value_discarded")
	squad.rockets.burst.connect(_burst)


func _burst(at: Vector2, radius: float, _shot: Shot) -> void:
	impacts.append(at)
	radii.append(radius)


func _spawn(at: Vector2) -> Fighter:
	var h: Fighter = squad.spawn_member(arena, at, TROOPER)
	h.pos = at
	h.cooldown = 0
	return h


func _step() -> void:
	now += 1
	dodges.cull(arena, walls)
	arena.step(now)


func _until_tell(h: Fighter) -> void:
	for i: int in 360:
		_step()
		if GuardTell.telling(h):
			return
	fail_test("no visible rocket tell in six seconds")


func _until_round() -> Shot:
	for i: int in 360:
		_step()
		if not arena.shots.is_empty():
			return arena.shots[0]
	fail_test("no rocket launched in six seconds")
	return null


func test_plants_for_full_tell_and_fires_once_at_the_locked_point() -> void:
	var h: Fighter = _spawn(Vector2(13, 0))
	_until_tell(h)
	var at: Vector2 = h.pos
	var start: int = now
	assert_eq(h.tell_left, squad.pit.roster.archetype(TROOPER).telegraph_ticks)
	for i: int in h.tell_left:
		if arena.guard_tell.locked(h):
			break
		arena.rivet.pos.y += 0.02
		_step()
		assert_true(arena.shots.is_empty())
		assert_eq(h.pos, at)
	assert_true(arena.guard_tell.locked(h))
	var lock_at: Vector2 = arena.rivet.pos
	var locked_facing: Vector2 = h.facing
	arena.rivet.pos.y += 4.0
	var shot: Shot = _until_round()
	if shot == null:
		return
	assert_gte(now - start, 20)
	assert_eq(now - start, squad.pit.roster.archetype(TROOPER).telegraph_ticks)
	assert_eq(h.pos, at)
	assert_eq(h.facing, locked_facing)
	assert_eq(shot.weapon, &"rocket")
	assert_eq(shot.size, &"large")
	assert_almost_eq(shot.vel.length(), 9.0, 0.001)
	assert_true(shot.vel.normalized().dot(at.direction_to(lock_at)) > 0.99999)
	for i: int in 120:
		_step()
		if shot.spent():
			break
	assert_true(shot.spent())
	assert_eq(squad.rockets.count(), 0)
	assert_eq(impacts.size(), 1)
	if impacts.size() == 1:
		assert_lt(impacts[0].distance_to(lock_at), 0.001)
		assert_eq(radii[0], 3.0)
	assert_eq(arena.rivet.hurt_tick, -1000000)


func test_solid_prop_stops_a_rocket_before_rivet() -> void:
	@warning_ignore("return_value_discarded")
	_spawn(Vector2(14, 0))
	var shot: Shot = _until_round()
	if shot == null:
		return
	walls.boxes.append(Rect2(5, -2, 1, 4))
	for i: int in 120:
		_step()
	assert_eq(dodges.blocked, 1)
	assert_eq(impacts.size(), 1)
	if impacts.size() == 1:
		assert_almost_eq(impacts[0].x, 6.0, 9.0 * SimClock.TICK_DT + 0.001)
		assert_eq(radii[0], 3.0)
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)


func test_direct_hit_lands_after_shooter_dies() -> void:
	var h: Fighter = _spawn(Vector2(14, 0))
	var shot: Shot = _until_round()
	if shot == null:
		return
	arena.damage(h, 1.0, arena.rivet.id, &"gloria")
	assert_false(h.alive())
	for i: int in 120:
		_step()
	assert_eq(arena.rivet.hp, arena.rivet.max_hp - shot.damage)
	assert_eq(impacts.size(), 1)
	if impacts.size() == 1:
		assert_lte(impacts[0].distance_to(arena.rivet.pos), arena.rivet.radius_m)


func test_four_troopers_obey_the_live_rocket_limit() -> void:
	squad.pit.roster.max_shooters = 1
	arena.rivet.hp = 10000.0
	arena.rivet.max_hp = arena.rivet.hp
	for i: int in 4:
		@warning_ignore("return_value_discarded")
		_spawn(Vector2(18.0, -3.0 + 2.0 * i))
	var owners: Dictionary[int, bool] = {}
	var peak: int = 0
	for i: int in 1200:
		_step()
		peak = maxi(peak, arena.shots.size())
		for s: Shot in arena.shots:
			owners[s.shooter_id] = true
	assert_eq(peak, squad.pit.roster.max_shooters)
	assert_eq(owners.size(), 4)


func test_backs_away_then_changes_firing_site_between_launches() -> void:
	var h: Fighter = _spawn(Vector2(4, 0))
	_until_tell(h)
	assert_gte(h.pos.distance_to(arena.rivet.pos), FoeRocket.MIN_RANGE_M)
	var sites: Array[Vector2] = []
	for i: int in 900:
		_step()
		if squad.minds[h.id].agent.shot_tick == now:
			sites.append(h.pos)
			if sites.size() == 2:
				break
	assert_eq(sites.size(), 2)
	if sites.size() == 2:
		assert_gt(sites[0].distance_to(sites[1]), 2.0)
