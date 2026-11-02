class_name CityView
extends Node2D
## Draws the city: a camera on the CitySystem's focus, the resident chunks (ChunkView, time
## sliced) and the actors (one write_render() per frame into CrowdLayers). Reads no frame delta
## (SIM-01): everything it shows is sim state. Render only; never needed headless or in replay.

const VIEW_MARGIN_M: float = 4.0

## Pixels per metre on screen / 32: 1.0 on foot, 1.5 in a car (48 px/m).
var zoom: float = 1.5
var camera: Camera2D = Camera2D.new()
var chunks: ChunkView = null
var crowd: CrowdLayers = CrowdLayers.new()
var visible_actors: int = 0
var _city: CitySystem = null


func setup(city: CitySystem) -> void:
	_city = city
	add_child(camera)
	if is_inside_tree():
		camera.make_current()
	crowd.attach(self)
	var textures: CityTextures = CityTextures.new(CityGen.read_json(CitySystem.TEXTURES))
	chunks = ChunkView.new(get_canvas_item(), textures)
	city.sim.set_render(crowd.rids(), CrowdLayers.placeholder_clips())


func _process(_delta: float) -> void:
	if _city == null:
		return
	var focus: Vector2 = _city.focus
	camera.zoom = Vector2.ONE * zoom
	camera.position = focus * SimConst.PX_PER_M
	chunks.update(focus, _city.residency)
	var half: Vector2 = get_viewport_rect().size * 0.5 / (zoom * SimConst.PX_PER_M)
	half += Vector2.ONE * VIEW_MARGIN_M
	_city.sim.write_render(focus.x - half.x, focus.y - half.y, focus.x + half.x, focus.y + half.y)
	var counts: PackedInt32Array = _city.sim.get_render_counts()
	visible_actors = counts[SimConst.RL_PEDS] + counts[SimConst.RL_CARS] if counts.size() > 2 else 0


func _exit_tree() -> void:
	if chunks != null:
		chunks.dispose()
