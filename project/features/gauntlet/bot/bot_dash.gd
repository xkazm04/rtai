class_name BotDash
extends RefCounted
## Read each observed round or stomp once. A later wave or a second stomp gets a fresh read.

var _profile: BotProfile
var _rng: RandomNumberGenerator
var _ready_at: Dictionary[int, int] = {}


func _init(profile: BotProfile, registry: RngRegistry) -> void:
	_profile = profile
	_rng = registry.stream(&"test_player_dash")


func choose(view: BotView, tick: int) -> BotDefence.Choice:
	var seen: Dictionary[int, int] = {}
	var best: float = INF
	var source: int = 0
	var direction: Vector2 = Vector2.ZERO
	for shot: BotView.Round in view.incoming():
		if shot.size != Shot.LARGE or not _read(shot.id, tick, seen):
			continue
		var eta: float = _impact(shot, view.player())
		if eta >= best or eta > BotDefence.LOOKAHEAD_TICKS:
			continue
		var side: Vector2 = _side(view, shot, eta)
		if side != Vector2.ZERO:
			best = eta
			source = shot.id
			direction = side
	for foe: BotView.Hostile in view.hostiles():
		if not foe.alive or foe.tell_ticks <= 0 or foe.stomp_m <= 0.0 or foe.tell != &"large":
			continue
		var id: int = -1 - foe.id
		if not _read(id, tick, seen) or foe.tell_ticks >= best:
			continue
		if view.player().pos.distance_to(foe.pos) <= foe.stomp_m:
			var escape: BotDefence.Choice = BotMachineFight.stomp(view, foe, false)
			var clearance: float = foe.stomp_m - view.player().pos.distance_to(foe.pos) + 0.35
			if not view.walk_clear(view.player().pos, view.player().pos + escape.move * clearance):
				continue
			best = foe.tell_ticks
			source = id
			direction = escape.move
	_ready_at = seen
	var choice: BotDefence.Choice = BotDefence.Choice.new()
	if view.player().can_dash and direction != Vector2.ZERO:
		choice.action = &"dash"
		choice.move = direction
		_ready_at[source] = -1
	return choice


func _read(id: int, tick: int, seen: Dictionary[int, int]) -> bool:
	if _ready_at.has(id):
		seen[id] = _ready_at[id]
	else:
		seen[id] = tick + _profile.dash_read_ticks if _rng.randf() < _profile.dash_chance else -1
	return seen[id] >= 0 and tick >= seen[id]


static func _impact(shot: BotView.Round, me: BotView.Player) -> float:
	var direct: float = BotDefence.impact_ticks(shot, me)
	if is_finite(direct) or me.pos.distance_to(shot.landing) > shot.splash_m:
		return direct
	var speed: float = shot.vel.length()
	return shot.remaining_m / (speed * SimClock.TICK_DT) if speed > 0.0 else INF


static func _side(view: BotView, shot: BotView.Round, eta: float) -> Vector2:
	var me: BotView.Player = view.player()
	var escape: float = maxf(me.radius, shot.splash_m)
	if BotMachineFight.roll_in_time(me, escape, maxi(1, ceili(eta))):
		return Vector2.ZERO
	var side: Vector2 = shot.vel.normalized().orthogonal()
	if side.dot(me.pos - shot.pos) < 0.0:
		side = -side
	for dir: Vector2 in [side, -side]:
		if view.walk_clear(me.pos, me.pos + dir * me.dash_m):
			return dir
	return Vector2.ZERO
