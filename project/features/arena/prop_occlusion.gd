class_name PropOcclusion
extends Node2D
## View lab (tilted --view only): the arena's standing props (walls, the dumpster, crate rows:
## ArenaFloorView.PROP_H_M at or over MIN_H_M) are drawn with the floor, under every actor. Under a
## tilt they rise up the screen, so a body just north of one (behind it: the camera sits south)
## would draw over it. Each frame this node, on the actor layer over the bodies, redraws every prop
## with a body behind it (the floor's own _prop: pixel-identical) and that body as an ink silhouette
## cut to the prop's drawn area: hidden, never vanished; a corpse (PropLying) is hidden, no ink. A
## body in front of such a prop whose screen box meets it is lifted over this node (FRONT_DZ).
## Only made when the view occludes (view.json `occlude`, under a tilt): `top` is bit-identical.

## Props lower than this hide nothing worth a patch (a cone).
const MIN_H_M: float = 1.0
## The silhouette's ink: the print's ink, see-through enough that the prop still reads as solid.
const SILHOUETTE: Color = Color(0.090, 0.075, 0.106, 0.8)
## Its cream rim, so it reads on a prop's dark south face (it15: the bare ink was lost there).
const RIM: Color = Color(0.949, 0.910, 0.835, 0.85)
## The silhouette's shoulder width (m): the body's, not its foreshortened hip's.
const SIL_W_M: float = 0.42
## The body box's width (m), as RigDepthSort's overlap test.
const BODY_W_M: float = 0.9
## How far a body in front of a redrawn prop is lifted (z): over roof_occluders, under fx.
const FRONT_DZ: int = 201

## Measured over the run (Log at exit): frames drawn, body-frames hidden behind a prop.
var frames: int = 0
var hidden_frames: int = 0
## The first and last frame a body was hidden (-1: none), for filming the case.
var first_hidden: int = -1
var last_hidden: int = -1
var _floor: ArenaFloorView = null
var _layer: Node = null
## This frame's hidden bodies.
var _hits: Array[Hit] = []
## This frame's bodies in front of a prop that meets their screen box, and that prop (parallel).
var _front: Array[CutRig] = []
var _front_of: Array[ArenaStation.Prop] = []
var _ends: PackedVector2Array = PackedVector2Array()  # each rig's (feet, head) this frame


## A body hidden behind a prop: the prop's drawn area (local px), the prop, the body's feet, head.
class Hit:
	var area: Rect2
	var cut: Array[PackedVector2Array]  # the silhouette's cut: the card's outline(s), else area
	var prop: ArenaStation.Prop
	var feet: Vector2
	var head: Vector2


## The arena's view (tilted --view only): on the print stage's actor layer, else the city's.
static func for_view(view: CollectCallView) -> void:
	var ps: PrintStage = view.print_stage
	var floor_view: ArenaFloorView = view.stage_view as ArenaFloorView
	if ps != null:
		attach(ps.actor_layer(), floor_view, ps.item_material())
	elif view.city_view != null:
		attach(view.city_view.actor_layer(), floor_view, null)


## Adds the occluder over the actors on `layer` under a tilted view; else nothing. `print_mat` is
## the actor layer's per-item print (null on the city's actor layer, which the floor sits on).
static func attach(layer: Node, floor_view: ArenaFloorView, print_mat: Material) -> void:
	if not ViewMode.shared().occlude or floor_view == null:
		return
	var o: PropOcclusion = PropOcclusion.new()
	o._floor = floor_view
	o._layer = layer
	o.scale = floor_view.scale
	o.material = print_mat
	o.z_index = RenderLayers.z(&"roof_occluders")
	o.process_priority = 101  # after RigDepthSort has set this frame's z: FRONT_DZ goes on top
	layer.add_child(o)


func _process(_delta: float) -> void:
	_hits = hits()
	_lift_front()
	frames += 1
	hidden_frames += _hits.size()
	if not _hits.is_empty():
		first_hidden = frames if first_hidden < 0 else first_hidden
		last_hidden = frames
	queue_redraw()


func _exit_tree() -> void:
	var span: String = "frames %d-%d" % [first_hidden, last_hidden]
	var n: String = "%d body-frames hidden over %d frames" % [hidden_frames, frames]
	Log.info("view", "occlusion: %s, %s" % [n, span])


## Lifts every body in front of a prop this node redraws over it (RigDepthSort reset its z).
func _lift_front() -> void:
	var redrawn: Dictionary[ArenaStation.Prop, bool] = {}
	for h: Hit in _hits:
		redrawn[h.prop] = true
	var lifted: Dictionary[CutRig, bool] = {}
	for i: int in _front.size():
		if redrawn.has(_front_of[i]) and not lifted.has(_front[i]):
			lifted[_front[i]] = true
			_front[i].z_index += FRONT_DZ
	if lifted.is_empty():
		return
	for c: Node in _layer.get_children():  # Rivet's held weapon and magazine ride his lift
		var rig: CutRig = RigDepthSort.rig_of(c)
		if rig != null and lifted.has(rig):
			(c as CanvasItem).z_index += FRONT_DZ


