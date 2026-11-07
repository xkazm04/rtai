class_name HandheldFocusPause
extends Node
## d9-handheld: under a handheld device profile (DeviceProfile.is_handheld, `--device=deck` etc.)
## losing the window's focus pauses quest 1 the way the pause button does: the Steam overlay over a
## running fight, a Windows handheld's shell, alt-tab. It never unpauses (the player resumes).
## LaunchArgs adds it next to the profile; the desktop game never has one.


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		@warning_ignore("return_value_discarded")
		pause(get_tree().current_scene as Quest1Game)


## Pauses `quest` when a run is live and not already paused; true when it did.
static func pause(quest: Quest1Game) -> bool:
	if quest == null or quest.session == null or quest.paused or quest._ended:
		return false
	quest.set_paused(true)
	Log.info("device", "focus lost: quest 1 paused")
	return true
