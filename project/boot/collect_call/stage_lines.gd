class_name StageLines
extends RefCounted
## What the Toner Room's lines do on the stage (collect_call_stage.json line_hooks), once per
## line as it comes on screen: Brass hands over Gloria, Juno repairs Rivet, Kilohm's accents
## spike the whispers, Don tapes the cash under the nearest payphone.


static func apply(stage: CollectCallStage, line: String) -> void:
	if line == stage.last_line:
		return
	stage.last_line = line
	match stage.layout.line_hooks.get(line, ""):
		"give_gloria":
			stage.arena.rivet.weapon = &"gloria"
		"repair":
			stage.arena.rivet.hp = stage.arena.rivet.max_hp
		"whisper":
			stage.whisper_now = true
		"cash_under_phone":
			stage.cash_phone = nearest_phone(stage)


static func nearest_phone(stage: CollectCallStage) -> String:
	var at: Vector2 = stage.arena.rivet.pos
	var best: String = ""
	for phone: String in stage.layout.phones:
		var d: float = stage.layout.phones[phone].distance_to(at)
		if best == "" or d < stage.layout.phones[best].distance_to(at):
			best = phone
	return best
