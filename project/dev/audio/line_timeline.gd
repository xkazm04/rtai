extends Node
## Prints when each quest 1 line is on screen (tick in, tick out) as the bot plays it, so the voice
## queue can be judged offline against voice_lengths.json:
##   godot --headless --path project res://dev/audio/line_timeline.tscn -- [--out=<file.json>]

const MAX_TICKS: int = 60 * 400


func _ready() -> void:
	var play: CollectCallPlay = CollectCallPlay.begin()
	var seen: Array[Dictionary] = []
	var cur: String = ""
	var n: int = 0
	while play.running() and n < MAX_TICKS:
		play.tick_once()
		n += 1
		var line: QuestLine = play.system.runner.lines.current
		var id: String = line.id if line != null else ""
		if id != cur:
			if cur != "":
				seen[seen.size() - 1]["out"] = n
			if id != "":
				seen.append({"id": id, "in": n, "out": -1})
			cur = id
	var path: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			path = arg.get_slice("=", 1)
	var text: String = JSON.stringify({"ticks": n, "lines": seen}, "  ", true)
	if path != "":
		var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		if f != null:
			@warning_ignore("return_value_discarded")
			f.store_string(text)
	else:
		printerr(text)
	get_tree().quit(0)
