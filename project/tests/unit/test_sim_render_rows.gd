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


func test_baked_bodies_keep_their_sim_slot_across_a_rigged_slot() -> void:
	var state := CitySimState.new()
	state.init(18)
	for slot: int in [0, 14, 15, 511]:
		state.alive[slot] = 1
		state.kind[slot] = SimConst.K_PED
	var renderer := CitySimRender.new(state)
	var rids: Array[RID] = []
	for k: int in SimConst.RL_COUNT:
		var rid: RID = RenderingServer.multimesh_create()
		var cap: int = SimConst.PCAP if k == SimConst.RL_BULLETS else SimConst.CAP
		RenderingServer.multimesh_allocate_data(
			rid, cap, RenderingServer.MULTIMESH_TRANSFORM_2D, true, true
		)
		rids.append(rid)
	renderer.setup(rids, PackedInt32Array())
	renderer.set_rig_slots(PackedInt32Array([14]))
	renderer.write(-1, -1, 1, 1)
	for rid: RID in rids:
		RenderingServer.free_rid(rid)
	assert_eq(renderer.counts[SimConst.RL_PEDS], 3)
	var rows := PackedFloat32Array(renderer._layers[SimConst.RL_PEDS])
	var slots: Array[int] = [0, 15, 511]
	for row: int in slots.size():
		assert_eq(rows[row * SimConst.RL_STRIDE + 13], float(slots[row] + 1))


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
