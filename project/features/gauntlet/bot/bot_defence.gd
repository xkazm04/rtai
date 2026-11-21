class_name BotDefence
extends RefCounted
## Read each windup and sample roll skill once per distinct threat. A large
## threat wins even when Rivet misses his dodge and a small round arrives first.

const LOOKAHEAD_TICKS: int = 30
const FRONT_DOT: float = 0.5


class Choice:
	var action: StringName = &""
	var move: Vector2
	var aim: Vector2
	var cover: bool
	var threat: StringName = &""
	var hold_position: bool
	var form: StringName = &""


class Tell:
	var noticed: bool
	var ready_at: int
	var dodge: bool


var _profile: BotProfile
var _rng: RandomNumberGenerator
var _tells: Dictionary[int, Tell] = {}
var _dodges: Dictionary[int, bool] = {}


func _init(profile: BotProfile, registry: RngRegistry) -> void:
	_profile = profile
	_rng = registry.stream(&"test_player_defence")


func choose(view: BotView, tick: int) -> Choice:
	var me: BotView.Player = view.player()
	var tell: BotView.Hostile = _notice(view, tick)
	var large: BotView.Round = null
	var small: BotView.Round = null
	var large_eta: float = INF
	var small_eta: float = INF
	var live: Dictionary[int, bool] = {}
	for shot: BotView.Round in view.incoming():
		if not _dodges.has(shot.id):
			_dodges[shot.id] = _rng.randf() < _profile.roll_skill
		live[shot.id] = _dodges[shot.id]
		var eta: float = impact_ticks(shot, me)
		if eta > LOOKAHEAD_TICKS:
			continue
		if shot.size == &"large" and eta < large_eta:
			large = shot
			large_eta = eta
		elif shot.size == &"small" and eta < small_eta and view.clear_line(shot.pos, me.pos):
			small = shot
			small_eta = eta
	_dodges = live
	if large != null:
		return _evade(view, large.pos, large.vel, _dodges[large.id], true)
	if tell != null:
		if tell.stomp_m > 0.0 and tell.tell_ticks > 0:
			return BotMachineFight.stomp(view, tell, _tells[tell.id].dodge)
		return _evade(view, tell.pos, tell.facing, _tells[tell.id].dodge, true)
	if small != null:
		return _small(view, small, small_eta)
	return Choice.new()


## Closest approach along the remaining flight, in simulation ticks.
static func impact_ticks(shot: BotView.Round, me: BotView.Player) -> float:
	var speed: float = shot.vel.length()
	if speed <= 0.0:
		return INF
	var dir: Vector2 = shot.vel / speed
	var rel: Vector2 = me.pos - shot.pos
	var along: float = rel.dot(dir)
	if along < 0.0 or absf(rel.cross(dir)) > me.radius:
		return INF
	var offset: float = sqrt(maxf(0.0, me.radius * me.radius - rel.cross(dir) ** 2))
	var entry: float = maxf(0.0, along - offset)
	if entry > shot.remaining_m:
		return INF
	return entry / (speed * SimClock.TICK_DT)


func _small(view: BotView, shot: BotView.Round, eta: float) -> Choice:
	var me: BotView.Player = view.player()
	var from_front: Vector2 = me.pos.direction_to(shot.pos)
	if me.can_guard and me.facing.dot(from_front) >= FRONT_DOT:
		var choice: Choice = Choice.new()
		if eta <= _profile.guard_lead_ticks:
			choice.action = &"guard"
			choice.aim = from_front
		return choice
	return _evade(view, shot.pos, shot.vel, _dodges[shot.id], false)


func _notice(view: BotView, tick: int) -> BotView.Hostile:
	var seen: Dictionary[int, Tell] = {}
	var nearest: BotView.Hostile = null
	for foe: BotView.Hostile in view.hostiles():
		if not foe.alive or foe.tell != &"large":
			continue
		var tell: Tell = _tells.get(foe.id)
		if tell == null:
			tell = Tell.new()
			tell.noticed = _rng.randf() < _profile.tells_read
			tell.ready_at = tick + _profile.reaction_ticks
			tell.dodge = _rng.randf() < _profile.roll_skill
		seen[foe.id] = tell
		if not tell.noticed or tick < tell.ready_at:
			continue
		var at: Vector2 = view.player().pos
		if nearest == null or at.distance_to(foe.pos) < at.distance_to(nearest.pos):
			nearest = foe
	_tells = seen
	return nearest


func _evade(view: BotView, source: Vector2, line: Vector2, dodge: bool, blast: bool) -> Choice:
	var choice: Choice = Choice.new()
	choice.threat = &"large" if blast else &"small"
	var me: BotView.Player = view.player()
	var cover: BotCover.Route = BotCover.seek(view, source, _profile.cover_seek_m)
	if cover.length == 0.0:
		choice.cover = true
	elif dodge and me.can_roll and line != Vector2.ZERO:
		var side: Vector2 = line.normalized().orthogonal()
		choice.move = -side if side.dot(me.pos - source) < 0.0 else side
		choice.action = &"roll"
	elif cover.length < INF:
		choice.cover = true
		choice.move = cover.step
	elif blast and not me.can_roll and me.forms.has(&"tonnage"):
		choice.form = &"tonnage"
	return choice
