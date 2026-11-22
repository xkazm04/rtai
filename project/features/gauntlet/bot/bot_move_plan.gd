class_name BotMovePlan
extends RefCounted
## Roll once when a target first offers a move. Holding the same opening across
## input edges or a transformation must not turn a novice's chance into certainty.

enum Action { NONE, SHORT, BLINK, CRACK, FLANK, SHOOT }

var action: Action = Action.NONE
var foe: BotView.Hostile
var _rng: RandomNumberGenerator
var _decisions: Dictionary[Vector2i, bool] = {}


func _init(registry: RngRegistry) -> void:
	_rng = registry.stream(&"test_player_moves")


func choose(view: BotView, chance: float) -> void:
	var present: Dictionary[Vector2i, bool] = {}
	var me: BotView.Player = view.player()
	foe = null
	action = Action.NONE
	for target: BotView.Hostile in view.hostiles():
		if not target.alive:
			continue
		if target.short_held and target.archetype == &"sentry_turret":
			_prefer(me, target, Action.FLANK)
		if target.cracked or (target.short_held and target.archetype == &"shield_robot"):
			if BotArsenal.best_gun(view, me.pos.distance_to(target.pos)) != null:
				_prefer(me, target, Action.SHOOT)
		if target.can_crack and (me.form == &"tonnage" or me.forms.has(&"tonnage")):
			_consider(me, target, Action.CRACK, chance, present)
		if target.can_blink and (me.form == &"kerf" or me.forms.has(&"kerf")):
			_consider(me, target, Action.BLINK, chance, present)
		if target.can_short and (me.form == &"ohm" or me.forms.has(&"ohm")):
			_consider(me, target, Action.SHORT, chance, present)
	_decisions = present


func _consider(
	me: BotView.Player,
	target: BotView.Hostile,
	which: Action,
	chance: float,
	present: Dictionary[Vector2i, bool]
) -> void:
	var key: Vector2i = Vector2i(target.id, which)
	var take: bool
	if _decisions.has(key):
		take = _decisions[key]
	else:
		take = chance >= 1.0 or _rng.randf() < chance
		Log.info(
			"gauntlet",
			(
				"move opening %s on %s #%d, accepted %s"
				% [Action.keys()[which], target.archetype, target.id, take]
			)
		)
	present[key] = take
	if take:
		_prefer(me, target, which)


func _prefer(me: BotView.Player, target: BotView.Hostile, which: Action) -> void:
	if foe != null and _priority(which, target) < _priority(action, foe):
		return
	if foe != null and _priority(which, target) == _priority(action, foe):
		if me.pos.distance_squared_to(foe.pos) <= me.pos.distance_squared_to(target.pos):
			return
	action = which
	foe = target


static func _priority(which: Action, target: BotView.Hostile) -> int:
	if which == Action.SHORT and target.archetype == &"sentry_turret":
		return Action.BLINK + 1
	if which >= Action.CRACK:
		return which + 1
	return which


func form() -> StringName:
	match action:
		Action.SHORT:
			return &"ohm"
		Action.BLINK:
			return &"kerf"
		Action.CRACK:
			return &"tonnage"
		Action.FLANK, Action.SHOOT:
			return &"base"
	return &""


func drive(view: BotView, intent: GauntletBot.Intent, ready: bool) -> void:
	var me: BotView.Player = view.player()
	intent.aim = me.pos.direction_to(foe.pos)
	intent.slot = &""
	intent.attack = &""
	if action == Action.CRACK:
		intent.move = view.chase(foe)
		intent.sprint = true
	if not ready or me.form != form() or not me.settled:
		return
	if action == Action.FLANK:
		var rear: Vector2 = foe.pos - foe.facing * (me.radius + foe.radius)
		var toward: Vector2 = me.pos.direction_to(rear)
		intent.move = toward if view.walk_clear(me.pos, rear) else view.chase(foe)
	if action == Action.SHOOT:
		intent.move = _face_plate(view)
	if action in [Action.SHOOT, Action.FLANK]:
		var gun: BotView.Slot = BotArsenal.best_gun(view, intent.reach)
		if gun != null:
			if me.current_slot != gun.index:
				intent.slot = view.select_slot(gun)
			elif view.aim_point(foe).is_finite() and intent.reach <= gun.reach:
				intent.aim = me.pos.direction_to(view.aim_point(foe))
				intent.attack = &"fire"
		elif action == Action.FLANK and intent.reach <= GauntletBot.MELEE_M:
			intent.attack = &"melee"
	elif action != Action.CRACK or intent.reach <= me.stomp_reach:
		intent.attack = &"melee"


func _face_plate(view: BotView) -> Vector2:
	var at: Vector2 = view.player().pos
	if not view.aim_point(foe).is_finite():
		return view.chase(foe)
	if foe.facing.dot(foe.pos.direction_to(at)) >= foe.front_cos:
		return Vector2.ZERO
	var front: Vector2 = foe.pos + foe.facing * maxf(at.distance_to(foe.pos), GauntletBot.MELEE_M)
	return at.direction_to(front) if view.walk_clear(at, front) else view.chase(foe)
