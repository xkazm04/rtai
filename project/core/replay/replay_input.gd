class_name ReplayInput
extends InputSource
## Feeds a recorded ReplayLog back in, tick for tick (SIM-05).

var _log: ReplayLog


func _init(log: ReplayLog) -> void:
	_log = log


func sample(tick: int) -> TickInput:
	return _log.input_at(tick)
