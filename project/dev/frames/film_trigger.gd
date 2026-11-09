class_name FilmTrigger
extends RefCounted
## n11 tools, dev only: the ticks Rivet fired and a hostile died on, so a film can ask for "the
## frame of his 3rd round and the 4 after it" instead of guessing a tick (combat's REQUEST, n11).
## A fire is a tick his gun's round count went up. A kill is a hostile going from alive to dead.
## Both are written to probe.json on every film, so one run also says when things happened.

var fires: Array[int] = []
var kills: Array[int] = []
var _rules: Array[Rule] = []
var _rounds: int = -1
var _alive: Dictionary[int, bool] = {}


class Rule:
	var kind: String = ""
	var nth: int = 0
	var after: int = 0


## From `fire:3+4,kill:1+6`: nth event (1 = the first), then frames after it.
static func parse(text: String) -> FilmTrigger:
	var t: FilmTrigger = FilmTrigger.new()
	for rule: String in text.split(",", false):
		var rest: String = rule.get_slice(":", 1)
		var r: Rule = Rule.new()
		r.kind = rule.get_slice(":", 0)
		r.nth = rest.get_slice("+", 0).to_int()
		r.after = rest.get_slice("+", 1).to_int()
		t._rules.append(r)
	return t


## Call once per sim tick.
func watch(tick: int, arena: CombatArena) -> void:
	var rounds: int = arena.gun.shots_fired if arena.gun != null else 0
	if _rounds >= 0 and rounds > _rounds:
		fires.append(tick)
	_rounds = rounds
	for h: Fighter in arena.hostiles:
		if _alive.has(h.id) and _alive[h.id] and not h.alive():
			kills.append(tick)
		_alive[h.id] = h.alive()


## True while `tick` is on a rule's event or within the frames after it.
func wants(tick: int) -> bool:
	for r: Rule in _rules:
		var happened: Array[int] = fires if r.kind == "fire" else kills
		if happened.size() < r.nth:
			continue
		var at: int = happened[r.nth - 1]
		if tick >= at and tick <= at + r.after:
			return true
	return false


func events() -> Dictionary:
	return {"fire": fires, "kill": kills}
