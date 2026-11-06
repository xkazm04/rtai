class_name CityOcclusion
extends Node2D
## The city's buildings over a body behind them (night n8, lane city; brief item 2). The world
## canvas (ChunkView, ChunkLift's lifted roofs and south faces) is under the whole actors canvas,
## so under a tilt a body just north of a building draws ON its lifted roof. Each frame this node,
## on the actors canvas at roof_occluders, redraws every building with a body behind it (face and
## roof, ChunkLift's own draw: the same commands) and that body as an ink silhouette cut to the
## building's drawn area, in PropOcclusion's look (its SILHOUETTE, RIM, SIL_W_M, FRONT_DZ: the
## view lane's answer). A body in front of a redrawn building whose box meets it is lifted over
## this node for the frame. Only under a lifted view that occludes: `top` never makes one.
## Render only: reads the chunks, the rigs and the view; writes nothing but z on the rigs it lifts.

## A body's screen height (m at the ground's px per metre) for the patch and the silhouette: the
## cards stand upright under a tilt (Rivet's reads ~1.6 m tall at 70), so it is not foreshortened.
const BODY_H_M: float = 1.7
## A body's feet this far (px) inside a building's north edge still count as behind it.
const NORTH_TOL_PX: float = 4.0

## Measured over the run (Log at exit): frames, body-frames hidden behind a building.
var frames: int = 0
var hidden_frames: int = 0
var _lift: ChunkLift = null
var _tex: CityTextures = null
var _city: CitySystem = null
var _view: CityView = null
var _print: Material = null
var _layer: Node = null
var _draw_set: Array[Bld] = []
var _hits: Array[PackedVector2Array] = []
var _hit_area: Array[Rect2] = []


## A building on the ground (px): its texture, turn, ground centre and rect, drawn area.
class Bld:
	var t: int
	var rot: float
	var at: Vector2
	var r: Rect2
	var area: Rect2


## Adds the occluder to the city's actors canvas when the chunks are lifted and the view occludes.
static func attach(view: CityView, city: CitySystem, print_mat: Material) -> void:
	var lift: ChunkLift = view.chunks.lift
	if lift == null or not lift.occlude or not ViewMode.shared().occlude:
		return
	var o: CityOcclusion = CityOcclusion.new()
	o._lift = lift
	o._tex = view.textures
	o._city = city
	o._layer = view.actor_layer()
	o._view = view
	o._print = print_mat
	o.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	o.z_index = RenderLayers.z(&"roof_occluders")
	o.process_priority = 101  # after RigDepthSort has set this frame's z
	o._layer.add_child(o)


func _process(_delta: float) -> void:
	var printed: bool = _view.look_params == null or _view.look_params.printed
	material = _print if _view.look_enabled and printed else null  # as the crowd's print
	_scan()
	frames += 1
	hidden_frames += _hits.size()
	queue_redraw()


func _exit_tree() -> void:
	Log.info("city", "occlusion: %d body-frames hidden over %d frames" % [hidden_frames, frames])


## This frame's hits: buildings with a body behind them, the body's silhouettes, the bodies to lift.
func _scan() -> void:
	_draw_set.clear()
	_hits.clear()
	_hit_area.clear()
	var rigs: Array[CutRig] = []
	for c: Node in _layer.get_children():
		RigCastShadows.collect(c, 0, rigs)
	var front: Dictionary[CutRig, Rect2] = {}
	var seen: Dictionary[Vector3, Bld] = {}
	var hit_of: Dictionary[Vector3, bool] = {}
	for rig: CutRig in rigs:
		var feet: Vector2 = rig.global_position
		var head: Vector2 = feet - Vector2(0.0, BODY_H_M * SimConst.PX_PER_M)
		for b: Bld in buildings_near(feet / SimConst.PX_PER_M):
			var key: Vector3 = Vector3(b.at.x, b.at.y, b.t)
			if not seen.has(key):
				seen[key] = b
			if not PropOcclusion.body_patch(feet, head, b.area).has_area():
				continue
			if feet.y < b.r.position.y + NORTH_TOL_PX:
				hit_of[key] = true
				_hits.append(silhouette(feet, head))
				_hit_area.append(b.area)
			else:
				front[rig] = b.area
	_pick_draw_set(seen, hit_of)
	var lifted: Dictionary[CutRig, bool] = {}
	for rig: CutRig in front:
		for a: Rect2 in _hit_area:
			if a.intersects(front[rig]):
				lifted[rig] = true
	_lift_front(lifted)


