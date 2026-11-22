class_name BotCarryPick
extends RefCounted
## Offers arrive after the block clears. Remember whether the enemies in the
## latest wave actually came within the carry radius before they disappeared.

var _wave: int = -1
var _clustered: bool = false


func observe(arena: CombatArena, wave: int) -> void:
	if wave != _wave:
		_wave = wave
		_clustered = false
	var squad: ArenaSquad = arena.squad_ai
	if _clustered or squad == null or not squad.moves.overkill_carry.enabled:
		return
	var row: MoveTable.Overkill = squad.moves.overkill_carry
	var radius: float = row.first.radius_m if squad.carry == null else row.second.radius_m
	for i: int in arena.hostiles.size():
		var left: Fighter = arena.hostiles[i]
		if not left.alive():
			continue
		for j: int in range(i + 1, arena.hostiles.size()):
			var right: Fighter = arena.hostiles[j]
			if right.alive() and left.pos.distance_squared_to(right.pos) <= radius * radius:
				_clustered = true
				return


func desired(stage: ArenaStage, wave: int) -> StringName:
	var squad: ArenaSquad = stage.arena.squad_ai
	if squad == null or not squad.moves.overkill_carry.enabled or wave < 3:
		return &""
	if squad.carry != null:
		return MoveBonus.OVERKILL_2 if squad.carry.rank == 1 else &""
	var carry: RivetCarry = stage.pilot.carry
	if not _clustered or carry == null:
		return &""
	var ids: Array[StringName] = carry.first_seen if carry.wheel_inventory else carry.slots
	for id: StringName in ids:
		if id in [&"hand_cannon", &"shotgun", &"rocket_launcher", &"mini_nuke"]:
			return MoveTable.OVERKILL
	return &""
