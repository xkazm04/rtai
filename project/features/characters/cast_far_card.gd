class_name CastFarCard
extends Sprite2D
## Same five-facing projection and foot anchors as the full rig, after it leaves the rig pool.

var _contact: StreetCopWalk.Contact
var _base_scale: Vector2


## The hit flash of the rig it stands in for (rig.is_tinted()): tint material while lit, raw after.
func sync_tint(on: bool) -> void:
	var want: Material = tint_of(on)
	if material != want:
		material = want


## The one hit-flash rule every card view shares: the tint material while lit, null (raw) after.
static func tint_of(on: bool) -> Material:
	if on:
		return PartMaterials.get_mat(PartMaterials.PartKind.PART, true, 0)
	return null


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
	if path.get_file() == StreetMulroneyHit.HIT and h.alive():
		StreetMulroneyHit.anchor(self)
	_place(h.pos * SimConst.PX_PER_M, face, moving)
	show()


func _place(at: Vector2, face: Vector2i, moving: bool) -> void:
	if _contact != null and moving:
		transform = _contact.place(at, face, _base_scale, SimConst.PX_PER_M)
		frame_coords.y = posmod(_contact.cell, vframes)
	else:
		if _contact != null:
			_contact.reset()
		transform = Transform2D(0.0, _base_scale, 0.0, at)


func _configure(pose: CastCardPose, path: String) -> void:
	texture = StreetStrips.get_tex(path)
	centered = false
	hframes = RigHeadCard.FRAMES
	var fall: bool = path == pose.sheets.fall
	vframes = StreetCopWalk.rows_of(path)
	_contact = null
	if CastCards.anchored(path):
		_contact = StreetCopWalk.Contact.new()
		_contact.configure(path)
	if fall or path == pose.sheets.hit:
		vframes = StreetWalkerFall.FALL_FRAMES if fall else 1
	var cell: Vector2 = texture.get_size() / Vector2(hframes, vframes)
	var seated: bool = _contact != null or CastCards.padded(path)
	var foot_y: float = StreetCopWalk.FOOT_Y if seated else StreetWalkerCards.FOOT_Y
	offset = -cell * Vector2(0.5, 0.5 if fall else foot_y)
	var art: String = ViewMode.shared().art
	var height: float = StreetWalkerCards.HEIGHT_BY_ART.get(art, StreetWalkerCards.HEIGHT_M)
	var k: float = pose.sheets.scale_of(pose.actor_id)
	if _contact != null or CastCards.padded(path):
		k *= CastCardKinds.cell_ratio(path, StreetCopWalk.CELL_RATIO)
	_base_scale = (
		Vector2.ONE
		* (height * SimConst.PX_PER_M * k / (StreetWalkerFall.STILL_PX if fall else cell.y))
	)
