class_name PrologueRiflePosts
extends RefCounted
## After first contact each rifle bounds to a different wreck. On a volley order
## they step out around its shoulder. Between orders Rivet can still outflank them.

var deployed: bool = false
var bound_mps: float
var _yard: Rect2
var _posts: Array[Rect2] = []
var _assigned: Dictionary[int, int] = {}
var _duck_at: int = -1
var _dodge_m: float
var _displace_m: float
var _clearance: float
var _peeking: bool = false


func _init(yard: PrologueYard, data: DataTable, command: Dictionary) -> void:
	_yard = yard.yard.grow(-0.8)
	bound_mps = data.num(command, "rifle_bound_mps")
	_dodge_m = data.num(command, "rifle_dodge_m")
	_displace_m = data.num(command, "displace_m")
	_clearance = data.num(command, "rifle_clearance_m")
	for id: String in data.array(command, "rifle_posts"):
		for wreck: PrologueYard.Wreck in yard.wrecks:
			if wreck.id == id:
				_posts.append(wreck.footprint.grow(_clearance))
				break


func reset() -> void:
	_duck_at = -1
	_assigned.clear()
	deployed = false
	_peeking = false


func order(is_volley: bool) -> void:
	_peeking = is_volley
	_duck_at = -1


func volley(tick: int, rifle: EnemyWeapon) -> void:
	deployed = true
	_duck_at = tick + rifle.burst * rifle.burst_gap_ticks


func step(tick: int) -> void:
	if tick == _duck_at:
		_peeking = false


func mark(file: int, player: Vector2) -> Vector2:
	var index: int = _assigned.get(file, file)
	var post: Rect2 = _posts[index]
	if not _peeking and player.distance_to(post.get_center()) < _displace_m:
		var next: int = (index + 1) % _posts.size()
		var prev: int = posmod(index - 1, _posts.size())
		if (
			player.distance_to(_posts[next].get_center())
			< player.distance_to(_posts[prev].get_center())
		):
			next = prev
		_assigned[file] = next
		post = _posts[next]
	var mid: Vector2 = post.get_center()
	var away: Vector2 = player.direction_to(mid)
	var side: float = 1.0 if file % 2 == 0 else -1.0
	var edge: Vector2
	var corner: Vector2
	if absf(away.x) > absf(away.y):
		edge = mid + Vector2.RIGHT * signf(away.x) * post.size.x * 0.5
		corner = Vector2.DOWN * side * post.size.y * 0.5
	else:
		edge = mid + Vector2.DOWN * signf(away.y) * post.size.y * 0.5
		corner = Vector2.RIGHT * side * post.size.x * 0.5
	return edge + corner if _peeking else edge


## A rifle steps off the sight line while Rivet tracks it. A committed volley
## holds its lane. Leading the sidestep or closing from cover still works.
func evade(h: Fighter, arena: CombatArena, destination: Vector2) -> Vector2:
	var rivet: Fighter = arena.rivet
	var dir: Vector2 = rivet.pos.direction_to(h.pos)
	if _peeking or rivet.facing.dot(dir) < 0.96 or not arena.guard_map.sight_line(rivet.pos, h.pos):
		return destination
	var side: Vector2 = dir.orthogonal() * _dodge_m
	if h.id % 2 != 0:
		side = -side
	for step_by: Vector2 in [side, -side]:
		var next: Vector2 = h.pos + step_by
		if _yard.has_point(next) and arena.guard_map.clear_line(h.pos, next):
			return next
	return destination
