class_name ArenaFloorView
extends StageView
## The dev arena's floor in quest 1's ink (StageView's tiles and labels): every area of the plan
## as a dock-floor slab with its stencilled name, the stations' props (cover, walls, cones, the
## firing line, lane marks) and a range ring under each dummy. Reads the sim, never writes it.

const PROP_FILL: Dictionary[String, Color] = {
	"wall_high": Color("#17131B"),
	"cover_high": Color("#17131B"),
	"cover_low": Color(0.090, 0.075, 0.106, 0.55),
	"door": Color(0.090, 0.075, 0.106, 0.18),
	"cone": Color("#E8502A"),
	"firing_line": Color("#E8502A"),
}
const FLOOR_TILE_M: float = 8.0
## The area's stencilled name, this far in from its top edge (below a station's edge wall).
const LABEL_M: float = 2.2
## The city's inked props as the arena's cover, so the arena reads as the game, not a sketch:
## low cover is a row of crates (one crate of the stack, repeated along the box), high cover a
## dumpster, the course's cones the street cone. Walls stay solid ink (architecture).
## View lab: each solid prop kind's height (m) under a tilted --view (others are paint: 0).
## top_lift: the swept slices that extrude a prop toward its leaning top.
const PROP_SLICES: int = 8
const PROP_H_M: Dictionary[String, float] = {
	"cone": 0.7, "cover_low": 1.0, "cover_high": 1.6, "wall_high": 3.0
}
const CRATES: Texture2D = preload("res://features/city/art/props/crate_stack.png")
const CRATE_PX: Rect2 = Rect2(0.0, 0.0, 80.0, 80.0)
const DUMPSTER: Texture2D = preload("res://features/city/art/props/dumpster.png")
const CONE: Texture2D = preload("res://features/city/art/props/traffic_cone.png")
## On the city block a pit wall is a row of inked concrete barrier segments (still solid), not
## the arena's flat ink bar: the street's warm grey, a cream top edge, a joint every BARRIER_M.
const BARRIER_FILL: Color = Color("#8E867C")
const BARRIER_M: float = 2.0

## Off-screen margin for the target rings and tracks (m): wider than a ring (0.8 m) plus its line
## and anything the print pass samples around a pixel.
const CULL_M: float = 3.0

var _city: bool = false
## perf-city: on the city block the props and the crowd rings are drawn once on this child (behind
## this node, with its material: the same order and print), not re-issued every frame (0.5 ms of
## a 60 fps frame in the city fight). Props and spawns never change after the stations load.
var _static: Node2D = null
var _static_of: ArenaStage = null


func _draw() -> void:
	var arena: ArenaStage = stage as ArenaStage
	if arena == null:
		return
	_city = arena.cells != null
	for a: ArenaPlan.Area in arena.plan.areas:
		if arena.cells == null:  # on the city proving block the city is the floor
			_tiled(a.rect, "dock_floor", FLOOR_TILE_M)
			_floor(a.rect, Color(0, 0, 0, 0), "")
	if _city:
		_held(arena)
	else:
		_props(self, arena)
	for b: VehicleBody in arena.cars():
		_car(b)
	draw_set_transform(Vector2.ZERO)
	for a: ArenaPlan.Area in arena.plan.areas:  # over the props: a wall never hides a name
		if arena.cells == null:
			Ink.label(
				self, a.rect.position + Vector2(a.rect.size.x * 0.5, LABEL_M), a.name, 30, Ink.INK
			)
	var view: Rect2 = _view_m()
	for t: ArenaTargets.Target in arena.targets.targets:
		var up: bool = t.fighter.exposed
		if view.has_point(t.fighter.pos):
			_ring(t.fighter.pos, 0.8, Ink.INK if up else Ink.WASH)
		if t.spawn.motion != "static":
			_track(t, view)


## perf-city: the world rect on screen in metres, CULL_M wider each side. A target ring or track
## outside it draws nothing visible, so it is not issued (19 rings were 0.3-0.4 ms a frame).
func _view_m() -> Rect2:
	var px: Rect2 = get_global_transform_with_canvas().affine_inverse() * get_viewport_rect()
	return Rect2(px.position / Ink.PX_PER_M, px.size / Ink.PX_PER_M).grow(CULL_M)


func _held(arena: ArenaStage) -> void:
	if _static == null:
		_static = Node2D.new()
		_static.show_behind_parent = true
		_static.use_parent_material = true
		add_child(_static)
		@warning_ignore("return_value_discarded")
		_static.draw.connect(func() -> void: _props(_static, _static_of))
	if _static_of != arena or ViewMode.shared().eye_h_m > 0.0:  # a perspective eye moves
		_static_of = arena
		_static.queue_redraw()


