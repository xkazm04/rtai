class_name PrologueBattle
extends RefCounted
## The scripted contact and the recurring orders share one clock. The spoken row starts
## the tell. Only its deadline releases the flank or the rifle burst.

var formation: PrologueFormation
var fire: PrologueSquadFire
var pistol: ProloguePistol
var spec: BossSpec = BossSpec.shipped(&"mulroney")
var orders: Array[Dictionary] = []
var ranged: bool = false
var due_tick: int = -1
var exposed_until: int = -1
var last_action_tick: int = -1
var died_tick: int = -1
var deaths: int = 0
var _attack: BossAttack
var _again: int
var _line_up: String
var _shoot: String
var _pistol_at: Vector2
var _start_at: Vector2
var _patrol: ProloguePatrol
var _lines: PrologueLines
var _prompts: ProloguePrompts


func _init(
	yard: PrologueYard, data: DataTable, lines: PrologueLines, prompts: ProloguePrompts
) -> void:
	formation = PrologueFormation.new(yard, data)
	fire = PrologueSquadFire.new(data)
	pistol = ProloguePistol.new(StringName(data.text(data.raw, "pistol_pickup_id")))
	var beat: Dictionary = data.array(data.raw, "beats")[1]
	_line_up = data.text(beat, "first_line")
	_shoot = data.text(beat, "last_line")
	_lines = lines
	_prompts = prompts


func enter(stage: ArenaStage, patrol: ProloguePatrol, tick: int) -> void:
	if formation.boss == null:
		_start_at = stage.arena.rivet.pos
		_patrol = patrol
	else:
		deaths += 1
		stage.arena.rivet.pos = _start_at
		pistol.clear(stage)
		if pistol.marked_tick >= 0:
			pistol.mark(stage.pilot.carry, _pistol_at, tick)
	ranged = false
	exposed_until = -1
	last_action_tick = -1
	formation.enter(stage.arena)
	(stage.arena as PrologueCombat).formation = formation
	fire.reset(stage.arena.rivet.pos)
	@warning_ignore("return_value_discarded")
	_lines.begin(2, tick)
	stage.arena.announce_boss(spec.id)
	_order(stage.arena, _line_up, tick)


func _fallen_pistol(stage: ArenaStage) -> Vector2:
	var player: Vector2 = stage.arena.rivet.pos
	var yard: PrologueYard = stage.plan as PrologueYard
	var at: Vector2 = yard.gate + Vector2.UP * 1.6
	var nearest: float = INF
	for officer: ProloguePatrol.Officer in _patrol.officers:
		var h: Fighter = officer.body
		if h.archetype != &"patrol_cop" or h == _patrol.dale or not yard.yard.has_point(h.pos):
			continue
		# Prefer a pistol the player can actually see and walk to before auto-collection.
		var distance: float = player.distance_to(h.pos)
		var score: float = absf(distance - 4.0 * WeaponPickups.REACH_M)
		if distance < 2.0 * WeaponPickups.REACH_M:
			score += yard.yard.size.length()
		if score < nearest:
			at = h.pos
			nearest = score
	return at


func step(stage: ArenaStage, tick: int) -> bool:
	var arena: CombatArena = stage.arena
	if not formation.boss.alive():
		died_tick = tick
		pistol.leave(stage)
		_prompts.clear()
		arena.shots.clear()
		return true
	fire.track(arena.rivet.pos)
	var before: String = _lines.current
	_lines.advance(tick, stage.press_left and due_tick < 0)
	if _lines.current == _shoot and before != _shoot:
		ranged = true
		if pistol.marked_tick < 0:
			_pistol_at = _fallen_pistol(stage)
			pistol.mark(stage.pilot.carry, _pistol_at, tick)
		formation.engage(arena)
		_order(arena, _shoot, tick)
	elif ranged and _lines.current.is_empty() and tick >= _again:
		var next: String = _shoot if _attack.id == &"line_up" else _line_up
		_order(arena, next, tick)
	if tick == due_tick:
		_execute(arena, tick)
	var open: bool = tick < exposed_until
	formation.boss.exposed = open or not formation.shields_standing()
	formation.march(arena, ranged, open)
	if ranged:
		fire.step(arena, formation, tick, due_tick >= 0)
	pistol.observe(stage.pilot.carry, _prompts, tick)
	_prompts.step(tick)
	return false


## Repeat the short command over the combat tell once its full dialogue row has played.
func command_hint() -> String:
	if due_tick < 0 or not ranged or _lines.current != "":
		return ""
	return tr("Mulroney · Line up!") if _attack.id == &"line_up" else tr("Mulroney · Shoot him !")


func _order(arena: CombatArena, line: String, tick: int) -> void:
	_attack = spec.attacks[&"line_up" if line == _line_up else &"volley"]
	formation.posts.order(_attack.id == &"volley")
	orders.append({"line": line, "tick": tick})
	due_tick = tick + _attack.windup
	_again = due_tick + _attack.recovery + spec.phases[0].gap
	arena.announce_tell(_attack.id)


func _execute(arena: CombatArena, tick: int) -> void:
	due_tick = -1
	last_action_tick = tick
	exposed_until = tick + _attack.punish
	formation.relieve()
	formation.pushing = _attack.id == &"line_up"
	if not formation.pushing:
		fire.volley(arena, formation, tick)
		formation.posts.volley(tick, arena.squad_ai.pit.roster.weapons[&"rifle"])
