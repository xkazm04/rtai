class_name KerfSpectral
extends Node2D
## The cutter head around the flight body's centre. Its host supplies ground facing and tick state.

enum Mood { POISED, CRUISE, LUNGE }

const LUNGE_TICKS: int = 8
const TUCK_TICKS: int = 4
const AIM_LIMIT: float = deg_to_rad(25.0)
const AIM_TICKS: int = 4
const ARCH_M: float = 0.62
const ARM_M: float = 0.82
const KNUCKLE_M: Vector2 = Vector2(-0.34, 0.54)
const ART: String = "res://features/souls/art/kerf/spectral/"
## Cell pixels per world metre, calibrated against the poised overhead profile at 64 px/m.
const GRID_PPM_70: float = 69.0
const GRID_PPM_55: float = 72.0

var beams: KerfBeams = KerfBeams.new()
var _top: Node2D = Node2D.new()
var _arch: Sprite2D
var _arch_scale: Vector2
var _arms: Array[Sprite2D] = []
var _tuck: float = 0.0
var _last_pose_tick: int = -1
var _echoes: KerfEcho
var _yaw: float = 0.0
var _yaw_start: float = 0.0
var _yaw_goal: float = 0.0
var _aim_tick: int = 0
var _sight_enabled: bool = HitFeel.feel_flag() != "off"
var _lens: Sprite2D
var _tilted: Sprite2D = Sprite2D.new()
var _tilted_eye: KerfTiltEye = KerfTiltEye.new()
var _sheet: GhostSheet
var _art: String = "?"
var _hull_m: float
var _eyes: Array[Texture2D] = []


func _init(hull_m: float) -> void:
	_hull_m = hull_m


static func mood(speed_mps: float, ticks_since_blink: int, _charges: int) -> int:
	if ticks_since_blink >= 0 and ticks_since_blink < LUNGE_TICKS:
		return Mood.LUNGE
	return Mood.CRUISE if speed_mps > 3.0 else Mood.POISED


func _ready() -> void:
	add_child(beams)
	add_child(_top)
	@warning_ignore("return_value_discarded")
	_part("hull", _hull_m, Vector2.ZERO)
	_arch = _part("cables", ARCH_M, Vector2(-0.2, 0.0))
	_arch.rotation = -PI / 2.0
	_arch_scale = Vector2.ONE * ARCH_M * SimConst.PX_PER_M / _arch.texture.get_height()
	for side: int in [-1, 1]:
		var arm: Sprite2D = _part("arm", ARM_M, KNUCKLE_M * Vector2(1, side))
		# Rotate about the round knuckle near the left edge of the cutout.
		arm.offset.x = arm.texture.get_width() * 0.42
		_arms.append(arm)
	# Nose socket (281,154) in the centred 375 x 313 hull, with a 62 px bezel.
	_lens = _part("lens_open", _hull_m * 62.0 / 375.0, Vector2(93.5, -2.5) * _hull_m / 375.0)
	_eyes = [_lens.texture, load(ART + "lens_half.png"), load(ART + "lens_slit.png")]
	_tilted.name = &"ghost_drawn"
	_tilted.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(_tilted)
	_tilted_eye.texture = _eyes[Mood.CRUISE]
	_tilted.add_child(_tilted_eye)
	_tilted_eye.hide()


func live(
	stage: CollectCallStage, flight: GhostFlight, speed: float, facing: float, oct: int
) -> void:
	var k: KerfStage = stage.pilot.kerf
	var since: int = -1 if k.trail_tick.is_empty() else stage.tick - k.trail_tick[-1]
	beams.tick = stage.tick
	beams.charges = k.charges
	beams.recharge = 0.0 if since == 0 else k.recharge_k()
	var target: Fighter
	if _sight_enabled and k.on() and k.charges > 0 and k.num(&"sight_k") > 0.0:
		if stage.pilot.ghosts.settled_in(KerfStage.GHOST):
			target = k.pick(stage, k.sight_aim)
	var at: Vector2 = stage.arena.rivet.pos
	var yaw: float = (
		angle_difference(facing, at.direction_to(target.pos).angle()) if target else 0.0
	)
	_aim(clampf(yaw, -AIM_LIMIT, AIM_LIMIT), stage.tick)
	position = Vector2.ZERO
	if since >= 0 and since < KerfSlot.RETURN_TICKS + TUCK_TICKS:
		var shift: Vector2 = (KerfSlot.end_m(k, -1, since) - k.trail_to[-1]) * SimConst.PX_PER_M
		if flight != null:
			# The flight spring sees a teleport as velocity. Keep its lift, cancel its blink lag.
			var back: float = smoothstep(
				KerfSlot.RETURN_TICKS, KerfSlot.RETURN_TICKS + TUCK_TICKS, since
			)
			shift -= flight.hover.lag_px * (1.0 - back)
		global_position += shift
	pose(speed, since, target != null, facing, oct)
	if not beams.reduced_motion:
		if _echoes == null:
			_echoes = KerfEcho.new()
			add_child(_echoes)
			_echoes.bind(_top, _tilted, _tilted_eye)
		_echoes.step(stage)
	elif _echoes != null:
		_echoes.queue_free()
		_echoes = null


