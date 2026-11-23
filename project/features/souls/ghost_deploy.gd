class_name GhostDeploy
extends RefCounted
## The first ghost skill. A deploy action holds a cursor in world metres. Its falling edge commits a
## single strike and starts two independent clocks for the apparition and the form.

enum Phase { IDLE, AIMING, ACTIVE }

var phase: Phase = Phase.IDLE
var form: StringName = &""
var spot: Vector2 = Vector2.ZERO
var origin: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.RIGHT
var ticks_left: int = 0
var cooldowns: Dictionary[StringName, int] = {}
var last_refusal: StringName = &""
var strike: GhostDeployStrike
var _action: StringName = &""
var _number_form: StringName = &""


func _init(attacks: GhostAttacks, press: HaulerForm) -> void:
	strike = GhostDeployStrike.new(attacks, press)


func step(
	stage: CollectCallStage, c: PlayerCommand, actions: PlayerActions, forms: GhostForms
) -> void:
	_advance()
	if GhostNumberKeys.in_car(stage):
		_cancel_hold()
		return
	if _action == &"" and not _begin_hold(stage, c, actions, forms):
		return
	if not stage.arena.rivet.alive():
		last_refusal = &"dead"
		_cancel_hold()
		return
	var id: StringName = held_form(forms)
	if _number_form != &"" and not forms.locks.allows(forms.table, id):
		_cancel_hold()
		return
	if c.is_held(actions, _action):
		if phase != Phase.ACTIVE:
			_aim(stage, c, id)
		return
	_action = &""
	_number_form = &""
	last_refusal = _refusal(forms, id)
	if last_refusal != &"":
		if phase == Phase.AIMING:
			_clear()
		return
	_release(stage, c, id)


func _begin_hold(
	stage: CollectCallStage, c: PlayerCommand, actions: PlayerActions, forms: GhostForms
) -> bool:
	if c.was_pressed(actions, &"ghost_deploy"):
		_action = &"ghost_deploy"
		return true
	if c.pressed == 0:
		return false
	_number_form = GhostNumberKeys.pressed(c, actions, forms)
	if _number_form == &"":
		return false
	_action = GhostNumberKeys.action(forms.table, _number_form)
	if _action == GhostNumberKeys.ACTIONS[0] and c.was_pressed(actions, &"car"):
		return not GhostNumberKeys.car_may_enter(stage.vehicles)
	return true


## The simulated cursor and the marker use the same form, even during a busy refusal.
func held_form(forms: GhostForms) -> StringName:
	if _action == &"":
		return &""
	return forms.selected if _number_form == &"" else _number_form


func _cancel_hold() -> void:
	_action = &""
	_number_form = &""
	if phase == Phase.AIMING:
		_clear()


func _release(stage: CollectCallStage, c: PlayerCommand, selected: StringName) -> void:
	var row: GhostAttacks.DeployRow = strike.attacks.deploy[selected]
	if c.aim != Vector2.ZERO or phase != Phase.AIMING or form != selected:
		_aim(stage, c, selected)
	else:
		# A pad can centre its aim stick on release after Rivet's last movement tick.
		var from: Vector2 = stage.arena.rivet.pos
		var to: Vector2 = from + (spot - from).limit_length(row.range_m)
		spot = GhostDeploySpot.clip(stage, from, to)
		if spot != from:
			facing = from.direction_to(spot)
	phase = Phase.ACTIVE
	ticks_left = row.life_ticks
	cooldowns[form] = row.cooldown_ticks
	origin = spot
	strike.land(stage, self)


func _advance() -> void:
	if not cooldowns.is_empty():
		for id: StringName in GhostAttacks.GHOSTS:
			if cooldowns.has(id):
				cooldowns[id] -= 1
				if cooldowns[id] == 0:
					@warning_ignore("return_value_discarded")
					cooldowns.erase(id)
	if phase == Phase.ACTIVE:
		ticks_left -= 1
		if ticks_left == 0:
			_clear()


func _aim(stage: CollectCallStage, c: PlayerCommand, selected: StringName) -> void:
	form = selected
	phase = Phase.AIMING
	var rivet: Fighter = stage.arena.rivet
	var row: GhostAttacks.DeployRow = strike.attacks.deploy.get(form)
	var reach: float = row.range_m if row != null else 0.0
	if c.aim_m > 0.0:
		reach = minf(reach, c.aim_m)
	facing = c.aim.normalized() if c.aim != Vector2.ZERO else rivet.facing
	spot = GhostDeploySpot.clip(stage, rivet.pos, rivet.pos + facing * reach)


func _refusal(forms: GhostForms, id: StringName) -> StringName:
	if forms.table.form(id) == null or not forms.locks.allows(forms.table, id):
		return GhostLocks.LOCKED
	var row: GhostAttacks.DeployRow = strike.attacks.deploy.get(id)
	if row == null or not row.enabled:
		return &"disabled"
	if cooldowns.has(id):
		return &"cooldown"
	if phase == Phase.ACTIVE or not forms.settled() or forms.current() != GhostForms.BASE:
		return &"busy"
	return &""


func _clear() -> void:
	phase = Phase.IDLE
	form = &""
	spot = Vector2.ZERO
	origin = Vector2.ZERO
	facing = Vector2.RIGHT


func write_state(out: StreamPeerBuffer) -> void:
	if phase == Phase.IDLE and cooldowns.is_empty() and _action == &"":
		return
	out.put_utf8_string("ghost_deploy")
	out.put_8(phase)
	out.put_8(int(_action != &""))
	out.put_utf8_string(form)
	for point: Vector2 in [spot, origin, facing]:
		out.put_float(point.x)
		out.put_float(point.y)
	out.put_32(ticks_left)
	for id: StringName in GhostAttacks.GHOSTS:
		var left: int = cooldowns.get(id, 0)
		out.put_32(left)
	if _number_form != &"":
		out.put_utf8_string(_number_form)