## The stations' props (on the city only what collides, and cones) and the crowd spawn rings.
func _props(ci: CanvasItem, arena: ArenaStage) -> void:
	if arena == null:
		return
	for s: ArenaStation in arena.stations.stations:
		for p: ArenaStation.Prop in s.props:
			if not _city or p.kind in ArenaWalls.SOLID or p.kind == "cone":
				_prop(ci, arena.plan.base + p.at, p)
		for sp: ArenaStation.Spawn in s.spawns:
			if sp.kind == "crowd":
				_ring(arena.plan.base + sp.at, sp.span_m, Ink.WASH, ci)


func _prop(ci: CanvasItem, at: Vector2, p: ArenaStation.Prop) -> void:
	var fill: Color = PROP_FILL.get(p.kind, Ink.WASH)
	var r: Rect2 = Rect2(Ink.px(at - p.size * 0.5), p.size * Ink.PX_PER_M)
	var h_m: float = PROP_H_M.get(p.kind, 0.0)
	var up: Vector2 = ViewMode.shared().lift_at(ci.get_global_transform() * r.get_center(), h_m)
	if ViewMode.shared().eye_h_m > 0.0 and up != Vector2.ZERO:  # top_lift: swept, leaning out
		for i: int in PROP_SLICES:
			ci.draw_rect(
				Rect2(r.position + up * (float(i) / PROP_SLICES), r.size), fill.darkened(0.45)
			)
		r.position += up
		ci.draw_rect(r.grow(1.0), Ink.INK, false, Ink.LINE_PX)
	elif up != Vector2.ZERO:  # view lab: the south face, then the top at the prop's height
		var face: Rect2 = Rect2(r.position.x, r.end.y + up.y, r.size.x, -up.y)
		ci.draw_rect(face, fill.darkened(0.45), true)
		ci.draw_rect(face, Ink.INK, false, Ink.LINE_PX)
		r.position += up
	if _city and p.kind == "wall_high":
		_barrier(ci, r)
		return
	match p.kind:
		"cone":
			ci.draw_texture_rect(CONE, r, false)
			return
		"cover_high":
			ci.draw_texture_rect(DUMPSTER, r, false)
			return
		"cover_low":
			_crate_row(ci, r)
			return
	ci.draw_rect(r, fill, true)
	ci.draw_rect(r, Ink.INK, false, Ink.LINE_PX)


## A concrete barrier run: fill, ink rim, a cream top edge and a joint line every BARRIER_M.
func _barrier(ci: CanvasItem, r: Rect2) -> void:
	ci.draw_rect(r, BARRIER_FILL, true)
	var long_x: bool = r.size.x >= r.size.y
	var step: float = BARRIER_M * Ink.PX_PER_M
	var n: int = int(maxf(r.size.x, r.size.y) / step)
	for i: int in range(1, n + 1):
		var off: Vector2 = Vector2(step * i, 0.0) if long_x else Vector2(0.0, step * i)
		var end: Vector2 = Vector2(0.0, r.size.y) if long_x else Vector2(r.size.x, 0.0)
		ci.draw_line(r.position + off, r.position + off + end, Ink.INK, Ink.LINE_PX * 0.5)
	var edge: Rect2 = r.grow(-Ink.LINE_PX * 1.5)
	var top: Vector2 = Vector2(edge.size.x, 0.0) if long_x else Vector2(0.0, edge.size.y)
	ci.draw_line(edge.position, edge.position + top, Ink.CREAM, Ink.LINE_PX)
	ci.draw_rect(r, Ink.INK, false, Ink.LINE_PX)


## Square crates along the box's long side (the last one squeezed to fit).
func _crate_row(ci: CanvasItem, r: Rect2) -> void:
	var side: float = minf(r.size.x, r.size.y)
	var along: Vector2 = Vector2(side, 0.0) if r.size.x >= r.size.y else Vector2(0.0, side)
	var n: int = maxi(roundi(maxf(r.size.x, r.size.y) / side), 1)
	for i: int in n:
		var cell: Rect2 = Rect2(r.position + along * i, Vector2(side, side))
		ci.draw_texture_rect_region(CRATES, cell.intersection(r), CRATE_PX)


func _ring(at: Vector2, radius_m: float, color: Color, ci: CanvasItem = self) -> void:
	ci.draw_arc(Ink.px(at), radius_m * Ink.PX_PER_M, 0.0, TAU, 32, color, Ink.LINE_PX)


## A moving dummy's path: the strafe span or the approach lane, as a thin ink line.
func _track(t: ArenaTargets.Target, view: Rect2) -> void:
	var a: Vector2 = t.home
	var b: Vector2 = t.home
	if t.spawn.motion == "strafe":
		a = t.home - Vector2(0.0, t.spawn.span_m * 0.5)
		b = t.home + Vector2(0.0, t.spawn.span_m * 0.5)
	else:
		b = t.home - Vector2(t.spawn.span_m, 0.0)
	if not view.intersects(Rect2(a, Vector2.ZERO).expand(b)):
		return
	draw_line(Ink.px(a), Ink.px(b), Ink.WASH, Ink.LINE_PX)
