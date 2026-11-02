@abstract class_name WorldSystem
extends RefCounted
## A system the composition root owns (ARC-04). It receives the WorldContext exactly once,
## through setup(), and never looks anything up by path or name. Call down, signal up (ARC-05):
## cross-feature news goes out through ctx.events, never through a sibling reference.
## Sim systems also step on the fixed tick (SIM-01) and write their state for the replay hash.

@abstract func setup(ctx: WorldContext) -> void


## One fixed 60 Hz tick. Read time only as SimClock.TICK_DT and `tick`, never a frame delta.
func step(_tick: int, _input: TickInput) -> void:
	pass


## Writes every value a replay must reproduce, in a fixed order (SIM-05 state hash).
func write_state(_out: StreamPeerBuffer) -> void:
	pass
