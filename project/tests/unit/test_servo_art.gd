extends GutTest
## d8 bosses: Servo's parts are picked by the view row's pitch; straight down today's art.


func test_top_loads_todays_parts() -> void:
	assert_eq(ServoArt.path_at(&"torso", 90.0), ServoRig.ART % &"torso")


func test_pitch_55_loads_the_p55_parts() -> void:
	assert_eq(ServoArt.path_at(&"torso", 55.0), "res://features/bosses/servo/art/p55/torso.png")


func test_a_part_without_p55_art_keeps_todays() -> void:
	assert_eq(ServoArt.path_at(&"crate", 55.0), ServoRig.ART % &"crate")
	assert_eq(ServoArt.path_at(&"torso", 70.0), ServoRig.ART % &"torso")


func test_p55_parts_keep_todays_sizes() -> void:
	for n: StringName in [&"torso", &"head", &"rack3", &"pad_hazard", &"shin", &"drone"]:
		var court: Texture2D = load(ServoArt.path_at(n, 55.0))
		var today: Texture2D = load(ServoRig.ART % n)
		assert_eq(court.get_size(), today.get_size(), String(n))


func test_servo_stands_only_under_a_view_with_lift() -> void:
	var was: ViewMode = ViewMode._shared
	var n: Node2D = add_child_autofree(Node2D.new())
	ViewMode._shared = ViewMode.of("top")
	assert_eq(ServoArt.stand_m(n, Vector2(3.0, 4.0), 48.0), Vector2.ZERO)
	ViewMode._shared = ViewMode.of("tilt")
	var up: Vector2 = ServoArt.stand_m(n, Vector2(3.0, 4.0), 48.0)
	ViewMode._shared = was
	assert_lt(up.y, 0.0, "the upper body draws up the screen")
	assert_almost_eq(up.x, 0.0, 0.001)


func test_a_row_with_art_falls_back_to_the_p55_parts() -> void:
	var p55: String = "res://features/bosses/servo/art/p55/torso.png"
	assert_eq(ServoArt.path_at(&"torso", 70.0, true), p55)
	assert_eq(ServoArt.path_at(&"torso", 90.0, true), ServoRig.ART % &"torso")
	assert_eq(ServoArt.path_at(&"crate", 70.0, true), ServoRig.ART % &"crate")


func test_parts_follow_the_art_key_not_the_live_pitch() -> void:
	var was: ViewMode = ViewMode._shared
	var vm: ViewMode = ViewMode.of("combo")
	ViewMode._shared = vm
	vm.art = "p55"
	vm.pitch_deg = 66.0  # mid-ease: the key already swapped
	var mid: String = ServoArt.path(&"torso")
	ViewMode._shared = ViewMode.of("top")
	var top: String = ServoArt.path(&"torso")
	ViewMode._shared = was
	assert_eq(mid, "res://features/bosses/servo/art/p55/torso.png")
	assert_eq(top, ServoRig.ART % &"torso")


func test_the_rig_reloads_its_parts_on_an_art_change() -> void:
	var was: ViewMode = ViewMode._shared
	var parts: ServoParts = ServoParts.new()
	ViewMode._shared = ViewMode.of("top")
	var first: bool = parts.sync()
	var again: bool = parts.sync()
	var top: String = parts.tex[&"torso"].resource_path
	ViewMode._shared = ViewMode.of("tilt")
	var swapped: bool = parts.sync()
	var tilt: String = parts.tex[&"torso"].resource_path
	ViewMode._shared = was
	assert_true(first, "the first sync loads")
	assert_false(again, "the same key keeps the textures")
	assert_true(swapped, "a new key reloads")
	assert_eq(top, ServoRig.ART % &"torso")
	assert_eq(tilt, "res://features/bosses/servo/art/p55/torso.png")
	assert_eq(parts.tex.size(), ServoParts.NAMES.size())
