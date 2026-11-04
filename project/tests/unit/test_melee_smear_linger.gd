extends GutTest
## combat-notes: a finished 2-tick cut's smear stays whole for MeleeSmearView.LINGER frames
## (fading), then wipes one angle a frame; a planted "wipe at once" (LINGER 0) is caught.


func _fan(cut_frames: int) -> MeleeSmearView:
	var v: MeleeSmearView = MeleeSmearView.new()
	add_child_autofree(v)
	for f: int in cut_frames:
		v.feed(Vector2.ZERO, 0.4 * f, 40.0, true)
	return v


func _frames_shown(v: MeleeSmearView, linger: int) -> int:
	# drives the view after the cut, counting frames with 2+ angles (a band is drawn)
	var shown: int = 0
	for f: int in 20:
		v.feed(Vector2.ZERO, 0.0, 40.0, false)
		if v.steps() >= 2:
			shown += 1
		elif f >= linger:
			break
	return shown


func test_a_short_cut_lingers_whole_then_wipes() -> void:
	var v: MeleeSmearView = _fan(3)
	assert_eq(v.steps(), 3, "a 3-frame cut holds 3 angles")
	for f: int in MeleeSmearView.LINGER:
		v.feed(Vector2.ZERO, 0.0, 40.0, false)
		assert_eq(v.steps(), 3, "whole through the linger (frame %d)" % f)
	assert_lt(v.fade(), 1.0, "it fades while it lingers")
	for f: int in 3:
		v.feed(Vector2.ZERO, 0.0, 40.0, false)
	assert_eq(v.steps(), 0, "then wiped one angle a frame")


func test_the_fan_shows_longer_than_the_cut() -> void:
	var shown: int = _frames_shown(_fan(3), MeleeSmearView.LINGER)
	assert_gte(shown, MeleeSmearView.LINGER + 1, "the fan outlasts the 2-tick cut")


func test_planted_instant_wipe_is_caught() -> void:
	# the iteration-3 behaviour (no linger): the fan is gone 2 frames after the cut
	var v: MeleeSmearView = _fan(3)
	var shown: int = 0
	for f: int in 20:
		if v.steps() > 0:
			v._angles.remove_at(0)  # the planted wipe
		if v.steps() >= 2:
			shown += 1
	assert_lt(shown, MeleeSmearView.LINGER + 1, "the planted wipe fails the linger check")


func test_a_new_cut_resets_the_fade() -> void:
	var v: MeleeSmearView = _fan(3)
	v.feed(Vector2.ZERO, 0.0, 40.0, false)
	v.feed(Vector2.ZERO, 0.2, 40.0, true)
	assert_eq(v.fade(), 1.0, "cutting again is full strength")
