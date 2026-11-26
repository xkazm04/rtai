class_name PrintStage
extends Node2D
## The visual engine one gameplay view drops in (core/render/README.md): camera (`rig`), world lock
## (`world_px`), D4/D5 print, actors canvas + item print (actor_layer(), item_material()), lights,
## FX, world-UI markers, each on its render layer; place() once a frame. Render only, no delta.

const LOOK_SHADER: String = "res://assets/shaders/look_d4.gdshader"
const ITEM_SHADER: String = "res://assets/shaders/look_d4_item.gdshader"
## n31-12: world_px + camera in render px (FRAGCOORD's) under the stretch; false or headless: old.
const PRINT_IN_RENDER_PX: bool = true
static var in_render_px: bool = PRINT_IN_RENDER_PX and DisplayServer.get_name() != "headless"

## Screen px per world px (1.0 = 32 px/m); the rig drives it when set.
var zoom: float = 1.5
## A look_profiles.json id, `auto` (D4 -> D5 by zoom) or `off`.
var look_id: StringName = LookProfiles.shared().default_id
var rig: CameraRig = null
var clock: SimClock = null
## n15: a host with no clock (the dev arena) gives the lights its sim tick (Callable -> int).
var light_tick: Callable = Callable()
## A one-off camera offset in world px a host adds this frame, inside the print lock (hauler_kick).
var kick_px: Vector2 = Vector2.ZERO
var camera: Camera2D = Camera2D.new()
var lights: LightLayer = LightLayer.new()
var fx: FxSystem = FxSystem.new()
var fx_triggers: FxTriggers = FxTriggers.new()
var markers: WorldMarkers = WorldMarkers.new()
## The camera's world offset in screen px this frame (every print shader's world lock).
var world_px: Vector2 = Vector2.ZERO
var look_params: LookParams = null
## Stage-local print overrides (LookZone, a close-up stage's own floor level); empty = as before.
var look_zones: Array[LookZone] = []
var _look_rect: ColorRect = ColorRect.new()
var _look_mat: ShaderMaterial = ShaderMaterial.new()
var _item_mat: ShaderMaterial = ShaderMaterial.new()
## The FX and cast views' copies of the item print, plus the amber ink when the table turns it on.
var _fx_mat: ShaderMaterial = ShaderMaterial.new()
var _cast_mat: ShaderMaterial = ShaderMaterial.new()
var _actors: CanvasLayer = CanvasLayer.new()
var _overlays: Array[LookOverlay] = []
var _print_off: Vector2 = Vector2.ZERO
var _print_zoom: float = -1.0


func _ready() -> void:
	add_child(camera)
	camera.make_current()
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_build_print()
	_actors.layer = RenderLayers.canvas(&"actors")
	_actors.follow_viewport_enabled = true
	_item_mat.shader = load(ITEM_SHADER)
	_fx_mat.shader = _item_mat.shader
	add_child(_actors)
	_build_fx()


## F-04 events on `bus`: a CameraRig (made if none), FX cues on hits/kills; `at`: player world px.
func listen(bus: EventBus, p_clock: SimClock, player_id: int, at: Callable) -> void:
	clock = p_clock
	if rig == null:
		rig = CameraRig.new()
	rig.listen(bus, p_clock)
	fx_triggers.rig = rig
	fx_triggers.player_id = player_id
	fx_triggers.listen(bus, p_clock, at)


## The canvas the view's people and vehicles go on (z bands `actors`, `vehicles`, ...).
func actor_layer() -> CanvasLayer:
	return _actors


## The per-node print (look_d4_item) every actor-canvas item sets as its material.
func item_material() -> ShaderMaterial:
	return _item_mat


## The FX view's print: the item print's uniforms, and amber as a nearest ink (n29, fire).
func fx_material() -> ShaderMaterial:
	return _fx_mat


## The cast view's print: as the FX view's (n29, electric).
func cast_material() -> ShaderMaterial:
	return _cast_mat


