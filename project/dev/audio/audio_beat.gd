extends Node
## The audio lane's quest 1 clip: the real CollectCallPlay (the bot plays the quest) drawn by
## CollectCallView, voiced by StageAudio (shots, hits, Rivet's steps, the voice lines). Record:
##   godot --rendering-driver d3d12 --path project --write-movie <f.avi> --fixed-fps 60
##     res://dev/audio/audio_beat.tscn -- --beat=opening|fight --seconds=30 [--report=<file.json>]
## `opening`: from tick 0 (the dumpster lines, the payphone). `fight`: fast-forwards to the first
## hostile (dock guards) and films the shots and the Robo-tazer. Windowed or headless (a smoke run).

const SKIP_PER_FRAME: int = 600
const KNOWN: PackedStringArray = ["--beat", "--seconds", "--report"]

var _beat: String = "opening"
var _frames: int = 60 * 30
var _report: String = ""
var _live: int = -1
var _play: CollectCallPlay
var _view: CollectCallView = CollectCallView.new()
var _audio: StageAudio


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN.has(flag):
			get_tree().quit(2)
			return
		var value: String = arg.get_slice("=", 1)
		if flag == "--beat":
			_beat = value
		elif flag == "--seconds":
			_frames = value.to_int() * 60
		else:
			_report = value
	_play = CollectCallPlay.begin()
	_view.bind(_play.stage, _play.port, _play.system)
	add_child(_view)
	_audio = StageAudio.attach(
		self, _play.stage, _play.system, _play.bus(), CollectCallPlay.MASTER_SEED
	)
	_audio.service.clock = null
	_live = 0 if _beat == "opening" else -1


func _process(_delta: float) -> void:
	if not _play.running():
		_done()
		return
	if _live < 0:
		for i: int in SKIP_PER_FRAME:
			_play.tick_once()
			if _play.stage.arena.hostiles_alive() > 0:
				_live = 0
				break
		return
	_play.tick_once()
	_view.focus = _play.stage.arena.rivet.pos
	_live += 1
	if _live >= _frames:
		_done()


func _done() -> void:
	var s: AudioService = _audio.service
	var out: Dictionary = {
		"beat": _beat,
		"frames": _live,
		"played": s.played,
		"dropped": s.dropped,
		"voice_lines": _audio.voice.played,
		"voice_drops": s.voice.drops,
		"missing": s.bank.missing,
	}
	printerr("audio_beat: %s" % JSON.stringify(out))
	if _report != "":
		var f: FileAccess = FileAccess.open(_report, FileAccess.WRITE)
		if f != null:
			@warning_ignore("return_value_discarded")
			f.store_string(JSON.stringify(out, "  ", true))
	get_tree().quit(0)
