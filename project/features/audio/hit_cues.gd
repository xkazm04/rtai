class_name HitCues
extends RefCounted
## n7-melee: Rivet's melee hits and the ghost attacks had no sound of their own (the audit's sound
## column: a non-lethal claw jab, a cut, a stomp or a bolt played nothing; a kill only the generic
## kill punch). This plays the weapon's `hits` cue (audio_cues.json) where the victim stands, on
## the tick CombatArena reports the hit (wounded or kill_landed), so the sound lands on the hit
## frame. The chainsaw grind wounds every tick: a victim heard less than MeleeWound.GAP_TICKS ago
## is skipped (a kill always plays). Render side only: reads the arena, writes nothing back.
## `--hit-cues=off` = none (the before).

var played: int = 0
var _arena: CombatArena
var _hits: Dictionary[StringName, StringName] = {}
## Plays cue id at a position in metres on a tick: AudioService.cue, or a recorder in tests.
var _play: Callable
var _gate: MeleeWound = MeleeWound.new()


static func attach(
	arena: CombatArena, hits: Dictionary[StringName, StringName], play: Callable
) -> HitCues:
	var h: HitCues = HitCues.new()
	h._arena = arena
	h._hits = hits
	h._play = play
	@warning_ignore("return_value_discarded")
	arena.wounded.connect(h._on_wounded)
	@warning_ignore("return_value_discarded")
	arena.kill_landed.connect(h._on_kill)
	return h


static func enabled() -> bool:
	return not OS.get_cmdline_user_args().has("--hit-cues=off")


## The cue a hit by `weapon` plays (&"" = none of its own).
func cue_for(weapon: StringName) -> StringName:
	return _hits.get(weapon, &"")


func _on_wounded(victim: Fighter, weapon: StringName) -> void:
	var id: StringName = cue_for(weapon)
	if id != &"" and _gate.admit(victim.id, _arena.tick):
		_fire(id, victim.pos)


func _on_kill(
	victim: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName
) -> void:
	var id: StringName = cue_for(weapon)
	if id != &"":
		_fire(id, victim.pos)


func _fire(id: StringName, at: Vector2) -> void:
	played += 1
	_play.call(id, at, _arena.tick)
