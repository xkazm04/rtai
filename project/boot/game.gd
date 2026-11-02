extends Node
## Game autoload: run lifecycle (new game, quit). DebugTools is instantiated from dev/ here,
## never registered as an autoload (ARC-02). No per-frame gameplay state lives here (ARC-03).


func is_dev_build() -> bool:
	return OS.is_debug_build() or OS.has_feature("devtools")


## Called by "new game" and by tests. Resets every autoload that holds mutable state.
func reset_all() -> void:
	Log.reset()
	Data.reset()
	Save.reset()
	Events.reset()
