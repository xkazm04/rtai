class_name DentSpectralDrawn
extends Node2D
## Flight and punch cards for the mounted body. The mount already banks, lifts and squashes it.

enum Pose { HOVER, DIVE, SWING, HIT, COCK, JAB, STEER }

const DIVE_MPS: float = 2.5
const TURN_DPS: float = 150.0
const HEIGHT_M: float = 1.45
const FINISH: Shader = preload("res://features/souls/dent_spectral_finish.gdshader")
## Centres of the gripping fist in STEER, in source-cell pixels (toward through away).
const GRIP_55: Array[Vector2] = [
	Vector2(85, 105), Vector2(124, 93), Vector2(199, 82), Vector2(207, 72), Vector2(189, 56)
]
const GRIP_70: Array[Vector2] = [
	Vector2(84, 105), Vector2(219, 86), Vector2(264, 84), Vector2(261, 66), Vector2(243, 62)
]

## Outer knuckles in the JAB column use a different arm extension from STEER.
const FIST_55: Array[Vector2] = [
	Vector2(86, 131), Vector2(216, 104), Vector2(232, 95), Vector2(232, 77), Vector2(184, 55)
]
const FIST_70: Array[Vector2] = [
	Vector2(96, 161), Vector2(199, 171), Vector2(282, 121), Vector2(288, 79), Vector2(244, 63)
]

var sprite: Sprite2D = Sprite2D.new()
var _rim: Sprite2D = Sprite2D.new()
var _bend: DentSteerMesh
var _outline_bend: DentSteerMesh
var _grips: PackedVector2Array = [Vector2.ZERO, Vector2.ZERO]
var _art: String = ""
var _fly: GhostSheet
var _act: GhostSheet


func _init() -> void:
	_rim.centered = false
	var glow: ShaderMaterial = GhostApparition.ghost_material(true, 0.0)
	glow.set_shader_parameter(&"hi", Color("#55f3de"))
	_rim.material = glow
	add_child(_rim)
	sprite.centered = false
	sprite.name = &"ghost_drawn"
	var finish: ShaderMaterial = ShaderMaterial.new()
	finish.shader = FINISH
	sprite.material = finish
	add_child(sprite)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS


## The hit interrupts the hands until steering or the jab can resume.
static func pose(hover: GhostHover, jab: DentJab, seized: bool, hurt_age: int) -> Pose:
	if hurt_age >= 0 and hurt_age < GhostDrawn.HIT_TICKS:
		return Pose.HIT
	if seized:
		return Pose.STEER
	if jab != null and GhostActs.jabbing(jab):
		return Pose.COCK if jab.winding() else Pose.JAB
	if absf(hover.yaw_rate_dps) >= TURN_DPS:
		return Pose.SWING
	return Pose.DIVE if hover.speed_mps >= DIVE_MPS else Pose.HOVER


func show_pose(drawn: GhostDrawn, facing: float, current: Pose, strings: bool = false) -> void:
	var vm: ViewMode = ViewMode.shared()
	if vm.art != _art:
		_art = vm.art
		_fly = GhostSheet.of(GhostDrawn.path_of(_art, "dent", "sp_fly"), 4)
		_act = GhostSheet.of(GhostDrawn.path_of(_art, "dent", "sp_act"), 4)
	var sheet: GhostSheet = _act if current >= Pose.COCK else _fly
	var col: int = current - Pose.COCK if current >= Pose.COCK else current
	if strings and current == Pose.STEER:
		col = 3  # STEER TWO HANDS in the fourth act cell.
	var oct: int = drawn.octant(facing)
	sheet.show(sprite, oct, col)
	if current == Pose.SWING:
		sprite.flip_h = swing_flip(oct, drawn.flight.hover.yaw_rate_dps)
	sheet.show(_rim, oct, col)
	_rim.flip_h = sprite.flip_h
	var cell: Vector2 = sheet.tex.get_size() / Vector2(4, GhostDrawn.ROWS)
	# The packed grids stand on their bottom edge. Mount the belt on the ribbon instead.
	var belt_y: float = 0.82 if current == Pose.DIVE and oct in [0, 1, 3, 4] else 0.69
	sprite.offset = -cell * Vector2(0.5, belt_y)
	_rim.offset = sprite.offset
	_place(drawn.flight.hover, facing, vm, cell)


