class_name OhmSpirit
extends Node2D
## Straight-down cutout in master texels, with +x forward and +y to Ohm's right.
## The fork and sleeve form a two-link chain with the wrist at their common joint.

const ART: String = "res://features/souls/art/ohm/spectral/"
const REST_FORK_M: Vector2 = Vector2(1.60, 0.96)
const STAFF_ANGLE: float = 0.18
const FIST_CENTRE_PX: Vector2 = Vector2(395.0, 99.0)
const SHAFT_GRIP_PX: float = 264.0
const THRUST_M: float = 0.35
const OUT_TICKS: int = 8
const BACK_TICKS: int = 12
const AMBER: Color = OhmBoltDraw.AMBER

static var _textures: Dictionary[String, Texture2D] = {}
var _parts: Dictionary
var _texels_per_m: float
var _hem: Sprite2D
var _beard: Sprite2D
var _free_arm: Sprite2D
var _staff_arm: Sprite2D
var _staff: Sprite2D
var _jars: OhmJars
var _fork: OhmFork
var _puffs: Array[Sprite2D] = []
var _vents: PackedVector2Array = []
var _lengths: Vector2
var _drift: OhmDrift = OhmDrift.new()
var _row: GhostHoverRow = GhostHoverRow.of(OhmStage.ID)


func _ready() -> void:
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ART + "parts.json"))
	_parts = meta.parts
	_texels_per_m = meta.texels_per_m
	scale = Vector2.ONE * SimConst.PX_PER_M / _texels_per_m
	add_child(OhmDrawn.halo(920.0, 0.22))
	_hem = _part("hem", Vector2(-138.0, 0.0))
	_staff = _part("staff", Vector2.ZERO)
	_free_arm = _part("arm_free", Vector2(-24.0, -132.0))
	var body: Sprite2D = _part("body", Vector2.ZERO)
	body.scale = Vector2.ONE * 1.13
	_jars = OhmJars.new()
	body.add_child(_jars)
	var circles: Array = meta.body_jars
	_vents = _jars.top_circles(body, _texture("body_jars"), circles)
	_staff_arm = _part("arm_staff", Vector2(56.0, 124.0))
	_beard = _part("beard", Vector2(154.0, 0.0))
	_build_staff()
	for vent: Vector2 in _vents:
		var puff: Sprite2D = GhostRim.soft_glow(AMBER, 1.0, 96.0)
		puff.position = vent
		puff.hide()
		add_child(puff)
		_puffs.append(puff)
	_staff_pose(REST_FORK_M)


func _build_staff() -> void:
	var fork_px: Vector2 = _measure("staff", "fork_px")
	# The shaft pivots inside the painted fist. Both anchors lie on their part's local x-axis.
	_staff_arm.offset.y = -FIST_CENTRE_PX.y
	_staff.offset = Vector2(-SHAFT_GRIP_PX, -fork_px.y)
	_staff.scale = Vector2.ONE * 1.5
	_staff.self_modulate = Color(1.16, 1.16, 1.16)
	_lengths = Vector2(
		FIST_CENTRE_PX.x + _staff_arm.offset.x, (fork_px.x + _staff.offset.x) * _staff.scale.x
	)
	_fork = OhmFork.new()
	_staff.add_child(_fork)
	var staff_part: Dictionary = _parts.staff
	_fork.place(_staff, OhmFork.unpack(staff_part))


func _part(id: String, at: Vector2) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = _texture(id)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.centered = false
	sprite.offset = -_measure(id, "pivot_px")
	sprite.position = at
	add_child(sprite)
	return sprite


## The master-scale cuts shrink by about eleven to one at play zoom. Filter the linework and
## jar edges at that scale, sharing the mip chains across spectral rigs.
static func _texture(id: String) -> Texture2D:
	if not _textures.has(id):
		var source: Texture2D = load(ART + id + ".png") as Texture2D
		var image: Image = source.get_image()
		if not image.has_mipmaps() and image.generate_mipmaps() == OK:
			_textures[id] = ImageTexture.create_from_image(image)
		else:
			_textures[id] = source
	return _textures[id]


