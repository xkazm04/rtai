extends "res://dev/cast/cast_lineup.gd"
## Rivet, the patrol cop, the gunner's card and his robot rig of today, in one native-scale plate.
## The last portrait drops the gunner's row from the loaded library: the old robot-rig look.

const TODAY: String = "robot_rig_today"


func _ready() -> void:
	CastMulroneyPreview.enable(FoeGunnerCardView.ID)
	await super._ready()


func _far_patrol(_foe: Fighter) -> void:
	pass


func _capture_wave() -> bool:
	if not await _portrait(_arena.rivet, "Rivet"):
		return false
	for id: StringName in [&"patrol_cop", FoeGunnerCardView.ID]:
		if not await _spawn_portrait(id, String(id)):
			return false
	@warning_ignore("return_value_discarded")
	CastCards.shipped()._by_id.erase(FoeGunnerCardView.ID)
	return await _spawn_portrait(FoeGunnerCardView.ID, TODAY)


func _spawn_portrait(id: StringName, label: String) -> bool:
	var foe: Fighter = _arena.squad_ai.spawn_member(_arena, MARK, id)
	@warning_ignore("return_value_discarded")
	_arena.squad_ai.mind_for(foe)
	return await _portrait(foe, label)


func _capture_prologue() -> bool:
	_game = PrologueGame.new()
	return true
