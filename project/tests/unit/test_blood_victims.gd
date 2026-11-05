extends GutTest


func test_dry_kinds_print_nothing_on_humans_but_robots_leak() -> void:
	var v: BloodVictims = BloodVictims.new()
	v.robot_ids[7] = true
	assert_true(v.dry(&"cauterised", 3))
	assert_true(v.dry(&"burned", 3))
	assert_false(v.dry(&"cauterised", 7), "a robot always leaks oil")
	assert_false(v.dry(&"kill", 3))


func test_route_player_robot_human() -> void:
	var v: BloodVictims = BloodVictims.new()
	v.robot_ids[7] = true
	assert_eq(v.route(1, 1), BloodVictims.Route.PLAYER)
	assert_eq(v.route(7, 1), BloodVictims.Route.ROBOT)
	assert_eq(v.route(3, 1), BloodVictims.Route.HUMAN)
