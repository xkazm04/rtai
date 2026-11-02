extends GutTest
## World-UI markers (core/render/world_markers.gd): every kind loads in an ink its accent use
## allows, handles add / move / remove, and the objective pointer pins inside the screen edge
## only while the objective is off screen.

const SCREEN: Vector2 = Vector2(1280, 800)


func test_every_kind_loads_on_doctrine() -> void:
	var m: WorldMarkers = autofree(WorldMarkers.new())
	for id: StringName in [&"objective", &"pickup", &"soul"]:
		assert_true(m.kinds.has(id), String(id))
	var pal: PaletteTokens = PaletteTokens.shared()
	var soul: Color = m.kinds[&"soul"]["color"]
	var objective: Color = m.kinds[&"objective"]["color"]
	assert_eq(pal.classify(soul), 2, "the soul is teal")
	assert_eq(pal.classify(objective), 1, "the objective is vermilion")
	assert_eq(m.z_index, RenderLayers.z(&"world_markers"))


func test_handles() -> void:
	var m: WorldMarkers = autofree(WorldMarkers.new())
	assert_eq(m.add(&"nope", Vector2.ZERO), -1)
	var a: int = m.add(&"pickup", Vector2.ZERO)
	var b: int = m.add(&"objective", Vector2.ONE)
	assert_ne(a, b)
	m.objective = b
	m.remove(b)
	assert_eq(m.count(), 1)
	assert_eq(m.objective, -1, "removing the objective clears the pointer")


func test_the_pointer_pins_inside_the_edge_only_off_screen() -> void:
	var m: WorldMarkers = autofree(WorldMarkers.new())
	m.objective = m.add(&"objective", Vector2(640, 400))
	assert_eq(m.pointer_at(Transform2D(), SCREEN), Vector2.INF, "on screen: no pointer")
	m.move(m.objective, Vector2(5000, 400))
	var at: Vector2 = m.pointer_at(Transform2D(), SCREEN)
	var margin: float = m.pointer["margin_px"]
	assert_almost_eq(at.x, SCREEN.x - margin, 0.01)
	assert_almost_eq(at.y, 400.0, 0.01)
	m.move(m.objective, Vector2(640, -9000))
	assert_almost_eq(m.pointer_at(Transform2D(), SCREEN).y, margin, 0.01)
