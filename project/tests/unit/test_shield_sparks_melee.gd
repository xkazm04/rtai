extends GutTest
## n31-melee 04d: Rivet's melee throws metal: a non-lethal hit on a robot sprays its sparks and oil
## (blood_fx.json hits.thug_hit) once per strike, a human's stays dry; a through-the-slab weapon
## (melee_weapons.json vs_shield through) on a riot shield's front throws the slab's sparks.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _foe(arena: CombatArena, id: int, arch: StringName, machine: bool) -> Fighter:
	var f: Fighter = Fighter.make(Fighter.Kind.GUARD, id, arena.rivet.pos + Vector2(1.0, 0.0), 9.0)
	f.archetype = arch
	f.machine = machine
	f.facing = Vector2.LEFT
	arena.hostiles.append(f)
	return f


func _sparks(arena: CombatArena) -> ShieldSparks:
	var blood: CombatBlood = autofree(CombatBlood.new())
	return ShieldSparks.melee(arena, func() -> CombatBlood: return blood)


func test_a_robot_hit_sprays_once_per_strike_and_a_human_stays_dry() -> void:
	var arena: CombatArena = _arena()
	var s: ShieldSparks = _sparks(arena)
	var robot: Fighter = _foe(arena, 7, &"thug", true)
	var man: Fighter = _foe(arena, 8, &"thug", false)
	assert_eq(s.on_hit(robot, &"claw", false), 1, "the claw on a robot throws sparks and oil")
	assert_eq(s.on_hit(robot, &"chainsaw", false), 0, "the grind's next tick: one per strike")
	arena.tick += MeleeWound.GAP_TICKS
	assert_eq(s.on_hit(robot, &"katana", false), 1)
	assert_eq(s.on_hit(robot, &"katana", true), 0, "a dead robot leaks through CombatBlood")
	assert_eq(s.on_hit(man, &"claw", false), 0, "a human's non-lethal hit stays as it was")
	assert_eq(s.on_hit(robot, &"pistol", false), 0, "melee only")


func test_a_through_weapon_on_the_shield_front_throws_slab_sparks() -> void:
	var arena: CombatArena = _arena()
	var s: ShieldSparks = _sparks(arena)
	var cop: Fighter = _foe(arena, 9, &"riot_cop", false)
	assert_true(ShieldSparks.through(&"chainsaw"))
	assert_false(ShieldSparks.through(&"katana"), "the katana is blocked, the slab's own sparks")
	assert_eq(s.on_hit(cop, &"katana", false), 0)
	assert_eq(s.on_hit(cop, &"chainsaw", false), 2, "the saw bites the slab")
	cop.facing = Vector2.RIGHT
	arena.tick += MeleeWound.GAP_TICKS
	assert_eq(s.on_hit(cop, &"chainsaw", false), 0, "from behind: no slab in the way")
	assert_eq(s.thrown, PackedInt32Array([0, 1]))


func test_the_baton_and_the_plasma_sword_flick_off_the_slab_front() -> void:
	var arena: CombatArena = _arena()
	var m: ClawMarks = ClawMarks.attach(arena)
	var cop: Fighter = _foe(arena, 9, &"riot_cop", false)
	arena.wounded.emit(cop, &"electro_baton")
	arena.wounded.emit(cop, &"chainsaw")
	arena.wounded.emit(cop, &"katana")
	assert_eq(m.slabs.size(), 1, "the baton flicks; the saw sparks, the katana is blocked")
	cop.facing = Vector2.RIGHT
	arena.wounded.emit(cop, &"plasma_sword")
	assert_eq(m.slabs.size(), 1, "from behind: no slab")
	cop.facing = Vector2.LEFT
	arena.wounded.emit(cop, &"plasma_sword")
	assert_eq(m.slabs.size(), 2)


func _wired(arena: CombatArena) -> Array:
	var blood: CombatBlood = autofree(CombatBlood.new())
	var link: ReactLink = ReactLink.new()
	ShieldSparks.wire(link, arena, func() -> CombatBlood: return blood)
	return [link, blood]


func test_a_blocked_round_throws_sparks_off_the_face_only_for_a_live_victim() -> void:
	var arena: CombatArena = _arena()
	var cop: Fighter = _foe(arena, 9, &"riot_cop", false)
	var wired: Array = _wired(arena)
	var link: ReactLink = wired[0]
	var blood: CombatBlood = wired[1]
	link.blocked.emit(404, Vector2.LEFT)
	assert_eq(blood.oil.drops, 0, "a victim that is gone throws nothing")
	link.blocked.emit(cop.id, Vector2.LEFT)
	assert_gt(blood.oil.drops, 0, "the blocked round throws white sparks into the oil fx")
	assert_eq(blood.blood.drops, 0)


func test_the_wounded_signal_is_a_non_lethal_hit_and_a_kill_is_lethal() -> void:
	var arena: CombatArena = _arena()
	var robot: Fighter = _foe(arena, 7, &"thug", true)
	var wired: Array = _wired(arena)
	var blood: CombatBlood = wired[1]
	arena.wounded.emit(robot, &"claw")
	assert_gt(blood.oil.drops, 0, "wounded sprays the robot")
	var after: int = blood.oil.drops
	arena.tick += MeleeWound.GAP_TICKS
	arena.kill_landed.emit(robot, &"claw", Vector2.RIGHT, robot.pos, &"claw")
	assert_eq(blood.oil.drops, after, "a kill on a robot is not sprayed here")


func test_a_blow_from_inside_the_victim_falls_back_to_its_back() -> void:
	var arena: CombatArena = _arena()
	var s: ShieldSparks = _sparks(arena)
	var robot: Fighter = _foe(arena, 7, &"thug", true)
	robot.pos = arena.rivet.pos
	assert_eq(s.on_hit(robot, &"claw", false), 1, "zero-length blow: no crash, still sprays")
	var cop: Fighter = _foe(arena, 9, &"riot_cop", false)
	cop.pos = arena.rivet.pos
	cop.facing = Vector2.RIGHT
	assert_eq(
		s.on_hit(cop, &"chainsaw", false), 2, "fallback dir is -facing: the blow meets the slab"
	)
	cop.facing = Vector2.LEFT
	arena.tick += MeleeWound.GAP_TICKS
	assert_eq(s.on_hit(cop, &"chainsaw", false), 2, "whichever way it faces")


func test_robot_and_slab_kinds_are_counted_apart() -> void:
	var arena: CombatArena = _arena()
	var s: ShieldSparks = _sparks(arena)
	var robot: Fighter = _foe(arena, 7, &"thug", true)
	var cop: Fighter = _foe(arena, 9, &"riot_cop", false)
	assert_eq(s.on_hit(robot, &"claw", false), 1)
	assert_eq(s.on_hit(cop, &"chainsaw", false), 2)
	assert_eq(s.thrown, PackedInt32Array([1, 1]))
