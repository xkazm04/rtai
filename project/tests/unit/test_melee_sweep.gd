extends GutTest
## n31 melee 02: with --melee-sweep (MeleeSweep.on) a hit tests on every tick its blade is drawn
## cutting, in the sector the drawn blade crossed; each fighter is struck once per hit; the struck
## set is in write_state. Planted: the flag off keeps the one-tick test (the late mover is missed).

## n31 melee 02 part 2: the swept geometry (sweep_reach_m, sweep_lunge_ticks) is read only with
## the flag on; off, every swing keeps its table reach and lunge.
const DRAWN: Dictionary[StringName, float] = {
	&"claw": 1.4, &"chainsaw": 1.65, &"electro_baton": 1.5, &"katana": 1.8, &"plasma_sword": 1.9
}
const TABLE: Dictionary[StringName, float] = {
	&"claw": 1.4, &"chainsaw": 1.65, &"electro_baton": 1.55, &"katana": 2.1, &"plasma_sword": 2.2
}

var arena: CombatArena
var hands: PlayerMelee


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	arena = CombatArena.new(CombatTuning.shipped(), bus, RngRegistry.new(51).stream(&"combat"))


func after_each() -> void:
	MeleeSweep.on = false


func _ids() -> Array[StringName]:
	var ids: Array[StringName] = [MeleeTable.CLAW]
	ids.append_array(MeleeTable.weapon_ids())
	return ids


func _arm(id: StringName) -> void:
	var t: MeleeTable = MeleeTable.shipped() if id == MeleeTable.CLAW else MeleeTable.weapon(id)
	hands = PlayerMelee.new(t)


func _dummy(pos: Vector2) -> Fighter:
	var f: Fighter = arena.spawn_guard(pos)
	f.pos = pos
	f.archetype = &"patrol_cop"
	f.set_meta(MeleeLethal.NAMED, true)  # takes the hit's plain damage (no finisher)
	f.hp = 1000.0
	f.max_hp = f.hp
	return f


func _tick(press: bool) -> void:
	arena.tick += 1
	@warning_ignore("return_value_discarded")
	hands.step(arena, press, Vector2.RIGHT)


## Swings until tick_in is one short of the last cutting tick, puts a dummy inside the blade's
## last drawn sector, then runs that tick. True when the dummy was hit.
func _late_mover_hit(id: StringName) -> bool:
	_arm(id)
	var h: MeleeHit = hands.combo.table.hits[0]
	var last: int = MeleeSweep.window(h).y
	var f: Fighter = _dummy(Vector2(500.0, 500.0))
	_tick(true)
	var guard: int = 0
	while hands.combo.tick_in != last - 1 and guard < 400:
		_tick(false)
		guard += 1
	var a0: float = MeleeSweep.drawn(hands.combo, h, last - 1)
	var a1: float = MeleeSweep.drawn(hands.combo, h, last)
	f.pos = arena.rivet.pos + Vector2.RIGHT.rotated((a0 + a1) * 0.5) * h.reach_m * 0.6
	_tick(false)
	return f.hp < f.max_hp or not f.alive()


func test_late_mover_in_the_last_cutting_tick_is_hit_with_the_sweep() -> void:
	MeleeSweep.on = true
	for id: StringName in _ids():
		assert_true(_late_mover_hit(id), "%s hits on its last drawn cutting tick" % id)


func test_planted_one_tick_test_misses_the_late_mover() -> void:
	MeleeSweep.on = false
	for id: StringName in _ids():
		assert_false(_late_mover_hit(id), "%s before: tested on one tick only" % id)


