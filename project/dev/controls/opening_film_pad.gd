class_name OpeningFilmPad
extends RefCounted
## Drives the installed actions. Wheel presses use the same mouse event LiveInput latches in play.


static func sticks(move: Vector2, aim: Vector2) -> void:
	for stem: String in ["move", "aim"]:
		var axes: Vector2 = move if stem == "move" else aim
		button(StringName(stem + "_right"), axes.x)
		button(StringName(stem + "_left"), -axes.x)
		button(StringName(stem + "_down"), axes.y)
		button(StringName(stem + "_up"), -axes.y)


static func button(action: StringName, strength: float) -> void:
	if strength > 0.0:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)


static func scroll(live: LiveInput) -> void:
	for bound: InputEvent in InputMap.action_get_events(&"weapon_next"):
		if bound is InputEventMouseButton:
			var notch: InputEventMouseButton = bound.duplicate() as InputEventMouseButton
			notch.pressed = true
			live.note_event(notch)
			return
