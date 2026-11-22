class_name PrologueFormation
extends RefCounted
## Three ranks enter through the same opening. A line-up sends the outside shields around
## Rivet while the centre holds. The rifle rank stays a pace behind the front.

var members: Array[Fighter] = []
var shields: Array[Fighter] = []
var rifles: Array[Fighter] = []
var boss: Fighter
var last_stand_hp: float
var pushing: bool = false
var _inside: Dictionary[int, bool] = {}
var _gate: Vector2
var _front: Vector2
var _contact: Vector2
var _spacing: float
var _rank_gap: float
var _flank_m: float
var _wave: Dictionary
var _data: DataTable


func _init(yard: PrologueYard, data: DataTable) -> void:
	_data = data
	_wave = data.array(data.raw, "waves")[1]
	var command: Dictionary = data.object(data.raw, "command")
	_gate = yard.gate
	_contact = data.vec(command, "front_at")
	_spacing = data.num(command, "file_spacing_m")
	_rank_gap = data.num(command, "rank_spacing_m")
	_flank_m = data.num(command, "flank_m")
	last_stand_hp = data.num(command, "last_stand_hp")


func enter(arena: CombatArena) -> void:
	for h: Fighter in members:
		arena.hostiles.erase(h)
	members.clear()
	shields.clear()
	rifles.clear()
	_inside.clear()
	pushing = false
	_front = _contact
	var squad: PrologueSquad = arena.squad_ai as PrologueSquad
	squad.talking = true
	squad.clear_wave()
	for group: Dictionary in _data.array(_wave, "groups"):
		var arch: StringName = StringName(_data.text(group, "archetype"))
		for i: int in _data.integer(group, "count"):
			var n: int = members.size()
			var at: Vector2 = _gate + Vector2((n % 3 - 1) * 1.25, 1.25 + floorf(n / 3.0) * 1.4)
			var h: Fighter = squad.spawn_member(arena, at, arch)
			h.pos = at
			h.facing = Vector2.UP
			h.exposed = false
			h.max_hp = squad.pit.roster.archetype(arch).hp
			h.hp = h.max_hp
			members.append(h)
			match _data.text(group, "role"):
				"front_line":
					shields.append(h)
				"ranged_line":
					rifles.append(h)
				"behind_line":
					boss = h


func engage(arena: CombatArena) -> void:
	for h: Fighter in members:
		h.exposed = h != boss or not shields_standing()
	arena.announce_wave(StringName(_data.text(_wave, "id")), 2)


func march(arena: CombatArena, fighting: bool, hold_boss: bool) -> void:
	var player: Vector2 = arena.rivet.pos
	var facing: Vector2 = _gate.direction_to(player)
	if facing.is_zero_approx():
		facing = Vector2.UP
	if fighting:
		var want: Vector2 = player - facing * _flank_m
		want.y = minf(want.y, _contact.y)
		var pace: float = arena.squad_ai.pit.roster.archetype(&"riot_cop").speed_mps
		_front = _front.move_toward(want, pace * SimClock.TICK_DT)
	for h: Fighter in members:
		if not h.alive():
			continue
		var mark: Vector2 = _mark(h, player, facing)
		if not _inside.has(h.id):
			mark = Vector2(clampf(h.pos.x, _gate.x - 1.5, _gate.x + 1.5), _gate.y - 1.5)
			if h.pos.distance_to(mark) < 0.2:
				_inside[h.id] = true
		elif h == boss and hold_boss:
			h.facing = h.pos.direction_to(player)
			continue
		var speed: float = arena.squad_ai.pit.roster.archetype(h.archetype).speed_mps
		if not h.pursuit.advance(h, mark, speed):
			h.pos = h.pos.move_toward(mark, speed * SimClock.TICK_DT)
		h.facing = h.pos.direction_to(player)


func _mark(h: Fighter, player: Vector2, facing: Vector2) -> Vector2:
	var across: Vector2 = facing.orthogonal()
	if h == boss:
		return _front - facing * (2.0 * _rank_gap)
	var front_rank: bool = h in shields
	var rank: Array[Fighter] = shields if front_rank else rifles
	var file: float = rank.find(h) - (rank.size() - 1) * 0.5
	if pushing and front_rank and not is_zero_approx(file):
		return player - facing * 0.7 + across * signf(file) * _flank_m
	return _front + across * file * _spacing - facing * (0.0 if front_rank else _rank_gap)


func men_standing() -> bool:
	for h: Fighter in members:
		if h != boss and h.alive():
			return true
	return false


func shields_standing() -> bool:
	for h: Fighter in shields:
		if h.alive():
			return true
	return false
