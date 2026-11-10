class_name DentJab
extends RefCounted
## n15 hero h-4 (the owner's Call, 2026-11-10): Dent's fallback strike. Melee is his overload
## command while a car is seized; with no car a press did nothing at all. Now it jabs with his arm:
## jab_windup_s after the press, every exposed live hostile within jab_reach_m (plus its radius)
## and inside jab_cone_dot of the facing the press was made on takes jab_damage and a jab_knock_m
## shove (weapon dent_jab); one jab per jab_gap_s. The shipped values are Rivet's claw jab
## (rivet_melee.json claw_1), never more. ghost_attacks.json dent.jab 0 = off (the before).

const WEAPON: StringName = &"dent_jab"

var attacks: GhostAttacks
## Presses that started a jab, jabs thrown (the strike tick: the view's act counter), jabs that
## struck at least one body.
var presses: int = 0
var swings: int = 0
var landed: int = 0
## The step the pending jab lands on (-1 = none, counted by `steps`): the view's wind-up runs
## until then.
var due_tick: int = -1
## The step the last jab was thrown on (-1 = none): the view draws the jab cells from it.
## Not hashed.
var swung_step: int = -1
## Steps taken (one per sim tick the pilot drives; its own clock, so a host that does not advance
## stage.tick still times the jab).
var steps: int = 0
var _facing: Vector2 = Vector2.RIGHT
var _ready_tick: int = 0


func _init(p_attacks: GhostAttacks = null) -> void:
	attacks = p_attacks if p_attacks != null else GhostAttacks.shipped()


func num(key: StringName) -> float:
	return attacks.num(DentStage.GHOST, key)


func on() -> bool:
	return num(&"jab") > 0.0


## True while a pressed jab winds up (it lands at due_tick).
func winding() -> bool:
	return due_tick >= 0


## One tick: `press` = a melee press Dent's hands are free for (settled, no car seized), `facing`
## the heading the jab goes along.
func step(stage: CollectCallStage, press: bool, facing: Vector2) -> void:
	steps += 1
	if due_tick >= 0 and steps >= due_tick:
		due_tick = -1
		_land(stage)
	if not press or not on() or steps < _ready_tick or not stage.arena.rivet.alive():
		return
	presses += 1
	_facing = facing.normalized() if facing.length() > 0.001 else Vector2.RIGHT
	due_tick = steps + roundi(num(&"jab_windup_s") / SimClock.TICK_DT)
	_ready_tick = steps + maxi(1, roundi(num(&"jab_gap_s") / SimClock.TICK_DT))
	if due_tick == steps:
		due_tick = -1
		_land(stage)


## Forgets a pending jab (the form ended or a car was seized mid wind-up).
func cancel() -> void:
	due_tick = -1


func _land(stage: CollectCallStage) -> void:
	var arena: CombatArena = stage.arena
	swings += 1
	swung_step = steps
	var at: Vector2 = arena.rivet.pos
	var reach: float = num(&"jab_reach_m")
	var hit: bool = false
	for f: Fighter in arena.hostiles:
		var to: Vector2 = f.pos - at
		if not f.alive() or to.length() > reach + f.radius_m:
			continue
		var dir: Vector2 = to.normalized() if to.length() > 0.001 else _facing
		if dir.dot(_facing) < num(&"jab_cone_dot"):
			continue
		arena.hit_dir = dir
		arena.hit_at = f.pos
		arena.damage(f, num(&"jab_damage"), arena.rivet.id, WEAPON)
		f.pos = DentStage.push_out(stage, f.pos + dir * num(&"jab_knock_m"), f.radius_m)
		hit = true
	landed += 1 if hit else 0


## Hashed only once a jab was pressed, so a replay with no Dent jab keeps its old state bytes.
func write_state(out: StreamPeerBuffer) -> void:
	if presses == 0:
		return
	out.put_32(presses)
	out.put_32(swings)
	out.put_32(due_tick)
	out.put_32(steps)
