extends GutTest
## d8 bosses: the throne-car's art (walls, roof, throne cards) per view pitch; straight down none.

const PARTS: Array[String] = [
	"car_side", "car_front", "car_rear", "car_roof", "throne_back", "throne_front"
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
	assert_false(ResourceLoader.exists(KingCarWalls.DIR % [70, "car_side"]))


func test_the_roof_fits_the_car_footprint() -> void:
	var tex: Texture2D = load(KingCarWalls.DIR % [55, "car_roof"]) as Texture2D
	var want: float = KingBodyView.CAR_LEN_M / KingBodyView.CAR_W_M
	assert_almost_eq(float(tex.get_width()) / float(tex.get_height()), want, 0.01)
