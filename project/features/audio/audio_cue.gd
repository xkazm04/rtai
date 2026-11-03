class_name AudioCue
extends RefCounted
## One row of data/tables/audio_cues.json (gtai.audio-cues/1).

var id: StringName = &""
var sound: String = ""
var takes: int = 1
var bus: StringName = &"sfx"
var gain_db: float = 0.0
var pitch: float = 1.0
var pitch_jitter: float = 0.0
var max_m: float = 0.0
var cooldown_ticks: int = 0
var max_voices: int = 1
var priority: int = 0
var loop: bool = false
## A cue started along with this one ("" = none): the blood under a death or a kill punch.
var layer: StringName = &""


static func from_row(row: Dictionary) -> AudioCue:
	var c: AudioCue = AudioCue.new()
	c.id = StringName(str(row["id"]))
	c.sound = str(row["sound"])
	c.takes = _i(row, "takes")
	c.bus = StringName(str(row["bus"]))
	c.gain_db = _f(row, "gain_db")
	c.pitch = _f(row, "pitch")
	c.pitch_jitter = _f(row, "pitch_jitter")
	c.max_m = _f(row, "max_m")
	c.cooldown_ticks = _i(row, "cooldown_ticks")
	c.max_voices = _i(row, "max_voices")
	c.priority = _i(row, "priority")
	var loop_flag: bool = row["loop"]
	c.loop = loop_flag
	c.layer = StringName(str(row.get("layer", "")))
	return c


static func _f(row: Dictionary, key: String) -> float:
	var v: float = row[key]
	return v


static func _i(row: Dictionary, key: String) -> int:
	var v: float = row[key]
	return int(v)
