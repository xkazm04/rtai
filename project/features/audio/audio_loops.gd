class_name AudioLoops
extends Node
## Looping beds (cues with loop=true): the engine, the siren, the city. Each is a plain player on
## its cue's bus that fades toward a target level, so a bed can start, stop and swell without a pop.

const FADE_DB_PER_S: float = 24.0
const SILENT_DB: float = -60.0

var _tables: AudioTables
var _bank: SoundBank
var _players: Dictionary[StringName, AudioStreamPlayer] = {}
var _target_db: Dictionary[StringName, float] = {}


func _init(tables: AudioTables, bank: SoundBank) -> void:
	_tables = tables
	_bank = bank


## Turns bed `id` on (at its cue gain + `trim_db`) or off.
func set_on(id: StringName, on: bool, trim_db: float = 0.0) -> void:
	var cue: AudioCue = _tables.cue(id)
	if cue == null or not cue.loop:
		return
	if not _players.has(id):
		if not on:
			return
		var s: AudioStream = _bank.stream(cue, 0)
		if s == null:
			return
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.stream = s
		p.bus = cue.bus
		p.volume_db = SILENT_DB
		add_child(p)
		p.play()
		_players[id] = p
	_target_db[id] = (cue.gain_db + trim_db) if on else SILENT_DB


func is_on(id: StringName) -> bool:
	return _target_db.get(id, SILENT_DB) > SILENT_DB


## Called by AudioService every rendered frame with the clock's frame_delta().
func step(frame_s: float) -> void:
	for id: StringName in _players:
		var p: AudioStreamPlayer = _players[id]
		p.volume_db = move_toward(p.volume_db, _target_db[id], FADE_DB_PER_S * frame_s)
		if p.volume_db <= SILENT_DB and _target_db[id] <= SILENT_DB and p.playing:
			p.stream_paused = true
		elif p.stream_paused and _target_db[id] > SILENT_DB:
			p.stream_paused = false
