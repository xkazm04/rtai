class_name ServoBodyView
extends BossView
## Servo in the arena (found by BossView.make at this path): three layers on the actors' layer,
## low to high: the ground (the depot's bays and conveyor, drop rings filling, blasts, CS crates,
## his own tells: the beam to the mark, the lock ring, the carpet lane, the bay-hop ring), the
## cutout rig (ServoRig, drone rack and all), and the air (the drones over their shadows). The
## framework's BossTellView still draws the dash lane and the beam line. Render only (SIM-03):
## every layer reads the fight each frame.

var _rig: ServoRig = ServoRig.new()
var _ground: Node2D = Node2D.new()
var _air: Node2D = Node2D.new()
var _paint: ServoDraw = ServoDraw.new()
var _depot: ServoDepotDraw = ServoDepotDraw.new()
var _cut: ServoCut = ServoCut.new()
var _frame: int = 0
## Seconds the conveyor has run (it starts with rush hour, phase 2); one frame = one tick here.
var _belt_s: float = 0.0


func _ready() -> void:
	_paint.px = Ink.PX_PER_M
	_depot.px = Ink.PX_PER_M
	_cut.px = Ink.PX_PER_M
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
	if arena != null:  # Kerf's cut drones fall in two halves (ServoCut)
		errs.append(arena.kill_landed.connect(_on_kill))
	assert(errs.all(func(e: Error) -> bool: return e == OK))


func moves() -> ServoMoves:
	return fight.moves as ServoMoves


func _process(_delta: float) -> void:
	super._process(0.0)  # the base reads no delta (render only)
	if blood != null:  # the drones are robots too: oil, never red
		for b: Fighter in moves().bodies():
			blood.victims.robot_ids[b.id] = true
	_frame += 1
	if fight.phase >= 1 and fight.state != BossFight.State.DEFEATED:
		_belt_s += SimClock.TICK_DT
	_rig.pose(_frame)
	_ground.queue_redraw()
	_air.queue_redraw()


func _draw() -> void:
	pass  # the rig is Servo's body; the base disc stays off


func _draw_ground() -> void:
	if moves().swarm.tuning != null:
		_depot.draw(_ground, moves().swarm.tuning, moves().depot_origin, _belt_s)
	_paint.parcels(_ground, moves().swarm)
	_paint.tells(_ground, fight, moves())


func _draw_air() -> void:
	_cut.draw(_air, _paint.drone_tex, ServoDraw.DRONE_K, _frame)
	_paint.drones(_air, moves().swarm)


func _on_kill(
	victim: Fighter, weapon: StringName, dir: Vector2, at: Vector2, _k: StringName
) -> void:
	if weapon == ServoCut.WEAPON and victim.machine and moves().drone_bodies.owns(victim.id):
		_cut.take(victim.pos if at == Vector2.ZERO else at, dir, _frame)
