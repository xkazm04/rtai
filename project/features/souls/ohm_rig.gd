class_name OhmRig
extends Node2D
## Ohm, the elder spot-welder (TARGETS.md ghost_ohm_mage.jpg, its top-down drawing), as a cutout rig
## from straight above: the domed riveted shell with its goggles at the front, the cable beard
## spilling forward under them, the copper hose loop on its back, two stubby feet under the shell,
## and two long arms ending in copper electrode fingers. Parts are the Codex sheet cut by
## tools/art/ghost_parts.py (art/ohm/, raw art like Kerf's). Units: world px at PX_PER_M; +x =
## facing (set rotation = facing angle).
## Gait "cane": the right arm is the cane, planted ahead and left behind as the body shuffles past
## it, then swung forward again; the feet patter under the shell, the body leans onto the cane. The
## left arm holds its electrodes forward (the bolt's hand). unfold (0..1) is the transformation:
## 0 = limbs folded under the shell.

const ART: String = "res://features/souls/art/ohm/"
const PX_PER_M: float = 32.0
const TEAL: Color = Color(0.18, 0.77, 0.71)
## Part lengths (metres, the art's long side) and their spots in the body frame (x forward,
## y right).
const SHELL_M: float = 0.8
const BEARD_M: float = 0.5
const BEARD_AT: Vector2 = Vector2(0.42, 0.0)
const HOSE_M: float = 0.34
const HOSE_AT: Vector2 = Vector2(-0.36, 0.0)
const FOOT_M: float = 0.3
const HIP: Vector2 = Vector2(-0.04, 0.18)
const SHOULDER: Vector2 = Vector2(0.1, 0.26)
const UPPER_M: float = 0.36
const FORE_M: float = 0.54
const ARM_THICK_M: float = 0.24
## The guard arm (left): its electrode tips held at the bolt's hands (OhmStage.HANDS_M ahead, a
## little to the left), the elbow cocked out to the side as in the target.
const GUARD_HAND: Vector2 = Vector2(0.5, -0.12)
## The cane arm (right): how far ahead it plants and how far back it trails (metres, body frame).
const CANE_AHEAD_M: float = 0.7
const CANE_SIDE_M: float = 0.5
## One cane cycle covers STRIDE_M of ground; the swing takes the last SWING_K of it.
const STRIDE_M: float = 0.7
const SWING_K: float = 0.3
## Feet: fore/aft reach (metres) and steps per cane cycle; the lean onto the cane (radians).
const FOOT_REACH_M: float = 0.1
const STEPS_PER_CYCLE: float = 2.0
const LEAN: float = deg_to_rad(6.0)
## Idle breath (Hz, scale amplitude).
const BREATH_HZ: float = 0.6
const BREATH_K: float = 0.025

var unfold: float = 1.0
## Ground speed (m/s), fed by the host each tick.
var speed_mps: float = 0.0
## 0..1 through the cane cycle (advances with ground covered, not time).
var phase: float = 0.0
var _t: float = 0.0
var _body: Node2D = Node2D.new()
var _feet: Array[Sprite2D] = []
## [upper_r, fore_r, upper_l, fore_l]
var _arms: Array[Sprite2D] = []


func _ready() -> void:
	add_child(_soft_glow())
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
	pose()


## One step of `dt` seconds (the host passes SimClock.TICK_DT per sim tick).
func advance(dt: float) -> void:
	_t = fmod(_t + dt, 1000.0)
	phase = fmod(phase + speed_mps * dt / STRIDE_M, 1.0)
	pose()


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


## Lays the body out for the current phase, breath and unfold.
func pose() -> void:
	var u: float = smoothstep(0.0, 1.0, unfold)
	var breath: float = 1.0 + BREATH_K * sin(TAU * BREATH_HZ * _t)
	_body.scale = Vector2.ONE * breath * lerpf(0.7, 1.0, u)
	_body.rotation = LEAN * sin(TAU * phase) * u
	for side: int in 2:
		var m: float = 1.0 if side == 0 else -1.0
		var step: float = sin(TAU * (phase * STEPS_PER_CYCLE + side * 0.5))
		_feet[side].position = Vector2(HIP.x + step * FOOT_REACH_M * u, HIP.y * m) * PX_PER_M
	var sh_r: Vector2 = SHOULDER
	_arm(0, sh_r, sh_r.lerp(cane_tip(phase), u), 1.0)
	var sh_l: Vector2 = Vector2(SHOULDER.x, -SHOULDER.y)
	_arm(2, sh_l, sh_l.lerp(GUARD_HAND, u), -1.0)


## Two-bone arm from `a` to the hand `b` (body frame, metres), the elbow bent outward.
func _arm(i: int, a: Vector2, b: Vector2, m: float) -> void:
	var d: float = clampf(a.distance_to(b), 0.02, UPPER_M + FORE_M - 0.001)
	var along: float = (UPPER_M * UPPER_M - FORE_M * FORE_M + d * d) / (2.0 * d)
	var out: float = sqrt(maxf(0.0, UPPER_M * UPPER_M - along * along))
	var dir: Vector2 = (b - a).normalized() if a.distance_to(b) > 0.001 else Vector2.RIGHT
	var elbow: Vector2 = a + dir * along + dir.orthogonal() * out * -m
	_place(_arms[i], a, elbow)
	_place(_arms[i + 1], elbow, b)


func _place(s: Sprite2D, a: Vector2, b: Vector2) -> void:
	var d: Vector2 = b - a
	s.position = a * PX_PER_M
	s.rotation = d.angle()
	var len_px: float = maxf(d.length(), 0.05) * PX_PER_M
	s.scale = Vector2(
		len_px / float(s.texture.get_width()),
		ARM_THICK_M * PX_PER_M / float(s.texture.get_height())
	)


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


## The soul glow under the old welder: a soft teal disc (teal belongs to the souls).
func _soft_glow() -> Sprite2D:
	var g: GradientTexture2D = GradientTexture2D.new()
	g.width = 64
	g.height = 64
	g.fill = GradientTexture2D.FILL_RADIAL
	g.fill_from = Vector2(0.5, 0.5)
	g.fill_to = Vector2(1.0, 0.5)
	var grad: Gradient = Gradient.new()
	grad.set_color(0, Color(TEAL, 0.4))
	grad.set_color(1, Color(TEAL, 0.0))
	g.gradient = grad
	var s: Sprite2D = Sprite2D.new()
	s.texture = g
	s.scale = Vector2.ONE * 1.9 * PX_PER_M / 64.0
	return s
