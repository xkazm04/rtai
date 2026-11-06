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
var hud_feed: HudFeed = HudFeed.new()
## The save notice (Save.take_notice after a load); the game calls `notice.show(line)`.
var notice: SaveNotice = SaveNotice.new()
## The slice's objective prompt and pointer (off unless the caller turns it on).
var objective_view: ObjectiveView = null
## Where the camera looks, in metres; Vector2.INF follows Rivet.
var focus: Vector2 = Vector2.INF
## On the city: a view-only camera lean off the city focus (m; the dev `--cam=fight`), so the sim
## focus that streams the chunks stays on Rivet. Zero = bit-identical.
var city_lean_m: Vector2 = Vector2.ZERO
## View only: how far (m) the camera sits below the focus so a big ghost body clears the subtitle
## box (StoryForms writes it on quest 1). Zero = bit-identical.
var forms_lift_m: float = 0.0
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
## Camera scale in px per metre (48 by default; the slice plays on foot at 32, AGENTS camera).
var px_per_m: float = Ink.PX_PER_M
## Quest 1 on the generated city: the CityView (ground, roofs, crowd, its print pass and camera on
## the city's focus, which follows Rivet) draws the world, and the quest's props, cast and FX go
## on its actor layer; the invented arena's floors are not drawn. Set before adding the view.
var city_view: CityView = null
var city: CitySystem = null
## The Hauler stomp's shake and hit-stop (features/souls/hauler_kick.gd).
var hauler_kick: HaulerKick = HaulerKick.new()
## The camera side of the shared hit feel (features/combat/hit_feel/feel_cam.gd, lane n7-ranged).
var feel_cam: FeelCam = null
## n7-melee: Rivet's melee hits on the same FeelCam (they land with no `struck`).
var melee_feel: MeleeFeel = null
var _feel_px: Vector2 = Vector2.ZERO
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
	_ready_blood(print_stage.actor_layer())


## The combat blood and corpse stains (d5-combat) on `layer`: the printed path's actor layer, or
## the CityView's on the city (quest 1 on the generated city, the arena's city block).
func _ready_blood(layer: CanvasLayer) -> void:
	if _stage != null and _stage.events() != null:
		blood = CombatBlood.new()
		layer.add_child(blood)
		blood.listen(_stage.events(), _locate, _stage.arena.rivet.id)
		stains = CorpseStains.new(BODIES, blood.blood.use_splat_mesh().colour, blood.blood.dark())
		stains.material = blood.print_material()
		layer.add_child(stains)
		@warning_ignore("return_value_discarded")
		blood.bled_body.connect(stains.on_bled_body)


func _ready_on_city() -> void:
	add_child(city_view)
	city_view.zoom = px_per_m / SimConst.PX_PER_M
	city_view.setup(city)
	stage_view.zones = false
	var k: Vector2 = Vector2.ONE * SimConst.PX_PER_M / Ink.PX_PER_M
	for v: Node2D in [stage_view, fx_view, cast_view]:
		v.scale = k
		city_view.actor_layer().add_child(v)
	_ready_blood(city_view.actor_layer())
	# pipelines warmed with the camera where Rivet stands now (a Continue or Retry starts
	# mid-street), and that street drawn at once instead of over many budgeted frames
	@warning_ignore("return_value_discarded")
	city_view.prewarm()
	Log.info("quest1", "street filled in %d chunk passes" % fill_street())


## Draws every resident chunk around the city focus now: the chunk view streams under a per-frame
## budget, so after a jump (Continue, Retry, a dev still) the street would draw in over many
## frames. The sim's residency is not touched (that steps on the tick). Returns the passes taken.
func fill_street(max_passes: int = 600) -> int:
	if city_view == null or city == null or city_view.chunks == null:
		return 0
	var n: int = 0
	while n < max_passes:
		city_view.chunks.update(city.focus, city.residency, city_view.zoom)
		n += 1
		if not city_view.chunks.frame_swapped:
			break
	return n


func _process(_delta: float) -> void:
	hud_feed.fill(hud_view.state, _stage, _system)
	hud_view.state.notice = notice.text()
	_hauler_kick()
	_feel_kick()
	if _stage == null:
		return
	if city_view != null:
		# the CityView (a child) places its camera after this: its world_px is last frame's
		_step_blood(city_view.world_px)
		return
	var at: Vector2 = focus if focus != Vector2.INF else _stage.arena.rivet.pos
	if print_stage != null:
		print_stage.place(at)
		_step_blood(print_stage.world_px)
	else:
		_camera.position = Ink.px(at)


func _step_blood(world_px: Vector2) -> void:
	if blood == null:
		return
	blood.step(_stage.tick, world_px)
	stains.walkers = PackedVector2Array([_stage.arena.rivet.pos * SimConst.PX_PER_M])
	stains.step_bodies(_stage.tick, _dead_px())


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


## features/souls: a Hauler stomp landing shakes the camera and holds the clock (hit-stop), on
## the city (quest 1) and on the printed floor (the arena's pit and pad).
func _hauler_kick() -> void:
	if _stage == null or _stage.pilot == null or (city_view == null and print_stage == null):
		return
	hauler_kick.reduced_motion = fx_view.reduced_motion
	var clock: SimClock = _stage.clock
	if city_view != null and city_view.clock != null:
		clock = city_view.clock
	var h: HaulerStage = _stage.pilot.hauler
	var glide_m: Vector2 = KerfGlide.offset_m(_stage.pilot.kerf, _stage.tick)
	if city_view != null:
		var lean_px: Vector2 = (
			(city_lean_m + glide_m + Vector2(0.0, forms_lift_m)) * SimConst.PX_PER_M
		)
		city_view.kick_px = hauler_kick.step(h, _stage.tick, clock, city_view.rig) + lean_px
	else:
		var lift_px: Vector2 = (glide_m + Vector2(0.0, forms_lift_m)) * SimConst.PX_PER_M
		print_stage.kick_px = hauler_kick.step(h, _stage.tick, clock, print_stage.rig) + lift_px


## Every round Rivet lands shakes, kicks and stops the camera by the shared hit feel (FeelCam), on
## top of whatever _hauler_kick wrote this frame. View only (SimClock.hold, a camera offset).
func _feel_kick() -> void:
	if _stage == null or (city_view == null and print_stage == null):
		return
	var clock: SimClock = city_view.clock if city_view != null and city_view.clock != null else null
	if feel_cam == null:
		feel_cam = FeelCam.attach(_stage.arena, clock if clock != null else _stage.clock)
		melee_feel = MeleeFeel.attach(feel_cam, _stage.arena)
	feel_cam.reduced_motion = fx_view.reduced_motion
	var zoom: float = city_view.zoom if city_view != null else print_stage.zoom
	var now: Vector2 = feel_cam.offset_px(_stage.tick, zoom)
	# with a pilot _hauler_kick rewrote kick_px this frame; without one, take last frame's back out
	var add: Vector2 = now if _stage.pilot != null else now - _feel_px
	_feel_px = now
	if city_view != null:
		city_view.kick_px += add
	else:
		print_stage.kick_px += add
