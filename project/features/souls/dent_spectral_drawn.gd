class_name DentSpectralDrawn
extends Node2D
## Flight and punch cards for the mounted body. The mount already banks, lifts and squashes it.

enum Pose { HOVER, DIVE, SWING, HIT, COCK, JAB, STEER }

const DIVE_MPS: float = 2.5
const TURN_DPS: float = 150.0
const HEIGHT_M: float = 1.45
const FINISH: Shader = preload("res://features/souls/dent_spectral_finish.gdshader")

var sprite: Sprite2D = Sprite2D.new()
var _rim: Sprite2D = Sprite2D.new()
var _art: String = ""
var _fly: GhostSheet
var _act: GhostSheet


func _init() -> void:
	_rim.centered = false
	_rim.material = GhostApparition.ghost_material(true, 0.0)
	add_child(_rim)
	sprite.centered = false
	sprite.name = &"ghost_drawn"
	var finish: ShaderMaterial = ShaderMaterial.new()
	finish.shader = FINISH
	sprite.material = finish
	add_child(sprite)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS


## Use the same strike and hurt tick windows as the standing figure. A seized car owns the hands.
static func pose(hover: GhostHover, jab: DentJab, seized: bool, hurt_age: int) -> Pose:
	if seized:
		return Pose.STEER
	if jab != null and GhostActs.jabbing(jab):
		return Pose.COCK if jab.winding() else Pose.JAB
	if hurt_age >= 0 and hurt_age < GhostDrawn.HIT_TICKS:
		return Pose.HIT
	if absf(hover.yaw_rate_dps) >= TURN_DPS:
		return Pose.SWING
	return Pose.DIVE if hover.speed_mps >= DIVE_MPS else Pose.HOVER


func show_pose(drawn: GhostDrawn, facing: float, current: Pose) -> void:
	var vm: ViewMode = ViewMode.shared()
	if vm.art != _art:
		_art = vm.art
		_fly = GhostSheet.of(GhostDrawn.path_of(_art, "dent", "sp_fly"), 4)
		_act = GhostSheet.of(GhostDrawn.path_of(_art, "dent", "sp_act"), 4)
	var sheet: GhostSheet = _act if current >= Pose.COCK else _fly
	var col: int = current - Pose.COCK if current >= Pose.COCK else current
	var oct: int = drawn.octant(facing)
	sheet.show(sprite, oct, col)
	if current == Pose.SWING:
		sprite.flip_h = swing_flip(oct, drawn.flight.hover.yaw_rate_dps)
	sheet.show(_rim, oct, col)
	_rim.flip_h = sprite.flip_h
	_place(drawn.flight.hover, facing, vm)


static func swing_flip(oct: int, yaw: float) -> bool:
	return (RigHeadCard.OCT_FLIP[oct] == 1) != (yaw < 0.0)


func _place(hover: GhostHover, facing: float, vm: ViewMode) -> void:
	# Profile head widths at alpha >= 128, excluding legacy's detached wisp.
	var head_ratio: float = 70.0 / 77.0 if _art == "p55" else 77.0 / 90.0
	var width: float = 1.8 / 176.5 * head_ratio
	var height: float = HEIGHT_M / (212.0 if _art == "p55" else 223.0)
	var forward: Vector2 = Vector2.from_angle(facing)
	sprite.rotation = hover.lean * forward.x
	var tip: float = cos(hover.lean) * (1.0 - 0.22 * hover.lean * forward.y)
	sprite.scale = Vector2(width, height * tip / vm.ground_k()) * SimConst.PX_PER_M
	# Expand the one-pass apparition silhouette about the cell centre, not about the feet.
	_rim.transform = sprite.transform.scaled_local(Vector2.ONE * 1.055)
	_rim.position = Vector2.UP.rotated(sprite.rotation) * sprite.offset.y * sprite.scale.y * 0.0275
