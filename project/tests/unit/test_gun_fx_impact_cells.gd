extends GutTest
## n15 combat item 4: the drawn impact cells by surface (GunFxImpactCells).


func test_the_ground_has_a_drawn_cell() -> void:
	for kind: int in [GunFx.Hit.GROUND]:
		var path: String = GunFxImpactCells.DIR + GunFxImpactCells.FILES[kind]
		assert_not_null(load(path) as Texture2D, path)
		assert_gt(float(GunFxImpactCells.SPAN_M[kind]), 0.0, "a span per surface")
	assert_false(GunFxImpactCells.FILES.has(GunFx.Hit.BODY), "a body keeps its ink burst")
	assert_false(GunFxImpactCells.FILES.has(GunFx.Hit.PLATING), "Rivet keeps his strokes")
	assert_false(GunFxImpactCells.FILES.has(GunFx.Hit.METAL), "metal: not filmed yet")


func test_the_cell_opens_then_fades_inside_the_impact() -> void:
	assert_almost_eq(GunFxImpactCells.open_of(0.0), GunFxImpactCells.OPEN_K, 0.001, "opens small")
	assert_almost_eq(GunFxImpactCells.open_of(GunFxImpactCells.GROW), 1.0, 0.001, "whole at GROW")
	assert_almost_eq(GunFxImpactCells.open_of(1.0), 1.0, 0.001, "and stays whole")
	assert_eq(GunFxImpactCells.fade_of(0.0), 1.0, "opaque on the hit")
	assert_eq(GunFxImpactCells.fade_of(GunFxImpactCells.GROW), 1.0, "opaque while it opens")
	assert_almost_eq(GunFxImpactCells.fade_of(1.0), 0.0, 0.001, "gone at the end")
	assert_gt(GunFxImpactCells.fade_of(0.6), GunFxImpactCells.fade_of(0.8), "fades monotonically")


func test_the_longest_side_spans_its_metres() -> void:
	var tex: Texture2D = load(GunFxImpactCells.DIR + "impact_dust.png") as Texture2D
	var px: float = GunFxImpactCells.span_px(GunFx.Hit.GROUND, tex) * tex.get_width()
	assert_almost_eq(px, GunFxImpactCells.SPAN_M[GunFx.Hit.GROUND] * Ink.PX_PER_M, 0.01)
