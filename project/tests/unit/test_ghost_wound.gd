extends GutTest
## n7-melee: a ghost attack's non-lethal hit (Tonnage's ram, the slam's survivors) played no wound
## on the struck body: it lands through CombatArena.damage and struck only carries rounds.
## human_reactions.json ghost_wound maps the weapon to a hit class; a weapon not in it plays none.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _cop(arena: CombatArena, at: Vector2) -> Fighter:
	var f: Fighter = Fighter.make(Fighter.Kind.GUARD, 7, at, 9.0)
	arena.hostiles.append(f)
	return f


func after_each() -> void:
	ReactLink.melee_deaths = true


func test_the_shipped_ram_and_slam_wound_as_blast() -> void:
	var table: ReactTable = ReactTable.shipped()
	assert_eq(table.ghost_wound(&"ram"), &"blast")
	assert_eq(table.ghost_wound(&"stomp_wave"), &"blast")
	assert_eq(table.ghost_wound(&"claw"), &"", "melee keeps its own path")


func test_a_ram_that_does_not_kill_queues_a_blast_wound_away_from_rivet() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	var f: Fighter = _cop(arena, Vector2(0.0, -2.0))
	arena.damage(f, 1.0, arena.rivet.id, &"ram")
	assert_true(f.alive())
	assert_eq(link._pending.size(), 1, "queued on the hit tick")
	var h: Array = link._pending[0]
	var hit_class: StringName = h[3]
	var dir: Vector2 = h[1]
	assert_eq(hit_class, &"blast")
	assert_almost_eq(dir.y, -1.0, 0.001, "thrown away from the press")


func test_an_unmapped_ghost_weapon_queues_none() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	arena.damage(_cop(arena, Vector2(1.0, 0.0)), 1.0, arena.rivet.id, &"ohm_bolt")
	assert_eq(link._pending.size(), 0, "the bolt's stun is FightAreas', not a wound")


func test_a_ram_on_a_riot_shield_front_throws_the_body_without_block_sparks() -> void:
	var link: ReactLink = ReactLink.make(_arena())
	var rig: CutRig = CutRig.new()
	rig.variant = RigVariant.crowd(6)
	watch_signals(link)
	link._ghost_blow = true
	link._wound(rig, 9, &"blast", Vector2.LEFT, false)
	assert_signal_not_emitted(link, "blocked", "the press took his hp: no 'blocked' sparks")
	assert_eq(HumanReact.on(rig).kind, &"knockdown")
	rig.free()


func test_a_blast_round_on_the_same_shield_still_blocks() -> void:
	var link: ReactLink = ReactLink.make(_arena())
	var rig: CutRig = CutRig.new()
	rig.variant = RigVariant.crowd(6)
	watch_signals(link)
	link._wound(rig, 9, &"blast", Vector2.LEFT, false)
	assert_signal_emitted(link, "blocked", "a gun's blast keeps the slab (not Rivet's blow)")
	rig.free()
