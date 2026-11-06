class_name TonnageRig
extends Node2D
## Tonnage, the walking stamping press (TARGETS.md, ghost_tonnage_bulky.jpg), as a cutout rig from
## straight above: four piston legs out at the corners with their octagonal feet, the riveted crown
## slab over them, the press head (the brow) at the front edge, the hose bundle on the back. The
## parts are the Codex sheet cut by tools/art/ghost_parts.py (art/tonnage/), drawn in the shared
## part print. Units: world px at PX_PER_M; +x = facing (set rotation = facing angle).
## Gait "stamp": the diagonal leg pairs alternate; a lifted foot rises toward the camera (grows) and
## swings a stride forward, then stamps down (stamped fires with the foot's local position).
## unfold (0..1) is the transformation: 0 = the collapsed in-between pose (legs folded under, plates
## shut), 1 = the full press.

signal stamped(local_m: Vector2)

const ART: String = "res://features/souls/art/tonnage/"
const PX_PER_M: float = 32.0
## Part widths in metres (the art's long side): the crown slab is the footprint's core.
const CROWN_M: float = 2.3
const HEAD_M: float = 2.2
const FOOT_M: float = 0.95
const HOSES_M: float = 1.5
const LEG_THICK_M: float = 0.42
## Hip (the crown's corner) and planted foot, metres in the body frame (x forward, y right).
const HIP_M: float = 0.9
const FOOT_AT_M: float = 1.5
const STRIDE_M: float = 0.8
## A lifted foot grows by this much at the top of its step (it rises toward the camera).
const LIFT_K: float = 0.16
const TEAL: Color = Color(0.18, 0.77, 0.71)
## Under a tilted --view: the heights (m, unfolded) the parts ride at, so the press stands on its
## legs with its feet planted (a lifted foot rises FOOT_H_M at the top of its step). Straight down
## the screen-up vector is ZERO and every position is exactly the flat one.
const HIP_H_M: float = 1.3
const CROWN_H_M: float = 1.5
const HEAD_H_M: float = 1.35
const HOSES_H_M: float = 1.8
const FOOT_H_M: float = 0.35

## The shared part print (PartMaterials) on Tonnage's parts. Off by default: at 32 px/m its
## flat-sticker LOD prints the gunmetal crown as one ink mass and hides the teal seams (JOURNAL
## 00:10, frames/tonnage-print-ab-32ppm.png); the raw art keeps the plates and seams. Static so a
## dev run can flip it before the rig builds.
static var print_parts: bool = false

var unfold: float = 1.0
## Ground speed (m/s), fed by the host each frame; the gait phase advances with distance.
var speed_mps: float = 0.0
var _phase: float = 0.0
var _feet: Array[Sprite2D] = []
var _legs: Array[Sprite2D] = []
var _crown: Sprite2D = null
var _head: Sprite2D = null
var _hoses: Sprite2D = null
var _glow: Sprite2D = null
var _down: Array[bool] = [true, true]


func _ready() -> void:
	_glow = _soft_glow()
	for i: int in 4:
		_feet.append(_part("foot", FOOT_M, false))
	for i: int in 4:
		_legs.append(_part("leg", 0.0, true))
	_head = _part("press_head", HEAD_M, false)
	_crown = _part("crown", CROWN_M, false)
	_hoses = _part("hoses", HOSES_M, false)
	pose()


## One gait step of `dt` seconds of wall or sim time (the host passes SimClock.TICK_DT per tick).
func advance(dt: float) -> void:
	_phase = fposmod(_phase + speed_mps * dt / (STRIDE_M * 2.0), 1.0)
	pose()


