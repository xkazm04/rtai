extends GutTest
## n7-melee: the ghost attacks' wind-ups and whiffs play their own sound once, on the frame the
## stage shows them: the press tell once per armed slam, the landing thud only when the slam hit no
## body (a body hit plays HitCues' ghost_slam), the seize clunk once per seized car, Ohm's bolt
## crackle only when it struck no body; every cue has a row in audio_cues.json.

var _ids: Array[StringName] = []
var _at: Array[Vector2] = []


func _record(id: StringName, at: Vector2, tick: int) -> bool:
	assert_gte(tick, 0)
	_ids.append(id)
	_at.append(at)
	return true


func _cues() -> TellCues:
	_ids.clear()
	_at.clear()
	return TellCues.make(_record)


func test_the_press_tell_plays_once_per_armed_slam_where_it_will_land() -> void:
	var t: TellCues = _cues()
	t.press(false, Vector2.ZERO, 1)
	for tick: int in range(2, 30):
		t.press(true, Vector2(2.0, 0.0), tick)
	t.press(false, Vector2.ZERO, 31)
	t.press(true, Vector2(0.0, 2.0), 60)
	assert_eq(_ids, [TellCues.PRESS_TELL, TellCues.PRESS_TELL] as Array[StringName])
	assert_eq(_at[0], Vector2(2.0, 0.0), "where the press will land")


func test_a_slam_that_hits_no_body_lands_with_a_thud() -> void:
	var t: TellCues = _cues()
	t.land(-1, 0, Vector2.ZERO, 1)
	assert_eq(t.played, 0, "no slam yet")
	t.land(40, 0, Vector2(3.0, 1.0), 40)
	t.land(40, 0, Vector2(3.0, 1.0), 41)
	assert_eq(_ids, [TellCues.PRESS_LAND] as Array[StringName], "once per landing")
	assert_eq(_at[0], Vector2(3.0, 1.0))


func test_a_slam_that_hits_a_body_leaves_the_sound_to_the_hit() -> void:
	var t: TellCues = _cues()
	t.land(-1, 0, Vector2.ZERO, 1)
	t.land(40, 2, Vector2(3.0, 1.0), 40)
	assert_eq(t.played, 0, "HitCues plays ghost_slam for the bodies")
	t.land(90, 2, Vector2(1.0, 1.0), 90)
	assert_eq(_ids, [TellCues.PRESS_LAND] as Array[StringName], "the next slam whiffs")


func test_the_seize_clunk_plays_once_per_seized_car() -> void:
	var t: TellCues = _cues()
	for tick: int in 10:
		t.seize(0, Vector2.ZERO, tick)
	t.seize(1, Vector2(5.0, 0.0), 10)
	t.seize(1, Vector2(5.0, 0.0), 11)
	assert_eq(_ids, [TellCues.SEIZE] as Array[StringName])
	assert_eq(_at[0], Vector2(5.0, 0.0), "at the car")


func test_a_bolt_that_strikes_no_body_crackles_where_it_ends() -> void:
	var t: TellCues = _cues()
	t.bolt(-1, 0, Vector2.ZERO, 1)
	t.bolt(20, 0, Vector2(6.0, 0.0), 20)
	t.bolt(20, 0, Vector2(6.0, 0.0), 21)
	t.bolt(50, 3, Vector2(4.0, 0.0), 50)
	assert_eq(_ids, [TellCues.BOLT] as Array[StringName], "the body bolt is HitCues' to play")
	assert_eq(_at[0], Vector2(6.0, 0.0), "at the burned car")


func test_every_tell_cue_has_a_row() -> void:
	var tables: AudioTables = AudioTables.shipped()
	for id: StringName in [TellCues.PRESS_TELL, TellCues.PRESS_LAND, TellCues.SEIZE, TellCues.BOLT]:
		assert_not_null(tables.cue(id), "audio_cues.json row %s" % id)
