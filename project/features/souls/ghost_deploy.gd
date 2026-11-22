class_name GhostDeploy
extends RefCounted
## The first ghost skill. Q holds a cursor in world metres. Its falling edge commits a
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
var _held: bool = false


func _init(attacks: GhostAttacks, press: HaulerForm) -> void:
	strike = GhostDeployStrike.new(attacks, press)


func step(
	stage: CollectCallStage, c: PlayerCommand, actions: PlayerActions, forms: GhostForms
) -> void:
	_advance()
	var down: bool = c.is_held(actions, &"ghost_deploy")
	if c.was_pressed(actions, &"ghost_deploy"):
		_held = true
	if not _held:
		return
	if not stage.arena.rivet.alive():
		last_refusal = &"dead"
		_held = false
		if phase == Phase.AIMING:
			_clear()
		return
	if down:
		if phase != Phase.ACTIVE:
			_aim(stage, c, forms.selected)
		return
	_held = false
	last_refusal = _refusal(forms)
	if last_refusal != &"":
		if phase == Phase.AIMING:
			_clear()
		return
	_release(stage, c, forms.selected)


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


func _refusal(forms: GhostForms) -> StringName:
	var id: StringName = forms.selected
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
	if phase == Phase.IDLE and cooldowns.is_empty() and not _held:
		return
	out.put_utf8_string("ghost_deploy")
	out.put_8(phase)
	out.put_8(int(_held))
	out.put_utf8_string(form)
	for point: Vector2 in [spot, origin, facing]:
		out.put_float(point.x)
		out.put_float(point.y)
	out.put_32(ticks_left)
	for id: StringName in GhostAttacks.GHOSTS:
		var left: int = cooldowns.get(id, 0)
		out.put_32(left)
