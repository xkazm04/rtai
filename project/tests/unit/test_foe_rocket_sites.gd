extends GutTest

var pit: EnemyPit
var map: GuardRouteMap
var rocket: FoeRocket
var e: EnemyAgent


func before_each() -> void:
	pit = EnemyPit.new(EnemyRoster.shipped(), null)
	map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	rocket = FoeRocket.new()
	e = EnemyAgent.make(2, pit.roster.archetype(&"rocket_trooper"), Vector2(12, 0))


func test_overlap_uses_the_direction_behind_the_trooper() -> void:
	e.pos = pit.rivet_pos
	e.facing = Vector2.DOWN
	var site: Vector2 = rocket._firing_site(e, pit, map)
	assert_almost_eq(site, Vector2.UP.rotated(0.36) * e.arch.preferred_m, Vector2.ONE * 0.001)


func test_occluded_target_keeps_the_first_walkable_fallback_site() -> void:
	var wall: Array[Rect2] = [Rect2(4.0, -15.0, 1.0, 30.0)]
	map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), wall, null, 0.45)
	var first: Vector2 = Vector2.RIGHT.rotated(0.36) * e.arch.preferred_m
	assert_true(map.clear_line(e.pos, first))
	assert_false(map.clear_line(first, pit.rivet_pos))
	assert_almost_eq(rocket._firing_site(e, pit, map), first, Vector2.ONE * 0.001)


func test_clear_site_four_metres_from_launch_is_far_enough() -> void:
	var first: Vector2 = Vector2.RIGHT.rotated(0.36) * e.arch.preferred_m
	rocket.last_launch = first + Vector2.LEFT * 4.0
	assert_almost_eq(rocket._firing_site(e, pit, map), first, Vector2.ONE * 0.001)


func test_walkable_site_still_needs_room_for_the_arrival_tolerance() -> void:
	var first: Vector2 = Vector2.RIGHT.rotated(0.36) * e.arch.preferred_m
	rocket.last_launch = first + Vector2.LEFT * 3.1
	var site: Vector2 = rocket._firing_site(e, pit, map)
	assert_true(site.is_finite())
	assert_ne(site, first, "Stopping short here could leave the trooper inside its old spot")
	assert_gte(site.distance_to(rocket.last_launch) - 0.4, FoeRocket.NEW_SITE_M)


func test_trooper_keeps_its_destination_until_it_arrives() -> void:
	var destination: Vector2 = e.pos + Vector2.RIGHT * 0.8
	rocket._site = destination
	rocket._reposition(e, pit, map)
	assert_eq(rocket._site, destination, "Still approaching the selected firing site")
	assert_gt(e.vel.x, 0.0)
	e.pos = destination - Vector2.RIGHT * 0.3
	rocket._reposition(e, pit, map)
	assert_false(rocket._site.is_finite(), "Arrived and ready to aim from the new site")


func test_safe_site_on_range_boundary_is_kept_but_an_unsafe_one_is_replanned() -> void:
	rocket._site = Vector2.RIGHT * FoeRocket.MIN_RANGE_M
	rocket._reposition(e, pit, map)
	assert_almost_eq(e.vel.normalized(), Vector2.LEFT, Vector2.ONE * 0.001)
	rocket._site -= Vector2.RIGHT * 0.01
	e.vel = Vector2.ZERO
	rocket._reposition(e, pit, map)
	assert_gt(e.vel.y, 0.0)


func test_displaced_trooper_at_safe_range_still_moves_before_reloading() -> void:
	var rng: RandomNumberGenerator = RngRegistry.new(22).stream(&"combat")
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	var squad: ArenaSquad = ArenaSquad.new(map)
	var h: Fighter = squad.spawn_member(arena, Vector2(14, 0), &"rocket_trooper")
	var mind: SquadMind = SquadMind.new(h, e.arch)
	mind.agent.sees = true
	mind.rocket.last_launch = h.pos
	var launch: Vector2 = h.pos
	assert_null(mind.rocket.step(mind, h, arena, squad, map))
	assert_ne(launch, h.pos)
