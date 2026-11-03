class_name ArenaFloorView
extends StageView
## The dev arena's floor in quest 1's ink (StageView's tiles and labels): every area of the plan
## as a dock-floor slab with its stencilled name, the stations' props (cover, walls, cones, the
## firing line, lane marks) and a range ring under each dummy. Reads the sim, never writes it.

const PROP_FILL: Dictionary[String, Color] = {
	"wall_high": Color("#17131B"),
	"cover_low": Color(0.090, 0.075, 0.106, 0.55),
	"cone": Color("#E8502A"),
	"firing_line": Color("#E8502A"),
}
const FLOOR_TILE_M: float = 8.0


func _draw() -> void:
	var arena: ArenaStage = stage as ArenaStage
	if arena == null:
		return
	for a: ArenaPlan.Area in arena.plan.areas:
		_tiled(a.rect, "dock_floor", FLOOR_TILE_M)
		_floor(a.rect, Color(0, 0, 0, 0), a.name)
	for s: ArenaStation in arena.stations.stations:
		for p: ArenaStation.Prop in s.props:
			_prop(arena.plan.base + p.at, p)
		for sp: ArenaStation.Spawn in s.spawns:
			if sp.kind == "crowd":
				_ring(arena.plan.base + sp.at, sp.span_m, Ink.WASH)
	for t: ArenaTargets.Target in arena.targets.targets:
		var up: bool = t.fighter.exposed
		_ring(t.fighter.pos, 0.8, Ink.INK if up else Ink.WASH)
		if t.spawn.motion != "static":
			_track(t)


func _prop(at: Vector2, p: ArenaStation.Prop) -> void:
	var fill: Color = PROP_FILL.get(p.kind, Ink.WASH)
	var r: Rect2 = Rect2(Ink.px(at - p.size * 0.5), p.size * Ink.PX_PER_M)
	if p.kind == "cone":
		draw_circle(Ink.px(at), p.size.x * 0.5 * Ink.PX_PER_M, fill)
		return
	draw_rect(r, fill, true)
	draw_rect(r, Ink.INK, false, Ink.LINE_PX)


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
