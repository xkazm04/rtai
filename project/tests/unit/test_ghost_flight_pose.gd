extends GutTest

var _saved_view: ViewMode


class ShadowDiscs:
	extends GhostShadow
	var radii: Array[float] = []
	var alphas: Array[float] = []

	func _init(row: GhostHoverRow.Shadow) -> void:
		super(row)

	func _disc(radius_m: float, _colour: Color, alpha: float) -> void:
		radii.append(radius_m)
		alphas.append(alpha)


func before_each() -> void:
	_saved_view = ViewMode._shared


func after_each() -> void:
	ViewMode._shared = _saved_view


func test_shadow_is_a_direct_child_and_stays_at_the_ground_mark() -> void:
	ViewMode.select("tilt70")
	var flight: GhostFlight = add_child_autofree(GhostFlight.make(&"kerf"))
	flight.position = Vector2(32, -12)
	var body: Node2D = Node2D.new()
	flight.mount(body)
	var mark: Vector2 = Vector2(90, 45)
	flight.step(mark, 0.0, 0)
	flight.set_emerge(0.5)
	var shadow: GhostShadow = flight.shadow
	assert_not_null(shadow)
	assert_eq(shadow.get_parent(), flight)
	assert_true(shadow.is_visible_in_tree())
	assert_eq(shadow.position, mark)
	assert_eq(shadow.global_position, flight.position + mark)
	assert_eq(shadow.scale, Vector2.ONE)
	assert_eq(shadow.modulate.a, 1.0)
	assert_eq(shadow._height, 0.25)
	assert_eq(shadow.pool_open, 0.5)


func test_half_emerged_shadow_draws_the_scaled_pool_and_contact_disc() -> void:
	var flight: GhostFlight = add_child_autofree(GhostFlight.make(&"kerf"))
	var discs: ShadowDiscs = autofree(ShadowDiscs.new(flight.shadow._row))
	flight.shadow = discs
	flight.step(Vector2.ZERO, 0.0, 0)
	flight.set_emerge(0.5)
	discs._draw()
	# At 0.25 m Kerf's pool spreads by 1/16 and its contact disc shrinks by 1/16.
	assert_eq(discs.radii, [1.5 * 1.0625 * 0.5, 0.49 * 0.9375])
	assert_eq(discs.alphas, [0.32 * 0.5 / (1.0625 * 1.0625), 0.26 * 0.9375])


func test_mounted_scale_by_pitch_and_emergence(
	view: String = use_parameters(["tilt55", "tilt70", "top"])
) -> void:
	ViewMode.select(view)
	var flight: GhostFlight = add_child_autofree(GhostFlight.make(&"kerf"))
	var body: Node2D = Node2D.new()
	flight.mount(body)
	# Tick 25 is halfway through Kerf's bob. Turning on that tick banks it 3 degrees.
	flight.step(Vector2.ZERO, -PI / 2.0, 24)
	flight.step(Vector2.ZERO, 0.0, 1)
	for emerge: float in [1.0, 0.5]:
		flight.set_emerge(emerge)
		var across: float = cos(deg_to_rad(3.0) * emerge)
		var expected: Vector2 = Vector2(across, 1.0)
		if view == "top":
			# Overhead, each metre of lift adds 4.5% at full emergence. Kerf is at 0.5 m.
			expected = Vector2(1.0, across) * (1.0 + 0.0225 * emerge)
		assert_almost_eq(flight.body_scale(), expected, Vector2.ONE * 0.000001)
		assert_almost_eq(body.global_scale, expected, Vector2.ONE * 0.000001)
