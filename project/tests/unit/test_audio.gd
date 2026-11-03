extends GutTest
## features/audio: the cue table, the dice and the service culls (headless, dummy audio driver).


func _service() -> AudioService:
	var s: AudioService = AudioService.new(AudioTables.shipped(), 7)
	add_child_autofree(s)
	return s


func test_every_cue_has_its_files() -> void:
	var tables: AudioTables = AudioTables.shipped()
	assert_gt(tables.cues.size(), 15)
	var bank: SoundBank = SoundBank.new()
	assert_eq(bank.prewarm(tables.cues), _takes(tables))
	assert_eq(bank.missing.size(), 0, "missing: %s" % [bank.missing])


func test_dice_are_a_pure_function_of_the_seed() -> void:
	var a: AudioDice = AudioDice.new(5)
	var b: AudioDice = AudioDice.new(5)
	var c: AudioDice = AudioDice.new(6)
	var same: bool = true
	var differs: bool = false
	for i: int in 20:
		var x: float = a.unit()
		same = same and x == b.unit()
		differs = differs or x != c.unit()
	assert_true(same)
	assert_true(differs)


func test_a_take_never_repeats_back_to_back() -> void:
	var d: AudioDice = AudioDice.new(3)
	var last: int = -1
	for i: int in 200:
		var t: int = d.take(&"shot", 3)
		assert_ne(t, last)
		last = t


func test_a_cue_plays_then_cools_down() -> void:
	var s: AudioService = _service()
	assert_true(s.cue(&"shot", Vector2.ZERO, 100))
	assert_false(s.cue(&"shot", Vector2.ZERO, 100), "same tick: cooldown")
	var cooled: int = s.dropped.get(&"shot:cooldown", 0)
	assert_eq(cooled, 1)
	assert_true(s.cue(&"shot", Vector2.ZERO, 103))


func test_far_cues_are_culled_and_unknown_ids_ignored() -> void:
	var s: AudioService = _service()
	assert_false(s.cue(&"shot", Vector2(900.0, 0.0), 1))
	var far: int = s.dropped.get(&"shot:far", 0)
	assert_eq(far, 1)
	assert_false(s.cue(&"no_such_cue", Vector2.ZERO, 1))


func test_the_frame_cap_holds_back_a_riot() -> void:
	var s: AudioService = _service()
	var cap: int = int(s.tables.mix_float("voice_cap_per_frame", 4.0))
	var started: int = 0
	for id: StringName in [
		&"shot", &"shot_gloria", &"shot_assault_rifle", &"hit_flesh", &"hit_metal"
	]:
		if s.cue(id, Vector2.ZERO, 10):
			started += 1
	assert_eq(started, cap)


func test_the_buses_exist_from_the_mix_table() -> void:
	var s: AudioService = _service()
	for id: StringName in [&"sfx", &"voice", &"music", &"ui"]:
		assert_gt(AudioServer.get_bus_index(id), -1, String(id))
	assert_not_null(s)


func test_every_quest_line_has_a_voice_file() -> void:
	var audio: Dictionary[String, String] = QuestVoice.audio_fields(
		"res://quests/collect-call/quest.json"
	)
	assert_eq(audio.size(), 23)
	for path: String in audio.values():
		assert_true(ResourceLoader.exists(path), path)


func _takes(tables: AudioTables) -> int:
	var n: int = 0
	for c: AudioCue in tables.cues.values():
		n += c.takes
	return n


func test_distant_sfx_go_through_the_muffling_bus() -> void:
	var s: AudioService = _service()
	assert_true(s.cue(&"shot", Vector2(5.0, 0.0), 10))
	assert_eq(s.bus_in_use(&"shot"), &"sfx", "close: clear")
	assert_true(s.cue(&"shot_gloria", Vector2(40.0, 0.0), 10))
	assert_eq(s.bus_in_use(&"shot_gloria"), AudioService.FAR_BUS, "40 m: muffled")
	assert_true(AudioServer.get_bus_index(AudioService.FAR_BUS) >= 0)
	assert_gt(AudioServer.get_bus_effect_count(AudioServer.get_bus_index(AudioService.FAR_BUS)), 0)
