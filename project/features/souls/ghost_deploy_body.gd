class_name GhostDeployBody
extends Sprite2D
## Composite the real rig before applying the apparition wash and erosion. Each rig keeps
## its own material masks, silhouettes and part order. The transparent viewport sleeps off-cast.

const PIXELS: Vector2i = Vector2i(768, 768)
const FOOT: Vector2 = Vector2(384, 480)
const RES: float = 2.0
const APPEAR_TICKS: int = 6
## n31 ghost 12: a dropped Ohm rises this high over the spot while he fades in.
const OHM_RISE_M: float = 0.5

var source: SubViewport
var stage: CollectCallStage
var calm: bool
var _mount: Node2D
var _body: Node2D
var _fork: OhmFork
var _shown: StringName
var _wash: ShaderMaterial = GhostApparition.ghost_material(false, 0.15)
var _fade: ShaderMaterial = ShaderMaterial.new()


func _ready() -> void:
	visible = false
	centered = false
	offset = -FOOT
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_fade.shader = GhostBridgeFade.SHADER
	_fade.set_shader_parameter(&"grain", GhostVapour.grain())
	_fade.set_shader_parameter(&"band_k", 0.15)


func _open() -> void:
	source = SubViewport.new()
	source.size = PIXELS
	source.transparent_bg = true
	source.disable_3d = true
	source.world_2d = World2D.new()
	source.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(source)
	texture = source.get_texture()
	_mount = Node2D.new()
	source.add_child(_mount)


func _rig(form: StringName) -> void:
	_fork = null
	if _mount.get_child_count() > 0:
		_mount.get_child(0).free()
	match form:
		HaulerStage.GHOST:
			_body = TonnageRig.new()
		DentStage.GHOST:
			_body = DentBody.new()
		KerfStage.GHOST:
			_body = KerfRig.new()
		OhmStage.GHOST:
			var ohm: OhmRig = OhmRig.new()
			ohm.reduced_motion = calm
			_body = ohm
	GhostFormBodies.mount_rig(_mount, _body, form)
	if _body is DentBody:
		var dent: DentBody = _body as DentBody
		dent.reduced_motion = calm
		dent.setup(stage.pilot.ghosts.forms.table.form(form))
	else:
		PlayerScale.fit([_body])
		if _body is OhmRig:
			_body.scale *= stage.pilot.ghosts.forms.table.form(form).size_k
	_shown = form


func show_strike(ghost: GhostDeploy, age: int, steps: int) -> void:
	if source == null:
		_open()
	if ghost.form != _shown:
		_rig(ghost.form)
	visible = true
	var pitch: float = ViewMode.shared().ground_k()
	source.canvas_transform = Transform2D(0.0, Vector2(RES, RES * pitch), 0.0, FOOT)
	scale = Vector2(1.0 / RES, 1.0 / (RES * pitch))
	var yaw: float = PI * 0.5 if _faces_camera(ghost) else ghost.facing.angle()
	var drawn: GhostDrawn = _body.get(&"drawn")
	# Keep the authored follow-through cell while the apparition lingers. A charging drop
	# (n31 Tonnage) holds its wind-up until the dump tick, the strike's own age 0.
	var struck: int = ghost.dump.strike_age(ghost, stage.tick)
	drawn.deploy_age = clampi(struck, -1, GhostDrawn.CUT_TICKS + GhostDrawn.FOLLOW_TICKS - 1)
	drawn.jab = ghost.form == DentStage.GHOST
	var landed: int = stage.tick - drawn.deploy_age if struck >= 0 else -1
	drawn.feed(1, -1, stage.tick, struck < 0, landed)
	_stand(ghost, age, drawn.jab, struck)
	var at: Vector2 = GhostFormBodies.place_body(drawn, Vector2.ZERO, yaw, steps, true)
	if _body is DentBody:
		var dent: DentBody = _body as DentBody
		dent.deploy_pose = DentDropBeats.cell(_drops(ghost), age, struck)
		dent.step(true, at, yaw, steps, stage.tick)
	else:
		_body.visible = true
		_body.position = at
		_body.rotation = yaw
		_body.set(&"unfold", 1.0)
		_body.call(&"advance", steps * SimClock.TICK_DT)
	if _drops(ghost) and ghost.form == HaulerStage.GHOST:
		_beats(ghost, age, struck)
	elif _drops(ghost) and ghost.form == OhmStage.GHOST:
		# n31 ghost 12: a dropped Ohm stands on the spot and rises into his hover as he fades in.
		position += ViewMode.shared().lift_px(OHM_RISE_M * smoothstep(0.0, APPEAR_TICKS, age))
	_wash_body(ghost, age)
	source.render_target_update_mode = SubViewport.UPDATE_ONCE


