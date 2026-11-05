class_name ServoBodyView
extends BossView
## Servo in the arena (found by BossView.make at this path): three layers on the actors' layer,
## low to high: the ground (drop rings filling, blasts, CS crates, his own tells: the beam to the
## mark, the lock ring, the carpet lane, the bay-hop ring), the cutout rig (ServoRig, drone rack
## and all), and the air (the drones over their shadows). The framework's BossTellView still draws
## the dash lane and the beam line. Render only (SIM-03): every layer reads the fight each frame.

var _rig: ServoRig = ServoRig.new()
var _ground: Node2D = Node2D.new()
var _air: Node2D = Node2D.new()
var _paint: ServoDraw = ServoDraw.new()
var _frame: int = 0


func _ready() -> void:
	_paint.px = Ink.PX_PER_M
	_ground.z_index = -1
	_air.z_index = 2
	_rig.px = Ink.PX_PER_M
	_rig.fight = fight
	_rig.rack = moves().swarm.rack
	add_child(_ground)
	add_child(_rig)
	add_child(_air)
	var errs: Array[Error] = [
		_ground.draw.connect(_draw_ground),
		_air.draw.connect(_draw_air),
	]
	assert(errs.all(func(e: Error) -> bool: return e == OK))


func moves() -> ServoMoves:
	return fight.moves as ServoMoves


func _process(_delta: float) -> void:
	super._process(0.0)  # the base reads no delta (render only)
	if blood != null:  # the drones are robots too: oil, never red
		for b: Fighter in moves().bodies():
			blood.victims.robot_ids[b.id] = true
	_frame += 1
	_rig.pose(_frame)
	_ground.queue_redraw()
	_air.queue_redraw()


func _draw() -> void:
	pass  # the rig is Servo's body; the base disc stays off


func _draw_ground() -> void:
	_paint.parcels(_ground, moves().swarm)
	_paint.tells(_ground, fight, moves())


func _draw_air() -> void:
	_paint.drones(_air, moves().swarm)
