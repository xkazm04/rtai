class_name InputSource
extends RefCounted
## Where each tick's input comes from: live devices (lands with features/input), a test bot, or a
## replay log. SimLoop samples it exactly once per tick, in tick order. The base is idle.


func sample(_tick: int) -> TickInput:
	return TickInput.new()
