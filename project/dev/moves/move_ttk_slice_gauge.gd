class_name MoveTtkSliceGauge
extends MoveTtkTrial
## Separate first-impact measurement: the regular TTK trial always uses shipped HP.


func _fight(_move: StringName) -> Dictionary:
	var target: Fighter = stage.arena.hostiles[0]
	target.max_hp = 1000.0
	target.hp = target.max_hp
	stage.step(stage.tick + 1, controller.sample(target))
	if stage.pilot.kerf.slices != 1 or not target.alive():
		return {}
	return {"first_slice_damage": target.max_hp - target.hp}
