extends GutTest
## A one-cell clip for each look makes the reference writer's cell equal its atlas row.


func test_reference_writer_resolves_looks_by_body_without_changing_the_sim() -> void:
	var s := CitySimState.new()
	s.init(18)
	var renderer := CitySimRender.new(s)
	var table := PackedInt32Array()
	for look: int in SimConst.CLIP_VARIANTS:
		for clip: int in SimConst.CLIPS:
			table.append_array(PackedInt32Array([look, 1, 0]))
	renderer.setup([], table)
	var kinds: Array[int] = [
		SimConst.K_COP,
		SimConst.K_PED,
		SimConst.K_COP,
		SimConst.K_PED,
		SimConst.K_COP,
		SimConst.K_PED
	]
	var variants: Array[int] = [7, 5, 7, 7, 8, 255]
	var rows: Array[int] = [5, 3, 6, 7, 5, 1]
	for slot: int in kinds.size():
		s.kind[slot] = kinds[slot]
		s.variant[slot] = variants[slot]
		var row: int = renderer._frame_cell(slot)
		assert_eq(row, rows[slot], "slot %d" % slot)
		assert_eq(int(s.variant[slot]), variants[slot], "rendering preserves the variant")


func test_rows_match_the_rig_choice_for_a_thousand_actor_ids() -> void:
	for body: BodyPlan.Kind in [BodyPlan.Kind.COP, BodyPlan.Kind.PED]:
		var kind: int = SimConst.K_COP if body == BodyPlan.Kind.COP else SimConst.K_PED
		for variant: int in [0, 1, 2, 3, 4, 5, 6, 7, RigVariant.SWAT, 9, 254, 255]:
			var auto_look: bool = variant == 255 or RigVariant.crowd(variant).kind != body
			for slot: int in 1000:
				var look: int = RigVariant.crowd_index_for(slot, body) if auto_look else variant
				var expected: int = RigVariant.atlas_look(look)
				var got: int = CitySimClips.row_of(kind, variant, slot)
				if got != expected:
					assert_eq(got, expected, "kind %d, variant %d, slot %d" % [kind, variant, slot])
					return
	assert_true(true, "all explicit and automatic looks match on both body kinds")
