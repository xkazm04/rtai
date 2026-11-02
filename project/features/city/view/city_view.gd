class_name CityView
extends Node2D
## Draws the city: a camera on the CitySystem's focus, the resident chunks (ChunkView, time
## sliced) and the actors (one write_render() per frame into CrowdLayers). Reads no frame delta
## (SIM-01): everything it shows is sim state. Render only; never needed headless or in replay.
## Layers come from the render stack table (core/render/README.md): the world (this node's
## canvas: ground, decals, shadows, props, roofs), the D4 print pass (look_d4, reads the world
## through the screen texture) on the `print` canvas, the actors (look_d4_item) on `actors`.

const VIEW_MARGIN_M: float = 4.0
const LOOK_SHADER: String = "res://assets/shaders/look_d4.gdshader"
const ITEM_SHADER: String = "res://assets/shaders/look_d4_item.gdshader"

## Pixels per metre on screen / 32: 1.0 on foot, 1.5 in a car (48 px/m).
var zoom: float = 1.5
## The D4 print pass (the default look); false draws the raw art (A/B, crop tests).
var look_enabled: bool = true:
	set = set_look_enabled
## The look profile (data/tables/look_profiles.json): `auto` (D4 at gameplay zoom blending to D5
## at arena zoom), a profile id, or `off`. `-- --look=<id>` sets it at boot.
var look_id: StringName = LookProfiles.shared().default_id
## The look in use this frame (resolved from look_id at the current px/m).
var look_params: LookParams = null
var camera: Camera2D = Camera2D.new()
var chunks: ChunkView = null
var crowd: CrowdLayers = CrowdLayers.new()
## The 2D lights and the time-of-day grade (core/render/light_layer.gd), stepped on `clock`.
var lights: LightLayer = LightLayer.new()
## The pooled FX on the actors canvas's fx band (core/render/fx_system.gd).
var fx: FxSystem = FxSystem.new()
## FX cues as data (core/render/fx_triggers.gd) and the sim-snapshot reader that fires them.
var fx_triggers: FxTriggers = FxTriggers.new()
var fx_feed: CityFxFeed = CityFxFeed.new(fx_triggers)
## Objective / pickup / soul markers and the objective pointer on the world_ui canvas.
var markers: WorldMarkers = WorldMarkers.new()
## The sim clock the lights fade on (the composition root sets it; null = tick 0).
var clock: SimClock = null
## Camera feel (core/render/camera_rig.gd): when set it drives `zoom` and the camera offset each
## frame (eased zoom, look-ahead, shake); null keeps `zoom` as set (selftests, goldens, benches).
var rig: CameraRig = null
## The followed body's velocity (m/s) for the rig's look-ahead.
var follow_vel_mps: Vector2 = Vector2.ZERO
var textures: CityTextures = null
var visible_actors: int = 0
## Called with the focus (m) each frame right before the actors are written (the composition
## root hooks the characters in here: rig selection, the rig slots the crowd layer skips).
var before_render: Callable = Callable()
var warming: bool = false
var _city: CitySystem = null
var _look_rect: ColorRect = ColorRect.new()
var _look_mat: ShaderMaterial = ShaderMaterial.new()
var _item_mat: ShaderMaterial = ShaderMaterial.new()
var _actors: CanvasLayer = null
var _overlays: Array[LookOverlay] = []


func setup(city: CitySystem) -> void:
	_city = city
	add_child(camera)
	if is_inside_tree():
		camera.make_current()
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_build_layers()
	textures = CityTextures.new(CityGen.read_json(CitySystem.TEXTURES))
	chunks = ChunkView.new(get_canvas_item(), textures)
	city.sim.set_render(crowd.rids(), CrowdLayers.placeholder_clips())
	set_look_enabled(look_enabled)


func set_look_enabled(on: bool) -> void:
	look_enabled = on
	var printed: bool = on and (look_params == null or look_params.printed)
	_look_rect.visible = printed
	for node: MultiMeshInstance2D in crowd.nodes:
		node.material = _item_mat if printed else null


## Resolves look_id at the current zoom; pushes the uniforms only when the look changed.
func _update_look() -> void:
	var p: LookParams = LookProfiles.shared().resolve(look_id, zoom * SimConst.PX_PER_M)
	if p == look_params or p.equals(look_params):
		return
	var was_printed: bool = look_params == null or look_params.printed
	look_params = p
	p.apply(_look_mat, _item_mat)
	if was_printed != p.printed:
		set_look_enabled(look_enabled)


