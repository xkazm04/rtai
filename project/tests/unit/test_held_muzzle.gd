extends GutTest
## n7-ranged it11: the flash's spot follows the drawn bore tip only when fresh and on.

const FALLBACK: Vector2 = Vector2(9.0, -4.0)


func before_each() -> void:
	HeldMuzzle.reset()
	HeldMuzzle.on = true


func after_each() -> void:
	HeldMuzzle.reset()
	HeldMuzzle.on = true


func _sprite_at(pos: Vector2) -> Sprite2D:
	var s: Sprite2D = Sprite2D.new()
	s.position = pos
	add_child_autofree(s)
	return s


func _ci_at(pos: Vector2) -> Node2D:
	var n: Node2D = Node2D.new()
	n.position = pos
	add_child_autofree(n)
	return n


func test_nothing_published_is_the_fallback() -> void:
	assert_eq(HeldMuzzle.at_m(_ci_at(Vector2.ZERO), FALLBACK), FALLBACK)


func test_published_point_lands_in_the_drawing_items_metres() -> void:
	var s: Sprite2D = _sprite_at(Vector2(100.0, 50.0))
	HeldMuzzle.publish(s, Vector2(20.0, 0.0))
	var got: Vector2 = HeldMuzzle.at_m(_ci_at(Vector2(24.0, 2.0)), FALLBACK)
	assert_almost_eq(got.x, 96.0 / Ink.PX_PER_M, 0.0001)
	assert_almost_eq(got.y, 48.0 / Ink.PX_PER_M, 0.0001)


func test_flag_off_is_the_fallback() -> void:
	HeldMuzzle.publish(_sprite_at(Vector2(100.0, 50.0)), Vector2.ZERO)
	HeldMuzzle.on = false
	assert_eq(HeldMuzzle.at_m(_ci_at(Vector2.ZERO), FALLBACK), FALLBACK)


func test_a_hidden_gun_publishes_nothing() -> void:
	var s: Sprite2D = _sprite_at(Vector2(100.0, 50.0))
	s.visible = false
	HeldMuzzle.publish(s, Vector2.ZERO)
	assert_false(HeldMuzzle.fresh())
	assert_eq(HeldMuzzle.at_m(_ci_at(Vector2.ZERO), FALLBACK), FALLBACK)


func test_last_frames_point_is_stale() -> void:
	HeldMuzzle.publish(_sprite_at(Vector2(100.0, 50.0)), Vector2.ZERO)
	await wait_process_frames(1)
	assert_false(HeldMuzzle.fresh())
