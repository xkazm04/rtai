class_name KerfRig
extends Node2D
## Kerf, the freed laser-cutter head (TARGETS.md ghost_kerf_fast.jpg, its top-down drawing), as a
## cutout rig from straight above: the arrow hull (lens and cutter nozzle at the nose, the hazard
## cross-beam), the cable loops on its back, two jointed arms from the cross-beam reaching forward
## to their teal beam emitters (the duelist's guard), two blade legs trailing behind. Parts are the
## Codex sheet cut by tools/art/ghost_parts.py (art/kerf/, raw art like Tonnage's). Units: world
## px at PX_PER_M; +x = facing (set rotation = facing angle).
## Gait "hover": no steps; the body bobs toward the camera, the legs sweep back with speed and the
## arms tuck in. unfold (0..1) is the transformation: 0 = limbs folded onto the hull.

const ART: String = "res://features/souls/art/kerf/"
const PX_PER_M: float = 32.0
const TEAL: Color = Color(0.18, 0.77, 0.71)
## The hull's length, the cable loops' length (metres, the art's long side).
const HULL_M: float = 1.35
const CABLES_M: float = 0.56
const CABLES_AT: Vector2 = Vector2(-0.68, 0.0)
## Joints in the body frame (x forward, y right, metres; mirrored for the left side).
const SHOULDER: Vector2 = Vector2(-0.12, 0.4)
const HIP: Vector2 = Vector2(-0.46, 0.13)
## Segment lengths and thickness (metres).
const UPPER_M: float = 0.54
const FORE_M: float = 0.68
const LEG_UP_M: float = 0.5
const LEG_LO_M: float = 0.64
const ARM_THICK_M: float = 0.22
const LEG_THICK_M: float = 0.22
## Limb angles off +x (radians, right side) at rest and swept (full speed).
const UPPER_REST: float = deg_to_rad(40.0)
const FORE_REST: float = deg_to_rad(-12.0)
const UPPER_FAST: float = deg_to_rad(70.0)
const FORE_FAST: float = deg_to_rad(20.0)
const LEG_UP_REST: float = deg_to_rad(140.0)
const LEG_LO_REST: float = deg_to_rad(170.0)
const LEG_UP_FAST: float = deg_to_rad(165.0)
const LEG_LO_FAST: float = deg_to_rad(178.0)
## The speed (m/s) where the limbs are fully swept; the bob (Hz, scale amplitude).
const FAST_MPS: float = 10.0
const BOB_HZ: float = 1.3
const BOB_K: float = 0.035
## Tilted view: the v2 facing card (GhostCard, art/view/<art>/kerf_card.png: the tall lanky biped
## whose forearms are blades, Rivet-tall), its width (m), the ground point's height in the card and
## its soul halo alpha. It replaces the hull, cables and every limb (v2 is a different body plan).
const CARD_M: float = 0.8
const CARD_ANCHOR: float = 0.97
const CARD_HALO_A: float = 0.4
## The card's lean into the glide at full sweep (GhostCard.lean, by the facing's screen x).
const CARD_LEAN: float = deg_to_rad(12.0)

var unfold: float = 1.0
## Ground speed (m/s), fed by the host each tick.
var speed_mps: float = 0.0
var _t: float = 0.0
var _swept: float = 0.0
var _body: Node2D = Node2D.new()
var _hull: Sprite2D = null
var _cables: Sprite2D = null
## Per side (0 = right, 1 = left) four sprites: upper arm, forearm, leg upper, leg lower.
var _limbs: Array[Sprite2D] = []
var _hide: Array[Sprite2D] = []
var _card: GhostCard = GhostCard.new("kerf", CARD_M, CARD_ANCHOR)