## The loading-screen prewarm (WLD-07): every texture, every actor layer and both shaders drawn
## for a couple of frames before gameplay. Await it; returns the microseconds it took.
func prewarm() -> int:
	warming = true
	if _city != null:
		_place_camera(_city.focus)
	var us: int = await ViewPrewarm.new(self).run()
	warming = false
	return us


func _process(_delta: float) -> void:
	if _city == null or warming:
		return
	var focus: Vector2 = _city.focus
	_place_camera(focus)
	chunks.update(focus, _city.residency)
	var half: Vector2 = get_viewport_rect().size * 0.5 / (zoom * SimConst.PX_PER_M)
	half += Vector2.ONE * VIEW_MARGIN_M
	if before_render.is_valid():
		before_render.call(focus)
	_city.sim.write_render(focus.x - half.x, focus.y - half.y, focus.x + half.x, focus.y + half.y)
	var counts: PackedInt32Array = _city.sim.get_render_counts()
	visible_actors = counts[SimConst.RL_PEDS] + counts[SimConst.RL_CARS] if counts.size() > 2 else 0


## Camera on the focus; world_px locks the print pass's grime and hatch to the world.
func _place_camera(focus: Vector2) -> void:
	var tick: int = clock.tick() if clock != null else 0
	var offset: Vector2 = Vector2.ZERO
	if rig != null:
		rig.step(tick, follow_vel_mps)
		zoom = rig.ppm() / SimConst.PX_PER_M
		offset = rig.offset_px(SimConst.PX_PER_M)
	camera.zoom = Vector2.ONE * zoom
	_update_look()
	camera.position = focus * SimConst.PX_PER_M + offset
	fx_triggers.rig = rig
	fx_triggers.focus_px = focus * SimConst.PX_PER_M
	var world_px: Vector2 = (camera.position * zoom).round() - get_viewport_rect().size * 0.5
	_look_mat.set_shader_parameter(&"world_px", world_px)
	var look_now: StringName = look_id if look_enabled else LookProfiles.OFF
	for o: LookOverlay in _overlays:
		o.update(look_now, zoom * SimConst.PX_PER_M, world_px)
	lights.step(tick, world_px)
	fx.step(tick)
	fx.glow.step(tick)
	fx.ground.step(tick)
	markers.step(tick)


func _build_layers() -> void:
	var look: CanvasLayer = CanvasLayer.new()
	look.layer = RenderLayers.canvas(&"print")
	var look_shader: Shader = load(LOOK_SHADER)
	_look_mat.shader = look_shader
	_look_rect.material = _look_mat
	_look_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_look_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	look.add_child(_look_rect)
	for row: Dictionary in LookProfiles.shared().overlays:
		var o: LookOverlay = LookOverlay.create(row)
		_overlays.append(o)
		look.add_child(o)
	add_child(look)
	var actors: CanvasLayer = CanvasLayer.new()
	_actors = actors
	actors.layer = RenderLayers.canvas(&"actors")
	actors.follow_viewport_enabled = true
	var item_shader: Shader = load(ITEM_SHADER)
	_item_mat.shader = item_shader
	add_child(actors)
	crowd.attach(actors)
	_build_fx(actors)


## The FX on the actors' fx band, its ground twin on the world canvas (decals band) and its
## emissive twin above the lights; all three link their lights into the light layer.
func _build_fx(actors: CanvasLayer) -> void:
	actors.add_child(fx)
	fx.lights = lights
	fx_triggers.fx = fx
	add_child(lights)
	fx.ground = FxSystem.new()
	fx.ground.z_index = RenderLayers.z(&"ground_decals")
	fx.ground.lights = lights
	add_child(fx.ground)
	var emissive: CanvasLayer = CanvasLayer.new()
	emissive.layer = RenderLayers.canvas(&"emissive")
	emissive.follow_viewport_enabled = true
	fx.glow = FxSystem.new()
	fx.glow.z_index = RenderLayers.z(&"fx_emissive")
	fx.glow.lights = lights
	emissive.add_child(fx.glow)
	add_child(emissive)
	var world_ui: CanvasLayer = CanvasLayer.new()
	world_ui.layer = RenderLayers.canvas(&"world_ui")
	world_ui.follow_viewport_enabled = true
	world_ui.add_child(markers)
	add_child(world_ui)


## The canvas layer the actors draw on (above the print pass); characters attach here.
func actor_layer() -> CanvasLayer:
	return _actors


func _exit_tree() -> void:
	if chunks != null:
		chunks.dispose()
