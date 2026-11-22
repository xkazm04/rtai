class_name GhostDeployBot
extends RefCounted
## Plan the two input samples of a deploy. The pilot owns all clocks and the strike.

const RETRY_TICKS: int = 30

var _view: BotView
var _stage: ArenaStage
var _spots: GhostDeployBotSpot
var _rng: RandomNumberGenerator
var _deploy_bit: int
var _cycle_bit: int
var _retry_at: int = 0
var _held_spot: Vector2 = Vector2.INF


func _init(view: BotView, actions: PlayerActions, registry: RngRegistry) -> void:
	_view = view
	_rng = registry.stream(&"test_player_ghost_deploy")
	var bit: int = actions.bit(&"ghost_deploy")
	_deploy_bit = 1 << bit if bit >= 0 else 0
	_cycle_bit = 1 << actions.bit(&"power_gearbox")
	if view is BotViewArena:
		_stage = (view as BotViewArena)._stage
		if _stage.pilot != null and _stage.pilot.ghosts != null:
			_spots = GhostDeployBotSpot.new(_stage, actions)


func steer(intent: GauntletBot.Intent, buttons: int, form_use: float) -> int:
	if _spots == null or _deploy_bit == 0:
		return buttons
	var pilot: GhostPilot = _stage.pilot.ghosts
	var ghost: GhostDeploy = pilot.deploy
	var me: BotView.Player = _view.player()
	if _held_spot.is_finite():
		var release: Vector2 = _held_spot - me.pos
		_held_spot = Vector2.INF
		if ghost.phase == GhostDeploy.Phase.AIMING:
			_aim(intent, release)
			return buttons & ~_cycle_bit
	if buttons & _cycle_bit or form_use <= 0.0 or not _ready(pilot, me):
		return buttons
	var cursor: Vector2 = _spots.best(me.selected, intent.aim, _view.hostiles(), true)
	if cursor == Vector2.ZERO:
		return buttons
	if form_use < 1.0 and _rng.randf() >= form_use:
		_retry_at = _stage.tick + RETRY_TICKS
		return buttons
	_held_spot = me.pos + cursor
	_aim(intent, cursor)
	return buttons | _deploy_bit


func _ready(pilot: GhostPilot, me: BotView.Player) -> bool:
	var ghost: GhostDeploy = pilot.deploy
	var row: GhostAttacks.DeployRow = ghost.strike.attacks.deploy.get(me.selected)
	return (
		not pilot.transform_unlocked
		and _stage.tick >= _retry_at
		and _view.wave_active()
		and me.settled
		and me.form == GhostForms.BASE
		and ghost.phase == GhostDeploy.Phase.IDLE
		and row != null
		and row.enabled
		and not ghost.cooldowns.has(me.selected)
		and pilot.forms.locks.allows(pilot.forms.table, me.selected)
	)


func _aim(intent: GauntletBot.Intent, cursor: Vector2) -> void:
	intent.aim = cursor.normalized()
	intent.reach = cursor.length()
