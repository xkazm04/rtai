extends Node2D
## Dev graybox of Servo's fight (docs/bosses/servo.md) to judge the READ at game zoom before the
## rig lands: the scanner beam (thin tracking, thick locked), the drop rings filling as parcels
## fall, the drones over their ink shadows, crates, the dash lane, the rack cells. Servo and Rivet
## are stand-in shapes here (Servo's cutout rig is the next item). A dodging stand-in walks off
## the mark at every lock (6.75 m/s, Rivet's walk). Frames go to out_dir; stats beside them.

const PX: float = 32.0
const RIVET_MPS: float = 6.75
const RIVET_R: float = 0.6
const DODGE_M: float = 5.0
const HALF_M: float = 14.0

var out_dir: String = "user://servo_fight"
var ticks: int = 1200
var every: int = 2
var zoom: float = 1.0
var dodge: bool = true
## true = the stand-in shapes (the before), false = ServoRig on the cut parts.
var graybox: bool = false
var fight: BossFight = null
var rivet: Vector2 = Vector2(-8.0, 0.0)
var stats: Dictionary = {}
var _goal: Vector2 = Vector2(-8.0, 0.0)
var _side: float = 1.0
var _was_locked: bool = false
var _tick: int = 0
var _taken: float = 0.0
var _frame_no: int = 0
var _cam: Camera2D = Camera2D.new()
var _paint: ServoFightDraw = ServoFightDraw.new()
var _rig: ServoRig = null
var _over: Node2D = Node2D.new()


func _ready() -> void:
	if not graybox:
		_rig = ServoRig.new()
		_rig.fight = fight
		_rig.rack = moves().swarm.rack
		add_child(_rig)
	add_child(_over)
	@warning_ignore("return_value_discarded")
	_over.draw.connect(_draw_over)
	add_child(_cam)
	_cam.zoom = Vector2(zoom, zoom)
	_cam.make_current()


func moves() -> ServoMoves:
	return fight.moves as ServoMoves


## Runs the fight to `ticks`, saving a frame every `every` ticks; returns the exit code.
func shoot() -> int:
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	var ok: bool = true
	while _tick < ticks and fight.state != BossFight.State.DEFEATED:
		for i: int in every:
			_step()
		_cam.position = (rivet + fight.body.pos) * 0.5 * PX
		queue_redraw()
		_over.queue_redraw()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		ok = _save_frame() and ok
	stats["ticks"] = _tick
	stats["frames"] = _frame_no
	stats["rivet_damage_taken"] = _taken
	stats["marks"] = moves().marks_made
	stats["blast_hits"] = moves().blast_hits
	stats["drones_launched"] = moves().swarm.launched_total
	return 0 if ok else 1


func _step() -> void:
	if dodge and fight.locked and not _was_locked:
		var perp: Vector2 = fight.aim.orthogonal() * _side
		_side = -_side
		_goal = (rivet + perp * DODGE_M).clamp(Vector2(-HALF_M, -HALF_M), Vector2(HALF_M, HALF_M))
	_was_locked = fight.locked
	rivet = rivet.move_toward(_goal, RIVET_MPS * SimClock.TICK_DT)
	_taken += fight.step(_tick, rivet, RIVET_R)
	_taken += moves().tick(fight, rivet, RIVET_R)
	if _rig != null:
		_rig.pose(_tick)
	_tick += 1


func _draw() -> void:
	_paint.ground(self, HALF_M)
	_paint.parcels(self, moves().swarm)
	_paint.tells(self, fight, moves())
	if graybox:
		_paint.servo(self, fight, moves().swarm.rack)


## Above the rig: Rivet's stand-in, the drones and the HUD line.
func _draw_over() -> void:
	_paint.rivet(_over, rivet, RIVET_R)
	_paint.drones(_over, moves().swarm)
	var a: String = String(fight.attack.id) if fight.attack != null else "-"
	var line: String = (
		"servo dev view  phase %d  %s %s  hp %.0f  rivet took %.0f  t %.1f s"
		% [
			fight.phase + 1,
			a,
			BossFight.State.keys()[fight.state],
			fight.body.hp,
			_taken,
			_tick / 60.0
		]
	)
	var top_left: Vector2 = _cam.position - get_viewport_rect().size * 0.5 / zoom
	_over.draw_string(
		ThemeDB.fallback_font, top_left + Vector2(8, 20) / zoom, line, 0, -1, int(14 / zoom)
	)


func _save_frame() -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	_frame_no += 1
	return img.save_png(out_dir.path_join("f%05d.png" % _frame_no)) == OK
