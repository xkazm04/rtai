class_name ComboClipRun
extends Node
## rivet-motion: the claw combo against the melee dummy line. Rivet walks up to each of three
## dummies (ped, cop, ped) and mashes melee; MeleeCombo (rivet_melee.json timing) drives the rig's
## timed strike (claw, torch arm, two-hand slam) and the hit test on each landing tick: a hit
## flinches the dummy, the finisher knocks it back and down. Logs each landing tick.

const PX: float = 32.0
const GROUND: String = "res://features/city/art/ground/"
const DUMMY_GAP_M: float = 3.0
const STAND_OFF_M: float = 1.15
const WALK_MPS: float = 2.0
const ARMS: Array[int] = [BodyPlan.L, BodyPlan.R, 2]
const KNOCK_TICKS: int = 10
const DOWN_TICKS: int = 70
## The impact (placeholder until gunplay's shared hit-feel module lands, REQUEST 3 -> gunplay):
## ticks both bodies freeze on a landing hit, and the screen shake's amplitude in px, per hit.
const HITSTOP_TICKS: Array[int] = [3, 3, 7]
const SHAKE_PX: Array[float] = [2.0, 2.5, 7.0]
## The cop (dummy 1) dies on the finisher; the peds are knocked down and get up.
const DIES: Array[bool] = [false, true, false]

var zoom: float = 1.5
var _world: CanvasLayer = CanvasLayer.new()
var _post: CanvasLayer = CanvasLayer.new()
var _actors: CanvasLayer = CanvasLayer.new()
var _look: ShaderMaterial = ShaderMaterial.new()
var _rivet: CutRig = CutRig.new()
var _dummies: Array[CutRig] = []
var _knock: Array[Vector2] = []
var _down: PackedInt32Array = PackedInt32Array()
var _combo: MeleeCombo = MeleeCombo.new(MeleeTable.shipped())
var _tick: int = 0
var _seen_starts: int = 0
var _freeze: int = 0
var _shake: float = 0.0
var _origin: Vector2 = Vector2.ZERO


func _ready() -> void:
	for i: int in 3:
		var l: CanvasLayer = [_world, _post, _actors][i]
		l.layer = i
		add_child(l)
	for x: int in range(-3, 3):
		for y: int in range(-2, 2):
			_tile(Vector2(x * 8 + 4, y * 8 + 4) * PX)
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_look.shader = load("res://assets/shaders/look_d4.gdshader") as Shader
	_look.set_shader_parameter(&"grime_tex", GrimeLattice.texture())
	rect.material = _look
	_post.add_child(rect)
	var plans: Array[BodyPlan] = [HumanPlan.ped(), HumanPlan.cop(), HumanPlan.ped()]
	var looks: Array[int] = [0, 5, 2]
	for i: int in 3:
		var d: CutRig = CutRig.new()
		_actors.add_child(d)
		d.setup(plans[i], RigVariant.crowd(looks[i]))
		d.position = Vector2((i - 1) * DUMMY_GAP_M, -STAND_OFF_M) * PX
		d.snap_facing(PI * 0.5)
		d.face_to = PI * 0.5
		_dummies.append(d)
		_knock.append(Vector2.ZERO)
		@warning_ignore("return_value_discarded")
		_down.append(0)
	_actors.add_child(_rivet)
	_rivet.setup(RivetPlan.build(), RigVariant.rivet())
	_rivet.position = Vector2(-DUMMY_GAP_M * 1.7, 0.0) * PX
	_rivet.snap_facing(-PI * 0.5)
	var view: Vector2 = get_viewport().get_visible_rect().size
	var xf: Transform2D = Transform2D(0.0, Vector2(zoom, zoom), 0.0, view * 0.5)
	_world.transform = xf
	_actors.transform = xf
	_origin = xf.origin
	_look.set_shader_parameter("world_px", -view * 0.5)


func play() -> int:
	for i: int in 3:
		var to: Vector2 = Vector2((i - 1) * DUMMY_GAP_M, 0.0) * PX
		while _rivet.position.distance_to(to) > 1.0:
			var v: Vector2 = (to - _rivet.position).limit_length(WALK_MPS * PX)
			await _step(v, false)
		for t: int in 90:
			await _step(Vector2.ZERO, t % 4 == 0 and t < 40)
	for t: int in 40:
		await _step(Vector2.ZERO, false)
	return 0


func _step(vel: Vector2, press: bool) -> void:
	_tick += 1
	_apply_shake()
	if _freeze > 0:
		_freeze -= 1
		await get_tree().process_frame
		return
	_rivet.position += vel * SimClock.TICK_DT
	_rivet.vel_in = vel
	_rivet.face_to = -PI * 0.5
	if press:
		_combo.press()
	_combo.step()
	if _combo.starts != _seen_starts and _combo.hit_index != 0:
		_seen_starts = _combo.starts
		_start_strike()
	if _combo.lands():
		_land(_combo.current())
	_rivet.drive(SimClock.TICK_DT)
	for i: int in _dummies.size():
		_dummy(i)
	await get_tree().process_frame


func _start_strike() -> void:
	var h: MeleeHit = _combo.current()
	var dt: float = SimClock.TICK_DT
	var arm: int = ARMS[mini(_combo.hit_index - 1, ARMS.size() - 1)]
	_rivet.clips.strike(_rivet, h.windup * dt, h.active * dt, h.recovery * dt, arm)


func _land(h: MeleeHit) -> void:
	Log.info("combo", "tick %d: %s lands" % [_tick, h.id])
	for i: int in _dummies.size():
		var d: CutRig = _dummies[i]
		var to: Vector2 = (d.position - _rivet.position) / PX
		if to.length() > h.reach_m + 0.45 or to.normalized().dot(_rivet.fwd()) < h.cone_dot:
			continue
		d.clips.hit(d, to.normalized())
		var k: int = mini(_combo.hit_index - 1, HITSTOP_TICKS.size() - 1)
		_freeze = HITSTOP_TICKS[k]
		_shake = SHAKE_PX[k]
		if h.knockback_m > 1.0:
			_knock[i] = to.normalized() * h.knockback_m * PX / KNOCK_TICKS
			_down[i] = DOWN_TICKS
			if DIES[i]:
				d.clips.die(false)


func _dummy(i: int) -> void:
	var d: CutRig = _dummies[i]
	if _knock[i] != Vector2.ZERO:
		d.position += _knock[i]
		_knock[i] *= 0.82
		if _knock[i].length() < 0.3:
			_knock[i] = Vector2.ZERO
	_down[i] = maxi(_down[i] - 1, 0)
	d.clips.down = _down[i] > 0
	d.vel_in = Vector2.ZERO
	d.drive(SimClock.TICK_DT)


## A decaying shake on the world and the actors (a deterministic wobble, no RNG).
func _apply_shake() -> void:
	var off: Vector2 = Vector2(sin(_tick * 7.3), cos(_tick * 5.1)) * _shake
	_world.transform.origin = _origin + off
	_actors.transform.origin = _origin + off
	_shake = _shake * 0.72 if _shake > 0.2 else 0.0


func _tile(at: Vector2) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(GROUND + "sidewalk_tone.png") as Texture2D
	s.scale = Vector2.ONE * 8.0 * PX / s.texture.get_width()
	s.position = at
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)
