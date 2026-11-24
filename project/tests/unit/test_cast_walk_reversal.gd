extends GutTest


## Keep aiming down-right while changing travel, as in the sergeant's fight at tick 276.
func test_aimed_reversal_stays_within_twelve_screen_pixels() -> void:
	for path: String in [StreetMulroneyAnchors.EIGHT, StreetCopWalk.EIGHT]:
		for pitch: String in ["p70", "p55"]:
			var worst: float = _reversal(pitch.path_join(path))
			assert_lte(worst, 12.0, "%s/%s reversal %.3f px" % [pitch, path, worst])


func _reversal(path: String) -> float:
	var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
	contact.configure(path)
	var at: Vector2 = Vector2.ZERO
	var previous: Vector2 = Vector2.INF
	var worst: float = 0.0
	var scale_px: Vector2 = Vector2(0.269, 0.253)
	for tick: int in 100:
		var heading: Vector2 = Vector2(1.0, 0.18) if tick < 40 else Vector2(-0.8, 0.9)
		at += heading.normalized() * 3.2 * 32.0 * SimClock.TICK_DT
		if tick == 40:
			contact.reset()
		var xf: Transform2D = contact.place(at, Vector2i(1, 0), scale_px, 32.0)
		var ink: Vector4 = contact.registered.marks[8 + posmod(contact.cell, 8)]
		var body: Vector2 = xf * Vector2(ink.z, ink.w)
		if previous.is_finite() and tick != 40:
			worst = maxf(worst, body.distance_to(previous))
		previous = body
	return worst
