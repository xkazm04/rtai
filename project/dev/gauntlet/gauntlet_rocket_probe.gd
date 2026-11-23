class_name GauntletRocketProbe
extends RefCounted
## Match successful blast damage to the immediately following round-landed signal.
## Retain each wave's live member list so delayed spawns and late impacts keep their owner.

var _members: Array[Array] = []
var _by_shooter: Dictionary[int, int] = {}
var _hit: bool = false


func attach(session: GauntletSession, waves: GauntletWaves) -> void:
	@warning_ignore("return_value_discarded")
	session.world.context().events.wave_started.connect(_wave.bind(waves))
	@warning_ignore("return_value_discarded")
	session.stage.arena.struck.connect(_struck)
	@warning_ignore("return_value_discarded")
	session.stage.arena.squad_ai.rockets.burst.connect(_burst)


func _wave(encounter: StringName, _number: int, waves: GauntletWaves) -> void:
	if encounter == &"gauntlet":
		_members.append(waves._newest_started().members)


func _struck(victim: Fighter, _direction: Vector2, _lethal: bool, weapon: StringName) -> void:
	if victim.kind == Fighter.Kind.RIVET and weapon == &"rocket":
		_hit = true


func _burst(_at: Vector2, _radius: float, shot: Shot) -> void:
	if _hit:
		_by_shooter[shot.shooter_id] = _by_shooter.get(shot.shooter_id, 0) + 1
	_hit = false


func log_waves() -> void:
	for i: int in _members.size():
		var hits: int = 0
		var troopers: int = 0
		for foe: Fighter in _members[i]:
			troopers += int(foe.archetype == &"rocket_trooper")
			hits += _by_shooter.get(foe.id, 0)
		Log.info("rocket-probe", "wave %d rocket_hits %d troopers %d" % [i + 1, hits, troopers])
