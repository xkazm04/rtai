class_name CollectCallView
extends Node2D
## Draws quest 1's stage at gameplay zoom (Ink.PX_PER_M): places, people and effects in world
## space under a Camera2D that follows Rivet (or a focus the caller sets), the HUD in screen
## space. Placeholder ink only (no cutout parts yet). Reads the sim, never writes it.

var stage_view: StageView = StageView.new()
var cast_view: CastView = CastView.new()
var fx_view: FxView = FxView.new()
var hud_view: HudView = HudView.new()
var hud_feed: HudFeed = HudFeed.new()
## The slice's objective prompt and pointer (off unless the caller turns it on).
var objective_view: ObjectiveView = null
## Where the camera looks, in metres; Vector2.INF follows Rivet.
var focus: Vector2 = Vector2.INF
## Draw through the visual engine (core/render/print_stage.gd: camera, print pass, layers, world
## lock). Set false before adding the view to keep the raw placeholder ink under a plain camera
## (a caller with its own print pass, e.g. dev/noir/quest_fight.gd).
var printed: bool = true
var print_stage: PrintStage = null
## Camera scale in px per metre (48 by default; the slice plays on foot at 32, AGENTS camera).
var px_per_m: float = Ink.PX_PER_M
## Quest 1 on the generated city: the CityView (ground, roofs, crowd, its print pass and camera on
## the city's focus, which follows Rivet) draws the world, and the quest's props, cast and FX go
## on its actor layer; the invented arena's floors are not drawn. Set before adding the view.
var city_view: CityView = null
var city: CitySystem = null
var _camera: Camera2D = null
var _stage: CollectCallStage
var _system: QuestSystem


func bind(stage: CollectCallStage, port: CollectCallWorld, system: QuestSystem) -> void:
	_stage = stage
	stage_view.stage = stage
	cast_view.stage = stage
	cast_view.port = port
	fx_view.stage = stage
	_system = system


func _ready() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = RenderLayers.canvas(&"hud")
	add_child(layer)
	layer.add_child(hud_view)
	if objective_view != null:
		objective_view.stage = _stage
		objective_view.system = _system
		objective_view.px_per_m = px_per_m
		layer.add_child(objective_view)
	if city_view != null:
		_ready_on_city()
		return
	if not printed:
		for v: Node2D in [stage_view, fx_view, cast_view]:
			add_child(v)
		_camera = Camera2D.new()
		add_child(_camera)
		_camera.make_current()
		return
	print_stage = PrintStage.new()
	add_child(print_stage)
	print_stage.zoom = px_per_m / SimConst.PX_PER_M
	var k: Vector2 = Vector2.ONE * SimConst.PX_PER_M / Ink.PX_PER_M
	for v: Node2D in [stage_view, fx_view, cast_view]:
		v.scale = k
	stage_view.z_index = RenderLayers.z(&"ground")
	print_stage.add_child(stage_view)
	fx_view.z_index = RenderLayers.z(&"fx")
	fx_view.material = print_stage.item_material()
	cast_view.z_index = RenderLayers.z(&"actors")
	cast_view.material = print_stage.item_material()
	print_stage.actor_layer().add_child(cast_view)
	print_stage.actor_layer().add_child(fx_view)


func _ready_on_city() -> void:
	add_child(city_view)
	city_view.zoom = px_per_m / SimConst.PX_PER_M
	city_view.setup(city)
	stage_view.zones = false
	var k: Vector2 = Vector2.ONE * SimConst.PX_PER_M / Ink.PX_PER_M
	for v: Node2D in [stage_view, fx_view, cast_view]:
		v.scale = k
		city_view.actor_layer().add_child(v)
	# the chunks around where Rivet stands now (a Continue or Retry starts mid-street)
	@warning_ignore("return_value_discarded")
	city_view.prewarm()


func _process(_delta: float) -> void:
	hud_feed.fill(hud_view.state, _stage, _system)
	if _stage == null or city_view != null:
		return
	var at: Vector2 = focus if focus != Vector2.INF else _stage.arena.rivet.pos
	if print_stage != null:
		print_stage.place(at)
	else:
		_camera.position = Ink.px(at)
