class_name ServoPad
extends RefCounted
## Servo's hover pads (docs/bosses/servo.md section 1): the octagonal pad art, and its rotor's
## spin. The sheet's top view sets the pads square to the body, octagons with a landing mark; it8
## to it18 turned the whole pad with the rotor, so at 32 px/m it read as a round wheel. Now the pad
## holds square and the spin shows as rotor blades blurring inside it, only when the rotor revs
## (a tell's windup, a dash, the transition, the defeat's wind-down), so the spin-up still reads.
## Render only: the fight's state is never touched.

## true = the it8-it18 pad turning with its rotor (TURN_K of the spin); false = square to the body.
const TURN: bool = false
const TURN_K: float = 0.1
## The blades: radius (metres), the turn per unit of spin, and the spin per tick above which they
## show (the rig idles at 0.15 and revs at 0.9).
const BLADE_R_M: float = 0.4
const BLADE_K: float = 0.5
const BLADE_SHOW: float = 0.3
## The smear behind each blade: copies and their step back along the turn (radians).
const SMEAR: int = 3
const SMEAR_STEP: float = 0.16

var px: float = 32.0
var tex: Texture2D = null
var tint: Color = Color.WHITE
## The rotor's accumulated spin and its rate this tick (ServoRig._spin and its step).
var spin: float = 0.0
var rate: float = 0.0
var _pal: PaletteTokens = PaletteTokens.shared()


## Draws the pad at `at` (metres), square to `face` (radians), on side `s` (-1 / +1), scaled by k.
func draw(c: Node2D, at: Vector2, face: float, s: float, k: float) -> void:
	var rot: float = face + (spin * s * TURN_K if TURN else 0.0)
	c.draw_set_transform(at * px, rot, Vector2(k, k) * px / ServoRig.ART_PPM)
	c.draw_texture(tex, -tex.get_size() * 0.5, tint)
	c.draw_set_transform(Vector2.ZERO)
	if not TURN and rate > BLADE_SHOW:
		_blades(c, at, s, k)


## Two crossed blades and their smear, paper over the pad's dark landing disc.
func _blades(c: Node2D, at: Vector2, s: float, k: float) -> void:
	var r: float = BLADE_R_M * k * px
	var u: float = clampf((rate - BLADE_SHOW) / 0.4, 0.0, 1.0)
	var base: Color = _pal.color(&"paper") * tint
	for j: int in SMEAR:
		var a: float = spin * s * BLADE_K - s * SMEAR_STEP * j
		var col: Color = Color(base, (0.9 - 0.25 * j) * (0.4 + 0.6 * u))
		for q: int in 2:
			var d: Vector2 = Vector2.from_angle(a + q * PI / 2.0) * r
			c.draw_line(at * px - d, at * px + d, col, maxf(1.5, 0.06 * px * k))


## The punish window's vent steam round a pad (metres), turning with the tick.
func steam(c: Node2D, at: Vector2, tick: int) -> void:
	var a: float = 0.35 + 0.15 * sin(tick * 0.4)
	for j: int in 3:
		var off: Vector2 = Vector2.from_angle(tick * 0.05 + j * TAU / 3.0) * 0.5
		c.draw_circle((at + off) * px, (0.3 + 0.08 * j) * px, Color(_pal.color(&"paper"), a))
