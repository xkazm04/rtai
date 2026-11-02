class_name ViewPrewarm
extends RefCounted
## WLD-07 prewarm for a CityView: draws every draw-list texture once (one small rect each, with
## the world's mipmap filter, under the print pass) and one instance in every actor layer (with
## the item shader) for WARM_FRAMES rendered frames, so first-use texture bindings and pipeline
## compiles land on the loading screen instead of in gameplay. Headless it returns at once.

const WARM_FRAMES: int = 3
const CELL_PX: float = 12.0

var _view: CityView


func _init(view: CityView) -> void:
	_view = view


func run() -> int:
	var t0: int = Time.get_ticks_usec()
	if DisplayServer.get_name() == "headless" or not _view.is_inside_tree():
		return 0
	var centre: Vector2 = _view.camera.position
	var item: RID = _draw_textures(centre)
	_fill_actor_layers(centre)
	for i: int in WARM_FRAMES:
		await RenderingServer.frame_post_draw
	RenderingServer.free_rid(item)
	for mm: MultiMesh in _view.crowd.multimeshes:
		mm.visible_instance_count = 0
	return Time.get_ticks_usec() - t0


func _draw_textures(centre: Vector2) -> RID:
	var item: RID = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(item, _view.get_canvas_item())
	RenderingServer.canvas_item_set_default_texture_filter(item, ChunkView.MIPMAP_FILTER)
	var rids: Array[RID] = _view.textures.rids
	var cols: int = 16
	for i: int in rids.size():
		var cell: Vector2 = Vector2(i % cols, floori(float(i) / cols)) * CELL_PX
		var rect: Rect2 = Rect2(
			centre + cell - Vector2(cols, 5) * CELL_PX * 0.5, Vector2.ONE * CELL_PX
		)
		RenderingServer.canvas_item_add_texture_rect(item, rect, rids[i])
	return item


func _fill_actor_layers(centre: Vector2) -> void:
	for mm: MultiMesh in _view.crowd.multimeshes:
		var one: PackedFloat32Array = SimArrays.f32(mm.instance_count * SimConst.RL_STRIDE)
		var row: PackedFloat32Array = [
			CELL_PX, 0.0, 0.0, centre.x, 0.0, CELL_PX, 0.0, centre.y, 1, 1, 1, 1, 0, 0, 0, 0
		]
		for q: int in SimConst.RL_STRIDE:
			one[q] = row[q]
		RenderingServer.multimesh_set_buffer(mm.get_rid(), one)
		mm.visible_instance_count = 1
