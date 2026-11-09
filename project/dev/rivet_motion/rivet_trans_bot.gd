class_name RivetTransBot
extends RivetTourBot
## n10 rivet (dev, the defect hunt, `--tour-kind=trans`): the state transitions the weapon tour does
## not reach, one per row of the contact sheet: a swap while running (both ways), a roll out of a
## burst, a roll in a reload, a roll into a shot, a swap in a reload, a melee press in a burst.
## Needs two carried guns in slots 1 and 2 (`--loadout=pistol,plasma_rifle`). Reads only the sim.

## [ticks, aim degrees, stick along the aim, fire held from this tick (-1 never), [[tick, action]]]
const SEGS: Array = [
	[70, 0.0, 1.0, -1, [[20, &"weapon_slot_2"]]],
	[70, 180.0, 1.0, -1, [[20, &"weapon_slot_1"]]],
	[50, 0.0, 0.5, 0, [[10, &"roll"]]],
	[50, 180.0, 0.5, 0, [[10, &"roll"]]],
	[60, 0.0, 0.0, -1, [[0, &"reload"], [12, &"roll"]]],
	[50, 0.0, 1.0, 8, [[0, &"roll"]]],
	[60, 0.0, 0.0, -1, [[0, &"reload"], [14, &"weapon_slot_2"]]],
	[60, 180.0, 0.0, 8, [[20, &"melee"]]],
]
const SHEET_TICKS: PackedInt32Array = [6, 12, 18, 24, 30, 36, 42, 48, 56]


func columns() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for t: int in SHEET_TICKS:
		out.append(Vector2i(Phase.WALK, t))
	return out


func sample(_tick: int) -> TickInput:
	if phase == Phase.DONE:
		return TickInput.new()
	var s: Array = SEGS[oct_i]
	var deg: float = s[1]
	var aim: Vector2 = Vector2.from_angle(deg_to_rad(deg))
	var buttons: int = PlayerCommand.pack_aim(aim, _actions)
	var move: Vector2 = Vector2.ZERO
	if phase == Phase.HOME:
		var walk: float = _stage.arena.tuning.rivet["walk_mps"]
		move = ArenaRivetBot.arrive(home - _stage.arena.rivet.pos, walk, _actions)
		_home_ticks += 1
		move = Vector2.ZERO if _home_ticks > MAX_HOME else move
	else:
		var stick: float = s[2]
		move = aim * stick
		buttons |= _pressed(s)
	_advance(move)
	var m: Vector2 = move * TickInput.AXIS_MAX
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))


func _pressed(s: Array) -> int:
	var b: int = 0
	var from: int = s[3]
	if from >= 0 and in_phase >= from:
		b |= 1 << _actions.bit(&"fire")
	var presses: Array = s[4]
	for p: Array in presses:
		var at: int = p[0]
		var action: StringName = p[1]
		if at == in_phase:
			b |= 1 << _actions.bit(action)
	return b


func _advance(move: Vector2) -> void:
	in_phase += 1
	if phase == Phase.HOME:
		if move != Vector2.ZERO:
			return
		in_phase = 0
		_home_ticks = 0
		oct_i += 1
		phase = Phase.WALK if oct_i < SEGS.size() else Phase.DONE
		return
	var s: Array = SEGS[oct_i]
	var ticks: int = s[0]
	if in_phase >= ticks:
		in_phase = 0
		phase = Phase.HOME
