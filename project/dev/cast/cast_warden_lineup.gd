extends "res://dev/cast/cast_lineup.gd"
## Review the native card without the yard's legacy rig costume.


func _ready() -> void:
	CastMulroneyPreview.enable(FoeWardenCardView.ID)
	await super._ready()


func _far_patrol(_foe: Fighter) -> void:
	pass


func _portrait(subject: Fighter, id: String) -> bool:
	if id == FoeWardenCardView.ID:
		for item: Node in _scene.find_children("*", "Node2D", true, false):
			if item is PrologueProps:
				(item as Node2D).hide()
	elif id == CastMulroneyPreview.ID:
		CastMulroneyPreview.hide_dress(_scene)
	elif id not in ["Rivet", "patrol_cop"]:
		return true
	return await super._portrait(subject, id)
