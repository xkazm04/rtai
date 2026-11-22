class_name RivetFramesGrip
extends RefCounted
## A borrowed pose has an empty claw. Its live held sprite uses
## the painted palm in the current cell, since the hidden cutout hand follows a different gait.

const RIM_HIDDEN: StringName = &"rivet_walk_rim_hidden"
const FINGERS: StringName = &"stride_fingers"
const FRAME: StringName = &"stride_fingers_frame"
## A small patch of the painted palm wraps over the grip. UVs come from this exact gait cell.
const PATCH: PackedVector2Array = [
	Vector2(-0.032, 0.000),
	Vector2(-0.016, -0.014),
	Vector2(0.014, -0.012),
	Vector2(0.027, 0.005),
	Vector2(0.010, 0.025),
	Vector2(-0.022, 0.019)
]


## The held view invokes its usual articulated carry for every pose outside a bare movement grid.
static func place(rig: CutRig, part: Sprite2D, place_long: Callable) -> void:
	var card: Sprite2D = rig.head_card
	var on_grid: bool = RivetWalk.is_grid(card) and card.has_meta(RivetFrames.ON)
	on_grid = on_grid and not RivetWalk.is_armed(card)
	_rim(part, on_grid)
	if not on_grid:
		place_long.call(rig)
		return
	rig.held_shift = Vector2.ZERO
	var path: String = str(card.get_meta(RivetFrames.ON))
	var grip: Vector2 = palm(path, card.frame_coords, card.hframes)
	var cell: Vector2 = card.texture.get_size() / Vector2(card.hframes, card.vframes)
	part.global_position = card.to_global(card.offset + cell * grip)
	if rig.aiming:
		part.global_rotation = (rig.aim_at - rig.global_position).angle()
	_fingers(card, part, grip, cell)


static func _fingers(card: Sprite2D, part: Sprite2D, grip: Vector2, cell: Vector2) -> void:
	var fingers: Polygon2D = part.get_meta(FINGERS) if part.has_meta(FINGERS) else null
	if fingers == null:
		fingers = Polygon2D.new()
		fingers.name = FINGERS
		fingers.polygon = PATCH
		part.add_child(fingers)
		part.set_meta(FINGERS, fingers)
	if fingers.texture != card.texture or fingers.get_meta(FRAME, -1) != card.frame:
		fingers.texture = card.texture
		fingers.set_meta(FRAME, card.frame)
		var at: Vector2 = (Vector2(card.frame_coords) + grip) * cell
		var uv: PackedVector2Array = PackedVector2Array()
		for point: Vector2 in PATCH:
			@warning_ignore("return_value_discarded")
			uv.append(at + point * cell)
		fingers.uv = uv
	var t: Transform2D = card.global_transform.translated_local(card.offset + grip * cell)
	fingers.global_transform = t.scaled_local(cell)


## The drawn fingers in the currently displayed grid cell.
static func palm(path: String, frame: Vector2i, cols: int) -> Vector2:
	return RivetFramesGrids.palm(
		path.get_base_dir().get_file(), RivetWalk.is_run(path), frame, cols
	)


## The painted card has an ink edge. Match it while the part is over that card, and restore
## the articulated rig's paper rim when the view changes. Only touch the children on a swap.
static func _rim(part: Sprite2D, hidden: bool) -> void:
	if hidden == part.has_meta(RIM_HIDDEN):
		return
	part.use_parent_material = hidden  # The whole painted figure and its carried part draw raw.
	if hidden:
		part.set_meta(RIM_HIDDEN, true)
	else:
		part.remove_meta(RIM_HIDDEN)
	for child: Node in part.get_children():
		if child is Sprite2D and String(child.name).begins_with("Rim"):
			(child as Sprite2D).visible = not hidden
		elif child is Polygon2D and child.name == FINGERS:
			(child as Polygon2D).visible = hidden
