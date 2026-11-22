class_name GauntletBot
extends InputSource
## The brain sees only BotView. It can drive either the street or the pit.
## A new target costs reaction_ticks before an attack, including weapon selection.

const MELEE_M: float = 1.6
const ENGAGE_M: float = 13.0
const STRAFE_TICKS: int = 45


class Intent:
	var move: Vector2
	var aim: Vector2
	var reach: float
	var attack: StringName = &""
	var slot: StringName = &""
	var sprint: bool = false


var counters: BotCounters = BotCounters.new()
var travel: StringName = &"REST"
var cover_threat: StringName = &""
var _view: BotView
var _actions: PlayerActions
var _profile: BotProfile
var _aim_rng: RandomNumberGenerator
var _defence: BotDefence
var _moves: BotMovePlan
var _forms: BotForms
var _deploy: GhostDeployBot
var _machines: BotMachineFight = BotMachineFight.new()
var _target_id: int = -1
var _last_enemy: int = -1
var _ready: int = 0
var _previous: int = 0
var _recovering: bool = false


func _init(view: BotView, actions: PlayerActions, profile: BotProfile, run_seed: int) -> void:
	_view = view
	_actions = actions
	_profile = profile
	view.player().blast_margin = profile.blast_margin_m
	var registry: RngRegistry = RngRegistry.new(run_seed)
	_aim_rng = registry.stream(&"test_player_aim")
	_defence = BotDefence.new(profile, registry)
	_forms = BotForms.new(registry)
	_deploy = GhostDeployBot.new(view, actions, registry)
	_moves = BotMovePlan.new(registry)


func sample(tick: int) -> TickInput:
	_view.refresh()
	var me: BotView.Player = _view.player()
	counters.observe_totals(me)
	counters.sample_form(me)
	if me.hp <= 0.0:
		travel = &"REST"
		cover_threat = &""
		_target_id = -1
		_previous = 0
		_recovering = false
		return TickInput.new()
	var active: bool = _view.wave_active()
	var target: BotView.Hostile = priority_target() if active else null
	_moves.choose(_view, _profile.move_use)
	if active and _moves.foe != null:
		target = _moves.foe
	_acquire(target, tick)
	var intent: Intent = Intent.new()
	if me.hp >= me.street_max_hp * _profile.rest_hp:
		_recovering = false
	elif me.hp < me.street_max_hp * _profile.retreat_hp:
		_recovering = true
	if target != null:
		intent = _engage(target, tick)
	elif not active and me.hp >= me.street_max_hp * _profile.rest_hp:
		intent.move = _view.forward()
		intent.aim = intent.move
	if active and _moves.foe != null:
		_moves.drive(_view, intent, tick >= _ready)
		return _pack(intent, BotDefence.Choice.new(), _moves.form())
	var defend: BotDefence.Choice = _defence.choose(_view, tick)
	var want: StringName = _forms.desired(_view, target, _profile.form_use, defend.form)
	return _pack(intent, defend, want)


func _pack(intent: Intent, defend: BotDefence.Choice, want: StringName) -> TickInput:
	var me: BotView.Player = _view.player()
	if intent.attack == &"fire" and me.form != &"dent":
		if not BotArsenal.clear_shot(_view, intent, _actions, _profile.blast_margin_m):
			intent.attack = &""
	var buttons: int = _edge(BotForms.transform(me, want))
	if defend.hold_position:
		intent.move = Vector2.ZERO
	if defend.cover or defend.action != &"":
		intent.move = defend.move
		intent.aim = defend.aim if defend.aim != Vector2.ZERO else intent.aim
		buttons |= _bit(defend.action)
		counters.guard_ticks += int(defend.action == &"guard" and _bit(&"guard") != 0)
		counters.cover_ticks += int(defend.cover)
	elif buttons == 0:
		if (_recovering or intent.sprint) and intent.move != Vector2.ZERO:
			buttons |= _bit(&"sprint")
		buttons |= _edge(intent.slot)
		var attack: int = _bit(intent.attack)
		if intent.attack == &"melee" or (me.form == &"dent" and intent.attack == &"fire"):
			attack = _edge(intent.attack)
		buttons |= attack
	buttons = _deploy.steer(intent, buttons, _profile.form_use)
	_previous = buttons
	cover_threat = defend.threat if defend.cover else &""
	travel = &"REST"
	if intent.move != Vector2.ZERO:
		travel = &"RETREAT" if _recovering or defend.action == &"sprint" else &"ADVANCE"
	var move: Vector2 = intent.move.limit_length(1.0) * TickInput.AXIS_MAX
	return TickInput.new(
		buttons | PlayerCommand.pack_aim(intent.aim, _actions, intent.reach),
		roundi(move.x),
		roundi(move.y)
	)


func priority_target() -> BotView.Hostile:
	var best: BotView.Hostile = null
	var high: float = -INF
	for foe: BotView.Hostile in _view.hostiles():
		if not foe.alive:
			continue
		var weight: float = _profile.threat_weights.get(foe.archetype, 1.0)
		var score: float = weight / maxf(0.25, foe.pos.distance_to(_view.player().pos))
		if foe.tell == &"large":
			score += _profile.large_tell_bonus
		if score > high or (score == high and foe.id < best.id):
			best = foe
			high = score
	return best


func _acquire(target: BotView.Hostile, tick: int) -> void:
	var id: int = target.id if target != null else -1
	if id == _target_id:
		return
	_target_id = id
	_ready = tick + _profile.reaction_ticks
	if id >= 0:
		counters.targets_switched += int(_last_enemy >= 0 and _last_enemy != id)
		_last_enemy = id


func _engage(foe: BotView.Hostile, tick: int) -> Intent:
	var intent: Intent = Intent.new()
	var me: BotView.Player = _view.player()
	var dir: Vector2 = me.pos.direction_to(foe.pos)
	var distance: float = me.pos.distance_to(foe.pos)
	var visible: Vector2 = _view.aim_point(foe)
	intent.aim = me.pos.direction_to(visible) if visible.is_finite() else dir
	intent.reach = distance
	var slot: BotView.Slot = _view.weapon_for(distance, MELEE_M)
	var reach: float = slot.reach if slot != null else MELEE_M
	var blocked: bool = not visible.is_finite()
	var side: float = 1.0 if tick % (2 * STRAFE_TICKS) < STRAFE_TICKS else -1.0
	if _recovering:
		intent.move = _view.retreat() if distance < 30.0 else Vector2.ZERO
	elif foe.stomp_m > 0.0 or foe.archetype == &"sentry_turret":
		intent.move = _machines.advance(_view, foe)
		intent.sprint = distance > MELEE_M and (foe.opening or foe.archetype == &"sentry_turret")
	elif blocked or distance > minf(reach * 0.88, ENGAGE_M):
		intent.move = _view.chase(foe)
	elif distance > MELEE_M:
		intent.move = dir.orthogonal() * side * 0.55
	if tick < _ready or not me.settled:
		return intent
	if slot != null and me.current_slot != slot.index and (slot.melee or distance > MELEE_M):
		intent.slot = _view.select_slot(slot)
	if blocked:
		return intent
	var error: float = _aim_rng.randf_range(-_profile.aim_error_deg, _profile.aim_error_deg)
	BotArsenal.attack(_view, intent, foe, slot, error)
	return intent


func _bit(action: StringName) -> int:
	var bit: int = _actions.bit(action)
	return 1 << bit if bit >= 0 else 0


func firing() -> bool:
	return (_previous & _bit(&"fire")) != 0


func _edge(action: StringName) -> int:
	return _bit(action) & ~_previous
