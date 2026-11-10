extends GutTest
## The owner's note (2026-11-09): "there is collision with player which should not happen". Rivet
## walks the same straight line with a body lying across it as he walks with none, and the body
## does not move. Runs the real arena step (pilot, ArenaBodies, the stage's collide).

const WALK_TICKS: int = 120
const SETTLE_TICKS: int = 90
const STICK: int = 127
const OFF_M: float = 2.0


class Walk:
	extends InputSource

	func sample(_tick: int) -> TickInput:
		return TickInput.new(0, STICK, 0)


class Idle:
	extends InputSource


func _open(input: InputSource) -> ArenaSession:
	var s: ArenaSession = ArenaSession.open(Events, Data, ArenaSession.MASTER_SEED, input)
	add_child_autofree(s.world)
	return s


## Rivet's x and y over the walk; `corpse`: a guard is shot dead on his line first.
func _walk(corpse: bool) -> Dictionary:
	var s: ArenaSession = _open(Idle.new())
	var arena: CombatArena = s.stage.arena
	var body: Fighter = null
	if corpse:
		body = arena.spawn_guard(arena.rivet.pos + Vector2(OFF_M, 0.0))
		arena.damage(body, 1000.0, arena.rivet.id, &"pistol")
	for i: int in SETTLE_TICKS:
		s.step()
	var rest: Vector2 = body.pos if body != null else Vector2.ZERO
	s.world.loop().set_input(Walk.new())
	var path: PackedVector2Array = PackedVector2Array()
	for i: int in WALK_TICKS:
		s.step()
		@warning_ignore("return_value_discarded")
		path.append(arena.rivet.pos)
	return {"path": path, "body": body, "rest": rest}


func test_rivet_walks_over_a_body_as_over_nothing() -> void:
	var bare: Dictionary = _walk(false)
	var over: Dictionary = _walk(true)
	var a: PackedVector2Array = bare["path"]
	var b: PackedVector2Array = over["path"]
	assert_eq(a.size(), b.size())
	var worst: float = 0.0
	for i: int in a.size():
		worst = maxf(worst, a[i].distance_to(b[i]))
	assert_lt(worst, 0.001, "a body changed Rivet's path by %.3f m" % worst)
	assert_gt(b[b.size() - 1].x - b[0].x, OFF_M, "the walk reached past the body")


func test_a_walked_over_body_does_not_move() -> void:
	var over: Dictionary = _walk(true)
	var body: Fighter = over["body"]
	var rest: Vector2 = over["rest"]
	assert_eq(body.pos, rest, "Rivet pushed the body")


## Quest 1's Rivet-against-hostiles pass (`ArenaBodies`), called with him standing on a dead guard.
func test_quest_bodies_pass_has_no_contact_with_the_dead() -> void:
	var s: ArenaSession = _open(Idle.new())
	var arena: CombatArena = s.stage.arena
	var guard: Fighter = arena.spawn_guard(arena.rivet.pos + Vector2(0.1, 0.0))
	arena.damage(guard, 1000.0, arena.rivet.id, &"pistol")
	var at: Vector2 = arena.rivet.pos
	var rest: Vector2 = guard.pos
	assert_eq(ArenaBodies.resolve(arena, Vector2(6.0, 0.0)), 0, "no contact with a corpse")
	assert_eq(arena.rivet.pos, at, "Rivet not moved")
	assert_eq(guard.pos, rest, "the body not moved")
