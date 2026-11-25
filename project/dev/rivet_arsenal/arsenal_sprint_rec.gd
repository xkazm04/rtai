extends "arsenal_turn_rec.gd"
## Dev-only sprint tour on the same live arena, pilot and camera as the turn kit: Rivet sprints
## once through the eight octants (E, SE, S, SW, W, NW, N, NE) so every run grid row shows in play.
const OCTANT_TICKS: int = 90
const STILL_TICK: int = 60
const CLIP_EVERY: int = 2
## The tour is an octagon of about this side (9.3 m/s for 1.5 s); start where it stays centred.
const SIDE_M: float = 14.0


## The full-tilt stick of `octant` (0 = screen east, +1 = 45 degrees toward the camera).
static func tour_input(octant: int) -> Vector2i:
	var m: Vector2 = Vector2.from_angle(octant * PI / 4.0) * TickInput.AXIS_MAX
	return Vector2i(roundi(m.x), roundi(m.y))


func _record() -> void:
	_pad.aim = Vector2.ZERO
	_pad.fire = false
	_pad.sprint = true
	var side: float = SIDE_M * CharacterRigs.PX_PER_M
	_arena.rivet.pos -= Vector2(0.5, 0.5 + sqrt(0.5)) * side
	for octant: int in 8:
		_pad.move = tour_input(octant)
		for tick: int in OCTANT_TICKS:
			await _step()
			if tick == STILL_TICK:
				_log_octant(octant)
				await _save("sprint_oct%d" % octant, true)
			if clip and tick % CLIP_EVERY == 0:
				await _save_full("clip_%04d" % _frame)
				_frame += 1
	_pad.sprint = false
	_pad.move = Vector2i.ZERO
	get_tree().quit(1 if _failed else 0)


func _log_octant(octant: int) -> void:
	var rig: CutRig = _game.cast.rigs.rig_for(_arena.rivet.id)
	var card: Sprite2D = rig.head_card
	var sheet: String = str(card.get_meta(RivetFrames.ON, "")).get_file() if card != null else ""
	var row: int = floori(card.frame / float(maxi(card.hframes, 1))) if card != null else -1
	Log.info(
		"turn",
		(
			"sprint octant %d: %.1f m/s, %s row %d"
			% [octant, rig.speed_now / CharacterRigs.PX_PER_M, sheet, row]
		)
	)


func _save_full(stem: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	if image.save_png(out_dir.path_join(stem + ".png")) != OK:
		Log.error("turn", "cannot write " + stem)
		_failed = true