## Lays every part out for the current phase and unfold.
func pose() -> void:
	var u: float = smoothstep(0.0, 1.0, unfold)
	var up: Vector2 = _up() * lerpf(0.45, 1.0, u)
	for i: int in 4:
		var sx: float = 1.0 if i < 2 else -1.0
		var sy: float = 1.0 if i % 2 == 0 else -1.0
		var pair: int = 0 if (i == 0 or i == 3) else 1
		var lift: float = _lift(pair)
		var swing: float = _swing(pair)
		var hip: Vector2 = Vector2(sx, sy) * HIP_M * lerpf(0.55, 1.0, u)
		var foot: Vector2 = Vector2(sx, sy) * FOOT_AT_M * lerpf(0.5, 1.0, u)
		foot.x += swing * STRIDE_M * 0.5 * u
		hip += up * HIP_H_M
		foot += up * FOOT_H_M * lift
		_feet[i].position = foot * PX_PER_M
		_feet[i].scale = (
			Vector2.ONE * _k(_feet[i], FOOT_M) * (1.0 + LIFT_K * lift) * lerpf(0.6, 1.0, u)
		)
		_place_leg(_legs[i], hip, foot, lift)
	var bob: float = 1.0 + 0.012 * absf(sin(_phase * TAU * 2.0))
	_crown.scale = Vector2.ONE * _k(_crown, CROWN_M) * bob * lerpf(0.62, 1.0, u)
	_crown.rotation = -PI * 0.5 + (1.0 - u) * 0.35
	_crown.position = up * CROWN_H_M * PX_PER_M
	_head.position = (Vector2(lerpf(0.55, 1.12, u), 0.0) + up * HEAD_H_M) * PX_PER_M
	_head.scale = Vector2.ONE * _k(_head, HEAD_M) * lerpf(0.6, 1.0, u)
	_hoses.position = (Vector2(-0.55 * u, 0.0) + up * HOSES_H_M) * PX_PER_M
	_hoses.scale = Vector2.ONE * _k(_hoses, HOSES_M) * lerpf(0.4, 1.0, u)
	_glow.scale = Vector2.ONE * (CROWN_M * 1.9 * PX_PER_M / 64.0) * lerpf(0.5, 1.0, u)
	_check_stamps()


## The screen-up direction in the rig's own frame per unit of height (ZERO straight down).
func _up() -> Vector2:
	if not is_inside_tree():
		return Vector2.ZERO
	return ViewMode.shared().up_at(global_position).rotated(-global_rotation)


## 0..1: how high pair `pair`'s feet are (0 = planted). The pairs alternate half a cycle apart.
func _lift(pair: int) -> float:
	if speed_mps < 0.05:
		return 0.0
	var p: float = fposmod(_phase + 0.5 * pair, 1.0)
	return sin(p * TAU) if p < 0.5 else 0.0


## -1..1: the foot's swing along the stride (forward while lifted, back while planted).
func _swing(pair: int) -> float:
	if speed_mps < 0.05:
		return 0.0
	var p: float = fposmod(_phase + 0.5 * pair, 1.0)
	return -cos(p * TAU * 2.0) if p < 0.5 else 1.0 - 4.0 * (p - 0.5)


func _check_stamps() -> void:
	for pair: int in 2:
		var down: bool = _lift(pair) <= 0.0
		if down and not _down[pair]:
			var i: int = 0 if pair == 0 else 1
			stamped.emit(_feet[i].position / PX_PER_M)
			stamped.emit(_feet[3 - i].position / PX_PER_M)
		_down[pair] = down


func _place_leg(leg: Sprite2D, hip: Vector2, foot: Vector2, lift: float) -> void:
	var d: Vector2 = foot - hip
	leg.position = hip * PX_PER_M
	leg.rotation = d.angle()
	var tex_w: float = float(leg.texture.get_width())
	var tex_h: float = float(leg.texture.get_height())
	var len_px: float = maxf(d.length(), 0.2) * PX_PER_M * (1.0 + 0.5 * LIFT_K * lift)
	leg.scale = Vector2(len_px / tex_w, LEG_THICK_M * PX_PER_M / tex_h)


func _part(name: String, width_m: float, limb: bool) -> Sprite2D:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(ART + name + ".png") as Texture2D
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if print_parts:
		s.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, 0)
	if limb:
		s.centered = false
		s.offset = Vector2(0.0, -s.texture.get_height() * 0.5)
	else:
		s.rotation = -PI * 0.5  # the sheet draws body parts facing down; +x is forward
		s.scale = Vector2.ONE * _k(s, width_m)
	add_child(s)
	return s


func _k(s: Sprite2D, width_m: float) -> float:
	return width_m * PX_PER_M / float(maxi(s.texture.get_width(), s.texture.get_height()))


## The soul glow under the press: a soft teal disc on the ground (teal belongs to the souls).
func _soft_glow() -> Sprite2D:
	var g: GradientTexture2D = GradientTexture2D.new()
	g.width = 64
	g.height = 64
	g.fill = GradientTexture2D.FILL_RADIAL
	g.fill_from = Vector2(0.5, 0.5)
	g.fill_to = Vector2(1.0, 0.5)
	var grad: Gradient = Gradient.new()
	grad.set_color(0, Color(TEAL, 0.38))
	grad.set_color(1, Color(TEAL, 0.0))
	g.gradient = grad
	var s: Sprite2D = Sprite2D.new()
	s.texture = g
	add_child(s)
	return s
