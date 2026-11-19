class_name WalkSlideTile
extends Node2D
## A tracking camera on one right-profile take. World metre marks sit below the boot pad.
## The camera transform belongs to its CanvasLayer and never changes the rig's world position.

const SIZE: Vector2i = Vector2i(256, 224)
const FEET_Y: int = 202

var speed: float
var armed: bool
var rect: Rect2i
var columns: Array[int] = []
var rig: CutRig = CutRig.new()
var _motion: PlayerMotion = PlayerMotion.shipped()
var _actions: PlayerActions = PlayerActions.shipped()
var _command: PlayerCommand = PlayerCommand.new()
var _camera: CanvasLayer
var _zoom: Vector2


func setup(camera: CanvasLayer, origin: Vector2i, mps: float, pistol: bool, ppm: int) -> void:
	_camera = camera
	rect = Rect2i(origin, SIZE)
	speed = mps
	armed = pistol
	_zoom = ViewMode.shared().zoom_of(float(ppm) / CharacterRigs.PX_PER_M)
	_command.move = Vector2.RIGHT
	_command.aim = Vector2.RIGHT
	add_child(rig)
	rig.setup(RivetPlan.build(), RigVariant.rivet())
	rig.snap_facing(0.0)
	rig.gun_out = armed
	RivetFrames.publish(rig, &"pistol" if armed else &"", null)


func advance(matched: bool) -> bool:
	var displacement: Vector2 = _motion.step(_command, speed, _actions) * CharacterRigs.PX_PER_M
	var phase: float = _next_phase() if matched else -1.0
	rig.position += displacement
	rig.vel_in = _motion.velocity() * CharacterRigs.PX_PER_M
	rig.face_to = _motion.facing().angle()
	rig.drive(SimClock.TICK_DT)
	if phase >= 0.0:
		# drive recorded today's position. A second public placement reads zero new distance.
		rig.set_meta(RivetWalk.META_PH, phase)
		RivetFrames.place(rig, rig.head_card)
	var anchor: Vector2 = Vector2(rect.position) + Vector2(SIZE.x / 2, FEET_Y)
	_camera.transform = Transform2D(0.0, _zoom, 0.0, anchor - (rig.position * _zoom).round())
	queue_redraw()
	return not matched or phase >= 0.0


## The film enables this only at constant velocity. Read the previous drawing's support boot,
## as phase_of does before it selects the next cell. The mover and the camera never see phase.
func _next_phase() -> float:
	var card: Sprite2D = rig.head_card
	var length: float = StrideMatch.profile_cycle(card, card.global_scale.x, 0.0)
	if length <= 0.0:
		return -1.0
	var run: bool = RivetWalk.is_run(str(card.get_meta(RivetFrames.ON)))
	var cap: float = RivetWalk.MAX_RUN_CYCLES_S if run else RivetWalk.MAX_CYCLES_S
	var hz: float = StrideMatch.cadence(
		_motion.velocity().length() * CharacterRigs.PX_PER_M, length, cap
	)
	var previous: float = rig.get_meta(RivetWalk.META_PH, 0.0)
	return fposmod(previous + hz * SimClock.TICK_DT, 1.0)


func record_column() -> bool:
	var card: Sprite2D = rig.head_card
	if not RivetWalk.is_grid(card) or not is_equal_approx(_motion.velocity().x, speed):
		Log.warn(
			"walk-slide",
			"expected stride grid at %.1f m/s, got %.3f" % [speed, _motion.velocity().x]
		)
		return false
	var path: String = str(card.get_meta(RivetFrames.ON))
	if RivetWalk.is_armed(card) != armed or card.frame_coords.y != RivetFrames.BASE_OCT[0]:
		return false
	if RivetWalk.is_run(path) != (speed > RivetWalk.RUN_FROM_MPS):
		return false
	columns.append(card.frame_coords.x)
	return true


func describe() -> Dictionary:
	var card: Sprite2D = rig.head_card
	var path: String = str(card.get_meta(RivetFrames.ON))
	return {
		"speed": speed,
		"weapon": "pistol" if armed else "bare",
		"rect": [rect.position.x, rect.position.y, SIZE.x, SIZE.y],
		"strip": path,
		"run": RivetWalk.is_run(path),
		"cols": card.hframes,
		"columns": columns,
	}


func _draw() -> void:
	var px: float = CharacterRigs.PX_PER_M
	var half: float = (SIZE.x * 0.5 - 2.0) / _zoom.x
	var y: float = (SIZE.y - FEET_Y - 8.0) / _zoom.y
	for metre: int in range(
		ceili((rig.position.x - half) / px), floori((rig.position.x + half) / px) + 1
	):
		draw_rect(Rect2(Vector2(metre * px, y), Vector2(2.0, 6.0) / _zoom), Color.WHITE)
