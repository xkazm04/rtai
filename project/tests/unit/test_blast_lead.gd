extends GutTest
## n7-ranged: the camera leads toward the mini-nuke's shell, holds on the landing, eases back;
## a weapon without a blast_lead row never moves it.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(7)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _shell(arena: CombatArena, weapon: StringName, at: Vector2) -> Shot:
	var s: Shot = Shot.new()
	s.weapon = weapon
	s.pos = at
	s.from_rivet = true
	arena.shots.append(s)
	return s


func _run(lead: BlastLead, arena: CombatArena, from: int, to: int) -> Vector2:
	var out: Vector2 = Vector2.ZERO
	for t: int in range(from, to):
		out = lead.step(arena, HitFeel.shipped(), t)
	return out


func test_a_nuke_shell_pulls_the_view_toward_it_inside_the_cap() -> void:
	var arena: CombatArena = _arena()
	var lead: BlastLead = BlastLead.new()
	@warning_ignore("return_value_discarded")
	_shell(arena, &"mini_nuke", Vector2(0.0, 9.0))
	var v: Vector2 = _run(lead, arena, 0, 60)
	var k: float = HitFeel.shipped().weapon_num(&"mini_nuke", "blast_lead_k", 0.0)
	assert_gt(k, 0.0, "the nuke row leads (planted blast_lead_k 0 fails here)")
	assert_almost_eq(v.y, 9.0 * k, 0.3, "most of the way to the shell")
	assert_almost_eq(v.x, 0.0, 0.001)
	var far: Vector2 = _run(lead, arena, 60, 61)
	assert_lte(far.length(), HitFeel.shipped().weapon_num(&"mini_nuke", "blast_lead_max_m", 0.0))


func test_it_holds_on_the_landing_then_eases_back() -> void:
	var arena: CombatArena = _arena()
	var lead: BlastLead = BlastLead.new()
	@warning_ignore("return_value_discarded")
	_shell(arena, &"mini_nuke", Vector2(0.0, 9.0))
	var at: Vector2 = _run(lead, arena, 0, 60)
	arena.shots.clear()  # landed
	var held: Vector2 = _run(lead, arena, 60, 100)
	assert_almost_eq(held.y, at.y, 0.3, "held while the ring plays")
	var back: Vector2 = _run(lead, arena, 100, 400)
	assert_lt(back.length(), 0.05, "back on Rivet")


func test_a_pistol_round_never_moves_the_view() -> void:
	var arena: CombatArena = _arena()
	var lead: BlastLead = BlastLead.new()
	@warning_ignore("return_value_discarded")
	_shell(arena, &"pistol", Vector2(0.0, 9.0))
	assert_eq(_run(lead, arena, 0, 60), Vector2.ZERO)
