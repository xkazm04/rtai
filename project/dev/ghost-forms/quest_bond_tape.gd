extends Quest1Game
## Run the recorded controls to the final tick, even when an archived hash differs.

const KNOWN_FLAGS: PackedStringArray = ["--replay"]


func _replay(path: String) -> void:
	var tape: ReplayLog = ControlsReplay.load_for_playback(path)
	var again: Quest1Session = Quest1Session.open(Events, Data, tape.master_seed) if tape else null
	if again == null:
		get_tree().quit(2)
		return
	var difference: String = again.world.verify_replay(tape)
	var bond: GhostBond = again.pilot.ghosts.forms.bond
	var measured: Dictionary = {
		"ticks": again.tick(),
		"bond": bond.snapshot(),
		"master_at": bond.master_at,
		"replay": "identical" if difference.is_empty() else difference,
	}
	var full: bool = again.pilot.ghosts.forms.table.order.any(bond.ready)
	Log.info("quest-bond", JSON.stringify(measured))
	again.world.free()
	get_tree().quit(2 if full else int(not difference.is_empty()))
