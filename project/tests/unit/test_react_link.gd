extends GutTest
## ReactLink: the arena's landed rounds reach the human reaction layer (a kill queues the
## standard death with the weapon's damage class), Rivet never reacts, a victim without a full
## rig is skipped, and the queue drains each frame.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.gun = GunHand.make(WeaponTable.shipped(), &"pistol", reg.stream(&"gunplay"))
	return arena


func test_a_pistol_kill_queues_a_light_death_along_the_shot() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	var guard: Fighter = arena.spawn_guard(Vector2(10.0, 0.0))
	guard.cooldown = 999
	assert_true(arena.rivet_fire(guard.pos))
	for i: int in 30:
		arena.step(1000 + i)
	assert_eq(link._pending.size(), 1)
	var h: Array = link._pending[0]
	var id: int = h[0]
	var lethal: bool = h[2]
	var hit_class: StringName = h[3]
	assert_eq(id, guard.id)
	assert_true(lethal, "lethal")
	assert_eq(hit_class, &"light")
	var dir: Vector2 = h[1]
	assert_gt(dir.x, 0.9, "the round travels from Rivet toward the guard")


func test_rivet_never_reacts_and_burn_is_burn() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	arena.struck.emit(arena.rivet, Vector2.LEFT, false, &"pistol")
	assert_eq(link._pending.size(), 0)
	assert_eq(link.hit_class_of(&"burn"), &"burn")
	assert_eq(link.hit_class_of(&"no-such-gun"), &"light")
	assert_eq(link.hit_class_of(&"claw"), &"melee")
	assert_eq(link.hit_class_of(&"katana"), &"melee")
	assert_eq(link.hit_class_of(&"claw_shock"), &"light")


func test_a_victim_without_a_full_rig_is_skipped_and_the_queue_drains() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	var guard: Fighter = arena.spawn_guard(Vector2(4.0, 0.0))
	arena.struck.emit(guard, Vector2.RIGHT, false, &"pistol")
	var rigs: CharacterRigs = CharacterRigs.new()
	autofree(rigs)
	link.apply(rigs)
	assert_eq(link._pending.size(), 0)
	assert_eq(link.wounds, 0, "no rig, nothing played")


func test_a_burned_kill_chars_and_a_blown_kill_throws() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	var a: Fighter = arena.spawn_guard(Vector2(4.0, 0.0))
	var b: Fighter = arena.spawn_guard(Vector2(6.0, 0.0))
	arena.kill_landed.emit(a, &"pistol", Vector2.RIGHT, a.pos, &"burned")
	arena.struck.emit(a, Vector2.RIGHT, true, &"pistol")
	arena.kill_landed.emit(b, &"pistol", Vector2.RIGHT, b.pos, &"blown")
	arena.struck.emit(b, Vector2.RIGHT, true, &"pistol")
	var ca: StringName = link._pending[0][3]
	var cb: StringName = link._pending[1][3]
	assert_eq(ca, &"burn")
	assert_eq(cb, &"blast")


func test_area_states_name_their_family_stun_over_burn_over_down() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	var g: Fighter = arena.spawn_guard(Vector2(4.0, 0.0))
	assert_eq(link.state_family(g), &"", "no areas yet")
	arena.areas = FightAreas.new()
	var e: FighterFx = FighterFx.new()
	arena.areas.fx[g.id] = e
	e.down_ticks = 10
	assert_eq(link.state_family(g), &"knockdown")
	e.burn_ticks = 10
	assert_eq(link.state_family(g), &"burn")
	e.stun_ticks = 10
	assert_eq(link.state_family(g), &"stun")


func test_a_held_stun_outlasts_its_family_then_runs_out() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	var rig: CutRig = CutRig.new()
	rig.actor_id = 7
	var r: HumanReact = HumanReact.on(rig)
	for i: int in 240:
		link.hold(rig, &"stun", &"stun", Vector2.LEFT)
		r.t += SimClock.TICK_DT
	assert_eq(r.kind, &"stun", "4 s of stun on a 1.2 s family still convulses")
	assert_lt(r.progress(), 0.75)
	link.hold(rig, &"", &"stun", Vector2.LEFT)
	assert_almost_eq(r.progress(), 0.7, 0.05, "the release resumes at the run-out")
	rig.free()


func test_a_riot_rig_blocks_a_front_round_and_flinches_from_behind() -> void:
	var rig: CutRig = CutRig.new()
	rig.variant = RigVariant.crowd(6)
	assert_true(ReactLink.shielded(rig), "the riot look carries the shield")
	var table: ReactTable = ReactTable.shipped()
	var front: StringName = table.reaction_for(
		&"light", Vector2.LEFT, ReactLink.shielded(rig), false
	)
	var back: StringName = table.reaction_for(
		&"light", Vector2.RIGHT, ReactLink.shielded(rig), false
	)
	assert_eq(front, &"shield")
	assert_ne(back, &"shield")
	rig.variant = RigVariant.crowd(5)
	assert_false(ReactLink.shielded(rig), "the patrol look has none")
	rig.free()


func test_the_reaction_line_looks_cover_both_cop_looks_and_two_peds() -> void:
	assert_eq(ReactLineBot.look_of("react_dummy_2"), Vector2i(BodyPlan.Kind.COP, 6))
	assert_eq(ReactLineBot.look_of("react_dummy_3").x, BodyPlan.Kind.PED)
	assert_eq(ReactLineBot.look_of("dummy_human_1"), Vector2i(-1, -1))


func test_a_front_round_on_a_riot_shield_is_announced_a_back_round_is_not() -> void:
	var link: ReactLink = ReactLink.make(_arena())
	var rig: CutRig = CutRig.new()
	rig.variant = RigVariant.crowd(6)
	watch_signals(link)
	link._wound(rig, 7, &"light", Vector2.LEFT, false)
	assert_signal_emitted_with_parameters(link, "blocked", [7, Vector2.LEFT])
	assert_eq(link.blocks, 1)
	var bare: CutRig = CutRig.new()
	bare.variant = RigVariant.crowd(6)
	link._wound(bare, 8, &"light", Vector2.RIGHT, false)
	assert_eq(link.blocks, 1, "a round from behind is no block")
	assert_eq(link.wounds, 2)
	rig.free()
	bare.free()


func test_the_gunfx_shield_test_matches_the_shield_family() -> void:
	var table: ReactTable = ReactTable.shipped()
	var rig: CutRig = CutRig.new()
	rig.variant = RigVariant.crowd(6)
	rig.facing = 0.0
	assert_true(ReactLink.blocks_round(rig, Vector2.LEFT, table), "a front round sparks")
	assert_false(ReactLink.blocks_round(rig, Vector2.RIGHT, table), "a back round bleeds")
	rig.facing = PI
	assert_true(ReactLink.blocks_round(rig, Vector2.RIGHT, table), "the shield turns with him")
	rig.variant = RigVariant.crowd(5)
	assert_false(ReactLink.blocks_round(rig, Vector2.RIGHT, table), "no shield, no block")
	assert_false(ReactLink.blocks_round(null, Vector2.LEFT, table), "no full rig, no block")
	var link: ReactLink = ReactLink.make(_arena())
	assert_false(link.shield_test(null, Vector2.LEFT), "nothing played yet")
	rig.free()
