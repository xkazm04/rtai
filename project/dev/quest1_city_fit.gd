extends SceneTree
## Finds where quest 1's stage fits on the generated city (dev tool; dev/ is not exported): for
## each east-west street and squash, every origin along it is scored by how many of the stage's
## places (spawn points, hide spots, phones, allies, patrol corners) and walked legs (the bot's
## route, start to paid) overlap a building, prop or parked car. Prints the clear fits nearest
## the city's start; the chosen one goes into data/tables/collect_call_city.json by hand.
## Usage: godot --headless --path project -s res://dev/quest1_city_fit.gd


func _initialize() -> void:
	var script: GDScript = load("res://dev/quest1_city_fit_run.gd") as GDScript
	if script == null or not script.can_instantiate():
		printerr("quest1_city_fit: does not compile")
		quit(1)
		return
	var fit: Object = script.new()
	var rc: int = fit.call("run")
	quit(rc)
