extends RefCounted
## Observe each real march order, including a bound that cannot find a route. Delegation
## preserves the original pursuit's route, search cadence, push handling and counters.

const WINDOW: int = 5 * SimClock.TICK_RATE
const RADIUS_SQ: float = 0.5 * 0.5


class Orders:
	extends GuardPursuit
	var source: GuardPursuit
	var target: Vector2 = Vector2.INF
	var samples: PackedVector2Array = []
	var count: int = 0
	var index: int = 0
	var flagged: bool = false

	func _init(map: GuardRouteMap, original: GuardPursuit) -> void:
		super(map)
		source = original
		@warning_ignore("return_value_discarded")
		samples.resize(WINDOW + 1)

	func advance(h: Fighter, mark: Vector2, speed: float) -> bool:
		target = mark
		return source.advance(h, mark, speed)

	func push_body(h: Fighter, push: Vector2) -> void:
		source.push_body(h, push)

	func ticks_advanced() -> int:
		return source.ticks_advanced()

	func blocked() -> bool:
		return source.blocked()

	func blocked_goal() -> Vector2:
		return source.blocked_goal()

	## Check every possible five-second interval. A loop back to the start is movement.
	func stalled(pos: Vector2, walking: bool) -> bool:
		if not walking:
			count = 0
			return false
		samples[index] = pos
		index = (index + 1) % samples.size()
		count = mini(count + 1, samples.size())
		if count < samples.size() or samples[index].distance_squared_to(pos) > RADIUS_SQ:
			return false
		for point: Vector2 in samples:
			if samples[index].distance_squared_to(point) > RADIUS_SQ:
				return false
		return true


var stuck: Array[Dictionary] = []


func sample(game: PrologueGame) -> void:
	var arena: CombatArena = game.stage.arena
	for h: Fighter in arena.hostiles:
		if not h.alive():
			continue
		var orders: Orders = h.pursuit as Orders
		if orders == null:
			h.pursuit = Orders.new(arena.guard_map, h.pursuit)
			continue
		if not orders.flagged and orders.stalled(h.pos, _walking(game, h, orders.target)):
			orders.flagged = true
			stuck.append({"id": h.id, "at": str(h.pos), "tick": game.stage.tick})
		orders.target = Vector2.INF


func _walking(game: PrologueGame, h: Fighter, mark: Vector2) -> bool:
	if not game.stage.arena.rivet.alive():
		return false
	if mark.is_finite():
		return h.pos.distance_to(mark) > 0.2
	# No order means a reserve, a held commander, or an officer already at a mark.
	# In the hands fight two roles also move directly, without issuing march orders.
	var encounter: PrologueEncounter = game.encounter
	if encounter.phase != PrologueEncounter.Phase.HANDS:
		return false
	var squad: PrologueSquad = encounter.patrol.squad
	if squad.panic.members.has(h):
		return squad.panic.members[h].inside
	if not squad.minds.has(h.id):
		return false
	var agent: EnemyAgent = squad.minds[h.id].agent
	var outside_reach: bool = h.pos.distance_to(game.stage.arena.rivet.pos) > agent.arch.attack_m
	return outside_reach and h.swing_left == 0
