extends GutTest
## Which shipped sheets take the padded 256/192 cell ratio.


func test_contractor_attack_and_hit_are_padded_like_his_walk() -> void:
	for pitch: String in ["p55", "p70"]:
		var dir: String = "res://features/characters/art/view/%s/" % pitch
		assert_true(CastCardKinds.padded(dir + "contractor_attack.png"), pitch)
		assert_true(CastCardKinds.padded(dir + "contractor_cast_hit.png"), pitch)


func test_contractor_fall_and_the_quest_sheets_stay_unpadded() -> void:
	for pitch: String in ["p55", "p70"]:
		var dir: String = "res://features/characters/art/view/%s/" % pitch
		assert_false(CastCardKinds.padded(dir + "contractor_cast_fall.png"), pitch)
		assert_false(CastCardKinds.padded(dir + "contractor_hit.png"), pitch)
		assert_false(CastCardKinds.padded(dir + "contractor_fall.png"), pitch)
		assert_false(CastCardKinds.padded(dir + "contractor_card.png"), pitch)


func test_warden_and_gunner_padding_does_not_move() -> void:
	assert_true(CastCardKinds.padded("res://x/robot_gunner_attack.png"))
	assert_true(CastCardKinds.padded("res://x/appliance_warden_cast_hit.png"))
	assert_false(CastCardKinds.padded("res://x/robot_gunner_fall.png"))
	assert_false(CastCardKinds.padded("res://x/appliance_warden_fall.png"))
