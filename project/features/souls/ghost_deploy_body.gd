class_name GhostDeployBody
extends Sprite2D
## Composite the real rig before applying the apparition wash and erosion. Each rig keeps
## its own material masks, silhouettes and part order. The transparent viewport sleeps off-cast.

const PIXELS: Vector2i = Vector2i(768, 768)
const FOOT: Vector2 = Vector2(384, 480)
const RES: float = 2.0

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
	var yaw: float = ghost.facing.angle()
	var drawn: GhostDrawn = _body.get(&"drawn")
	drawn.deploy_age = age
	drawn.jab = ghost.form == DentStage.GHOST
	drawn.feed(1, -1, stage.tick, false, stage.tick - age)
	position = ghost.spot * SimConst.PX_PER_M
	if drawn.jab:
		var travel: float = smoothstep(0.0, 7.0, age)
		position = ghost.origin.lerp(ghost.spot, travel) * SimConst.PX_PER_M
	var at: Vector2 = GhostFormBodies.place_body(drawn, Vector2.ZERO, yaw, steps, true)
	if _body is DentBody:
		(_body as DentBody).step(true, at, yaw, steps, stage.tick)
	else:
		_body.visible = true
		_body.position = at
		_body.rotation = yaw
		_body.set(&"unfold", 1.0)
		_body.call(&"advance", steps * SimClock.TICK_DT)
	_wash_body(ghost)
	source.render_target_update_mode = SubViewport.UPDATE_ONCE


func _wash_body(ghost: GhostDeploy) -> void:
	var life: int = ghost.strike.attacks.deploy[ghost.form].life_ticks
	var fade_ticks: int = maxi(2, ceili(life / 3.0))
	var k: float = clampf(1.0 - float(ghost.ticks_left) / fade_ticks, 0.0, 1.0)
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
	if _fork == null:
		for node: Node in get_tree().get_nodes_in_group(OhmFork.GROUP):
			if _mount.is_ancestor_of(node):
				_fork = node as OhmFork
				break
	if _fork != null:
		var tips: PackedVector2Array = _fork.points_on(_mount)
		if tips.size() == 3:
			return position + tips[2]
	return fallback
