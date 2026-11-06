extends GutTest
## d8 bosses: the throne-car's art (walls, roof, throne cards) per view pitch; straight down none.

const PARTS: Array[String] = [
	"car_side", "car_front", "car_rear", "car_roof", "throne_back", "throne_front", "cannon"
]


func test_straight_down_keeps_the_code_mount() -> void:
	if ViewMode.shared().has_lift():
		pass_test("the shared view lifts in this run")
		return
	assert_eq(KingCarWalls.mount_k(), KingCarWalls.MOUNT_K)


func test_pitch_55_has_every_car_part() -> void:
	for n: String in PARTS:
		assert_true(ResourceLoader.exists(KingCarWalls.DIR % [55, n]), n)


func test_a_pitch_without_art_has_none() -> void:
	assert_false(ResourceLoader.exists(KingCarWalls.DIR % [65, "car_side"]))  # view70 owns p70


func test_the_roof_fits_the_car_footprint() -> void:
	var tex: Texture2D = load(KingCarWalls.DIR % [55, "car_roof"]) as Texture2D
	var want: float = KingBodyView.CAR_LEN_M / KingBodyView.CAR_W_M
	assert_almost_eq(float(tex.get_width()) / float(tex.get_height()), want, 0.01)


func test_only_the_bumper_slices_stand_proud() -> void:
	var proud: int = 0
	for i: int in KingCarWalls.SLICES:
		var z: float = KingCarWalls._z(i)
		var want: bool = z >= KingCarWalls.BUMPER_Z_M.x and z <= KingCarWalls.BUMPER_Z_M.y
		assert_eq(KingCarWalls._proud(i) > 0.0, want, "slice %d" % i)
		proud += 1 if want else 0
	assert_between(proud, 2, 10, "a band of slices, not the whole wall")


func test_the_cannon_strip_is_a_barrel_lying_along_x() -> void:
	var tex: Texture2D = load(KingCarWalls.DIR % [55, "cannon"]) as Texture2D
	assert_gt(tex.get_width(), tex.get_height(), "breech to muzzle along the strip")
