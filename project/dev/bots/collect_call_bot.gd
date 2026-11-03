class_name CollectCallBot
extends RefCounted
## Plays quest 1 (collect-call) through the stage's intent, one decision per tick, the way a
## player would: hide in the dumpster until the sirens are gone, answer the corner payphone,
## meet Juno, Brass, Dr. Kilohm and Don in turn, hold the middle of Dock 9 and nail whatever
## comes (grabbing one dropped rifle after wave 2), back off from Mertz, take one Robo-tazer hit,
## nail him in his vent window, torch the crates, try the Harbor Road phone while hot (Patch
## refuses), hide in a skip until heat 0, then answer it and get paid.

const STAND_M: float = 0.05
const MEET_ORDER: Array[String] = ["Juno", "Brass", "Dr. Kilohm", "Don Fax"]
const DOCK_HOLD: Vector2 = Vector2(100.0, 2.0)
const BOSS_STANDOFF: Vector2 = Vector2(96.0, -6.0)
const AIM_M: float = 14.0
const HOME: String = "Harbor Road"
## Where Rivet stands to use a phone or talk to an ally (inside the 1.7 m reach).
const AT_PHONE: Vector2 = Vector2(0.0, 1.1)
const AT_ALLY: Vector2 = Vector2(0.0, 1.6)
const LINGER_TICKS: int = 120
## How long a bot that will not torch waits by the crates before it gives up (10 s).
const GIVE_UP_TICKS: int = 600

var phase: String = "start"
## How near a goal counts as there (the input driver's thumb arrives less exactly than a direct
## move_to; every reach it stands in for is 1.1 m or more).
var stand_m: float = STAND_M
## false plants the scenario's fault: the bot never tries the Harbor Road phone while hot.
var tries_hot_phone: bool = true
## false plants the other fault: the bot never torches the crates (the quest cannot finish).
var torches: bool = true
var gave_up: bool = false
var refused: bool = false
var grabbed: bool = false
## Walking to a dropped rifle (kept until it is in hand, even when the next wave comes).
var fetching: bool = false
var _waited: int = 0
var _stage: CollectCallStage
var _system: QuestSystem


func _init(stage: CollectCallStage, system: QuestSystem) -> void:
	_stage = stage
	_system = system


func done() -> bool:
	return phase == "done" or gave_up


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
	return _stage.arena.rivet.pos.distance_to(to) <= stand_m


func _walk(to: Vector2) -> void:
	if _stage.arena.rivet.pos.distance_to(to) > stand_m:
		_stage.intent.move_to = to


func _hide(spot: String) -> void:
	if _stage.hidden_in == spot:
		return
	if _go(_stage.layout.hide_at[spot]):
		_stage.intent.interact = true


func _answer(phone: String) -> void:
	if _stage.router.connected(phone):
		return
	if _go(_stage.layout.phones[phone] + AT_PHONE) and _stage.router.ringing(phone):
		_stage.intent.interact = true


func _meet(runner: QuestRunner) -> void:
	if runner.lines.busy():
		return
	for tag: String in MEET_ORDER:
		if not runner.objective.met.has(tag):
			var at: Vector2 = _stage.layout.places.actors[tag].at
			if _go(at + AT_ALLY):
				_stage.intent.interact = true
			return


func _fight() -> void:
	var arena: CombatArena = _stage.arena
	var wave: int = _stage.layout.waves.current
	var lull: bool = arena.hostiles_alive() == 0 and wave >= 2
	if not grabbed and not arena.rifle_drops.is_empty() and (fetching or lull):
		fetching = true
		if _go(_nearest(arena.rifle_drops)):
			_stage.intent.interact = true
			grabbed = true
	else:
		_walk(_stage.layout.w(DOCK_HOLD))
	_shoot_nearest()


func _boss() -> void:
	var arena: CombatArena = _stage.arena
	if arena.boss == null:
		_walk(_stage.layout.marker("Dock 9 vault cage").at)
		return
	if arena.boss.alive():
		_walk(_stage.layout.w(BOSS_STANDOFF))
		if arena.boss.exposed and arena.tazer_hits >= 1:
			_stage.intent.fire_at = arena.boss.pos
		return
	if not _stage.crates_burning and _go(_stage.layout.crates_at + Vector2(0.0, 2.0)):
		if torches:
			_stage.intent.interact = true
		else:
			_waited += 1
			gave_up = _waited >= GIVE_UP_TICKS


## Watches the crates catch for a moment, listens to Patch's refusal, then hides till cool.
func _walk_home() -> void:
	var phone: Vector2 = _stage.layout.phones[HOME]
	if _stage.burn_ticks < LINGER_TICKS or _stage.refusal_left > 0:
		return
	if not refused and tries_hot_phone:
		if _go(phone + AT_PHONE):
			_stage.intent.interact = true
			refused = _stage.heat.level > 0
		return
	if _stage.heat.level > 0:
		_hide("harbor-skip")
		return
	_answer(HOME)


func _nearest(points: Array[Vector2]) -> Vector2:
	var best: Vector2 = points[0]
	for p: Vector2 in points:
		if p.distance_to(_stage.arena.rivet.pos) < best.distance_to(_stage.arena.rivet.pos):
			best = p
	return best


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
