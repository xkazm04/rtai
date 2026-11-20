extends GutTest

const GLASS_CHANNELS: Array[Color] = [Color.RED, Color.GREEN, Color.BLUE]
const FORK_TEXELS: Array[Vector2] = [Vector2(520.9, 18.0), Vector2(520.92, 72.29)]
const EPS: float = 0.001

var _spirit: OhmSpirit
var _drawn: GhostDrawn
var _charge: OhmCharge
var _stage: OhmStage
var _world: CollectCallStage


func before_each() -> void:
	var mount: Node2D = add_child_autofree(Node2D.new())
	PlayerScale.fit([mount])
	_spirit = OhmSpirit.new()
	mount.add_child(_spirit)
	_drawn = GhostDrawn.new("ohm", 1.55, 126.0, 180.0)
	_charge = OhmCharge.new()
	_stage = OhmStage.shipped()
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_world = CollectCallStage.new(StageLayout.shipped())
	_world.setup(World.build_context(bus, data, 1))


func _tick(activate: bool = false, press: bool = false) -> void:
	_world.tick += 1
	_stage.drive(_world, activate, press, Vector2.RIGHT)
	_charge.step(_stage, _world.tick)
	_spirit.pose(_drawn, _charge, _stage, false, _world.tick)


func test_three_painted_glasses_refill_in_order_after_the_press() -> void:
	_tick(true)
	_assert_glass(Vector3.ONE)
	_tick(false, true)
	var levels: Array[Vector3] = [
		Vector3.ZERO,
		Vector3(0.5, 0, 0),
		Vector3(1, 0, 0),
		Vector3(1, 0.5, 0),
		Vector3(1, 1, 0),
		Vector3(1, 1, 0.5),
		Vector3.ONE
	]
	for level: Vector3 in levels:
		_assert_glass(level)
		for _i: int in 5:
			_tick()


func _assert_glass(expected: Vector3) -> void:
	var rack: OhmJars = _spirit._jars
	assert_eq(rack.get_child_count(), 3)
	var last_y: float = -INF
	for i: int in 3:
		var rim: Polygon2D = rack.get_child(i) as Polygon2D
		var glass: Polygon2D = rim.get_child(0) as Polygon2D
		var glint: Sprite2D = glass.get_child(0) as Sprite2D
		var ink: ShaderMaterial = glass.material as ShaderMaterial
		# Sample the mask at the centre of the actual polygon: R, G, B in order across the back.
		var uv: Vector2 = glass.uv[0] - glass.polygon[0]
		var channel: Color = glass.texture.get_image().get_pixelv(Vector2i(uv))
		var fill: Vector3 = ink.get_shader_parameter(&"fill")
		assert_eq(channel, GLASS_CHANNELS[i])
		assert_almost_eq(fill.dot(Vector3(channel.r, channel.g, channel.b)), expected[i], EPS)
		assert_almost_eq(glint.self_modulate.a, expected[i], EPS)
		var circles: bool = ink.get_shader_parameter(&"circles")
		var flash: float = ink.get_shader_parameter(&"flash")
		var vent: float = ink.get_shader_parameter(&"vent")
		var teal: Color = ink.get_shader_parameter(&"teal")
		var full: Color = ink.get_shader_parameter(&"full")
		assert_true(circles)
		assert_eq(flash, 0.0)
		assert_eq(vent, 0.0)
		assert_eq(teal, Color("#19ffe1"))
		assert_eq(full, Color("#68fff1"))
		assert_gt(rim.position.y, last_y)
		assert_eq(rim.scale, Vector2.ONE * 1.4)
		last_y = rim.position.y