static func swing_flip(oct: int, yaw: float) -> bool:
	return (RigHeadCard.OCT_FLIP[oct] == 1) != (yaw < 0.0)


## Dent and the Ronin share the same texel density. The sheets already include the pitch.
static func texel_scale(art: String) -> float:
	return HEIGHT_M * SimConst.PX_PER_M / (212.0 if art == "p55" else 223.0)


func grip_world(strike: bool = false) -> Vector2:
	if _on_hit_card():
		return DentHit.grip(sprite, _art, 1)
	var cell: Vector2 = (GRIP_55 if _art == "p55" else GRIP_70)[sprite.frame_coords.y]
	if strike:
		cell = (FIST_55 if _art == "p55" else FIST_70)[sprite.frame_coords.y]
	if sprite.flip_h:
		cell.x = sprite.get_rect().size.x - cell.x
	return sprite.to_global(sprite.offset + cell)


func string_grip(index: int) -> Vector2:
	if _on_hit_card():
		return DentHit.grip(sprite, _art, index)
	return sprite.to_global(_grips[index])


func _on_hit_card() -> bool:
	return _fly != null and sprite.texture == _fly.tex and sprite.frame_coords.x == Pose.HIT


func steer_hands(turn: float, facing: float) -> void:
	if sprite.texture != _act.tex or sprite.frame_coords.x != 3:
		if _bend != null and _bend.visible:
			_bend.bend([], [])
			_outline_bend.bend([], [])
		return
	if _bend == null:
		_bend = DentSteerMesh.new(sprite)
		_outline_bend = DentSteerMesh.new(_rim)
	var rest: PackedVector2Array = _steer_palms()
	var world_gap: Vector2 = sprite.to_global(rest[1]) - sprite.to_global(rest[0])
	var screen_gap: Vector2 = world_gap * Vector2(1.0, ViewMode.shared().ground_k())
	var spread: float = maxf(0.0, 0.48 * SimConst.PX_PER_M / screen_gap.length() - 1.0) * 0.5
	var shifts: PackedVector2Array = []
	for i: int in 2:
		var side: int = -1 if i == 0 else 1
		var travel: Vector2 = DentStringSteer.offset_m(
			side, turn, Vector2.from_angle(facing), ViewMode.shared()
		)
		var d: Vector2 = travel * SimConst.PX_PER_M + world_gap * spread * side
		var shift: Vector2 = sprite.to_local(sprite.global_position + d)
		_grips[i] = rest[i] + shift
		if spread > 0.0 or not is_zero_approx(turn):
			@warning_ignore("return_value_discarded")
			shifts.append(shift)
	_bend.bend(rest, shifts)
	_outline_bend.bend(rest, shifts)


func _steer_palms() -> PackedVector2Array:
	var row: int = sprite.frame_coords.y
	var left: Vector2 = (DentStringSteer.LEFT_55 if _art == "p55" else DentStringSteer.LEFT_70)[row]
	var right: Vector2 = (DentStringSteer.RIGHT_55 if _art == "p55" else DentStringSteer.RIGHT_70)[row]
	var rest: PackedVector2Array = [left, right]
	if sprite.flip_h:
		rest = PackedVector2Array([right, left])
		for i: int in 2:
			rest[i].x = sprite.get_rect().size.x - rest[i].x
	for i: int in 2:
		rest[i] += sprite.offset
	return rest


func _place(hover: GhostHover, facing: float, vm: ViewMode, cell: Vector2) -> void:
	var forward: Vector2 = Vector2.from_angle(facing)
	sprite.rotation = hover.lean * forward.x
	var tip: float = cos(hover.lean) * (1.0 - 0.22 * hover.lean * forward.y)
	sprite.scale = vm.ground_of(Vector2(1.0, tip) * texel_scale(_art))
	# Expand the one-pass apparition silhouette about the cell centre.
	_rim.transform = sprite.transform.scaled_local(Vector2.ONE * 1.055)
	_rim.position = -sprite.transform.basis_xform(sprite.offset + cell * 0.5) * 0.055
