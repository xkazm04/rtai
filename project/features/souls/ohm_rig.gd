class_name OhmRig
extends Node2D
## Ohm's elder welder rig. World pixels, +x forward and +y right.
## The legacy cane plants ahead and slides back as the shell shuffles over it.

const ART: String = "res://features/souls/art/ohm/"
const PX_PER_M: float = 32.0
const TEAL: Color = Color(0.18, 0.77, 0.71)
const SHELL_M: float = 0.8
const BEARD_M: float = 0.5
const GLOW_M: float = 2.6
const GLOW_A: float = 0.5
const BEARD_AT: Vector2 = Vector2(0.42, 0.0)
const HOSE_M: float = 0.34
const HOSE_AT: Vector2 = Vector2(-0.36, 0.0)
const FOOT_M: float = 0.3
const HIP: Vector2 = Vector2(-0.04, 0.18)
const SHOULDER: Vector2 = Vector2(0.1, 0.26)
const UPPER_M: float = 0.36
const FORE_M: float = 0.54
const ARM_THICK_M: float = 0.24
const GUARD_HAND: Vector2 = Vector2(0.5, -0.12)
const CANE_AHEAD_M: float = 0.7
const CANE_SIDE_M: float = 0.5
const STRIDE_M: float = 0.7
const SWING_K: float = 0.3
const FOOT_REACH_M: float = 0.1
const STEPS_PER_CYCLE: float = 2.0
const LEAN: float = deg_to_rad(6.0)
const BREATH_HZ: float = 0.6
const BREATH_K: float = 0.025
const KICK_M: float = 0.2
const KICK_S: float = 0.25
const RECOIL_M: float = 0.1
const KICK_TWIST: float = deg_to_rad(16.0)
const CARD_M: float = 1.2
const CARD_ANCHOR: float = 0.8
const CARD_HALO_A: float = 0.45
const CYCLE_CELL: float = 126.0  # n11 it10: the profile row's stance foot, 15.7 cell px a frame

var ohm: OhmStage
var unfold: float = 1.0
## OhmStage.bolts, fed by the host: a rise kicks the guard arm (the first sight only arms it).
var bolts: int = 0
var reduced_motion: bool = false
var speed_mps: float = 0.0
var phase: float = 0.0
var drawn: GhostDrawn = GhostDrawn.new("ohm", 1.55, CYCLE_CELL, 180.0)  # n11: ohm_walk8.png
var _spirit: OhmSpirit
var _spectral: OhmDrawn
var _t: float = 0.0
var _seen_bolts: int = -1
var _kick: float = 0.0  # 1 at the bolt, falling to 0 over KICK_S
var _body: Node2D = Node2D.new()
var _feet: Array[Sprite2D] = []
var _arms: Array[Sprite2D] = []  # [upper_r, fore_r, upper_l, fore_l]
var _hide: Array[Sprite2D] = []
var _card: GhostCard = GhostCard.new("ohm", CARD_M, CARD_ANCHOR)
var _all: Array[Sprite2D] = []


func _init() -> void:
	if GhostLook.spectral(OhmStage.ID):
		_spectral = OhmDrawn.new()
		drawn._instant_windup = 0  # Spectral jars telegraph the instant cast.


func _process(_delta: float) -> void:
	if ohm != null:
		_spectral.charge.step(ohm, drawn._tick)
	if visible:
		pose()


func _ready() -> void:
	set_process(_spectral != null)
	process_priority = 21  # GhostFormView finishes feeding the instant cast at priority 20.
	if _spectral != null:
		add_child(_body)
		_spirit = OhmSpirit.new()
		_body.add_child(_spirit)
		pose()
		return
	add_child(GhostRim.soft_glow(TEAL, GLOW_A, GLOW_M * PX_PER_M))  # teal belongs to the souls
	add_child(_body)
	for side: int in 2:
		var foot: Sprite2D = _part("foot", FOOT_M)
		foot.flip_v = side == 1
		_feet.append(foot)
	var hose: Sprite2D = _part("hose", HOSE_M)
	hose.position = HOSE_AT * PX_PER_M
	var beard: Sprite2D = _part("beard", BEARD_M)
	beard.position = BEARD_AT * PX_PER_M
	for side: int in 2:
		for n: String in ["upper", "fore"]:
			var s: Sprite2D = _limb(n)
			s.flip_v = side == 1
			GhostRim.limb(s)
			_arms.append(s)
	var shell: Sprite2D = _part("shell", SHELL_M)  # added last: over the arms' roots
	GhostRim.body(shell)
	shell.add_child(OhmSeams.new())  # the soul seams and lenses, bold enough for 32 px/m
	_hide = [shell, beard, hose]
	_all.assign(_hide + _feet + _arms)
	_card.halo = Color(TEAL, CARD_HALO_A)
	pose()


