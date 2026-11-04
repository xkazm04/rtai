extends GutTest
## Lane human-reactions: the reaction table, the family choice by hit direction, the timings,
## the death pipeline and its signature-kill hook (lane brutality).

var _table: ReactTable
var _rig: CutRig


func before_each() -> void:
	_table = ReactTable.shipped()
	_rig = CutRig.new()
	_rig.actor_id = 7
	_rig.facing = 0.0


func after_each() -> void:
	_rig.free()


func test_table_loads_every_family() -> void:
	assert_true(_table.ok())
	for id: String in ["flinch", "stagger", "knockdown", "stun", "burn", "death_blast"]:
		assert_gt(_table.length(StringName(id)), 0.0, id)
	assert_almost_eq(_table.length(&"knockdown"), 2.2, 0.001)


func test_shield_blocks_only_from_the_front() -> void:
	# The body faces +x; a round travelling -x arrives from the front.
	assert_eq(_table.reaction_for(&"light", Vector2.LEFT, true, false), &"shield")
	assert_eq(_table.reaction_for(&"light", Vector2.RIGHT, true, false), &"flinch")


func test_melee_spins_from_the_side_and_folds_from_the_front() -> void:
	assert_eq(_table.reaction_for(&"melee", Vector2.DOWN, false, false), &"spin")
	assert_eq(_table.reaction_for(&"melee", Vector2.LEFT, false, false), &"fold")


func test_cover_and_class_mapping() -> void:
	assert_eq(_table.reaction_for(&"heavy", Vector2.LEFT, false, true), &"cover")
	assert_eq(_table.reaction_for(&"heavy", Vector2.LEFT, false, false), &"stagger")
	assert_eq(_table.reaction_for(&"shock", Vector2.LEFT, false, false), &"stun")
	assert_eq(_table.reaction_for(&"blast", Vector2.LEFT, false, false), &"knockdown")
	assert_eq(_table.death_for(&"burn"), &"death_burn")
	assert_eq(_table.death_for(&"light"), &"death_bullet")


func test_flinch_snaps_away_then_clears_on_time() -> void:
	var r: HumanReact = HumanReact.on(_rig)
	r.play(_rig, &"flinch", Vector2.DOWN, _table)
	var ticks: int = 0
	var peak: float = 0.0
	while r.active() and ticks < 600:
		r.pre(_rig, SimClock.TICK_DT)
		peak = maxf(peak, r.off.y)
		ticks += 1
	var want: int = ceili(_table.length(&"flinch") / SimClock.TICK_DT)
	assert_between(ticks, want - 1, want + 1, "flinch length in ticks")
	assert_gt(peak, 0.5 * _table.travel(&"flinch") * HumanReact.PX_M, "moves along the hit")


func test_death_holds_its_corpse_pose() -> void:
	var r: HumanReact = HumanReact.on(_rig)
	r.play(_rig, &"death_bullet", Vector2.LEFT, _table)
	for i: int in 300:
		r.pre(_rig, SimClock.TICK_DT)
	assert_true(r.active(), "a death never clears")
	assert_true(_rig.dead)
	assert_almost_eq(_rig.c_sprawl, 1.0, 0.01)
	r.play(_rig, &"flinch", Vector2.LEFT, _table)
	assert_eq(r.kind, &"death_bullet", "a corpse does not flinch")


func test_signature_kill_replaces_the_standard_death() -> void:
	var pipe: DeathPipe = DeathPipe.make(_table)
	assert_eq(pipe.kill(_rig, &"blast", Vector2.LEFT, &"rocket_launcher"), &"death_blast")
	var rig2: CutRig = CutRig.new()
	pipe.add_signature(
		func(_r: CutRig, _c: StringName, _d: Vector2, w: StringName) -> bool:
			return w == &"plasma_rifle"
	)
	assert_eq(pipe.kill(rig2, &"medium", Vector2.LEFT, &"plasma_rifle"), &"signature")
	assert_null(rig2.react, "the standard death never started")
	rig2.free()


func test_same_inputs_same_pose() -> void:
	var a: CutRig = CutRig.new()
	var b: CutRig = CutRig.new()
	for rig: CutRig in [a, b]:
		rig.actor_id = 11
		HumanReact.on(rig).play(rig, &"stun", Vector2.UP, _table)
		for i: int in 37:
			rig.react.pre(rig, SimClock.TICK_DT)
	assert_eq(a.react.off, b.react.off)
	assert_eq(a.twist, b.twist)
	a.free()
	b.free()


func test_an_electro_death_lies_stiff_a_round_death_sprawls() -> void:
	var r: HumanReact = HumanReact.on(_rig)
	r.play(_rig, &"death_shock", Vector2.LEFT, _table)
	for i: int in 300:
		r.pre(_rig, SimClock.TICK_DT)
	assert_almost_eq(_rig.c_plank, 1.0, 0.01, "legs together, arms along the sides")
	var rig2: CutRig = autofree(CutRig.new())
	var r2: HumanReact = HumanReact.on(rig2)
	r2.play(rig2, &"death_bullet", Vector2.LEFT, _table)
	for i: int in 300:
		r2.pre(rig2, SimClock.TICK_DT)
	assert_eq(rig2.c_plank, 0.0, "a round death keeps the X sprawl")


