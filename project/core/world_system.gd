@abstract class_name WorldSystem
extends RefCounted
## A system the composition root owns (ARC-04). It receives the WorldContext exactly once,
## through setup(), and never looks anything up by path or name. Call down, signal up (ARC-05):
## cross-feature news goes out through ctx.events, never through a sibling reference.

@abstract func setup(ctx: WorldContext) -> void
