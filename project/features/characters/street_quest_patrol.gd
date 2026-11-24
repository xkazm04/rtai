class_name StreetQuestPatrol
extends StreetCopWalk.Contact
## Per-patrol render sample shared by the quest facing matcher and the immediate-mode card.

var motion_tick: int = -1
var speed_mps: float = 0.0


func sample_speed(distance_px: float, ppm: float) -> void:
	var tick: int = Engine.get_physics_frames()
	if distance_px > StreetQuestCards.MOVING_PX:
		var elapsed: int = maxi(1, tick - motion_tick) if motion_tick >= 0 else 1
		speed_mps = distance_px / (ppm * elapsed * SimClock.TICK_DT)
		motion_tick = tick
	elif motion_tick < 0:
		motion_tick = tick


func draw(canvas: CanvasItem, at: Vector2, heading: Vector2, ppm: float, tint: Color) -> bool:
	var view: ViewMode = ViewMode.shared()
	var strip: String = StreetQuestCards.PATROL_WALK[view.art]
	if StreetCopWalk.PLANTED == StreetCopWalk.EIGHT:
		strip = strip.get_base_dir().path_join(StreetCopWalk.strip_for(speed_mps))
	configure(strip)
	var tex: Texture2D = StreetQuestCards._load(strip)
	var size_px: Vector2 = tex.get_size() / Vector2(RigHeadCard.FRAMES, drawings)
	var stand: Texture2D = StreetQuestCards._load(StreetQuestCards.PATROL[view.art])
	var s: float = (
		StreetQuestCards.WIDTH_M * ppm * stand.get_height() * RigHeadCard.FRAMES / stand.get_width()
	)
	s *= StreetCopWalk.CELL_RATIO / size_px.y
	var f: Vector2i = RigHeadCard.frame_of(heading.angle())
	var xf: Transform2D = place(at, f, Vector2(s, s / view.ground_k()), ppm)
	if f.y == 1:
		xf.x = -xf.x
	canvas.draw_set_transform_matrix(xf)
	var src: Rect2 = Rect2(Vector2(f.x, posmod(cell, drawings)) * size_px, size_px)
	canvas.draw_texture_rect_region(
		tex, Rect2(-size_px * Vector2(0.5, StreetCopWalk.FOOT_Y), size_px), src, tint
	)
	canvas.draw_set_transform(Vector2.ZERO)
	return true
