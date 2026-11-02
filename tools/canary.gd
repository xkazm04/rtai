@abstract class_name GdtoolkitCanary
extends RefCounted
## GDS-05 canary: the newest GDScript syntax this project uses. gdlint and gdformat must parse
## this file; syntax that fails here is banned until the pinned gdtoolkit can parse it.
## Never loaded by Godot (it lives outside project/).

var scores: Dictionary[StringName, int] = {}
var doubler: Callable = func(x: int) -> int: return x * 2

@abstract func area() -> float


func total(...values: Array) -> int:
	return values.size()


@warning_ignore_start("return_value_discarded")


func discard() -> void:
	scores.keys()


@warning_ignore_restore("return_value_discarded")
