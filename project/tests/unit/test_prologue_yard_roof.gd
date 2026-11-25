extends GutTest

const ROOF: String = "res://boot/prologue/art/arched_line/hall_roof_"
const PLUME: String = "res://boot/prologue/art/arched_line/hall_plume_"
const BAY: String = "res://boot/prologue/art/arched_line/hall_tall_"


func _front() -> Array[PrologueYardDressing.Piece]:
	return PrologueYardDressing.resolve("arched_line").factory_front


func _of(prefix: String) -> Array[PrologueYardDressing.Piece]:
	var out: Array[PrologueYardDressing.Piece] = []
	for piece: PrologueYardDressing.Piece in _front():
		if piece.art.begins_with(prefix):
			out.append(piece)
	return out


func test_every_bay_has_one_slab_of_the_shared_depth_at_its_centre() -> void:
	var bays: Array[PrologueYardDressing.Piece] = _of(BAY)
	var slabs: Array[PrologueYardDressing.Piece] = _of(ROOF)
	assert_eq(bays.size(), 5)
	assert_eq(slabs.size(), bays.size())
	var depth: float = slabs[0].size_m.y
	var north: float = slabs[0].at.y - depth * 0.5
	for bay: PrologueYardDressing.Piece in bays:
		var hits: Array[PrologueYardDressing.Piece] = []
		for slab: PrologueYardDressing.Piece in slabs:
			if is_equal_approx(slab.at.x, bay.at.x):
				hits.append(slab)
		assert_eq(hits.size(), 1, "one slab over the bay at x %s" % bay.at.x)
		if hits.size() == 1:
			assert_eq(hits[0].size_m.y, depth, "shared depth")
			assert_almost_eq(hits[0].at.y - depth * 0.5, north, 0.001, "straight north edge")
			assert_eq(hits[0].flip, bay.flip, "flipped like its bay")
			assert_gt(hits[0].size_m.x, bay.size_m.x, "overlaps the side seams")
			assert_lt(hits[0].tint.v, 1.0, "a step darker than the facade")


func test_slabs_and_plumes_draw_before_the_bays() -> void:
	var arts: Array[String] = []
	for piece: PrologueYardDressing.Piece in _front():
		arts.append(piece.art)
	var first_bay: int = arts.find(_of(BAY)[0].art)
	for piece: PrologueYardDressing.Piece in _of(ROOF) + _of(PLUME):
		assert_lt(arts.find(piece.art), first_bay, piece.art)


func test_no_two_bays_share_a_plume_set() -> void:
	var sets: Array[String] = []
	for bay: PrologueYardDressing.Piece in _of(BAY):
		var arts: Array[String] = []
		for plume: PrologueYardDressing.Piece in _of(PLUME):
			if absf(plume.at.x - bay.at.x) <= bay.size_m.x * 0.5:
				arts.append(plume.art)
		arts.sort()
		assert_gt(arts.size(), 0, "a plume over the bay at x %s" % bay.at.x)
		var key: String = ",".join(arts)
		assert_false(key in sets, "plume set shared: " + key)
		sets.append(key)
