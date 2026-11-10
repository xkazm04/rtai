extends GutTest
## n11 combat (critique: the kill spray read as round blobs of one size): a share of a kill's
## drops is a fine mist, smaller than the row's smallest drop and thrown faster.


func _sizes(kind: String) -> Array[float]:
	var b: BloodFx = BloodFx.new()
	b.splash(Vector2(100, 100), Vector2.RIGHT, kind)
	var flight: BloodFlight = b._flight
	var out: Array[float] = []
	for i: int in flight.size.size():
		if flight.life[i] > 0:
			out.append(flight.size[i])
	b.free()
	return out


func test_a_kill_spray_carries_a_fine_mist() -> void:
	var b: BloodFx = BloodFx.new()
	var row: Dictionary = b.p["hits"]["kill"]
	var lo: float = row["drop_px"][0]
	var share: float = row["fine"][0]
	b.free()
	var sizes: Array[float] = _sizes("kill")
	var fine: int = sizes.filter(func(s: float) -> bool: return s < lo).size()
	assert_gt(fine, int(sizes.size() * share * 0.5), "the mist is there")
	assert_lt(fine, sizes.size(), "and the beads are still there")


func test_a_row_without_a_fine_share_keeps_its_sizes() -> void:
	var b: BloodFx = BloodFx.new()
	var lo: float = b.p["hits"]["robot_hit"]["drop_px"][0]
	b.free()
	for s: float in _sizes("robot_hit"):
		assert_gte(s, lo - 0.0001)
