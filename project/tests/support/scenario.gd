@abstract class_name Scenario
extends RefCounted
## Base class for res://tests/scenarios/scenario_*.gd (TST-03). run() returns "" on success,
## or the failure reason.

@abstract func run(tree: SceneTree) -> String
