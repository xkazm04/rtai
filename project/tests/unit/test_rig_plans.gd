extends GutTest
## F-09b: the body plans resolve against the committed D4 parts, and every part a plan or a look
## can ask for exists (a missing part would only show up as a blank limb in play).


func test_rivet_plan_is_the_cutout_lanes() -> void:
	var p: BodyPlan = RivetPlan.build()
	assert_eq(p.kind, BodyPlan.Kind.RIVET)
	assert_almost_eq(p.thigh_len, 166.0, 0.01)
	assert_almost_eq(p.upper_len, 159.0, 0.01)
	assert_true(p.has_collar() and p.has_hand() and p.has_hose() and p.has_endon())
	assert_eq(p.gun_arm, BodyPlan.L, "the claw holds the gun")


func test_human_plans_come_from_parts_json() -> void:
	for p: BodyPlan in [HumanPlan.cop(), HumanPlan.ped()]:
		assert_gt(p.thigh_len, 100.0, "%s thigh" % p.name)
		assert_gt(p.shin_len, 100.0, "%s shin" % p.name)
		assert_gt(p.shoulder[BodyPlan.R].y, 40.0, "%s shoulder span" % p.name)
		assert_almost_eq(p.thigh_len, p.thigh_draw * HumanPlan.LEG_K, 0.01)
		assert_false(p.limb_lod, "flat human limbs keep their own print")
	assert_eq(HumanPlan.cop().shield_part, "shield")
	assert_false(HumanPlan.ped().ready_stance, "civilians' arms hang")


func test_every_part_a_plan_or_look_uses_exists() -> void:
	var missing: PackedStringArray = PackedStringArray()
	var plans: Array[BodyPlan] = [KingPlan.build()]
	for kind: BodyPlan.Kind in [BodyPlan.Kind.RIVET, BodyPlan.Kind.COP, BodyPlan.Kind.PED]:
		plans.append(RigPool.plan_of(kind))
	for p: BodyPlan in plans:
		for part: String in _parts(p):
			if not ResourceLoader.exists(PartLibrary.ART_ROOT + p.art_dir + "/" + part + ".png"):
				@warning_ignore("return_value_discarded")
				missing.append("%s/%s" % [p.art_dir, part])
	for look: int in RigVariant.CROWD_COUNT:
		var v: RigVariant = RigVariant.crowd(look)
		var dir: String = RigPool.plan_of(v.kind).art_dir
		for part: String in [v.head, v.torso]:
			if not ResourceLoader.exists(PartLibrary.ART_ROOT + dir + "/" + part + ".png"):
				@warning_ignore("return_value_discarded")
				missing.append("look %d: %s/%s" % [look, dir, part])
	assert_eq(missing, PackedStringArray(), "missing parts")


func test_rivet_forms_and_king() -> void:
	var night: BodyPlan = RivetPlan.build(RivetPlan.FORM_NIGHT)
	var base: BodyPlan = RivetPlan.build(RivetPlan.FORM_BASE)
	assert_lt(
		base.size_k, night.size_k, "the base form is smaller than the night's (owner, 2026-11-03)"
	)
	assert_lt(base.hand_ready[0].x, night.hand_ready[0].x, "the guard is pulled in")
	assert_lt(base.hand_ready[0].z, night.hand_ready[0].z, "T2's hunch: the guard hands drop")
	var king: BodyPlan = KingPlan.build()
	assert_eq(king.art_dir, "king")
	assert_false(king.has_hose(), "King carries no torch hose")
	assert_gt(king.size_k, base.size_k, "the boss is a touch bigger than Rivet")


func test_crowd_looks_split_cops_and_peds() -> void:
	for id: int in 200:
		var cop: int = RigVariant.crowd_index_for(id, BodyPlan.Kind.COP)
		var ped: int = RigVariant.crowd_index_for(id, BodyPlan.Kind.PED)
		assert_eq(RigVariant.crowd(cop).kind, BodyPlan.Kind.COP)
		assert_eq(RigVariant.crowd(ped).kind, BodyPlan.Kind.PED)
	assert_true(RigVariant.crowd(6).shield, "riot carries the shield")
	assert_false(RigVariant.crowd(5).shield, "patrol does not")


func test_sleeved_looks_have_every_arm_cell() -> void:
	var missing: PackedStringArray = PackedStringArray()
	var sleeved: int = 0
	for look: int in RigVariant.CROWD_COUNT:
		var v: RigVariant = RigVariant.crowd(look)
		if v.sleeve == "":
			continue
		sleeved += 1
		var p: BodyPlan = RigPool.plan_of(v.kind)
		var lib: PartLibrary = PartLibrary.of(p.art_dir)
		for part: String in [p.upper_part[0], p.fore_part[0], p.endon_upper[0], p.endon_fore[0]]:
			if not lib.sizes.has(part + v.sleeve):
				@warning_ignore("return_value_discarded")
				missing.append("look %d: %s%s" % [look, part, v.sleeve])
	assert_gt(sleeved, 0, "some crowd looks wear sleeve variants")
	assert_eq(
		missing, PackedStringArray(), "a sleeve suffix without its arm cells falls back to cream"
	)


func _parts(p: BodyPlan) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray([p.torso_part, p.head_part, p.pelvis_part])
	out.append_array(p.thigh_part)
	out.append_array(p.shin_part)
	out.append_array(p.foot_part)
	out.append_array(p.foot_toeoff)
	out.append_array(p.upper_part)
	out.append_array(p.fore_part)
	out.append_array(p.endon_upper)
	out.append_array(p.endon_fore)
	for extra: String in [
		p.collar_part,
		p.hand_open,
		p.hand_closed,
		p.hand_pistol,
		p.gun_cell,
		p.shield_part,
		p.hose_tex
	]:
		if extra != "":
			@warning_ignore("return_value_discarded")
			out.append(extra)
	return out