## The hit buildings, plus every building in front of one (a later south edge) that overlaps its
## drawn area (so the redraw keeps the painter's order), south edges last.
func _pick_draw_set(seen: Dictionary[Vector3, Bld], hit_of: Dictionary[Vector3, bool]) -> void:
	for key: Vector3 in seen:
		var c: Bld = seen[key]
		var take: bool = hit_of.has(key)
		for h: Vector3 in hit_of:
			var hb: Bld = seen[h]
			take = take or (c.r.end.y > hb.r.end.y and c.area.intersects(hb.area))
		if take:
			_draw_set.append(c)
	_draw_set.sort_custom(func(a: Bld, b: Bld) -> bool: return a.r.end.y < b.r.end.y)


## Lifts the bodies in front of a redrawn building over this node (RigDepthSort reset their z).
func _lift_front(lifted: Dictionary[CutRig, bool]) -> void:
	if lifted.is_empty():
		return
	for c: Node in _layer.get_children():  # the held weapon and magazine ride their rig's lift
		var rig: CutRig = RigDepthSort.rig_of(c)
		if rig != null and lifted.has(rig):
			(c as CanvasItem).z_index += PropOcclusion.FRONT_DZ


## The buildings of the resident chunks around a ground point (m), with their drawn areas.
func buildings_near(at_m: Vector2) -> Array[Bld]:
	var out: Array[Bld] = []
	var keys: Dictionary[Vector2i, bool] = {}
	for d: Vector2 in [Vector2(-16, -4), Vector2(16, -4), Vector2(-16, 28), Vector2(16, 28)]:
		var p: Vector2 = (at_m + d) / SimConst.CHUNK_M
		keys[Vector2i(floori(p.x), floori(p.y))] = true
	for key: Vector2i in keys:
		var res: CityResidency = _city.residency
		var chunk: CityChunk = res.chunk_at(key) if res.is_resident(key) else null
		if chunk != null:
			_collect(chunk, at_m * SimConst.PX_PER_M, out)
	return out


func _collect(chunk: CityChunk, near_px: Vector2, out: Array[Bld]) -> void:
	var reach: float = 40.0 * SimConst.PX_PER_M
	for k: int in chunk.command_count():
		var t: int = chunk.tex[k]
		var o: int = k * CityChunk.XF_STRIDE
		if not _lift.is_building_tex(t) or chunk.xf[o + 3] > 0.5:
			continue
		var at: Vector2 = Vector2(chunk.xf[o], chunk.xf[o + 1]) * SimConst.PX_PER_M
		if absf(at.x - near_px.x) > reach or absf(at.y - near_px.y) > reach:
			continue
		var b: Bld = Bld.new()
		b.t = t
		b.rot = chunk.xf[o + 2]
		b.at = at
		var ext: Vector2 = _lift.extent(t, b.rot)
		b.r = Rect2(at - ext * 0.5, ext)
		var up: float = -_lift.lift_of(t).y
		b.area = Rect2(b.r.position - Vector2(0.0, up), b.r.size + Vector2(0.0, up))
		out.append(b)


## PropOcclusion's upright figure, its shoulders SIL_W_M at the city's px per metre.
static func silhouette(feet: Vector2, head: Vector2) -> PackedVector2Array:
	var fig: PackedVector2Array = PropOcclusion.silhouette(feet, head)
	var k: float = SimConst.PX_PER_M / Ink.PX_PER_M
	for i: int in fig.size():
		fig[i].x = feet.x + (fig[i].x - feet.x) * k
	return fig


## The buildings with a body behind them (south edges last), then each silhouette cut to its area.
func _draw() -> void:
	var item: RID = get_canvas_item()
	for b: Bld in _draw_set:
		var roof: Vector2 = _lift.face(item, b.t, b.rot, b.at)
		var sz: Vector2 = _tex.size_px[b.t]
		RenderingServer.canvas_item_add_set_transform(item, Transform2D(b.rot, roof))
		RenderingServer.canvas_item_add_texture_rect(item, Rect2(-sz * 0.5, sz), _tex.rids[b.t])
	RenderingServer.canvas_item_add_set_transform(item, Transform2D.IDENTITY)
	for i: int in _hits.size():
		var r: Rect2 = _hit_area[i]
		var box: PackedVector2Array = PackedVector2Array(
			[r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
		)
		for part: PackedVector2Array in Geometry2D.intersect_polygons(_hits[i], box):
			if not Geometry2D.triangulate_polygon(part).is_empty():
				draw_colored_polygon(part, PropOcclusion.SILHOUETTE)
				@warning_ignore("return_value_discarded")
				part.append(part[0])
				draw_polyline(part, PropOcclusion.RIM, Ink.LINE_PX * 0.5)