## The props with a body behind them, then each such body's silhouette cut to its prop's area.
func _draw() -> void:
	var base: Vector2 = (
		(_floor.stage as ArenaStage).plan.base if not _hits.is_empty() else Vector2()
	)
	var done: Dictionary[ArenaStation.Prop, bool] = {}
	for h: Hit in _hits:
		if not done.has(h.prop):
			done[h.prop] = true
			_floor._prop(self, base + h.prop.at, h.prop)
	for h: Hit in _hits:
		for cut: PackedVector2Array in h.cut:
			for part: PackedVector2Array in Geometry2D.intersect_polygons(
				silhouette(h.feet, h.head), cut
			):
				if not Geometry2D.triangulate_polygon(part).is_empty():  # a sliver: no ink
					draw_colored_polygon(part, SILHOUETTE)
					@warning_ignore("return_value_discarded")
					part.append(part[0])
					draw_polyline(part, RIM, Ink.LINE_PX * 0.5)


## An upright body from `feet` to `head` (local px): RigCastShadows' figure, its shoulders SIL_W_M.
static func silhouette(feet: Vector2, head: Vector2) -> PackedVector2Array:
	var hip: float = maxf((feet.y - head.y) / RigCastShadows.BODY_IN_HIPS, 1.0)
	var fig: PackedVector2Array = RigCastShadows.figure(feet, Vector2.UP, hip)
	var k: float = SIL_W_M * Ink.PX_PER_M / (hip * RigCastShadows.WIDTH_IN_HIPS)
	for i: int in fig.size():
		fig[i].x = feet.x + (fig[i].x - feet.x) * k
	return fig


## Every (body, prop) pair where the body stands behind the prop and its screen box meets the
## prop's drawn area, in this node's local px.
func hits() -> Array[Hit]:
	var out: Array[Hit] = []
	var arena: ArenaStage = _floor.stage as ArenaStage
	var sorter: RigDepthSort = RigDepthSort.on(_layer)  # its rigs: this frame's, collected once
	if arena == null or sorter == null:
		return out
	_front.clear()
	_front_of.clear()
	var rigs: Array[CutRig] = sorter.frame_rigs
	_ends.clear()
	var lift: Vector2 = ViewMode.shared().lift_px(1.0) * RigCastShadows.BODY_IN_HIPS
	for rig: CutRig in rigs:
		var hip: float = RigCastShadows.hip_px(rig)
		var head: Vector2 = rig.global_position + lift * hip / SimConst.PX_PER_M
		_ends += PackedVector2Array([to_local(rig.global_position), to_local(head)])
	for s: ArenaStation in arena.stations.stations:
		for p: ArenaStation.Prop in s.props:
			if ArenaFloorView.PROP_H_M.get(p.kind, 0.0) >= MIN_H_M:
				_hits_of(arena.plan.base + p.at, p, rigs, out)
	return out


func _hits_of(at: Vector2, p: ArenaStation.Prop, rigs: Array[CutRig], out: Array[Hit]) -> void:
	var r: Rect2 = Rect2(Ink.px(at - p.size * 0.5), p.size * Ink.PX_PER_M)
	var area: Rect2 = drawn_area(r, p)
	var cut: Array[PackedVector2Array] = []
	for i: int in rigs.size():
		var feet: Vector2 = _ends[i * 2]
		if not PropLying.patch(self, rigs[i], feet, _ends[i * 2 + 1], area).has_area():
			continue
		var h: Hit = Hit.new()
		h.area = area
		cut = ArenaPropCards.cut_polys(p.kind, r, area) if cut.is_empty() else cut
		h.cut = cut
		h.prop = p
		h.feet = feet
		h.head = feet if rigs[i].dead and PropLying.ON else _ends[i * 2 + 1]  # a corpse: no ink
		if feet.y < r.position.y:  # north of the prop's north edge: behind it
			out.append(h)
		else:
			_front.append(rigs[i])
			_front_of.append(p)


## The prop's drawn area (local px): city's card (ArenaPropCards.stand_rect), else the box lifted.
func drawn_area(r: Rect2, p: ArenaStation.Prop) -> Rect2:
	var card: Rect2 = ArenaPropCards.stand_rect(p.kind, r)
	if card.has_area():
		return card
	var h_m: float = ArenaFloorView.PROP_H_M.get(p.kind, 0.0)
	var up: Vector2 = ViewMode.shared().lift_at(get_global_transform() * r.get_center(), h_m)
	return Rect2(r.position + Vector2(0.0, up.y), r.size + Vector2(0.0, -up.y))


## The part of a body's screen box (feet to head, local px) inside a prop's drawn `area`.
static func body_patch(feet: Vector2, head: Vector2, area: Rect2) -> Rect2:
	var w: float = BODY_W_M * Ink.PX_PER_M
	var body: Rect2 = Rect2(feet.x - w * 0.5, head.y, w, feet.y - head.y)
	return body.grow(Ink.LINE_PX).intersection(area)
