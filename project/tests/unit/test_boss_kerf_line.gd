extends GutTest
## BossKerfLine (features/bosses, bosses.json kerf_line_m): Kerf's blink line cuts the boss
## script's bodies within the width of the line, and none outside it.


func _arena() -> CombatArena:
	var reg: RngRegistry = RngRegistry.new(3)
	var bus: EventBus = autofree(EventBus.new())
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _body(arena: CombatArena, at: Vector2, hp: float) -> Fighter:
	var b: Fighter = arena.spawn_guard(at)
	b.pos = at  # spawn_guard jitters the spot
	b.hp = hp
	b.radius_m = 0.45
	b.machine = true
	return b


func test_line_cuts_bodies_on_it_only() -> void:
	var arena: CombatArena = _arena()
	var on: Fighter = _body(arena, Vector2(3, 0.5), 3.0)  # an armoured dive drone on the line
	var edge: Fighter = _body(arena, Vector2(5, -0.9), 1.0)  # 0.9 m off: inside 0.6 + 0.45
	var off: Fighter = _body(arena, Vector2(4, 2.0), 1.0)
	var bodies: Array[Fighter] = [on, edge, off]
	var n: int = BossKerfLine._cut(arena, bodies, Vector2.ZERO, Vector2(8, 0), 0.6)
	assert_eq(n, 2, "two bodies on the line")
	assert_false(on.alive(), "cut through its armour")
	assert_false(edge.alive(), "the radius counts")
	assert_true(off.alive(), "2 m off the line is spared")


func test_servo_sets_the_line_king_does_not() -> void:
	assert_almost_eq(BossSpec.shipped(&"servo").kerf_line_m, 0.6, 0.001, "Servo's drones")
	assert_eq(BossSpec.shipped(&"king").kerf_line_m, 0.0, "default: the target only")
