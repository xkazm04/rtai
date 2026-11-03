class_name SaveNotice
extends RefCounted
## The one-line save notice the HUD shows for a few seconds ("Could not read your newest save; went
## back to the one before"). The game calls `show` with `Save.take_notice()` after a load, the view
## calls `tick` each frame and draws `text()` while it is not empty. Pure state, no drawing.

const DEFAULT_SECONDS: float = 7.0

var _text: String = ""
var _left: float = 0.0


func show(line: String, seconds: float = DEFAULT_SECONDS) -> void:
	_text = line
	_left = seconds if line != "" else 0.0


func tick(dt: float) -> void:
	if _left <= 0.0:
		return
	_left -= dt
	if _left <= 0.0:
		_text = ""


## The line to draw now; empty when there is none or it has run out.
func text() -> String:
	return _text if _left > 0.0 else ""
