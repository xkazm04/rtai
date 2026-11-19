class_name CoverView
extends Node
## A tucked footprint from above and a crouch about the planted boots under a tilt.
## Equipped cards carry their own gun. Separate weapon and magazine nodes share the transform.

const ACTIVE: StringName = &"rivet_cover_view"

var _rigs: CharacterRigs
var _cover: PlayerCover
var _weight: float
var _tick: int
var _followers: Array[Node2D] = []
var _upper: CoverUpperCard


static func feed(rigs: CharacterRigs, motion: PlayerMotion, tick: int) -> void:
	var host: CoverView = rigs.get_meta(ACTIVE, null) if rigs.has_meta(ACTIVE) else null
	var cover: PlayerCover = motion.cover if motion != null else null
	MotionRigPose.publish(rigs, MoveCells.COVER, cover_cell(cover))
	if cover == null or cover.spot == null:
		if host != null:
			host._release(motion, tick)
		return
	if host == null:
		host = CoverView.new()
		host._rigs = rigs
		host.process_priority = 102
		rigs.add_child(host)
		rigs.set_meta(ACTIVE, host)
		host._place.call_deferred()
	host._cover = cover
	host._tick = tick
	host._weight = cover.crouch_weight()


static func cover_cell(cover: PlayerCover) -> StringName:
	if cover == null or cover.spot == null:
		return &""
	return MoveCells.cover_cell(
		cover.phase == PlayerCover.Phase.IN, cover.spot.low, cover.drawn_cells
	)


static func scale_for(crouch_scale_y: float, weight: float, flat: bool) -> Vector2:
	var height: float = lerpf(1.0, crouch_scale_y, weight)
	return Vector2(height if flat else 1.0, height)


func _release(motion: PlayerMotion, tick: int) -> void:
	# A toggle exits the sim immediately. Finish rising over leave_ticks on the render side.
	var elapsed: int = maxi(tick - _tick, 0)
	_tick = tick
	_weight = move_toward(_weight, 0.0, float(elapsed) / _cover.leave_ticks)
	if motion != null and motion.phase == PlayerMotion.Phase.FREE and _weight > 0.0:
		return
	var rig: CutRig = _rigs.rig_for(_rigs.feed.ids[0])
	if rig != null:
		MotionRigPose.place(rig, Transform2D.IDENTITY)
	for follower: Node2D in _followers:
		RenderingServer.canvas_item_set_transform(follower.get_canvas_item(), follower.transform)
	if is_instance_valid(_upper):
		_upper.hide()
		_upper.queue_free()
	_rigs.remove_meta(ACTIVE)
	set_process(false)
	queue_free()


func _process(_delta: float) -> void:
	_place()


func _place() -> void:
	if is_queued_for_deletion():
		return
	var rig: CutRig = _rigs.rig_for(_rigs.feed.ids[0])
	if rig == null:
		return
	var view: ViewMode = ViewMode.shared()
	var k: Vector2 = scale_for(_cover.crouch_scale_y, _weight, view.is_flat())
	if MoveCells.shows(rig.head_card):
		k = Vector2.ONE
	var pose: Transform2D = Transform2D(0.0, k, 0.0, Vector2.ZERO)
	MotionRigPose.place(rig, pose)
	if _followers.is_empty():
		for sibling: Node in _rigs.get_parent().get_children():
			if RigDepthSort.rig_of(sibling) == rig:
				_followers.append(sibling as Node2D)
	var around_feet: Transform2D = (
		rig.global_transform * pose * rig.global_transform.affine_inverse()
	)
	for f: Node2D in _followers:
		var parent_inv: Transform2D = f.transform * f.global_transform.affine_inverse()
		var draw: Transform2D = parent_inv * around_feet * f.global_transform
		RenderingServer.canvas_item_set_transform(f.get_canvas_item(), draw)
	var behind: bool = _cover.spot != null and _cover.spot.normal == Vector2.UP
	if view.occlude and behind and _cover.blocks_fire() and RivetFrames.drawn(rig):
		_upper = CoverUpperCard.show_above(
			rig.head_card, _upper if is_instance_valid(_upper) else null
		)
	elif is_instance_valid(_upper):
		_upper.hide()
