extends GutTest


func after_each() -> void:
	GhostLook.reset_for_test()


func _check(row: SignatureKill, look: StringName, ticks: int, streak: bool) -> void:
	GhostLook.override_for_test(look)
	var marks: KillMarks = KillMarks.new()
	var rng: RandomNumberGenerator = RngRegistry.new(31).stream(&"kills")
	var mark: KillMarks.Mark = marks.leave(row, Vector2.ZERO, Vector2.RIGHT, 7, rng)
	assert_eq(mark.flash_ticks, ticks)
	var strokes: Dictionary[int, Vector4] = {}
	var stroke: Vector4 = Vector4(1, 2, 0.3, 7)
	KerfVictim.streak(row, strokes, 11, stroke)
	assert_eq(strokes.has(11), streak)
	if streak:
		assert_eq(strokes[11], stroke)


func test_spectral_kerf_leaves_the_slot_clear() -> void:
	var row: SignatureKill = SignatureKillTable.load_table().for_weapon(&"kerf_slice")
	_check(row, GhostLook.SPECTRAL, 0, false)


func test_legacy_kerf_keeps_its_star_and_streak() -> void:
	var row: SignatureKill = SignatureKillTable.load_table().for_weapon(&"kerf_slice")
	_check(row, GhostLook.LEGACY, row.flash_ticks, true)


func test_another_signature_keeps_its_row_under_spectral() -> void:
	var row: SignatureKill = SignatureKillTable.load_table().for_weapon(&"ram")
	_check(row, GhostLook.SPECTRAL, row.flash_ticks, true)


func test_only_the_edges_wait_for_the_fourth_kill_tick() -> void:
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	var table: SignatureKillTable = SignatureKillTable.load_table()
	var kills: SignatureKills = SignatureKills.new(table, RngRegistry.new(3).stream(&"kills"))
	kills.tick = 17
	var half: Node2D = autofree(Node2D.new())
	var groups: Array[Node2D] = [null, half]
	var edge: KillCutEdge = KillCutEdge.new()
	half.add_child(edge)
	var row: SignatureKill = table.for_weapon(&"kerf_slice")
	GhostLook.override_for_test(GhostLook.LEGACY)
	var legacy: Node2D = autofree(KerfVictim.holder(row, groups, kills))
	assert_eq(legacy.get_child_count(), 0)
	assert_eq(legacy.z_index, 0)
	assert_true(legacy.z_as_relative)
	assert_true(edge.visible)
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	var holder: KerfVictim.Reaction = autofree(KerfVictim.holder(row, groups, kills))
	assert_true(half.visible)
	assert_false(edge.visible)
	for tick: int in range(18, 22):
		kills.tick = tick
		holder._process(0.0)
		assert_false(edge.visible)
	kills.tick = 22
	holder._process(0.0)
	assert_true(edge.visible)


func test_slice_victim_draws_over_the_ronin_for_thirty_ticks_then_rejoins_the_gib_layer() -> void:
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	var table: SignatureKillTable = SignatureKillTable.load_table()
	var kills: SignatureKills = SignatureKills.new(table, RngRegistry.new(3).stream(&"kills"))
	kills.tick = 17
	var row: SignatureKill = table.for_weapon(&"kerf_slice")
	var holder: KerfVictim.Reaction = add_child_autofree(KerfVictim.holder(row, [], kills))
	var ronin_z: int = RenderLayers.z(&"actors") + GhostFormView.Z_OVER_RIGS
	for tick: int in range(18, 48):
		kills.tick = tick
		holder._process(0.0)
		assert_false(holder.z_as_relative)
		assert_gt(holder.z_index, ronin_z)
		assert_lt(holder.z_index, RenderLayers.z(&"vehicles"))
		assert_true(holder.is_processing())
	kills.tick = 48
	holder._process(0.0)
	assert_true(holder.z_as_relative)
	assert_eq(holder.z_index, 0)
	assert_false(holder.is_processing())