func test_the_stiff_corpse_falls_back_on_its_heels_over_a_scorch() -> void:
	var r: HumanReact = HumanReact.on(_rig)
	r.play(_rig, &"death_shock", Vector2.LEFT, _table)  # from the front
	for i: int in 300:
		r.pre(_rig, SimClock.TICK_DT)
	assert_eq(_rig.plank_feet, 1.0, "feet toward the shooter, the head thrown away")
	assert_almost_eq(absf(r.turn), DeathPose.PLANK_TILT, 0.01, "lands off the shot's axis")
	assert_true(_rig.get_node_or_null(NodePath(CorpseScorch.NAME)) is CorpseScorch, "scorched")
	var rig2: CutRig = autofree(CutRig.new())
	var r2: HumanReact = HumanReact.on(rig2)
	r2.play(rig2, &"death_shock", Vector2.RIGHT, _table)  # from behind
	for i: int in 300:
		r2.pre(rig2, SimClock.TICK_DT)
	assert_eq(rig2.plank_feet, -1.0, "shot in the back it falls forward")


func test_the_stiff_corpse_lies_along_the_shot_whichever_way_it_faced() -> void:
	_rig.facing = -PI / 2.0  # faces north, shot from the west (REQUEST 24b: it lay across)
	var r: HumanReact = HumanReact.on(_rig)
	r.play(_rig, &"death_shock", Vector2.RIGHT, _table)
	for i: int in 300:
		r.pre(_rig, SimClock.TICK_DT)
	var head: float = _rig.facing + r.turn + (PI if _rig.plank_feet > 0.0 else 0.0)
	var off: float = absf(wrapf(head - Vector2.RIGHT.angle(), -PI, PI))
	assert_almost_eq(off, DeathPose.PLANK_TILT, 0.01, "the head end runs down the shot's line")
	assert_almost_eq(DeathPose.plank_turn(Vector2.LEFT), DeathPose.PLANK_TILT, 0.001, "head-on")


func test_a_burn_death_lies_charred_over_soot() -> void:
	var r: HumanReact = HumanReact.on(_rig)
	r.play(_rig, &"death_burn", Vector2.LEFT, _table)
	for i: int in 300:
		r.pre(_rig, SimClock.TICK_DT)
	assert_almost_eq(r.tint, 1.0, 0.01, "charred")
	assert_true(_rig.get_node_or_null(NodePath(CorpseScorch.NAME)) is CorpseScorch, "soot under it")


func test_a_melee_death_lies_curled_not_in_the_x() -> void:
	var r: HumanReact = HumanReact.on(_rig)
	r.play(_rig, &"death_melee", Vector2.LEFT, _table)
	for i: int in 300:
		r.pre(_rig, SimClock.TICK_DT)
	assert_almost_eq(_rig.c_tuck, DeathPose.MELEE_CURL, 0.01, "knees drawn, arms in")
	assert_almost_eq(_rig.c_sprawl, DeathPose.MELEE_LIE, 0.01, "not the round's flat X")
	assert_lt(DeathPose.MELEE_LIE, 1.0)


func test_a_blast_death_lands_twisted() -> void:
	var r: HumanReact = HumanReact.on(_rig)
	r.play(_rig, &"death_blast", Vector2.LEFT, _table)
	for i: int in 300:
		r.pre(_rig, SimClock.TICK_DT)
	assert_almost_eq(_rig.c_kick, DeathPose.BLAST_TWIST, 0.01, "one leg thrown up")


func test_the_clip_pass_clears_the_corpse_channels() -> void:
	_rig.c_plank = 1.0
	_rig.c_kick = 0.55
	_rig.plank_feet = 1.0
	RigClips.new().sample(_rig, SimClock.TICK_DT)
	assert_eq(_rig.c_plank, 0.0, "a reused rig does not lie stiff")
	assert_eq(_rig.c_kick, 0.0, "nor keep a leg thrown up")
	assert_eq(_rig.plank_feet, -1.0, "nor its stiff feet's side")


func test_a_signature_kill_can_lay_the_stiff_corpse_without_human_react() -> void:
	DeathPose.stiff_channels(_rig, Vector2.LEFT, 1.0)  # showcase REQUEST 29: KillShockFx
	assert_true(_rig.dead, "dead")
	assert_almost_eq(_rig.c_plank, 1.0, 0.001, "stiff")
	assert_eq(_rig.plank_feet, 1.0, "feet toward the shooter")
	assert_true(_rig.get_node_or_null(NodePath(CorpseScorch.NAME)) is CorpseScorch, "scorched")
