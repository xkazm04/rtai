extends SceneTree
## Scratch (n9 it9, not committed to project/): quest 1 on a --device row, fast-forwarded to
## --from by the scripted pad, then --frames frames at one tick a frame (film with --write-movie).
## godot --path project -s res://dev/zz_q1_deck.gd -- --row=deck --from=5800 --frames=2700 --view=combo


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	var made: Object = (load("res://dev/zz_q1_deck_run.gd") as GDScript).new()
	root.add_child.call(made)