func _stand(ghost: GhostDeploy, age: int, jab: bool, struck: int) -> void:
	position = ghost.spot * SimConst.PX_PER_M
	if ghost.form == OhmStage.GHOST and not _drops(ghost):
		var short_radius: float = ghost.strike.attacks.deploy[ghost.form].radius_m
		# Use the near quadrant so the fork and Rivet's gun both have a clear outline.
		var angle: float = deg_to_rad(-30.0 if ghost.facing.x >= 0.0 else 30.0)
		position -= ghost.facing.rotated(angle) * short_radius * SimConst.PX_PER_M
	elif jab and _drops(ghost):
		position = DentDropBeats.at(ghost, age, struck) * SimConst.PX_PER_M
	elif jab:
		var travel: float = smoothstep(0.0, 7.0, age)
		position = ghost.origin.lerp(ghost.spot, travel) * SimConst.PX_PER_M


## A deploy in drop mode (one press, a charge, the strike on its last tick).
func _drops(ghost: GhostDeploy) -> bool:
	return ghost.strike.attacks.deploy[ghost.form].drops()


## Tonnage and Ohm drop on a full circle and face the camera (row 0); Dent rams along a lane
## and faces it (n31 ghost 17).
func _faces_camera(ghost: GhostDeploy) -> bool:
	return _drops(ghost) and ghost.form != DentStage.GHOST


## Tonnage's drop beats (TonnageDropBeats): the fall and rise, and the strip's cell.
func _beats(ghost: GhostDeploy, age: int, struck: int) -> void:
	position += ViewMode.shared().lift_px(TonnageDropBeats.lift_m(age, struck))
	var charge: int = ghost.strike.attacks.deploy[ghost.form].charge_ticks
	TonnageDropBeats.paint(_body, TonnageDropBeats.col(age, charge, struck))


func _wash_body(ghost: GhostDeploy, age: int) -> void:
	var life: int = ghost.strike.attacks.deploy[ghost.form].life_ticks
	var fade_ticks: int = maxi(2, ceili(life / 3.0))
	var appear: float = maxf(0.0, 1.0 - float(age) / APPEAR_TICKS)
	var k: float = maxf(appear, 1.0 - float(ghost.ticks_left) / fade_ticks)
	var mat: ShaderMaterial = _fade if k > 0.0 else _wash
	material = mat
	mat.set_shader_parameter(&"voice_phase", 0.0 if calm else stage.tick * 0.008)
	if k > 0.0:
		_fade.set_shader_parameter(&"fade_from", lerpf(0.25, 1.0, k))
		_fade.set_shader_parameter(&"flow", 0.0 if calm else stage.tick * SimClock.TICK_DT)
	self_modulate.a = 0.95 * (1.0 - k)


func dismiss() -> void:
	if not visible:
		return
	hide()
	var drawn: GhostDrawn = _body.get(&"drawn")
	@warning_ignore("return_value_discarded")
	GhostFormBodies.place_body(drawn, Vector2.ZERO, 0.0, 0, false)
	_body.hide()
	source.render_target_update_mode = SubViewport.UPDATE_DISABLED


## The real spectral rig places these sockets in its current painted cell. The compositor
## cancels the capture scale and camera pitch, leaving the same local world-pixel offset.
func bolt_tip(fallback: Vector2) -> Vector2:
	if _shown != OhmStage.GHOST:
		return fallback
	if _fork == null or not _fork.is_visible_in_tree():
		_fork = null
		for node: Node in get_tree().get_nodes_in_group(OhmFork.GROUP):
			if _mount.is_ancestor_of(node) and (node as OhmFork).is_visible_in_tree():
				_fork = node as OhmFork
				break
	if _fork != null:
		var tips: PackedVector2Array = _fork.points_on(_mount)
		if tips.size() == 3:
			return position + tips[2]
	return fallback
