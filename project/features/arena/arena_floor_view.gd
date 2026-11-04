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
const CRATES: Texture2D = preload("res://features/city/art/props/crate_stack.png")
const CRATE_PX: Rect2 = Rect2(0.0, 0.0, 80.0, 80.0)
const DUMPSTER: Texture2D = preload("res://features/city/art/props/dumpster.png")
const CONE: Texture2D = preload("res://features/city/art/props/traffic_cone.png")
## The powers pad's cars in the city's traffic print: one atlas per VehicleBody.State (intact, d1,
## d2, the soul-hijacked teal plate, the burnt wreck), cell = the car's art id, nose to +x
## (CrowdLayers TRAFFIC_CELL_PX on a 3 x 3 grid), the car-shaped ink shadow under it.
const CAR_ATLAS: Array[Texture2D] = [
	preload("res://features/city/art/vehicles/traffic_atlas.png"),
	preload("res://features/city/art/vehicles/traffic_atlas_d1.png"),
	preload("res://features/city/art/vehicles/traffic_atlas_d2.png"),
	preload("res://features/city/art/vehicles/traffic_atlas_hijack.png"),
	preload("res://features/vehicles/art/traffic_atlas_wreck.png"),
]
const CAR_CELL_PX: Vector2 = Vector2(512.0, 256.0)
const CAR_COLS: int = 3


func _draw() -> void:
	var arena: ArenaStage = stage as ArenaStage
	if arena == null:
		return
	for a: ArenaPlan.Area in arena.plan.areas:
		if arena.cells == null:  # on the city proving block the city is the floor
			_tiled(a.rect, "dock_floor", FLOOR_TILE_M)
			_floor(a.rect, Color(0, 0, 0, 0), "")
	for s: ArenaStation in arena.stations.stations:
		for p: ArenaStation.Prop in s.props:
			if arena.cells == null or p.kind in ArenaWalls.SOLID or p.kind == "cone":
				_prop(arena.plan.base + p.at, p)  # on the city only what collides (and cones)
		for sp: ArenaStation.Spawn in s.spawns:
			if sp.kind == "crowd":
				_ring(arena.plan.base + sp.at, sp.span_m, Ink.WASH)
	for b: VehicleBody in arena.cars():
		_car(b)
	draw_set_transform(Vector2.ZERO)
	for a: ArenaPlan.Area in arena.plan.areas:  # over the props: a wall never hides a name
		if arena.cells == null:
			Ink.label(
				self, a.rect.position + Vector2(a.rect.size.x * 0.5, LABEL_M), a.name, 30, Ink.INK
			)
	for t: ArenaTargets.Target in arena.targets.targets:
		var up: bool = t.fighter.exposed
		_ring(t.fighter.pos, 0.8, Ink.INK if up else Ink.WASH)
		if t.spawn.motion != "static":
			_track(t)


func _prop(at: Vector2, p: ArenaStation.Prop) -> void:
	var fill: Color = PROP_FILL.get(p.kind, Ink.WASH)
	var r: Rect2 = Rect2(Ink.px(at - p.size * 0.5), p.size * Ink.PX_PER_M)
	match p.kind:
		"cone":
			draw_texture_rect(CONE, r, false)
			return
		"cover_high":
			draw_texture_rect(DUMPSTER, r, false)
			return
		"cover_low":
			_crate_row(r)
			return
	draw_rect(r, fill, true)
	draw_rect(r, Ink.INK, false, Ink.LINE_PX)


## Square crates along the box's long side (the last one squeezed to fit).
func _crate_row(r: Rect2) -> void:
	var side: float = minf(r.size.x, r.size.y)
	var along: Vector2 = Vector2(side, 0.0) if r.size.x >= r.size.y else Vector2(0.0, side)
	var n: int = maxi(roundi(maxf(r.size.x, r.size.y) / side), 1)
	for i: int in n:
		var cell: Rect2 = Rect2(r.position + along * i, Vector2(side, side))
		draw_texture_rect_region(CRATES, cell.intersection(r), CRATE_PX)


func _ring(at: Vector2, radius_m: float, color: Color) -> void:
	draw_arc(Ink.px(at), radius_m * Ink.PX_PER_M, 0.0, TAU, 32, color, Ink.LINE_PX)


## A moving dummy's path: the strafe span or the approach lane, as a thin ink line.
func _track(t: ArenaTargets.Target) -> void:
	var a: Vector2 = t.home
	var b: Vector2 = t.home
	if t.spawn.motion == "strafe":
		a = t.home - Vector2(0.0, t.spawn.span_m * 0.5)
		b = t.home + Vector2(0.0, t.spawn.span_m * 0.5)
	else:
		b = t.home - Vector2(t.spawn.span_m, 0.0)
	draw_line(Ink.px(a), Ink.px(b), Ink.WASH, Ink.LINE_PX)


## One car: its shadow offset down-right, then its body cell, both turned to its heading.
func _car(b: VehicleBody) -> void:
	var size: Vector2 = Vector2(VehicleView.CAR_L, VehicleView.CAR_W) / SimConst.PX_PER_M
	var r: Rect2 = Rect2(-size * 0.5 * Ink.PX_PER_M, size * Ink.PX_PER_M)
	var shadow: Vector2 = VehicleView.SHADOW_OFF / SimConst.PX_PER_M
	var cell: Rect2 = Rect2(
		Vector2(b.art % CAR_COLS, floorf(float(b.art) / CAR_COLS)) * CAR_CELL_PX, CAR_CELL_PX
	)
	var tex: Texture2D = CAR_ATLAS[clampi(b.state, 0, CAR_ATLAS.size() - 1)]
	draw_set_transform(Ink.px(b.pos + shadow), b.head.angle())
	draw_texture_rect_region(tex, r, cell, VehicleView.SHADOW)
	draw_set_transform(Ink.px(b.pos), b.head.angle())
	draw_texture_rect_region(tex, r, cell)
