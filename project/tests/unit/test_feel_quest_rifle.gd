extends GutTest
## n7-ranged (it26): Rivet's picked-up quest rifle (combat.json's hyphenated assault-rifle) finds
## the assault_rifle weapons row: a 2 px hit kick (the light class's 1 px did not read), a fire
## kick per round, no stop and no shake; --feel=off still means nothing.


func test_the_hyphenated_id_finds_its_row() -> void:
	var feel: HitFeel = HitFeel.shipped()
	var row: Dictionary = feel.camera_row(&"assault-rifle", &"light", false)
	var px: float = row["kick_px"]
	assert_eq(px, 2.0, "the rifle's own kick, not the light class's 1 px")
	var stop: StringName = row["hitstop"]
	var shake: StringName = row["shake"]
	assert_eq(stop, &"", "no stop: a burst would stutter")
	assert_eq(shake, &"", "no shake")
	assert_gt(feel.fire_row(&"assault-rifle").x, 0.0, "a recoil kick per round")
	var same: Dictionary = feel.camera_row(&"assault_rifle", &"light", false)
	assert_eq(row.hash(), same.hash(), "one row, two spellings")


func test_a_light_gun_keeps_the_class_kick() -> void:
	var row: Dictionary = HitFeel.shipped().camera_row(&"nail_gun", &"light", false)
	var px: float = row["kick_px"]
	assert_eq(px, 1.0)


func test_off_means_no_kick() -> void:
	var cam: FeelCam = FeelCam.attach(null, SimClock.new(), HitFeel.shipped())
	cam.feel.enabled = false
	assert_eq(cam.hit(&"assault-rifle", &"light", Vector2.RIGHT, false, 100), 0)
	assert_eq(cam.kicks, 0)
	assert_eq(cam.offset_px(100, 1.0), Vector2.ZERO)
