extends GutTest
## d8 bosses: Servo's parts are picked by the view row's pitch; straight down today's art.


func test_top_loads_todays_parts() -> void:
	assert_eq(ServoArt.path_at(&"torso", 90.0), ServoRig.ART % &"torso")


func test_pitch_55_loads_the_p55_parts() -> void:
	assert_eq(ServoArt.path_at(&"torso", 55.0), "res://features/bosses/servo/art/p55/torso.png")


func test_a_part_without_p55_art_keeps_todays() -> void:
	assert_eq(ServoArt.path_at(&"drone", 55.0), ServoRig.ART % &"drone")
	assert_eq(ServoArt.path_at(&"torso", 70.0), ServoRig.ART % &"torso")


func test_p55_parts_keep_todays_sizes() -> void:
	for n: StringName in [&"torso", &"head", &"rack3", &"pad_hazard", &"shin"]:
		var court: Texture2D = load(ServoArt.path_at(n, 55.0))
		var today: Texture2D = load(ServoRig.ART % n)
		assert_eq(court.get_size(), today.get_size(), String(n))
