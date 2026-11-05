extends GutTest
## features/souls GhostMorphFx: the camera beat peaks at the swap (the midpoint), is 1.0 when off,
## and reduced motion turns it off.


func test_beat_peaks_at_the_swap_and_rests_at_the_ends() -> void:
	var fx: GhostMorphFx = autofree(GhostMorphFx.new())
	fx.show_progress(true, 0.5, 1, false)
	assert_almost_eq(fx.beat(), 1.0 + GhostMorphFx.BEAT_ZOOM, 0.0001)
	fx.show_progress(true, 0.0, 0, false)
	assert_eq(fx.beat(), 1.0)
	fx.show_progress(false, 0.5, 1, false)
	assert_eq(fx.beat(), 1.0, "no beat when no transformation runs")


func test_reduced_motion_has_no_camera_punch() -> void:
	var fx: GhostMorphFx = autofree(GhostMorphFx.new())
	fx.reduced_motion = true
	fx.show_progress(true, 0.5, 1, false)
	assert_eq(fx.beat(), 1.0)
