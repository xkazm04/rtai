extends "res://dev/cast/cast_lineup.gd"
## Rivet, the patrol cop and the contractor card in one native-scale plate (size, beside still).


func _ready() -> void:
	CastMulroneyPreview.enable(&"contractor")
	await super._ready()


func _far_patrol(_foe: Fighter) -> void:
	pass


func _capture_wave() -> bool:
	if not await _portrait(_arena.rivet, "Rivet"):
		return false
	for id: StringName in [&"patrol_cop", &"contractor"]:
		var foe: Fighter = _arena.squad_ai.spawn_member(_arena, MARK, id)
		@warning_ignore("return_value_discarded")
		_arena.squad_ai.mind_for(foe)
		if not await _portrait(foe, String(id)):
			return false
	return true


func _capture_prologue() -> bool:
	_game = PrologueGame.new()
	return true
