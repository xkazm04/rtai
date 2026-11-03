class_name CityBlood
extends Node
## Composition-root glue (LAY-05) between the city and the combat blood (features/fx/combat_blood):
## puts a CombatBlood on the city view's actors canvas, follows the view's FX cues (the riot's sim
## deaths, Rivet's hits), splats the walls the sim calls solid, and steps it on the sim tick with
## the view's world lock each frame (after the view placed its camera: it is the view's child).
## Also the muzzle's one lit frame (MuzzlePop, spending the kill beat's flash budget) and the
## kill beat (features/fx/kill_beat.gd, `-- --kill-beat`): its silhouette frames hide
## the world canvas, its print pass and the light grade, so only the actors and the blood print.

var blood: CombatBlood = CombatBlood.new()
var beat: KillBeat = null
## Blood on the dead (follow()): null until the rig feed is known.
var stains: CorpseStains = null
## The muzzle's one lit frame (features/fx/muzzle_pop.gd); null when game.muzzle_pop.on is false.
var pop: MuzzlePop = null
var _feed: RigFeed = null
var _city: CitySystem
var _view: CityView


static func attach(city: CitySystem, view: CityView) -> CityBlood:
	var glue: CityBlood = CityBlood.new()
	glue._city = city
	glue._view = view
	view.actor_layer().add_child(glue.blood)
	glue.blood.attach(view.fx_triggers)
	glue.blood.solid = glue._solid
	glue.blood.player_px = func() -> Vector2: return city.target * SimConst.PX_PER_M
	view.add_child(glue)
	var game: Dictionary = glue.blood.blood.p.get("game", {})
	var beat_default: String = game.get("kill_beat", "off")
	glue.beat = KillBeat.new(beat_default)
	glue.beat.attach(view.fx_triggers)
	glue.beat.to_uv = glue._to_uv
	var hide: Array[Node] = [view, view.lights]
	for c: Node in view.get_children():
		if c is CanvasLayer and (c as CanvasLayer).layer == RenderLayers.canvas(&"print"):
			hide.append(c)
	glue.beat.hide_on_flash(hide)
	glue.add_child(glue.beat)
	var pop_row: Dictionary = game.get("muzzle_pop", {})
	if pop_row.get("on", false):
		glue.pop = MuzzlePop.new(pop_row)
		glue.pop.budget = glue.beat.impact.budget
		glue.pop.attach(view.fx_triggers)
		view.actor_layer().add_child(glue.pop)
	return glue


## Soaks the dead of `feed` (the city's rig feed) with the blood of their kill.
func follow(feed: RigFeed) -> void:
	_feed = feed
	stains = CorpseStains.new(16, blood.blood.use_splat_mesh().colour, blood.blood.dark())
	stains.material = blood.print_material()
	_view.actor_layer().add_child(stains)
	@warning_ignore("return_value_discarded")
	blood.bled.connect(stains.on_bled)


func _process(_delta: float) -> void:
	if _view.clock != null:
		blood.step(_view.clock.tick(), _view.world_px)
		beat.step(_view.clock.tick())
		if pop != null:
			pop.step(_view.clock.tick())
		if stains != null:
			stains.step(_view.clock.tick(), _feed)


## World px -> screen uv through the view's camera.
func _to_uv(px: Vector2) -> Vector2:
	var vp: Viewport = _view.get_viewport()
	return (vp.get_canvas_transform() * px) / vp.get_visible_rect().size


func _solid(px: Vector2) -> bool:
	var c: int = _city.sim.cell_at(px.x / SimConst.PX_PER_M, px.y / SimConst.PX_PER_M)
	return c == SimConst.C_BUILD or c == SimConst.C_PROP