func test_wounded_pending_cast_vents_amber_at_each_jar_then_fades_the_puffs() -> void:
	_stage.cast.delay_ticks = 3
	_tick(true)
	_tick(false, true)
	_world.arena.rivet.take(0.25, _world.tick, Vector2.LEFT)
	_tick()
	var starts: PackedVector2Array = _spirit._vents.duplicate()
	for age: int in range(25):
		var vent: float = maxf(0.0, 1.0 - age / 24.0)
		assert_almost_eq(_spirit._fork.vent, vent, EPS)
		if age == 0:
			assert_eq(OhmFork.fork_ink(_spirit._fork.vent), Color("#ffb000"))
		for i: int in 3:
			var rim: Polygon2D = _spirit._jars.get_child(i) as Polygon2D
			var glass: Polygon2D = rim.get_child(0) as Polygon2D
			var ink: ShaderMaterial = glass.material as ShaderMaterial
			var amber: Color = ink.get_shader_parameter(&"amber")
			var weight: float = ink.get_shader_parameter(&"vent")
			assert_eq(amber, Color("#ffb000"))
			assert_almost_eq(weight, vent, EPS)
			_assert_puff(_spirit._puffs[i], starts[i], i, age)
		_tick()


func _assert_puff(puff: Sprite2D, start: Vector2, index: int, age: int) -> void:
	var texture: GradientTexture2D = puff.texture as GradientTexture2D
	assert_eq(texture.gradient.get_color(0), Color("#ffb000"))
	assert_eq(texture.gradient.get_color(1).a, 0.0)
	assert_eq(puff.visible, age < 16)
	if age < 16:
		var k: float = age / 16.0
		assert_almost_eq(puff.modulate.a, 1.0 - k, EPS)
		assert_almost_eq(puff.scale.x, lerpf(0.7, 1.8, k), EPS)
		_assert_point(puff.position, start + Vector2(-130, (index - 1) * 70) * k)


func test_draw_order_runs_from_hem_and_shaft_to_fist_and_beard() -> void:
	var body: Sprite2D = _spirit._jars.get_parent() as Sprite2D
	var stack: Array[Sprite2D] = [
		_spirit._hem, _spirit._staff, _spirit._free_arm, body, _spirit._staff_arm, _spirit._beard
	]
	var last: int = -1
	for sprite: Sprite2D in stack:
		assert_eq(sprite.get_parent(), _spirit)
		assert_eq(sprite.z_index, 0)
		assert_false(sprite.show_behind_parent)
		assert_false(sprite.centered)
		assert_gt(sprite.get_index(), last)
		last = sprite.get_index()
	assert_eq(body.scale, Vector2.ONE * 1.13)
	assert_eq(_spirit._staff.self_modulate, Color(1.16, 1.16, 1.16))
	assert_false(_spirit._jars.show_behind_parent)
	assert_eq(_spirit._jars.z_index, 0)
	assert_eq(_spirit._fork.get_parent(), _spirit._staff)


func test_fork_and_wrist_travel_together_to_peak_and_back() -> void:
	_stage.bolt_tick = 0
	_stage.bolt_aim = Vector2(0.6, 0.8)
	var travel_m: Dictionary[int, float] = {0: 0.0, 4: 0.175, 8: 0.35, 14: 0.175, 20: 0.0, 21: 0.0}
	for age: int in travel_m:
		_spirit.pose(_drawn, _charge, _stage, false, age)
		var tips: PackedVector2Array = _spirit._fork.points_on(_spirit)
		assert_eq(tips.size(), 3)
		if tips.size() != 3:
			return
		var aim: Vector2 = _stage.bolt_aim.rotated(-_spirit.global_rotation)
		var expected: Vector2 = Vector2(1.60, 0.96) + aim * travel_m[age]
		_assert_point(tips[2] * PlayerScale.k() / 531.25, expected)
		assert_eq(_spirit._fork.stage, _stage)
		var staff: Sprite2D = _spirit._staff
		assert_almost_eq(staff.rotation, 0.18, EPS)
		for i: int in 2:
			var painted: Vector2 = staff.get_rect().position + FORK_TEXELS[i]
			_assert_point(_spirit.to_local(staff.to_global(painted)), tips[i])
		var arm: Sprite2D = _spirit._staff_arm
		var hole: Vector2 = arm.get_rect().position + Vector2(395, 99)
		var shaft: Vector2 = staff.get_rect().position + Vector2(264, 45.145)
		_assert_point(arm.to_global(hole), staff.to_global(shaft))
		_assert_point(staff.to_global(shaft), staff.global_position)


func _assert_point(actual: Vector2, expected: Vector2) -> void:
	assert_almost_eq(actual, expected, Vector2.ONE * EPS)
