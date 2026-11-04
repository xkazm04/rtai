extends GutTest
## combat-notes (owner note 2026-11-04, plasma "hot and heavy"): a plasma bolt that does not kill
## staggers the body on the frame it lands (human_reactions.json weapon_wound, over the medium
## class's flinch) and leaves a scorch mark; behind a riot shield the bearer staggers but the body
## is not marked; --no-plasma-heat (KillHoleFx.heat off) plays the night's flinch.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _hit(link: ReactLink, rig: CutRig, id: int, weapon: StringName) -> void:
	link._wound(rig, id, link.hit_class_of(weapon), Vector2.LEFT, false)
	link._heavy(rig, id, Vector2.LEFT, weapon)


func test_the_plasma_bolt_has_its_own_wound_family() -> void:
	var table: ReactTable = ReactTable.shipped()
	assert_true(table.ok())
	assert_eq(table.weapon_wound(&"plasma_rifle"), &"stagger")
	assert_eq(table.weapon_wound(&"pistol"), &"", "other guns keep their class's family")
	var by_class: StringName = table.reaction_for(&"medium", Vector2.LEFT, false, false)
	assert_eq(by_class, &"flinch", "without the row the medium class would only flinch")


func test_a_plasma_wound_staggers_on_the_hit_frame_and_scorches() -> void:
	var arena: CombatArena = _arena()
	arena.tick = 500
	var link: ReactLink = ReactLink.make(arena)
	var rig: CutRig = CutRig.new()
	rig.variant = RigVariant.crowd(5)
	_hit(link, rig, 7, &"plasma_rifle")
	var r: HumanReact = HumanReact.on(rig)
	assert_eq(r.kind, &"stagger", "the stagger starts on the frame the bolt lands")
	assert_almost_eq(r.progress(), 0.0, 0.001, "from its first frame, no lag")
	assert_true(link.scorched.has(7), "the body is marked")
	var marks: Array = link.scorched[7]
	var born: int = marks[0][0]
	assert_eq(born, 500, "the mark is born on the hit tick")
	var bare: CutRig = CutRig.new()
	bare.variant = RigVariant.crowd(5)
	_hit(link, bare, 8, &"pistol")
	assert_eq(HumanReact.on(bare).kind, &"flinch")
	assert_false(link.scorched.has(8), "a pistol round leaves no scorch")
	rig.free()
	bare.free()


func test_behind_a_shield_the_bearer_staggers_unmarked() -> void:
	var link: ReactLink = ReactLink.make(_arena())
	var rig: CutRig = CutRig.new()
	rig.variant = RigVariant.crowd(6)
	watch_signals(link)
	_hit(link, rig, 9, &"plasma_rifle")
	assert_signal_emitted(link, "blocked", "the slab still takes the bolt (sparks)")
	assert_eq(HumanReact.on(rig).kind, &"stagger")
	assert_false(link.scorched.has(9))
	rig.free()


func test_no_plasma_heat_plays_the_nights_flinch() -> void:
	var link: ReactLink = ReactLink.make(_arena())
	var rig: CutRig = CutRig.new()
	rig.variant = RigVariant.crowd(5)
	KillHoleFx.heat = false
	_hit(link, rig, 7, &"plasma_rifle")
	KillHoleFx.heat = true
	assert_eq(HumanReact.on(rig).kind, &"flinch")
	assert_false(link.scorched.has(7))
	rig.free()


func test_marks_sit_on_the_entry_side_and_keep_the_last_three() -> void:
	var marks: Dictionary[int, Array] = {}
	for t: int in 5:
		PlasmaScorchView.mark(marks, 3, Vector2.RIGHT, 100 + t)
	var list: Array = marks[3]
	assert_eq(list.size(), PlasmaScorchView.MAX_MARKS)
	var first: int = list[0][0]
	assert_eq(first, 102, "the oldest marks go first")
	assert_lt(PlasmaScorchView.spot_of(Vector2.RIGHT, 1).x, 0.0, "a bolt along +x enters at -x")
