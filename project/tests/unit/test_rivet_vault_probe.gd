extends GutTest

var probe: VaultProbe
var p: Vector2
var r: float = 0.6
var box: Rect2 = Rect2(-2.5, -0.4, 5.0, 0.8)


func before_each() -> void:
	p = Vector2(0.0, -1.15)
	var table: DataTable = DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
	probe = VaultProbe.new(table, table.object(table.raw, "vault"))
	probe.boxes[box] = "cover_low"


func _press(velocity: Vector2) -> VaultProbe.Hit:
	return probe.find(p, r, velocity, Vector2.DOWN)


func test_geometry_and_landing_clearance() -> void:
	var hit: VaultProbe.Hit = _press(Vector2.DOWN * 8.0)
	assert_eq(hit.reason, &"ok")
	assert_almost_eq(hit.height, 1.0, 1e-5)
	assert_almost_eq(hit.depth, box.size.y, 1e-5)
	assert_almost_eq(hit.entry.y, box.position.y, 1e-5)
	assert_true(probe.clear_at(hit.landing, r))
	assert_false(probe.clear_at(box.get_center(), r))


func test_nearest_face_reports_why_the_press_was_refused() -> void:
	assert_eq(_press(Vector2.DOWN).reason, &"too_slow")
	assert_eq(_press(Vector2(7, 4)).reason, &"bad_angle")
	probe.boxes[box] = "unmapped"
	assert_eq(_press(Vector2.DOWN * 8.0).reason, &"too_high")
	probe.boxes.clear()
	assert_eq(_press(Vector2.DOWN * 8.0).reason, &"none")
	probe.boxes[Rect2(-2.5, -0.4, 5, 3)] = "cover_low"
	assert_eq(_press(Vector2.DOWN * 8.0).reason, &"too_deep")


func test_other_solid_in_the_crossing_blocks_even_a_clear_endpoint() -> void:
	probe.boxes[Rect2(-1, 0.05, 2, 0.1)] = "wall_high"
	var hit: VaultProbe.Hit = _press(Vector2.DOWN * 8.0)
	assert_true(probe.clear_at(hit.landing, r))
	assert_eq(hit.reason, &"landing_blocked")


func test_generated_parked_sedan_across_width_and_along_length() -> void:
	probe.boxes.clear()
	probe.city = VaultCity.new(StageCells.shipped())
	var car: VaultCity.Prop = probe.city.owner(Vector2i(17, 52))
	assert_not_null(car)
	if car == null:
		return
	assert_eq(car.kind, "sedan")
	var rect: Rect2 = car.bounds
	p = Vector2(rect.position.x - r - 0.1, rect.get_center().y)
	var hit: VaultProbe.Hit = _press(Vector2.RIGHT * 8.0)
	assert_eq(hit.reason, &"ok")
	assert_almost_eq(hit.depth, 2.0, 1e-5)
	assert_true(probe.city.cells.clear(hit.landing, r))
	p = Vector2(rect.get_center().x, rect.position.y - r - 0.1)
	assert_eq(_press(Vector2.DOWN * 8.0).reason, &"too_deep")


func test_airborne_oracle_rejects_an_adjacent_prop_of_the_same_kind_and_void() -> void:
	probe.boxes.clear()
	probe.city = VaultCity.new(StageCells.shipped())
	p = Vector2(5.5, 45.15)
	var hit: VaultProbe.Hit = _press(Vector2.DOWN * 8.0)
	assert_eq(hit.reason, &"ok")
	var over: Vector2 = Vector2(5.5, 46.5)
	assert_eq(probe.contacts(over, r, hit), VaultProbe.Contact.TARGET)
	probe.boxes[Rect2(over, Vector2.ONE)] = hit.kind
	var both: int = VaultProbe.Contact.TARGET | VaultProbe.Contact.OTHER
	assert_eq(probe.contacts(over, r, hit), both)
	assert_eq(probe.contacts(Vector2(-2, -2), r, hit), VaultProbe.Contact.OTHER)


func test_diagonal_reach_uses_the_normal_distance_to_the_face() -> void:
	var velocity: Vector2 = Vector2.DOWN.rotated(deg_to_rad(30.0)) * 8.0
	p.y = box.position.y - r - probe.reach + 0.01
	assert_eq(_press(velocity).reason, &"ok")
	p.y -= 0.02
	assert_eq(_press(velocity).reason, &"none")


func test_obstacle_at_the_depth_limit_and_circle_at_its_corner() -> void:
	probe.boxes.clear()
	probe.boxes[Rect2(0, 0, 5, 2)] = "cover_low"
	p = Vector2(2, -1)
	probe.max_depth = 2.0
	assert_eq(_press(Vector2.DOWN * 8.0).reason, &"ok")
	assert_true(probe.clear_at(Vector2(-0.45, -0.45), r))
	assert_false(probe.clear_at(Vector2(-0.4, -0.4), r))


func test_relocating_a_station_removes_its_old_footprint() -> void:
	var prop: ArenaStation.Prop = ArenaStation.Prop.new()
	prop.kind = "cover_low"
	var station: ArenaStation = ArenaStation.new()
	station.props.append(prop)
	var source: ArenaStations = ArenaStations.new()
	source.stations.append(station)
	var old_base: Vector2 = Vector2(4, 6)
	var new_base: Vector2 = Vector2(12, 6)
	probe.stations(source, old_base)
	assert_false(probe.clear_at(old_base, r))
	probe.stations(source, new_base)
	assert_true(probe.clear_at(old_base, r))
	assert_false(probe.clear_at(new_base, r))
