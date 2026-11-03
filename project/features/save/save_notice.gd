class_name SaveNotice
extends RefCounted
## The one-line save notice the HUD shows for a few seconds ("A save was damaged. Loaded the last
## good one."). The game calls `show` with `Save.take_notice()` after a load; the view draws
## `text()` while it is not empty. Presentation time only (never the sim): it runs on a wall
## clock, injectable so a test needs no waiting.

const DEFAULT_SECONDS: float = 7.0

## Milliseconds now; replaced by a fake in tests.
var now_ms: Callable = Time.get_ticks_msec
var _text: String = ""
var _until_ms: int = 0


func show(line: String, seconds: float = DEFAULT_SECONDS) -> void:
	_text = line
	_until_ms = _now() + int(seconds * 1000.0)


## The line to draw now; empty when there is none or it has run out.
func text() -> String:
	if _text == "" or _now() >= _until_ms:
		return ""
	return _text


func _now() -> int:
	var ms: int = now_ms.call()
	return ms
