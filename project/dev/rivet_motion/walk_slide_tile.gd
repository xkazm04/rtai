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


func advance() -> void:
	var displacement: Vector2 = _motion.step(_command, speed, _actions) * CharacterRigs.PX_PER_M
	rig.position += displacement
	rig.vel_in = _motion.velocity() * CharacterRigs.PX_PER_M
	rig.face_to = _motion.facing().angle()
	rig.drive(SimClock.TICK_DT)
	var anchor: Vector2 = Vector2(rect.position) + Vector2(SIZE.x / 2, FEET_Y)
	_camera.transform = Transform2D(0.0, _zoom, 0.0, anchor - (rig.position * _zoom).round())
	queue_redraw()


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
