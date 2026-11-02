extends GutTest
## d5-close: the D5 detail tier. Off at gameplay zooms, on from 56 px/m with hysteresis, the D5
## part set mirrors the D4 set (same names and sizes = silhouette lock), and the tier only adds
## overlays: it never changes a D4 part's texture, so switching cannot move an outline.

var _rigs: CharacterRigs = null


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_rigs = CharacterRigs.new()
	add_child_autofree(_rigs)
	_rigs.setup(World.build_context(bus, data, 7))
	RigDetail.enabled = true
	RigDetail.active = false
	@warning_ignore("return_value_discarded")
	_rigs.feed.put(0, 1, BodyPlan.Kind.RIVET, Vector2.ZERO, Vector2.ZERO)


func after_each() -> void:
	_rigs.zoom = 1.0
	_rigs.step_ticks(0)


func test_tier_switches_with_hysteresis() -> void:
	for z: float in [1.0, 1.5, 1.74]:
		assert_false(RigDetail.set_view(z), "off at %.2f" % z)
	assert_true(RigDetail.set_view(1.75), "on at 56 px/m")
	assert_true(RigDetail.set_view(1.7), "still on inside the hysteresis band")
	assert_false(RigDetail.set_view(1.6), "off below 54 px/m")


func test_d5_parts_mirror_the_d4_parts() -> void:
	assert_true(RigDetail.has_d5("rivet"))
	var d4: PartLibrary = PartLibrary.of("rivet")
	for part: String in d4.sizes:
		var t5: Texture2D = PartLibrary.texture(RigDetail.D5_DIR + "rivet", part)
		assert_not_null(t5, part)
		if t5 != null:
			assert_eq(t5.get_size(), d4.tex(part).get_size(), part)


func test_tier_adds_overlays_and_keeps_the_d4_parts() -> void:
	_rigs.step_ticks(1)
	var rig: CutRig = _rigs.rig_for(1)
	var before: Array[Texture2D] = []
	for s: Sprite2D in rig.sprites:
		before.append(s.texture)
	_rigs.zoom = 2.0
	_rigs.step_ticks(1)
	assert_true(RigDetail.is_on(rig))
	for i: int in rig.sprites.size():
		assert_same(rig.sprites[i].texture, before[i], "D4 part untouched")
		var o: Sprite2D = rig.sprites[i].get_node(NodePath(String(RigDetail.OVERLAY)))
		assert_true(o.visible)
	_rigs.zoom = 1.0
	_rigs.step_ticks(1)
	assert_false(RigDetail.is_on(rig))
	var o0: Sprite2D = rig.sprites[0].get_node(NodePath(String(RigDetail.OVERLAY)))
	assert_false(o0.visible, "overlays hidden at 32 px/m")


func test_palette_swapped_parts_keep_the_d4_print() -> void:
	if not RigDetail.has_d5("cop"):
		pass_test("no D5 cop set installed")
		return
	@warning_ignore("return_value_discarded")
	_rigs.feed.put(1, 2, BodyPlan.Kind.COP, Vector2(32.0, 0.0), Vector2.ZERO)
	_rigs.zoom = 2.0
	_rigs.step_ticks(1)
	var cop: CutRig = _rigs.rig_for(2)
	assert_true(RigDetail.is_on(cop))
	for i: int in cop.sprites.size():
		var o: Sprite2D = cop.sprites[i].get_node(NodePath(String(RigDetail.OVERLAY)))
		assert_eq(o.visible, cop.sprite_swaps[i] == 0, "overlay %d" % i)
