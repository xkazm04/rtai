class_name CollectCallView
extends Node2D
## Draws quest 1's stage at gameplay zoom (Ink.PX_PER_M): places, people and effects in world
## space under a Camera2D that follows Rivet (or a focus the caller sets), the HUD in screen
## space. Placeholder ink only (no cutout parts yet). Reads the sim, never writes it.

var stage_view: StageView = StageView.new()
var cast_view: CastView = CastView.new()
var fx_view: FxView = FxView.new()
var hud_view: HudView = HudView.new()
## Where the camera looks, in metres; Vector2.INF follows Rivet.
var focus: Vector2 = Vector2.INF
var _camera: Camera2D = Camera2D.new()
var _stage: CollectCallStage


func bind(stage: CollectCallStage, port: CollectCallWorld, system: QuestSystem) -> void:
	_stage = stage
	stage_view.stage = stage
	cast_view.stage = stage
	cast_view.port = port
	fx_view.stage = stage
	hud_view.stage = stage
	hud_view.system = system


func _ready() -> void:
	add_child(stage_view)
	add_child(fx_view)
	add_child(cast_view)
	add_child(_camera)
	_camera.make_current()
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	layer.add_child(hud_view)


func _process(_delta: float) -> void:
	if _stage == null:
		return
	var at: Vector2 = focus if focus != Vector2.INF else _stage.arena.rivet.pos
	_camera.position = Ink.px(at)
