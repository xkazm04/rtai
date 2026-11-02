class_name CollectCallBot
extends RefCounted
## Plays quest 1 (collect-call) through the stage's intent, one decision per tick, the way a
## player would: hide in the dumpster until the sirens are gone, answer the corner payphone,
## meet Juno, Brass, Dr. Kilohm and Don in turn, hold the middle of Dock 9 and nail whatever
## comes (grabbing one dropped rifle after wave 2), back off from Mertz, take one Robo-tazer hit,
## nail him in his vent window, torch the crates, try the Harbor Road phone while hot (Patch
## refuses), hide in a skip until heat 0, then answer it and get paid.

const STAND_M: float = 0.4
const MEET_ORDER: Array[String] = ["Juno", "Brass", "Dr. Kilohm", "Don Fax"]
const DOCK_HOLD: Vector2 = Vector2(100.0, 2.0)
const BOSS_STANDOFF: Vector2 = Vector2(112.0, 10.0)
const AIM_M: float = 22.0
const HOME: String = "Harbor Road"

var phase: String = "start"
## false plants the scenario's fault: the bot never tries the Harbor Road phone while hot.
var tries_hot_phone: bool = true
var refused: bool = false
var grabbed: bool = false
var _stage: CollectCallStage
var _system: QuestSystem


func _init(stage: CollectCallStage, system: QuestSystem) -> void:
	_stage = stage
	_system = system


func done() -> bool:
	return phase == "done"


func act() -> void:
	var runner: QuestRunner = _system.runner
	if runner.state != QuestRunner.State.ACTIVE:
		if runner.state != QuestRunner.State.OFFERED and not runner.lines.busy():
			phase = "done"
		return
	phase = runner.current_beat().id
	match phase:
		"b1-dumpster":
			_hide("dumpster")
		"b2-payphone":
			_answer("Factory Row corner")
		"b3-toner-room":
			_meet(runner)
		"b4-dock":
			_fight()
		"b5-quartermaster":
			_boss()
		"b6-hot-walk":
			_walk_home()


## Walks toward `to`; true once there.
func _go(to: Vector2) -> bool:
	_walk(to)
	return _stage.arena.rivet.pos.distance_to(to) <= STAND_M


func _walk(to: Vector2) -> void:
	if _stage.arena.rivet.pos.distance_to(to) > STAND_M:
		_stage.intent.move_to = to


func _hide(spot: String) -> void:
	if _stage.hidden_in == spot:
		return
	if _go(_stage.layout.hide_at[spot]):
		_stage.intent.interact = true


func _answer(phone: String) -> void:
	if _stage.router.connected(phone):
		return
	if _go(_stage.layout.phones[phone]) and _stage.router.ringing(phone):
		_stage.intent.interact = true


func _meet(runner: QuestRunner) -> void:
	if runner.lines.busy():
		return
	for tag: String in MEET_ORDER:
		if not runner.objective.met.has(tag):
			var at: Vector2 = _stage.layout.places.actors[tag].at
			if _go(at + Vector2(0.0, 1.2)):
				_stage.intent.interact = true
			return


func _fight() -> void:
	var arena: CombatArena = _stage.arena
	var wave: int = _stage.layout.waves.current
	if (
		not grabbed
		and wave >= 2
		and arena.hostiles_alive() == 0
		and not arena.rifle_drops.is_empty()
	):
		if _go(arena.rifle_drops[0]):
			_stage.intent.interact = true
			grabbed = true
		return
	_walk(DOCK_HOLD)
	_shoot_nearest()


func _boss() -> void:
	var arena: CombatArena = _stage.arena
	if arena.boss == null:
		_walk(_stage.layout.marker("Dock 9 vault cage").at)
		return
	if arena.boss.alive():
		_walk(BOSS_STANDOFF)
		if arena.boss.exposed and arena.tazer_hits >= 1:
			_stage.intent.fire_at = arena.boss.pos
		return
	if not _stage.crates_burning and _go(_stage.layout.crates_at + Vector2(0.0, 2.0)):
		_stage.intent.interact = true


func _walk_home() -> void:
	var phone: Vector2 = _stage.layout.phones[HOME]
	if not refused and tries_hot_phone:
		if _go(phone):
			_stage.intent.interact = true
			refused = _stage.heat.level > 0
		return
	if _stage.heat.level > 0:
		_hide("harbor-skip")
		return
	_answer(HOME)


func _shoot_nearest() -> void:
	var arena: CombatArena = _stage.arena
	var best: Fighter = null
	for h: Fighter in arena.hostiles:
		var d: float = h.pos.distance_to(arena.rivet.pos)
		if h.alive() and h.exposed and d <= AIM_M:
			if best == null or d < best.pos.distance_to(arena.rivet.pos):
				best = h
	if best != null:
		_stage.intent.fire_at = best.pos
