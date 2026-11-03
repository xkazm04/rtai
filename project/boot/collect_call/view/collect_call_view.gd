class_name CollectCallView
extends Node2D
## Draws quest 1's stage at gameplay zoom (Ink.PX_PER_M): places, people and effects in world
## space under a Camera2D that follows Rivet (or a focus the caller sets), the HUD in screen
## space. Placeholder ink only (no cutout parts yet). Reads the sim, never writes it.

## Quest 1's dead never despawn (49 by the payout): one stain node each, drawn once.
const BODIES: int = 64

var stage_view: StageView = StageView.new()
var cast_view: CastView = CastView.new()
var fx_view: FxView = FxView.new()
var hud_view: HudView = HudView.new()
## Where the camera looks, in metres; Vector2.INF follows Rivet.
var focus: Vector2 = Vector2.INF
## Draw through the visual engine (core/render/print_stage.gd: camera, print pass, layers, world
## lock). Set false before adding the view to keep the raw placeholder ink under a plain camera
## (a caller with its own print pass, e.g. dev/noir/quest_fight.gd).
var printed: bool = true
var print_stage: PrintStage = null
## The combat blood (features/fx/combat_blood.gd, noir's blood in D4/D5) on the printed path:
## guards and the boss bleed on Events.actor_killed, Rivet leaks oil on player_hit.
var blood: CombatBlood = null
## Blood soaked into the dead guards (features/fx/corpse_stains.gd), with the blood.
var stains: CorpseStains = null
var _camera: Camera2D = null
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
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = RenderLayers.canvas(&"hud")
	add_child(layer)
	layer.add_child(hud_view)
	if not printed:
		for v: Node2D in [stage_view, fx_view, cast_view]:
			add_child(v)
		_camera = Camera2D.new()
		add_child(_camera)
		_camera.make_current()
		return
	print_stage = PrintStage.new()
	add_child(print_stage)
	print_stage.zoom = Ink.PX_PER_M / SimConst.PX_PER_M
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
	if _stage != null and _stage.events() != null:
		blood = CombatBlood.new()
		print_stage.actor_layer().add_child(blood)
		blood.listen(_stage.events(), _locate, _stage.arena.rivet.id)
		stains = CorpseStains.new(BODIES, blood.blood.use_splat_mesh().colour)
		stains.material = blood.print_material()
		print_stage.actor_layer().add_child(stains)
		@warning_ignore("return_value_discarded")
		blood.bled.connect(stains.on_bled)


func _process(_delta: float) -> void:
	if _stage == null:
		return
	var at: Vector2 = focus if focus != Vector2.INF else _stage.arena.rivet.pos
	if print_stage != null:
		print_stage.place(at)
		if blood != null:
			blood.step(_stage.tick, print_stage.world_px)
			stains.step_bodies(_stage.tick, _dead_px())
	else:
		_camera.position = Ink.px(at)


## Where fighter `id` stands (metres), or Vector2.INF.
func _locate(id: int) -> Vector2:
	var arena: CombatArena = _stage.arena
	if id == arena.rivet.id:
		return arena.rivet.pos
	for h: Fighter in arena.hostiles:
		if h.id == id:
			return h.pos
	return Vector2.INF


## The dead hostiles: id -> where they lie (px).
func _dead_px() -> Dictionary[int, Vector2]:
	var out: Dictionary[int, Vector2] = {}
	for h: Fighter in _stage.arena.hostiles:
		if not h.alive():
			out[h.id] = h.pos * SimConst.PX_PER_M
	return out
