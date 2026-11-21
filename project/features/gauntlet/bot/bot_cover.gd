class_name BotCover
extends RefCounted
## Find a reachable point in the shadow of a solid. Try the nearest point on each
## face, then a corner on the way there if the direct walk would cut through it.


class Route:
	var step: Vector2
	var length: float = INF


static func seek(view: BotView, source: Vector2, reach: float) -> Route:
	var me: BotView.Player = view.player()
	var best: Route = Route.new()
	if reach <= 0.0:
		return best
	for box: Rect2 in view.solid_props():
		var near: Vector2 = me.pos.clamp(box.position, box.end)
		if near.distance_to(me.pos) > reach:
			continue
		if BotView.crosses(box, source, me.pos):
			best.length = 0.0
			best.step = Vector2.ZERO
			return best
		var outer: Rect2 = box.grow(me.radius + 0.12)
		for goal: Vector2 in _faces(outer, me.pos):
			if not BotView.crosses(box, source, goal):
				continue
			var path: Route = _route(view, outer, goal)
			if path.length <= reach and path.length < best.length:
				best = path
	return best


static func _faces(box: Rect2, at: Vector2) -> PackedVector2Array:
	var near: Vector2 = at.clamp(box.position, box.end)
	var center: Vector2 = box.get_center()
	return PackedVector2Array(
		[
			Vector2(box.position.x, near.y),
			Vector2(box.end.x, near.y),
			Vector2(near.x, box.position.y),
			Vector2(near.x, box.end.y),
			Vector2(box.position.x, center.y),
			Vector2(box.end.x, center.y),
			Vector2(center.x, box.position.y),
			Vector2(center.x, box.end.y)
		]
	)


static func _route(view: BotView, outer: Rect2, goal: Vector2) -> Route:
	var at: Vector2 = view.player().pos
	var best: Route = Route.new()
	if view.walk_clear(at, goal):
		best.length = at.distance_to(goal)
		best.step = (goal - at).limit_length(1.0)
		return best
	var corners: PackedVector2Array = [
		outer.position,
		Vector2(outer.end.x, outer.position.y),
		outer.end,
		Vector2(outer.position.x, outer.end.y)
	]
	for bend: Vector2 in corners:
		var length: float = at.distance_to(bend) + bend.distance_to(goal)
		if length < best.length and view.walk_clear(at, bend) and view.walk_clear(bend, goal):
			best.length = length
			best.step = (bend - at).limit_length(1.0)
	return best
