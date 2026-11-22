class_name ProloguePatrol
extends RefCounted
## Each row enters the gate in files, then walks to its mark. The actors survive the cut
## from the conversation to combat, including anyone still outside after an early strike.


class Officer:
	extends RefCounted
	var body: Fighter
	var mark: Vector2
	var gate_exit: Vector2
	var inside: bool
	var lead_warden: bool


var dale: Fighter
var officers: Array[Officer] = []
var squad: PrologueSquad
var wave_id: String
var wave_start: Vector2
var approaching: int = 0
var fanned: bool = false
var _wave: Dictionary
var _arrival: Dictionary
var _data: DataTable
var _marks: Dictionary[String, Dictionary] = {}
var _approach_lines: Array[String] = []
var _fan_line: String
var _gate: Vector2
var _lead_mark: Vector2
var _speed: float
var _first_gap: float
var _last_gap: float


func _init(stage: ArenaStage, data: DataTable) -> void:
	_data = data
	_arrival = data.object(data.raw, "arrival")
	_wave = data.array(data.raw, "waves")[0]
	wave_id = data.text(_wave, "id")
	wave_start = data.vec(_arrival, "rivet_at")
	_gate = (stage.plan as PrologueYard).gate
	_lead_mark = data.vec(_arrival, "first_warden_at")
	_speed = data.num(_arrival, "walk_mps")
	_first_gap = data.num(_arrival, "dale_first_gap_m")
	_last_gap = data.num(_arrival, "dale_last_gap_m")
	_approach_lines.assign(data.array(_wave, "approach_lines"))
	_fan_line = data.text(_arrival, "fan_line")
	for row: Dictionary in data.array(_arrival, "formations"):
		_marks[data.text(row, "id")] = row
	squad = stage.arena.squad_ai as PrologueSquad
	squad.configure(stage.arena, data)


func place(arena: CombatArena, at_wave: bool) -> void:
	for officer: Officer in officers:
		arena.hostiles.erase(officer.body)
	officers.clear()
	squad.clear_wave()
	squad.talking = not at_wave
	squad.shot_tick = -1
	approaching = 0
	fanned = false
	for group: Dictionary in _data.array(_wave, "groups"):
		var id: String = _data.text(group, "id")
		var arch: StringName = StringName(_data.text(group, "archetype"))
		var mark: Dictionary = _data.object(_marks, id)
		for i: int in _data.integer(group, "count"):
			var officer: Officer = _spawn(arena, arch, mark, i)
			officer.lead_warden = id == "catchers" and i == 0
			if id == "winnick":
				dale = officer.body
			officer.body.exposed = at_wave or officer.body == dale
			if at_wave:
				officer.body.pos = officer.mark
	if at_wave:
		dale.pos = wave_start + Vector2.RIGHT * _last_gap
		dale.take(dale.max_hp, arena.tick, Vector2.RIGHT)


func _spawn(arena: CombatArena, arch: StringName, formation: Dictionary, i: int) -> Officer:
	var n: int = officers.size()
	var rank_size: int = _data.integer(_arrival, "rank_size")
	var spacing: float = _data.num(_arrival, "spacing_m")
	var file_x: float = (n % rank_size - (rank_size - 1) * 0.5) * spacing
	var rank_y: float = (floorf(float(n) / rank_size) + 1.0) * spacing
	var start: Vector2 = _gate + Vector2(file_x, rank_y)
	var officer: Officer = Officer.new()
	officer.body = squad.spawn_member(arena, start, arch)
	officer.body.pos = start
	officer.body.facing = Vector2.UP
	officer.gate_exit = _gate + Vector2(file_x, -_data.num(_arrival, "gate_exit_m"))
	officer.mark = _data.vec(formation, "first") + _data.vec(formation, "step") * (i % rank_size)
	officer.mark.y += floorf(float(i) / rank_size) * spacing
	officers.append(officer)
	return officer


func direct(arena: CombatArena, line: String) -> void:
	fanned = fanned or line == _fan_line
	approaching = maxi(approaching, _approach_lines.find(line) + 1)
	for officer: Officer in officers:
		if not officer.inside and officer.body.pos.distance_to(officer.gate_exit) < 0.2:
			officer.inside = true
		var target: Vector2 = _mark(officer, arena.rivet.pos)
		if not officer.inside:
			target = officer.gate_exit
		_walk(officer.body, target, arena.rivet.pos)


func _mark(officer: Officer, player: Vector2) -> Vector2:
	if officer.body == dale and approaching > 0:
		var gap: float = _first_gap if approaching == 1 else _last_gap
		return player + player.direction_to(dale.pos) * gap
	if not fanned and officer.body.archetype == &"appliance_warden":
		return _lead_mark if officer.lead_warden else officer.gate_exit
	return officer.mark


func _walk(body: Fighter, target: Vector2, look_at: Vector2) -> void:
	if body.pursuit.advance(body, target, _speed):
		return
	var next: Vector2 = body.pos.move_toward(target, _speed * SimClock.TICK_DT)
	body.facing = body.pos.direction_to(next if next != body.pos else look_at)
	body.pos = next


func panic(arena: CombatArena) -> void:
	squad.talking = false
	for officer: Officer in officers:
		officer.body.exposed = true
	arena.announce_wave(StringName(wave_id), 1)


func cleared() -> bool:
	for officer: Officer in officers:
		if officer.body.alive():
			return false
	return true
