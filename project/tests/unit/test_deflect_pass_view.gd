extends GutTest


func _arena() -> CombatArena:
	var reg: RngRegistry = RngRegistry.new(174)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), Events, reg.stream(&"combat"))
	DeflectRule.bind(arena, reg)
	return arena


func _front(arena: CombatArena) -> Shot:
	var s: Shot = Shot.new()
	s.from_rivet = false
	s.pos = Vector2.RIGHT
	s.vel = Vector2.LEFT * 120.0
	s.weapon = &"pistol"
	arena.shots.assign([s])
	return s


func test_pass_marks_contact_once_and_expires_on_the_eighth_tick() -> void:
	var arena: CombatArena = _arena()
	var layer: CanvasLayer = autofree(CanvasLayer.new())
	DeflectPassView.attach(layer, arena, 10)
	var view: DeflectPassView = layer.get_child(0) as DeflectPassView
	var rule: DeflectRule = DeflectRule.of(arena)
	rule.pass_ratio_k = 2.0
	arena.tick = 50
	var s: Shot = _front(arena)
	var at: Vector2 = Vector2(0.6, 0)
	assert_false(PlayerDeflect.send_back(arena, s, Vector2.RIGHT, at))
	assert_eq(view._marks.size(), 1)
	if not view._marks.is_empty():
		assert_almost_eq(view._marks[0].x, at.x, 0.00001)
	assert_false(PlayerDeflect.send_back(arena, s, Vector2.RIGHT))
	assert_eq(view._marks.size(), 1)
	rule.pass_ratio_k = 0.0
	assert_true(PlayerDeflect.send_back(arena, _front(arena), Vector2.RIGHT))
	assert_eq(view._marks.size(), 1)
	arena.tick += DeflectPassView.LIFE - 1
	view._process(0.0)
	assert_true(view.visible)
	arena.tick += 1
	view._process(0.0)
	assert_false(view.visible)
	assert_true(view._marks.is_empty())


func test_attaching_the_view_preserves_idle_replay_bytes() -> void:
	var arena: CombatArena = _arena()
	var before: StreamPeerBuffer = StreamPeerBuffer.new()
	arena.write_state(before)
	var layer: CanvasLayer = autofree(CanvasLayer.new())
	DeflectPassView.attach(layer, arena, 10)
	var after: StreamPeerBuffer = StreamPeerBuffer.new()
	arena.write_state(after)
	assert_eq(after.data_array, before.data_array)
