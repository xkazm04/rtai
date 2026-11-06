class_name TellCues
extends RefCounted
## n7-melee: the ghost attacks' wind-ups had no sound (the audit's sound column: a hit played its
## HitCues knock, the tell before it nothing). This plays three cues (audio_cues.json rows; a
## missing row is silent) from what the stage already shows, on the tick it shows it:
## - ghost_press_tell where Tonnage's press will land, the tick a slam is armed (the dashed ring);
## - ghost_press_land where it lands, when the slam struck no body (a body hit plays HitCues'
##   ghost_slam; a whiff onto the road, or a car crush alone, was silent);
## - ghost_seize at the car, the tick Dent's gearbox seizes it (the tether).
## Render side only: reads the stage, writes nothing back. `--tell-cues=off` = none (the before).

const PRESS_TELL: StringName = &"ghost_press_tell"
const PRESS_LAND: StringName = &"ghost_press_land"
const SEIZE: StringName = &"ghost_seize"

var played: int = 0
## Plays cue id at a position in metres on a tick: AudioService.cue, or a recorder in tests.
var _play: Callable
var _armed: bool = false
var _stomp_seen: int = -1
var _hits_seen: int = 0
var _seizes_seen: int = 0


static func make(play: Callable) -> TellCues:
	var t: TellCues = TellCues.new()
	t._play = play
	return t


static func enabled() -> bool:
	return not OS.get_cmdline_user_args().has("--tell-cues=off")


## One view frame of the stage (quest 1, the arena and the city block share it).
func step(stage: CollectCallStage) -> void:
	var p: StagePilot = stage.pilot
	if p == null:
		return
	var h: HaulerStage = p.hauler
	if h != null:
		var armed: bool = h.form.on and h.form.windup_k() > 0.0
		press(armed, h.slam_point(stage), stage.tick)
		land(h.stomp_tick, h.stomp_hits, h.stomp_at, stage.tick)
	var d: DentStage = p.dent
	if d != null:
		seize(d.seizes, d.car.pos if d.car != null else stage.arena.rivet.pos, stage.tick)


## The press tell plays once per armed slam, on the first frame it shows armed.
func press(armed: bool, at: Vector2, tick: int) -> void:
	if armed and not _armed:
		_fire(PRESS_TELL, at, tick)
	_armed = armed


## A new slam landing (stomp_tick moved) with no new body hit plays the landing thud.
func land(stomp_tick: int, stomp_hits: int, at: Vector2, tick: int) -> void:
	if stomp_tick == _stomp_seen:
		return
	if stomp_tick >= 0 and stomp_hits == _hits_seen:
		_fire(PRESS_LAND, at, tick)
	_stomp_seen = stomp_tick
	_hits_seen = stomp_hits


func seize(seizes: int, at: Vector2, tick: int) -> void:
	if seizes > _seizes_seen:
		_fire(SEIZE, at, tick)
	_seizes_seen = seizes


func _fire(id: StringName, at: Vector2, tick: int) -> void:
	played += 1
	_play.call(id, at, tick)