func _measure(id: String, field: String) -> Vector2:
	var part: Dictionary = _parts[id]
	return DataTable.new().vec(part, field)


func pose(drawn: GhostDrawn, charge: OhmCharge, stage: OhmStage, calm: bool, tick: int) -> void:
	var hover: GhostHover = drawn.flight.hover if drawn.flight != null else null
	var bank: float = hover.bank if hover != null else 0.0
	var cruise: float = hover.speed_mps / _row.top_mps if hover != null else 0.0
	var motion: float = 0.5 if calm else 1.0
	var facing: float = (get_parent() as Node2D).global_rotation
	_drift.step(tick, facing)
	var body_lag: float = 0.55 * _drift.beard.angle
	rotation = (OhmDrift.sway(tick, cruise) + body_lag) * motion
	if drawn.act_col() == GhostDrawn.HIT_COL:
		var lean: float = GhostRecoil.lean_of(drawn.card_name)
		rotation += GhostRecoil.tilt(tick - drawn.hurt_tick(), facing, lean, drawn.blow) * motion
	_hem.rotation = _drift.hem.angle * motion
	_beard.rotation = _drift.beard.angle * motion
	_free_arm.rotation = -0.31 + (0.25 * _drift.hem.angle + bank) * motion
	if drawn.flight != null:
		# Carry the tuned socket with the cloth as its root pivots behind the shell.
		var socket: Vector2 = _row.tail.anchor_m * _texels_per_m / PlayerScale.k()
		OhmDrawn.pin_tail(drawn.flight, _hem.to_global(socket - _hem.position))
	var lead: float = -body_lag * motion
	var target: Vector2 = REST_FORK_M.rotated(lead)
	if hover != null:
		target.x += 0.30 * clampf(cruise, 0.0, 1.0) * motion
		target.y -= 0.078 * sin(TAU * hover.tick / _row.bob_ticks) * motion
	if stage != null and stage.bolt_tick >= 0:
		var aim: Vector2 = stage.bolt_aim.rotated(-global_rotation)
		target += aim * THRUST_M * thrust(tick - stage.bolt_tick) * motion
	_staff_pose(target, lead)
	_jars.light(Vector3(charge.jar(0), charge.jar(1), charge.jar(2)), 0.0, charge.vent())
	_fork.stage = stage
	_fork.vent = charge.vent()
	_vent(charge.vent())


static func thrust(age: int) -> float:
	if age < 0 or age >= OUT_TICKS + BACK_TICKS:
		return 0.0
	if age <= OUT_TICKS:
		return smoothstep(0.0, OUT_TICKS, age)
	return 1.0 - smoothstep(OUT_TICKS, OUT_TICKS + BACK_TICKS, age)


func _staff_pose(target_m: Vector2, lead: float = 0.0) -> void:
	var target: Vector2 = target_m * _texels_per_m / PlayerScale.k()
	var wrist: Vector2 = target - Vector2.RIGHT.rotated(STAFF_ANGLE + lead) * _lengths.y
	_staff_arm.scale.x = _staff_arm.position.distance_to(wrist) / _lengths.x
	_staff_arm.rotation = _staff_arm.position.angle_to_point(wrist)
	_staff.position = wrist
	_staff.rotation = wrist.angle_to_point(target)


func _vent(amount: float) -> void:
	var age: float = (1.0 - amount) * OhmCharge.VENT_TICKS
	for i: int in 3:
		var puff: Sprite2D = _puffs[i]
		var k: float = clampf(age / 16.0, 0.0, 1.0)
		puff.visible = k < 1.0
		if puff.visible:
			puff.position = _vents[i] + Vector2(-130.0, (i - 1) * 70.0) * k
			puff.scale = Vector2.ONE * lerpf(0.7, 1.8, k)
			puff.modulate.a = 1.0 - k
