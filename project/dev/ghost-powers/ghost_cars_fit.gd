extends SceneTree
## Dev-only: checks quest 1's ghost_cars against the city's walk cells (ghost_cars_fit_run.gd).
##   godot --headless --path project -s res://dev/ghost-powers/ghost_cars_fit.gd


func _initialize() -> void:
	var script: GDScript = load("res://dev/ghost-powers/ghost_cars_fit_run.gd") as GDScript
	if script == null or not script.can_instantiate():
		printerr("ghost_cars_fit: does not compile")
		quit(1)
		return
	var fit: Object = script.new()
	var rc: int = fit.call("run")
	quit(rc)
