class_name PrintStage
extends Node2D
## The visual engine as one node any gameplay view drops in (core/render/README.md, "Plugging a
## view in"): the camera (eased zoom, look-ahead, shake, hit-stop through `rig`), the world lock
## (`world_px`, zoom-anchored), the D4 print pass + the D5 overlays by look profile and zoom, the
## actors canvas with the item print, the lights + time-of-day grade, the pooled FX (ground,
## actor and emissive twins) and the world-UI markers - every one on its declared render layer.
## The view draws its world as children of this node on the world bands (RenderLayers.z), its
## people / vehicles under actor_layer() with `material = item_material()`, and calls place()
## once a frame. CityView predates it and composes the same pieces (to move onto it after the
## lanes merge). Render only: reads no frame delta, writes nothing back to the sim.

const LOOK_SHADER: String = "res://assets/shaders/look_d4.gdshader"
const ITEM_SHADER: String = "res://assets/shaders/look_d4_item.gdshader"

## Screen px per world px (1.0 = 32 px/m); the rig drives it when set.
var zoom: float = 1.5
## A look_profiles.json id, `auto` (D4 -> D5 by zoom) or `off`.
var look_id: StringName = LookProfiles.shared().default_id
var rig: CameraRig = null
var clock: SimClock = null
## A one-off camera offset in world px a host adds this frame (a power's shake with no rig,
## features/souls/hauler_kick.gd); inside the print lock like the rig's. Zero = bit-identical.
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
	add_child(_actors)
	_build_fx()


## Wires the game feel to the F-04 events on `bus` at `p_clock`'s tick: a CameraRig (made here
## if none, on foot) follows vehicles / the boss / the contract end, and the FX cues fire on
## player_hit (sparks, the weapon's own cue, rivet_hit hit-stop) and on kills by `player_id`
## (kill hit-stop). `at` returns the player's position in world px (where hit FX land).
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


## Once a frame: the camera on `focus_m` (metres) at the rig's zoom, the look for that zoom, and
## every print / light / FX / marker pass stepped on the sim tick with this frame's world_px.
func place(focus_m: Vector2) -> void:
	var tick: int = clock.tick() if clock != null else 0
	var offset: Vector2 = kick_px
	if rig != null:
		rig.follow(tick, focus_m)
		zoom = rig.ppm() / SimConst.PX_PER_M
		offset += rig.offset_px(SimConst.PX_PER_M)
	camera.zoom = ViewMode.shared().zoom_of(zoom)  # --view: exactly ONE * zoom when flat
	camera.position = focus_m * SimConst.PX_PER_M + offset
	ViewMode.eye = camera.position  # view lab: a perspective top_lift lifts away from here
	fx_triggers.rig = rig
	fx_triggers.focus_px = focus_m * SimConst.PX_PER_M
	_update_look(focus_m)
	world_px = _print_px() - get_viewport_rect().size * 0.5
	_item_mat.set_shader_parameter(&"world_px", world_px)
	_look_mat.set_shader_parameter(&"world_px", world_px)
	for o: LookOverlay in _overlays:
		o.update(look_id, zoom * SimConst.PX_PER_M, world_px)
	lights.set_page_age(LookOverlay.page_age_of(_overlays))
	lights.step(tick, world_px)
	fx.step(tick, world_px)
	fx.glow.step(tick, world_px)
	fx.ground.step(tick, world_px)
	markers.step(tick)


func _update_look(focus_m: Vector2) -> void:
	var p: LookParams = LookProfiles.shared().resolve(look_id, zoom * SimConst.PX_PER_M)
	for z: LookZone in look_zones:
		p = z.apply_to(p, z.weight(focus_m))
	if p == look_params or p.equals(look_params):
		return
	look_params = p
	_item_mat.shader = load(ITEM_SHADER) if p.printed else null
	p.apply(_look_mat, _item_mat)
	_look_rect.visible = p.printed


## As CityView._print_px: a rig zoom step moves the offset by -camera * dz (no swim).
func _print_px() -> Vector2:
	if rig != null and _print_zoom > 0.0 and zoom != _print_zoom:
		_print_off -= camera.position * (zoom - _print_zoom)
	_print_zoom = zoom
	return (camera.position * camera.zoom + _print_off).round()


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


## FX twins (ground decals on the world canvas, actor fx band, emissive above the lights), the
## light layer and the world-UI markers, as CityView._build_fx.
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