func test_nobody_is_struck_twice_per_hit() -> void:
	MeleeSweep.on = true
	for id: StringName in _ids():
		_arm(id)
		if hands.combo.table.grinds():
			continue  # the chainsaw's grind re-tests by design
		var f: Fighter = _dummy(arena.rivet.pos + Vector2.RIGHT * 0.3)  # inside every sector
		var h: MeleeHit = hands.combo.table.hits[0]
		_tick(true)
		for t: int in h.length() + 2:
			_tick(false)
		assert_almost_eq(f.hp, f.max_hp - h.damage, 0.001, "%s struck once" % id)
		assert_eq(hands.landed, 1, "%s lands once" % id)
		assert_eq(hands.whiffs, 0, id)
		f.hp = 0.0  # out of the next weapon's way
		f.exposed = false


func test_an_empty_sweep_whiffs_once() -> void:
	MeleeSweep.on = true
	_arm(MeleeTable.CLAW)
	_tick(true)
	for t: int in hands.combo.table.hits[0].length() + 2:
		_tick(false)
	assert_eq(hands.whiffs, 1)
	assert_eq(hands.landed, 0)


func test_the_struck_set_is_in_the_replay_state() -> void:
	MeleeSweep.on = true
	_arm(MeleeTable.CLAW)
	var f: Fighter = _dummy(arena.rivet.pos + Vector2.RIGHT * 0.3)
	_tick(true)
	while hands.landed == 0 and hands.combo.hit_index != 0:
		_tick(false)
	assert_true(hands._sweep.struck.has(f.id), "struck mid-hit")
	var with_set: PackedByteArray = _state()
	hands._sweep.struck.clear()
	assert_ne(_state(), with_set, "the struck set changes the state bytes")
	MeleeSweep.on = false
	var off: PackedByteArray = _state()
	hands._sweep.struck[f.id] = true
	assert_eq(_state(), off, "flag off: the state carries no sweep bytes")


func _state() -> PackedByteArray:
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	hands.write_state(out)
	return out.data_array


func test_the_sweep_reach_is_the_drawn_one_only_with_the_flag() -> void:
	for on: bool in [false, true]:
		MeleeSweep.on = on
		for id: StringName in _ids():
			_arm(id)
			var want: float = DRAWN[id] if on else TABLE[id]
			assert_almost_eq(hands.combo.table.hits[0].reach_m, want, 0.0001, "%s on=%s" % [id, on])


func test_katana_lunge_has_arrived_at_contact_with_the_flag() -> void:
	for on: bool in [false, true]:
		MeleeSweep.on = on
		_arm(&"katana")
		_tick(true)
		var h: MeleeHit = hands.combo.current()
		var before_contact: float = 0.0
		for t: int in h.windup:
			hands.combo.tick_in = t
			before_contact += hands.combo.lunge_step_m()
		if on:
			assert_almost_eq(before_contact, h.lunge_m, 0.0001, "the whole lunge before contact")
		else:
			assert_lt(before_contact, h.lunge_m * 0.7, "before: spread over windup + active")


## A body past the katana's drawn blade but inside its table reach: missed with the sweep (the art
## cannot show that reach), hit by the one-tick test without it.
func test_a_body_past_the_drawn_katana_is_missed_with_the_sweep() -> void:
	for on: bool in [false, true]:
		MeleeSweep.on = on
		_arm(&"katana")
		var h: MeleeHit = hands.combo.table.hits[0]
		var f: Fighter = _dummy(arena.rivet.pos + Vector2.RIGHT * (1.8 + 0.45 + 0.15))
		_tick(true)
		for t: int in h.length() + 2:
			_tick(false)
		assert_eq(f.hp < f.max_hp, not on, "on=%s" % on)
		f.hp = 0.0
		f.exposed = false


func test_the_crescent_reaches_the_claw_reach_only_with_the_flag() -> void:
	MeleeSweep.on = false
	assert_almost_eq(RivetSwipeView.reach_max_m(1.4), RivetSwipeView.REACH_MAX_M, 0.0001)
	MeleeSweep.on = true
	assert_almost_eq(RivetSwipeView.reach_max_m(1.4), 1.4, 0.0001)
	assert_almost_eq(RivetSwipeView.reach_max_m(1.2), RivetSwipeView.REACH_MAX_M, 0.0001)
