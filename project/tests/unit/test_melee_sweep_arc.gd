extends GutTest
## n31 melee 02p3: the sweep follows the DRAWN sector (`sweep_arc_deg`, read with --melee-sweep:
## the pixels' angle range off the aim, 01e's body-free mask) and the saw's sweep ends at its
## first bite (the grind takes what it caught).

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


## n31 melee 02p3: a body beside the plasma sword (90 deg off the aim, 1.4 m), where nothing is
## drawn: missed with the sweep (its sector clamped to the drawn sweep_arc_deg), hit without it.
func test_a_body_beside_the_plasma_where_nothing_is_drawn_is_missed_with_the_sweep() -> void:
	for on: bool in [false, true]:
		for turn: float in [PI * 0.5, -PI * 0.5]:
			MeleeSweep.on = on
			_arm(&"plasma_sword")
			var h: MeleeHit = hands.combo.table.hits[0]
			var f: Fighter = _dummy(arena.rivet.pos + Vector2.RIGHT.rotated(turn) * 1.4)
			_tick(true)
			for t: int in h.length() + 2:
				_tick(false)
			assert_eq(f.hp < f.max_hp, not on, "on=%s turn=%s" % [on, turn])
			f.hp = 0.0
			f.exposed = false


## Every sweep tick's sector lies inside the hit's drawn angle range (side frame), per weapon.
func test_the_swept_sector_stays_inside_the_drawn_arc() -> void:
	MeleeSweep.on = true
	for id: StringName in _ids():
		_arm(id)
		var h: MeleeHit = hands.combo.table.hits[0]
		_tick(true)
		var seen: int = 0
		for t: int in h.length():
			if MeleeSweep.cuts(h, hands.combo.tick_in):
				var a: Vector2 = MeleeSweep.span(hands.combo, h) * MeleeSweep.side(hands.combo)
				assert_true(
					a.x >= h.sweep_arc.x - 0.0001 and a.x <= h.sweep_arc.y + 0.0001, "%s" % id
				)
				assert_true(
					a.y >= h.sweep_arc.x - 0.0001 and a.y <= h.sweep_arc.y + 0.0001, "%s" % id
				)
				seen += 1
			_tick(false)
		assert_gt(seen, 0, "%s ran sweep ticks" % id)


## The saw's sweep ends at its first bite (the grind takes what it caught); a blade does not.
func test_only_a_grinding_hit_stops_sweeping_once_it_has_bitten() -> void:
	var sweep: MeleeSweep = MeleeSweep.new()
	var saw: MeleeHit = MeleeHit.new()
	saw.grind_ticks = 8
	var blade: MeleeHit = MeleeHit.new()
	assert_false(sweep.bitten(saw), "nothing struck yet")
	sweep.hit_any = true
	assert_true(sweep.bitten(saw), "bitten")
	assert_false(sweep.bitten(blade), "a blade keeps sweeping")
