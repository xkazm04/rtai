class_name BladeTap
extends Node
## n31 melee 01a: calls `on_frame` once a frame after Rivet's held and swipe views processed
## (their priorities are 10 and 12), so blade_volume reads the geometry drawn this frame.

var on_frame: Callable = Callable()


func _ready() -> void:
	process_priority = 50


func _process(_delta: float) -> void:
	if on_frame.is_valid():
		on_frame.call()
