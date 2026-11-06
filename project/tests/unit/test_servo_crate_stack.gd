extends GutTest
## d8 bosses: a landed CS crate stands up as a box only under a view with lift; `top` keeps the
## flat crate (draw() draws nothing, the stencil does not move).

const PX: float = 48.0

var _was: ViewMode = null


func before_each() -> void:
	_was = ViewMode._shared


func after_each() -> void:
	ViewMode._shared = _was


func test_top_draws_nothing_and_keeps_the_stencil() -> void:
	ViewMode._shared = ViewMode.of("top")
	var n: Node2D = add_child_autofree(Node2D.new())
	var tex: Texture2D = load(ServoRig.ART % "crate") as Texture2D
	var k: float = PX / SimConst.PX_PER_M
	assert_false(ServoCrateStack.draw(n, Vector2(10.0, 20.0), 0.9 * PX, tex, k))
	assert_eq(ServoCrateStack.lid_lift(n, Vector2(10.0, 20.0), 0.9 * PX, k), Vector2.ZERO)


func test_tilt_lifts_the_lid_by_the_crate_height() -> void:
	ViewMode._shared = ViewMode.of("tilt")
	if not ViewMode._shared.has_lift():
		pass_test("no tilt row in this table")
		return
	var n: Node2D = add_child_autofree(Node2D.new())
	var k: float = PX / SimConst.PX_PER_M
	var lid: Vector2 = ServoCrateStack.lid_lift(n, Vector2(10.0, 20.0), 0.9 * PX, k)
	var want: Vector2 = ViewMode._shared.lift_px(0.9 * ServoCrateStack.HEIGHT_K) * k
	assert_almost_eq(lid.y, want.y, 0.001)
	assert_lt(lid.y, 0.0, "the lid draws up the screen")
