extends SceneTree


func _initialize() -> void:
	var judge: Scenario = (load("res://tests/scenarios/scenario_arena_zebra.gd") as GDScript).new()
	var reason: String = judge.run(self)
	if reason != "":
		printerr(reason)
	quit(0 if reason == "" else 1)
