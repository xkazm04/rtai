class_name BossCam
extends Node
## Dev `--boss-cam` (clips): the arena camera frames Rivet and the boss together, sitting
## FRAME_K of the way from Rivet to the boss, so a filmed attack keeps both on screen. View
## only (SIM-03): it sets CollectCallView.focus, never the sim; without the flag the camera
## follows Rivet.

const FLAG: String = "--boss-cam"
const FRAME_K: float = 0.45
## Farther apart than this (a respawn, the procession's far end) it follows Rivet alone.
const FAR_M: float = 20.0

var view: CollectCallView = null
var hook: BossHook = null


static func wanted() -> bool:
	return OS.get_cmdline_user_args().has(FLAG)


func _process(_delta: float) -> void:
	if view == null or hook == null or hook.fight == null:
		return
	var r: Vector2 = hook.rivet_pos()
	var b: Vector2 = hook.fight.body.pos
	view.focus = r if r.distance_to(b) > FAR_M else r.lerp(b, FRAME_K)
