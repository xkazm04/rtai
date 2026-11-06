extends GutTest
## n7-ranged (it25): Rivet's picked-up assault rifle (quest 1, no weapons row) voices his own shot,
## not the contractors' shot_assault_rifle; a contractor's rifle and Gloria keep theirs.


func _shot(from_rivet: bool, weapon: StringName) -> Shot:
	var s: Shot = Shot.new()
	s.from_rivet = from_rivet
	s.weapon = weapon
	return s


func test_rivets_rifle_has_its_own_cue() -> void:
	var cue: StringName = StageAudio.shot_cue(_shot(true, &"assault-rifle"))
	assert_eq(cue, StageAudio.RIVET_RIFLE_CUE)
	assert_ne(cue, &"shot_assault_rifle", "not the contractors' shot")


func test_a_contractors_rifle_and_gloria_keep_theirs() -> void:
	assert_eq(StageAudio.shot_cue(_shot(false, &"assault-rifle")), &"shot_assault_rifle")
	assert_eq(StageAudio.shot_cue(_shot(true, &"gloria")), &"shot_gloria")


func test_the_cue_exists_lower_than_the_contractors() -> void:
	var tables: AudioTables = AudioTables.shipped()
	var mine: AudioCue = tables.cue(StageAudio.RIVET_RIFLE_CUE)
	var theirs: AudioCue = tables.cue(&"shot_assault_rifle")
	assert_not_null(mine, "the cue row exists")
	if mine == null:
		return
	assert_eq(mine.sound, theirs.sound, "the same rifle sample")
	assert_lt(mine.pitch, theirs.pitch, "a step lower, so it stands out of theirs")
