extends GutTest
## n7-king it18: the gang's shades are their own part on the gang's head sprite (render only),
## drawn over the gang's chain; the plain robot thug and Rivet never get them.


func _gang_rig() -> CutRig:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(GangPlan.build(), RigVariant.rivet())
	return rig


func _shades(rig: CutRig) -> Array[GangShades]:
	var out: Array[GangShades] = []
	for n: Node in rig.head_spr.get_children():
		if n is GangShades:
			out.append(n as GangShades)
	return out


func test_dress_puts_one_pair_of_shades_on_the_head_sprite() -> void:
	var rig: CutRig = _gang_rig()
	GangShades.dress(rig)
	assert_eq(_shades(rig).size(), 1 if GangShades.MODE > 0 else 0)


func test_the_shades_draw_over_the_gang_chain() -> void:
	var rig: CutRig = _gang_rig()
	GangShades.dress(rig)
	for s: GangShades in _shades(rig):
		assert_gt(s.z_index, KingAccents.OVER_RIG_Z, "under the chain they are lost (it14 trial)")


func test_a_rig_without_dress_has_no_shades() -> void:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(ThugPlan.build(), RigVariant.rivet())
	assert_eq(_shades(rig).size(), 0, "the enemy-ai robot thug stays plain")


func test_the_crescent_stays_inside_the_dome() -> void:
	var outer: float = GangShades.BAND_R + GangShades.BAND_W * 0.5
	assert_lte(outer, 1.0, "the band's outer edge past the dome would print on the street")
	assert_gt(GangShades.BAND_R - GangShades.BAND_W * 0.5, 0.3, "a full cap hides the dome")
