extends "res://dev/cast/cast_lineup.gd"
## Use the actual prologue boss, alongside the same Rivet and patrol reference as the cast audit.


func _ready() -> void:
	CastMulroneyPreview.enable()
	await super._ready()


func _far_patrol(_foe: Fighter) -> void:
	pass


func _portrait(subject: Fighter, id: String) -> bool:
	if id == CastMulroneyPreview.ID:
		CastMulroneyPreview.hide_dress(_scene)
	elif id not in ["Rivet", "patrol_cop"]:
		return true
	return await super._portrait(subject, id)