func advance(dt: float) -> void:
	_t = fmod(_t + dt, 1000.0)
	if _spectral != null:
		return
	if _seen_bolts >= 0 and bolts > _seen_bolts:
		_kick = 1.0
	_seen_bolts = bolts
	if _kick <= 0.0:  # the cane stays planted through the kick
		phase = fmod(phase + speed_mps * dt / STRIDE_M, 1.0)
	_kick = maxf(0.0, _kick - dt / KICK_S)
	pose()


func kick_m() -> float:
	if _kick <= 0.0:
		return 0.0
	var t: float = 1.0 - _kick
	var curve: float = t / 0.2 if t < 0.2 else 1.0 - smoothstep(0.2, 1.0, t)
	return KICK_M * curve * (0.5 if reduced_motion else 1.0)


## The cane tip in the body frame (metres): planted ahead, sliding back while the body passes it,
## swung forward over the last SWING_K of the cycle.
static func cane_tip(p: float) -> Vector2:
	var plant: float = 1.0 - SWING_K
	var back: float = CANE_AHEAD_M - STRIDE_M
	var x: float = (
		lerpf(CANE_AHEAD_M, back, p / plant)
		if p < plant
		else lerpf(back, CANE_AHEAD_M, smoothstep(0.0, 1.0, (p - plant) / SWING_K))
	)
	return Vector2(x, CANE_SIDE_M)


func pose() -> void:
	var u: float = smoothstep(0.0, 1.0, unfold)
	var breath: float = 1.0 + BREATH_K * sin(TAU * BREATH_HZ * _t)
	_body.scale = Vector2.ONE * breath * lerpf(0.7, 1.0, u)
	if _spectral != null:
		_body.visible = not _spectral.step(self, drawn, _body.scale.x)
		if _body.visible:
			_spirit.pose(drawn, _spectral.charge, ohm, reduced_motion)
		return
	var kick: float = kick_m() / KICK_M
	_body.rotation = LEAN * sin(TAU * phase) * u + KICK_TWIST * kick
	_body.position = Vector2(-RECOIL_M * kick * PX_PER_M, 0.0)
	for side: int in 2:
		var m: float = 1.0 if side == 0 else -1.0
		var step: float = sin(TAU * (phase * STEPS_PER_CYCLE + side * 0.5))
		_feet[side].position = Vector2(HIP.x + step * FOOT_REACH_M * u, HIP.y * m) * PX_PER_M
	var sh_r: Vector2 = SHOULDER
	_arm(0, sh_r, sh_r.lerp(cane_tip(phase), u), 1.0)
	var sh_l: Vector2 = Vector2(SHOULDER.x, -SHOULDER.y)
	var guard: Vector2 = GUARD_HAND + Vector2(kick_m() + RECOIL_M * kick, 0.0)
	_arm(2, sh_l, sh_l.lerp(guard, u), -1.0)
	var carded: bool = not drawn.step(self, _all, PX_PER_M, _body.scale.x)
	_card.set_shown(carded)
	if carded:
		_card.size_k = _body.scale.x
		_card.step(self, _hide, _body.position, PX_PER_M)


func _arm(i: int, a: Vector2, b: Vector2, m: float) -> void:
	var elbow: Vector2 = OhmArm.joint(a, b, UPPER_M, FORE_M, m)
	_place(_arms[i], a, elbow)
	_place(_arms[i + 1], elbow, b)


func _place(s: Sprite2D, a: Vector2, b: Vector2) -> void:
	GhostRim.place_limb(s, a * PX_PER_M, b * PX_PER_M, ARM_THICK_M * PX_PER_M)


func _limb(name: String) -> Sprite2D:
	var s: Sprite2D = _sprite(name)
	s.centered = false
	s.offset = Vector2(0.0, -s.texture.get_height() * 0.5)
	return s


func _part(name: String, length_m: float) -> Sprite2D:
	var s: Sprite2D = _sprite(name)
	var long_px: int = maxi(s.texture.get_width(), s.texture.get_height())
	s.scale = Vector2.ONE * length_m * PX_PER_M / float(long_px)
	return s


func _sprite(name: String) -> Sprite2D:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(ART + name + ".png") as Texture2D
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_body.add_child(s)
	return s