func _ready() -> void:
	add_child(GhostRim.soft_glow(TEAL, 0.4, 2.4 * PX_PER_M))  # teal belongs to the souls
	add_child(_body)
	for side: int in 2:
		var leg_up: Sprite2D = _limb("leg_upper")
		var leg_lo: Sprite2D = _limb("leg_lower")
		var upper: Sprite2D = _limb("upper")
		var fore: Sprite2D = _limb("fore")
		for s: Sprite2D in [leg_up, leg_lo, upper, fore]:
			s.flip_v = side == 1  # the left side mirrors (the claw curves outward)
			GhostRim.limb(s)
		_limbs.append_array([upper, fore, leg_up, leg_lo])
	_cables = _part("cables", CABLES_M)
	_cables.position = CABLES_AT * PX_PER_M
	_hull = _part("hull", HULL_M)
	GhostRim.body(_hull)
	_hide = [_hull, _cables]
	_hide.append_array(_limbs)
	_card.halo = Color(TEAL, CARD_HALO_A)
	pose()


## One hover step of `dt` seconds (the host passes SimClock.TICK_DT per sim tick).
func advance(dt: float) -> void:
	_t = fmod(_t + dt, 1000.0)
	var want: float = clampf(speed_mps / FAST_MPS, 0.0, 1.0)
	_swept = move_toward(_swept, want, dt * 3.0)
	pose()


## Lays the limbs out for the current sweep, bob and unfold.
func pose() -> void:
	var u: float = smoothstep(0.0, 1.0, unfold)
	_body.scale = Vector2.ONE * (1.0 + BOB_K * sin(TAU * BOB_HZ * _t)) * lerpf(0.75, 1.0, u)
	for side: int in 2:
		var m: float = 1.0 if side == 0 else -1.0
		var i: int = side * 4
		var a_up: float = lerpf(UPPER_REST, UPPER_FAST, _swept) * m * u
		var a_fo: float = lerpf(FORE_REST, FORE_FAST, _swept) * m * u
		var shoulder: Vector2 = Vector2(SHOULDER.x, SHOULDER.y * m)
		var elbow: Vector2 = shoulder + Vector2.from_angle(a_up) * UPPER_M * u
		_place(_limbs[i], shoulder, elbow, ARM_THICK_M)
		var hand: Vector2 = elbow + Vector2.from_angle(a_fo) * FORE_M * u
		_place(_limbs[i + 1], elbow, hand, ARM_THICK_M)
		var trail: float = sin(TAU * BOB_HZ * _t + side * PI) * deg_to_rad(4.0)
		var l_up: float = (lerpf(LEG_UP_REST, LEG_UP_FAST, _swept) + trail) * m
		var l_lo: float = (lerpf(LEG_LO_REST, LEG_LO_FAST, _swept) + trail * 2.0) * m
		var hip: Vector2 = Vector2(HIP.x, HIP.y * m)
		var knee: Vector2 = hip + Vector2.from_angle(lerp_angle(PI, l_up, u)) * LEG_UP_M * u
		var tip: Vector2 = knee + Vector2.from_angle(lerp_angle(PI, l_lo, u)) * LEG_LO_M * u
		_place(_limbs[i + 2], hip, knee, LEG_THICK_M)
		_place(_limbs[i + 3], knee, tip, LEG_THICK_M)
	_card.size_k = _body.scale.x
	_card.lean = CARD_LEAN * _swept * cos(global_rotation)
	_card.step(self, _hide, Vector2.ZERO, PX_PER_M)


func _place(s: Sprite2D, a: Vector2, b: Vector2, thick_m: float) -> void:
	var d: Vector2 = b - a
	s.position = a * PX_PER_M
	s.rotation = d.angle()
	var len_px: float = maxf(d.length(), 0.05) * PX_PER_M
	s.scale = Vector2(
		len_px / float(s.texture.get_width()), thick_m * PX_PER_M / float(s.texture.get_height())
	)


func _limb(name: String) -> Sprite2D:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(ART + name + ".png") as Texture2D
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	s.centered = false
	s.offset = Vector2(0.0, -s.texture.get_height() * 0.5)
	_body.add_child(s)
	return s


func _part(name: String, length_m: float) -> Sprite2D:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(ART + name + ".png") as Texture2D
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var long_px: int = maxi(s.texture.get_width(), s.texture.get_height())
	s.scale = Vector2.ONE * length_m * PX_PER_M / float(long_px)
	_body.add_child(s)
	return s