func _aim(goal: float, tick: int) -> void:
	if not is_equal_approx(goal, _yaw_goal):
		_yaw_start = _yaw
		_yaw_goal = goal
		_aim_tick = tick - 1
	_yaw = lerpf(_yaw_start, _yaw_goal, smoothstep(0, AIM_TICKS, tick - _aim_tick))


func pose(speed_mps: float, since: int, locked: bool, facing: float, oct: int) -> void:
	var vm: ViewMode = ViewMode.shared()
	if vm.art != _art:
		_art = vm.art
		_sheet = null
		if _art in ["p70", "p55"]:
			_sheet = GhostSheet.of(GhostDrawn.path_of(_art, "kerf", "hover"), 3)
			if _sheet == null:
				Log.error("kerf", "missing %s hover grid" % _art)
		_tilted.visible = _sheet != null
		_top.visible = _sheet == null
	var col: int = mood(speed_mps, since, beams.charges)
	_fold(col)
	beams.fast = clampf(speed_mps / 12.0, 0.0, 1.0)
	beams.tail_x = -0.55 * SimConst.PX_PER_M * absf(global_scale.x)
	beams.global_transform = Transform2D(
		facing + (_yaw if _sheet == null else 0.0), global_position
	)
	beams.queue_redraw()
	if _sheet != null:
		_sheet.show(_tilted, oct, col)
		_tilted_eye.place(_tilted, _art, locked)
		_tilted.offset = Vector2.ZERO  # GhostSheet normally anchors at the feet.
		var density: float = GRID_PPM_70 if _art == "p70" else GRID_PPM_55
		# The cruise drawing already lengthens a little as the top-view arms fold back.
		var s: float = (
			SimConst.PX_PER_M * absf(global_scale.x) * lerpf(1, 1.05, beams.fast) / density
		)
		_tilted.global_transform = Transform2D(
			0.0, Vector2(s, s / vm.ground_k()), 0.0, global_position
		)
		beams.attach_to_cell(_tilted)
	else:
		_top.global_rotation = facing + _yaw
		_top.scale = Vector2.ONE.lerp(Vector2(1.08, 0.86), beams.fast)
		var eye: int = Mood.LUNGE if beams.charges == 0 else col
		_lens.texture = _eyes[Mood.CRUISE if eye == Mood.POISED and locked else eye]


func _fold(col: int) -> void:
	var elapsed: int = maxi(0, beams.tick - _last_pose_tick)
	_last_pose_tick = beams.tick
	var target: float = 0.0 if col == Mood.POISED else 1.0
	_tuck = 1.0 if col == Mood.LUNGE else move_toward(_tuck, target, float(elapsed) / TUCK_TICKS)
	_arch.scale = _arch_scale * Vector2(lerpf(1.0, 0.9, _tuck), lerpf(1.15, 0.85, _tuck))
	var angle: float = deg_to_rad(lerpf(14.0, 3.0, _tuck))
	_arms[0].rotation = PI + angle
	_arms[1].rotation = PI - angle


func _part(part: String, width_m: float, at_m: Vector2) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = load(ART + part + ".png") as Texture2D
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.scale = Vector2.ONE * width_m * SimConst.PX_PER_M / sprite.texture.get_width()
	sprite.position = at_m * SimConst.PX_PER_M
	_top.add_child(sprite)
	return sprite
