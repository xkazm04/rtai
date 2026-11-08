extends GutTest
## n9-handheld it6: the boss fight frames Rivet and the boss together (BossCam) on every handheld
## row (devices.json `boss_cam`); the desktop rows keep the camera on Rivet unless `--boss-cam`.

var _saved: DeviceProfile = null


func before_each() -> void:
	_saved = DeviceProfile._shared


func after_each() -> void:
	DeviceProfile._shared = _saved


func test_every_handheld_row_and_no_desktop_row_frames_the_fight() -> void:
	for id: String in DeviceProfile.of("").ids:
		var p: DeviceProfile = DeviceProfile.of(id)
		assert_eq(p.boss_cam, p.is_handheld(), id)


func test_wanted_follows_the_row() -> void:
	DeviceProfile._shared = DeviceProfile.of("desktop")
	assert_false(BossCam.wanted(), "the shipped desktop follows Rivet")
	DeviceProfile._shared = DeviceProfile.of("deck")
	assert_true(BossCam.wanted(), "the Deck row frames the fight")
	DeviceProfile._shared = DeviceProfile.of("switch_handheld")
	assert_true(BossCam.wanted(), "the Switch-class row too")
