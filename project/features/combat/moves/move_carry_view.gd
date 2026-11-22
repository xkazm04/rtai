class_name MoveCarryView
extends RefCounted
## Short amber arcs in world pixels. Only the endpoints and expiry of recent hits are kept.


class Arc:
	extends RefCounted
	var start: Vector2
	var end: Vector2
	var until: int


var _recent: Array[Arc] = []


func record(origin: Vector2, target: Vector2, tick: int, duration: int) -> void:
	while not _recent.is_empty() and _recent[0].until <= tick:
		_recent.remove_at(0)
	var arc: Arc = Arc.new()
	arc.start = Ink.px(origin)
	arc.end = Ink.px(target)
	arc.until = tick + duration
	_recent.append(arc)


static func paint(view: Node2D, arena: CombatArena) -> void:
	var carry: MoveCarry = arena.squad_ai.carry
	if carry == null or not arena.squad_ai.moves.overkill_carry.enabled:
		return
	for arc: Arc in carry.arcs._recent:
		if arena.tick < arc.until:
			_draw_arc(view, arc)


static func _draw_arc(view: Node2D, arc: Arc) -> void:
	var path: PackedVector2Array = OhmBoltView.jag(
		arc.start, arc.end, arc.until, OhmView.JAG_M, Ink.PX_PER_M
	)
	view.draw_polyline(path, OhmBoltDraw.AMBER, OhmView.TEAL_W, true)
	view.draw_polyline(path, Color.WHITE, OhmView.CORE_W, true)