## Once a frame: the camera on `focus_m` (m), the look, every pass stepped with this world_px.
func place(focus_m: Vector2) -> void:
	var tick: int = clock.tick() if clock != null else 0
	var offset: Vector2 = kick_px
	if rig != null:
		rig.follow(tick, focus_m)
		zoom = rig.ppm() / SimConst.PX_PER_M
		offset += rig.offset_px(SimConst.PX_PER_M)
	camera.zoom = ViewMode.shared().zoom_of(zoom)  # --view: exactly ONE * zoom when flat
	var xf: Transform2D = get_viewport().get_final_transform()
	var cam: Vector2 = focus_m * SimConst.PX_PER_M + offset
	camera.position = snap_cam(cam, camera.zoom, xf, zoom) if in_render_px else cam
	ViewMode.eye = camera.position  # view lab: a perspective top_lift lifts away from here
	fx_triggers.rig = rig
	fx_triggers.focus_px = focus_m * SimConst.PX_PER_M
	_update_look(focus_m)
	world_px = lock_px(_print_px(), get_viewport_rect().size * 0.5, xf)
	for m: ShaderMaterial in [_item_mat, _fx_mat, _cast_mat, _look_mat]:
		m.set_shader_parameter(&"world_px", world_px)
	for o: LookOverlay in _overlays:
		o.update(look_id, zoom * SimConst.PX_PER_M, world_px)
	lights.set_page_age(LookOverlay.page_age_of(_overlays))
	lights.step(lights_tick(tick, clock, light_tick), world_px)
	for f: FxSystem in [fx, fx.glow, fx.ground]:
		f.step(tick, world_px)
	markers.step(tick)


## The tick the lights step on: the clock's, else the host's `src`, else `tick`.
static func lights_tick(tick: int, p_clock: SimClock, src: Callable) -> int:
	var t: int = src.call() if p_clock == null and src.is_valid() else tick
	return t


func _update_look(focus_m: Vector2) -> void:
	var p: LookParams = LookProfiles.shared().resolve(look_id, zoom * SimConst.PX_PER_M)
	for z: LookZone in look_zones:
		p = z.apply_to(p, z.weight(focus_m))
	if p == look_params or p.equals(look_params):
		return
	look_params = p
	_item_mat.shader = load(ITEM_SHADER) if p.printed else null
	p.apply(_look_mat, _item_mat)
	_fx_mat.shader = _item_mat.shader
	p.apply(null, _fx_mat)
	var amber: float = 1.0 if LookProfiles.shared().fx_amber_ink else 0.0
	_fx_mat.set_shader_parameter(&"amber_ink", amber)
	_cast_mat.shader = _item_mat.shader
	p.apply(null, _cast_mat)
	_cast_mat.set_shader_parameter(&"amber_ink", amber)
	_look_rect.visible = p.printed


## As CityView._print_px: a rig zoom step moves the offset by -camera * dz (no swim).
func _print_px() -> Vector2:
	if rig != null and _print_zoom > 0.0 and zoom != _print_zoom:
		_print_off -= camera.position * (zoom - _print_zoom)
	_print_zoom = zoom
	return camera.position * camera.zoom + _print_off


## `cam` (world px) on whole render px: camera zoom `cz` x the stretch `xf` (old: logical at `z`).
static func snap_cam(cam: Vector2, cz: Vector2, xf: Transform2D, z: float) -> Vector2:
	var k: Vector2 = cz * xf.get_scale() if in_render_px else Vector2.ONE * z
	return (cam * k).round() / k


## FRAGCOORD + lock_px is one value per world point, whatever the camera (FRAGCOORD = s px + o).
static func lock_px(cam_screen: Vector2, half: Vector2, xf: Transform2D) -> Vector2:
	var t: Transform2D = xf if in_render_px else Transform2D.IDENTITY
	return (cam_screen * t.get_scale()).round() - (half * t.get_scale() + t.origin)


func _build_print() -> void:
	var look: CanvasLayer = CanvasLayer.new()
	look.layer = RenderLayers.canvas(&"print")
	_look_mat.shader = load(LOOK_SHADER)
	_look_mat.set_shader_parameter(&"grime_tex", GrimeLattice.texture())
	_look_rect.material = _look_mat
	_look_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_look_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	look.add_child(_look_rect)
	for row: Dictionary in LookProfiles.shared().overlays:
		var o: LookOverlay = LookOverlay.create(row)
		_overlays.append(o)
		look.add_child(o)
	add_child(look)


## FX twins (ground decals, actor fx band, emissive), lights, world-UI markers (as CityView's).
func _build_fx() -> void:
	_actors.add_child(fx)
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
