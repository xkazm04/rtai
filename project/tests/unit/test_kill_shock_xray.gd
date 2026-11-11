extends GutTest
## n16 kills-polish: the electro X-ray skeleton stands on the body's feet (DEFECTS ranking #2),
## not lying along the shot beside him. `--shock-xray=lie` (the before) is unset under tests.


func test_the_skeleton_is_upright_by_default() -> void:
	assert_false(KillXray.lies())


func test_the_skeleton_centre_is_half_its_height_above_the_feet() -> void:
	var feet: Vector2 = Vector2(100.0, 200.0)
	var mid: Vector2 = KillXray.mid(feet, KillShockFx.XRAY_M, 32.0)
	assert_eq(mid.x, feet.x)
	var want: float = feet.y - (KillShockFx.XRAY_M * 0.5 - KillXray.FOOT_M) * 32.0
	assert_almost_eq(mid.y, want, 0.001)


func test_the_skeleton_rises_with_the_zoom() -> void:
	var rise64: float = -KillXray.mid(Vector2.ZERO, KillShockFx.XRAY_M, 64.0).y
	var rise32: float = -KillXray.mid(Vector2.ZERO, KillShockFx.XRAY_M, 32.0).y
	assert_almost_eq(rise64, rise32 * 2.0, 0.001)
	assert_gt(rise32, 0.0)
