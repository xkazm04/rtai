class_name GhostDeployTally
extends RefCounted
## The interval belongs to the wave. Overlapping waves sample the same release independently.

## Successful stun applications per release, separate from the duration of active shorts.
var stuns: Dictionary[StringName, int] = {}
var _casts: Dictionary[StringName, int] = {}
var _kills: Dictionary[StringName, int] = {}
var _stun_ticks: int = 0
var _sampled: int = -1


func begin(tick: int) -> void:
	_casts.clear()
	_kills.clear()
	stuns.clear()
	_stun_ticks = 0
	_sampled = tick


func sample(stage: CollectCallStage) -> void:
	if stage.tick <= _sampled:
		return
	_sampled = stage.tick
	var strike: GhostDeployStrike = stage.pilot.ghosts.deploy.strike
	if strike.release_tick == stage.tick:
		var form: StringName = strike.release_form
		_casts[form] = _casts.get(form, 0) + 1
		_kills[form] = _kills.get(form, 0) + strike.release_kills
		stuns[form] = stuns.get(form, 0) + strike.release_stuns
	_stun_ticks += strike.stunned_count(stage.arena, stage.tick)


func append_wave(row: Dictionary) -> void:
	if not _casts.is_empty():
		row["deploys"] = _casts.duplicate()
		row["deploy_kills"] = _kills.duplicate()
	if _stun_ticks > 0 or _casts.has(OhmStage.GHOST):
		row["deploy_stun_s"] = {"ohm": _stun_ticks * SimClock.TICK_DT}
