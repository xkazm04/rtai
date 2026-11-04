class_name CorpseDecayHook
extends ArenaHook
## Corpse decay in the live fight (station `corpse_decay`, arena_stations/corpse-decay.json; the
## arena, its pit and the city block). Each tick it books the newly dead into CorpseDecay, steps
## it, and takes every released body out of the fight (CombatArena.hostiles), so the guard, shot
## and view loops stay the size of the living fight however long a horde runs. The fixtures (any
## fighter already standing on the first tick: dummies, claw cops, lab guards; they stand up
## again) never leave: a released fixture is only `gone` (undrawn) until it is alive again.
## Folds both ledgers into the replay hash. attach_view() adds CorpseFade, the render side.

var decay: CorpseDecay = null
## Released fixtures still in the fight, drawn by nobody until they stand up.
var gone: Dictionary[int, bool] = {}
var died: int = 0
var pruned: int = 0
## The most dead fighters left in CombatArena.hostiles at the end of any tick (horde check).
var peak_dead_listed: int = 0
## False (--no-decay, or a check's planted fault): nothing is booked, nothing leaves.
var on: bool = true
## Released ids waiting for the render side (CorpseFade drains them); empty headless.
var out_bodies: PackedInt32Array = PackedInt32Array()
var out_stains: PackedInt32Array = PackedInt32Array()
var _viewed: bool = false
var _seen: Dictionary[int, bool] = {}
var _fixtures: Dictionary[int, bool] = {}
var _first: bool = true
var _stage: ArenaStage = null


func setup(stage: ArenaStage, _ctx: WorldContext) -> void:
	_stage = stage
	decay = CorpseDecay.shipped()
	on = not ArenaArgs.parse().has("--no-decay")


func step(stage: ArenaStage, tick: int) -> void:
	if _first:
		_first = false
		for h: Fighter in stage.arena.hostiles:
			_fixtures[h.id] = true
	if not on:
		return
	_book(stage.arena, tick)
	decay.step(tick)
	for id: int in decay.bodies.released:
		_release(stage.arena, id)
	if _viewed:
		out_bodies.append_array(decay.bodies.released)
		out_stains.append_array(decay.stains.released)
	var listed: int = 0
	for h: Fighter in stage.arena.hostiles:
		listed += 0 if h.alive() or gone.has(h.id) else 1
	peak_dead_listed = maxi(peak_dead_listed, listed)


## Fighters booked as fixtures on the first tick (they stand up again, so they never leave).
func fixtures() -> int:
	return _fixtures.size()


func write_state(out: StreamPeerBuffer) -> void:
	if decay != null:
		decay.write_state(out)
	out.put_32(pruned)


func telemetry() -> Dictionary:
	var b: DecayLedger = decay.bodies
	return {
		"died": died,
		"pruned": pruned,
		"bodies_now": b.count(),
		"bodies_peak": b.peak,
		"bodies_cap": b.cap,
		"early_fades": b.early,
		"forced": b.forced,
		"forced_alpha": b.forced_alpha,
		"stains_now": decay.stains.count(),
		"peak_dead_listed": peak_dead_listed,
	}


func attach_view(p_view: Node) -> void:
	var cc: CollectCallView = p_view as CollectCallView
	if cc == null or p_view.get_parent() == null:
		return
	_viewed = true
	var fade: CorpseFade = CorpseFade.new()
	fade.hook = self
	fade.view = cc
	fade.stage = _stage
	p_view.get_parent().add_child(fade)


## A body that died this tick starts its clocks; a fixture standing again is whole.
func _book(arena: CombatArena, tick: int) -> void:
	for h: Fighter in arena.hostiles:
		if h.alive():
			if _seen.has(h.id):
				@warning_ignore("return_value_discarded")
				_seen.erase(h.id)
				@warning_ignore("return_value_discarded")
				gone.erase(h.id)
				decay.forget(h.id)
		elif not _seen.has(h.id):
			_seen[h.id] = true
			decay.add(h.id, tick)
			died += 1


func _release(arena: CombatArena, id: int) -> void:
	if _fixtures.has(id):
		gone[id] = true
		return
	@warning_ignore("return_value_discarded")
	_seen.erase(id)
	for i: int in arena.hostiles.size():
		var h: Fighter = arena.hostiles[i]
		if h.id == id and not h.alive():
			arena.hostiles.remove_at(i)
			pruned += 1
			return
