extends "res://dev/rivet_arsenal/arsenal_turn_rec.gd"
## n31 ground: per gait (move = the full stick unsprinted, the keyboard move; sprint) Rivet tours
## the 8 octants (E, SE, S, ...); from CAPTURE_FROM on each tick is rendered full (`_a`), without
## the drop shadows (`_b`) and without Rivet (`_c`), cropped around the rig ground point;
## frames.jsonl logs the sim ground point and the code contact ellipse (crop px).
const OCTANT_TICKS: int = 120
const CAPTURE_FROM: int = 40
const CROP: Vector2i = Vector2i(256, 320)
const FOOT_AT: Vector2i = Vector2i(128, 256)
const SIDE_M: Dictionary = {"move": 10.0, "sprint": 14.0}

var gaits: PackedStringArray = PackedStringArray()
var _log: FileAccess


func _record() -> void:
	_log = FileAccess.open(out_dir.path_join("frames.jsonl"), FileAccess.WRITE)
	_pad.aim = Vector2.ZERO
	_pad.fire = false
	var centre: Vector2 = _arena.rivet.pos
	for gait: String in gaits:
		_pad.sprint = gait == "sprint"
		var side: float = SIDE_M[gait] * CharacterRigs.PX_PER_M
		_arena.rivet.pos = centre - Vector2(0.5, 0.5 + sqrt(0.5)) * side
		for octant: int in 8:
			_pad.move = _tour_input(octant)
			for tick: int in OCTANT_TICKS:
				await _step()
				if tick >= CAPTURE_FROM:
					await _capture("%s_o%d_t%03d" % [gait, octant, tick], gait, octant, tick)
	_log.close()
	get_tree().quit(1 if _failed else 0)


func _capture(stem: String, gait: String, octant: int, tick: int) -> void:
	var rig: CutRig = _game.cast.rigs.rig_for(_arena.rivet.id)
	var shadows: Array[Node] = _shadow_nodes()
	var origin: Vector2i = Vector2i.ZERO
	for pass_id: String in ["a", "b", "c"]:
		for s: Node in shadows:
			(s as CanvasItem).visible = pass_id == "a"
		# ArenaRobotRigs sets rig.visible every frame: hide it below the node, on the server.
		RenderingServer.canvas_item_set_visible(rig.get_canvas_item(), pass_id != "c")
		await RenderingServer.frame_post_draw
		var image: Image = get_viewport().get_texture().get_image()
		if pass_id == "a":
			origin = Vector2i(_screen(rig.global_position, image)) - FOOT_AT
		var crop: Image = image.get_region(Rect2i(origin, CROP))
		if crop.save_png(out_dir.path_join("%s_%s.png" % [stem, pass_id])) != OK:
			_failed = true
	for s: Node in shadows:
		(s as CanvasItem).visible = true
	RenderingServer.canvas_item_set_visible(rig.get_canvas_item(), true)
	_write_meta(rig, stem, [gait, octant, tick], origin)


func _write_meta(rig: CutRig, stem: String, key: Array, origin: Vector2i) -> void:
	var image_size: Vector2 = Vector2(get_viewport().get_texture().get_size())
	var ground: Vector2 = _screen_sized(rig.global_position, image_size) - Vector2(origin)
	var hip: float = RigCastShadows.hip_px(rig)
	var view: ViewMode = ViewMode.shared()
	var at: Vector2 = (
		rig.global_position + view.cast_dir() * hip * RigCastShadows.CONTACT_SLIDE_HIPS
	)
	var one_m: Vector2 = rig.global_position + Vector2(CharacterRigs.PX_PER_M, 0.0)
	var ppm: float = (
		_screen_sized(one_m, image_size).x - _screen_sized(rig.global_position, image_size).x
	)
	var card: Sprite2D = rig.head_card
	var card_up: float = 0.0
	if card != null and card.visible:
		card_up = (
			_screen_sized(rig.global_position, image_size).y
			- _screen_sized(card.global_position, image_size).y
		)
	var r: float = hip * RigCastShadows.CONTACT_R_HIPS * ppm / CharacterRigs.PX_PER_M
	var row: Dictionary = {
		"stem": stem,
		"gait": key[0],
		"octant": key[1],
		"tick": key[2],
		"ground_x": ground.x,
		"ground_y": ground.y,
		"screen_ppm": ppm,
		"code_cx": _screen_sized(at, image_size).x - origin.x,
		"code_cy": _screen_sized(at, image_size).y - origin.y,
		"code_rx": r,
		"code_ry": r * RigCastShadows.CONTACT_FLAT,
		"card_up": card_up,
		"phase": rig.phase,
		"speed": rig.speed_now / CharacterRigs.PX_PER_M,
		"frame": card.frame if card != null else -1,
	}
	if not _log.store_line(JSON.stringify(row)):
		_failed = true


func _shadow_nodes() -> Array[Node]:
	var out: Array[Node] = []
	for n: Node in _game.find_children("*", "Node2D", true, false):
		if n is RigCastShadows:
			out.append(n)
	return out


## The full-tilt stick of `octant` (as arsenal_sprint_rec.gd's tour).
static func _tour_input(octant: int) -> Vector2i:
	var m: Vector2 = Vector2.from_angle(octant * PI / 4.0) * TickInput.AXIS_MAX
	return Vector2i(roundi(m.x), roundi(m.y))


func _screen(at: Vector2, image: Image) -> Vector2:
	return _screen_sized(at, Vector2(image.get_size()))


func _screen_sized(at: Vector2, image_size: Vector2) -> Vector2:
	var scale_px: Vector2 = image_size / get_viewport().get_visible_rect().size
	var rig: CutRig = _game.cast.rigs.rig_for(_arena.rivet.id)
	return (rig.get_canvas_transform() * at) * scale_px
