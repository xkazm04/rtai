extends GutTest
## Suppression: a nail that passes a human enemy within EnemySuppress.NEAR_M makes it flinch away
## (a tell breaks); a hit is a hit, robots never flinch, and the refractory gap holds.


func _pit(arch: StringName, at: Vector2) -> EnemyPit:
	var pit: EnemyPit = PitLayout.build(5, false)
	pit.rivet_pos = Vector2.ZERO
	PitLayout.place(pit, [arch], PackedVector2Array([at]))
	return pit


func _fly(pit: EnemyPit, dir: Vector2, ticks: int = 30) -> void:
	pit.rivet_fire(dir)
	for _t: int in ticks:
		pit.step()


func test_near_miss_flinches_a_cop_away_from_the_nail() -> void:
	var pit: EnemyPit = _pit(&"patrol_cop", Vector2(8.0, 0.6))
	var cop: EnemyAgent = pit.agents[0]
	_fly(pit, Vector2.RIGHT, 20)
	assert_true(cop.alive(), "a miss does not kill")
	assert_eq(pit.stats["nail_hits"], 0.0)
	assert_eq(pit.stats["flinches"], 1.0)
	assert_gt(cop.flinch_dir.y, 0.5, "it ducks away from the line the nail took")


func test_a_flinch_breaks_the_tell() -> void:
	var pit: EnemyPit = _pit(&"patrol_cop", Vector2(8.0, 0.0))
	var cop: EnemyAgent = pit.agents[0]
	for _t: int in 400:
		pit.step()
		if cop.state == EnemyAgent.State.WINDUP:
			break
	assert_eq(cop.state, EnemyAgent.State.WINDUP, "the cop reached its tell")
	EnemySuppress.flinch(pit, cop, cop.pos + Vector2(0.0, -0.5))
	assert_eq(cop.state, EnemyAgent.State.STAGGER, "the windup is broken")
	assert_false(cop.token, "the squad token goes back")
	assert_eq(pit.stats["tells_broken"], 1.0)
	assert_eq(cop.pose(pit.tick), &"flinch")


func test_a_hit_is_not_a_flinch() -> void:
	var pit: EnemyPit = _pit(&"patrol_cop", Vector2(8.0, 0.0))
	_fly(pit, Vector2.RIGHT, 20)
	assert_eq(pit.stats["nail_hits"], 1.0)
	assert_eq(pit.stats["flinches"], 0.0)


func test_robots_never_flinch() -> void:
	var pit: EnemyPit = _pit(&"robot_gunner", Vector2(8.0, 0.8))
	_fly(pit, Vector2.RIGHT, 20)
	assert_eq(pit.stats["nail_hits"], 0.0)
	assert_eq(pit.stats["flinches"], 0.0)


func test_refractory_gap_stops_pinning() -> void:
	var pit: EnemyPit = _pit(&"patrol_cop", Vector2(8.0, 0.7))
	pit.rivet_fire(Vector2.RIGHT)
	for _t: int in 4:
		pit.step()
	_fly(pit, Vector2.RIGHT, 16)
	assert_eq(pit.stats["flinches"], 1.0, "the second nail inside the gap is ignored")
