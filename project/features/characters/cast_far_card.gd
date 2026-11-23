class_name CastFarCard
extends Sprite2D
## Same five-facing projection and foot anchors as the full rig, after it leaves the rig pool.


func draw_pose(pose: CastCardPose, h: Fighter, moving: bool, tick: int) -> void:
	var path: String = pose.sheets.walk
	var row: int = StreetWalkerCards.stride_frame(pose.walked / StreetQuestCards.STRIDE_M, moving)
	var angle: float = h.facing.angle()
	var since_hit: float = (tick - h.hurt_tick) * SimClock.TICK_DT
	var blow: Vector2 = h.hurt_dir if h.hurt_dir != Vector2.ZERO else -h.facing
	if not h.alive():
		var progress: float = clampf(since_hit / pose.death_length, 0.0, 1.0)
		if progress < StreetWalkerFall.FALL_AT[1] and pose.opens_on_hit:
			path = pose.sheets.hit
			row = 0
			angle = (-blow).angle()
		else:
			path = pose.sheets.fall
			row = StreetWalkerFall.fall_frame(progress)
			angle = blow.angle()
	elif since_hit >= 0.0 and since_hit < pose.hit_hold:
		path = pose.sheets.hit
		row = 0
		angle = (-blow).angle()
	elif pose.attack >= 0:
		path = pose.sheets.attack
		row = pose.attack
	if texture == null or texture.resource_path != path:
		_configure(pose, path)
	var face: Vector2i = RigHeadCard.frame_of(angle)
	frame_coords = Vector2i(face.x, row)
	flip_h = face.y == 1
	position = h.pos * SimConst.PX_PER_M
	show()


func _configure(pose: CastCardPose, path: String) -> void:
	texture = StreetStrips.get_tex(path)
	centered = false
	hframes = RigHeadCard.FRAMES
	var fall: bool = path == pose.sheets.fall
	vframes = StreetWalkerCards.STRIDE_FRAMES
	if fall or path == pose.sheets.hit:
		vframes = StreetWalkerFall.FALL_FRAMES if fall else 1
	var cell: Vector2 = texture.get_size() / Vector2(hframes, vframes)
	offset = -cell * Vector2(0.5, 0.5 if fall else StreetWalkerCards.FOOT_Y)
	var art: String = ViewMode.shared().art
	var height: float = StreetWalkerCards.HEIGHT_BY_ART.get(art, StreetWalkerCards.HEIGHT_M)
	var k: float = StreetCrowdCards.body_scale(pose.actor_id) * pose.sheets.body_scale
	scale = (
		Vector2.ONE
		* (height * SimConst.PX_PER_M * k / (StreetWalkerFall.STILL_PX if fall else cell.y))
	)
