extends GutTest
## n8-view it15: quest 1 under combo eases to the boss pitch while Mertz is up (ViewPitchQuest).

var _saved: ViewMode = null


func before_each() -> void:
	_saved = ViewMode._shared


func after_each() -> void:
	ViewMode._shared = _saved


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func test_the_boss_is_up_from_his_spawn_until_he_is_down() -> void:
	var arena: CombatArena = _arena()
	assert_false(ViewPitchQuest.boss_up(arena), "no boss yet: play pitch")
	assert_false(ViewPitchQuest.boss_up(null))
	var mertz: Fighter = arena.spawn_boss(Vector2(4.0, 2.0))
	assert_true(ViewPitchQuest.boss_up(arena), "Mertz stepped in: boss pitch")
	mertz.hp = 0.0
	assert_false(ViewPitchQuest.boss_up(arena), "Mertz down: back to play")


func test_combo_gets_an_ease_driven_by_the_boss() -> void:
	ViewMode._shared = ViewMode.of("combo")
	var view: Node = autofree(Node.new())
	var arena: CombatArena = _arena()
	var ease: ViewPitchEase = ViewPitchQuest.attach(view, arena, SimClock.new())
	assert_not_null(ease)
	assert_eq(ease.get_parent(), view)
	assert_eq(ease.pitch.boss_pitch, 55.0)
	var before: bool = ease.boss_on.is_valid() and ease.boss_on.call() == true
	assert_false(before, "before Mertz")
	@warning_ignore("return_value_discarded")
	arena.spawn_boss(Vector2.ZERO)
	var up: bool = ease.boss_on.is_valid() and ease.boss_on.call() == true
	assert_true(up, "Mertz up")


func test_top_tilt_and_tilt70_get_no_ease() -> void:
	for id: String in ["top", "tilt", "tilt70"]:
		ViewMode._shared = ViewMode.of(id)
		var view: Node = autofree(Node.new())
		assert_null(ViewPitchQuest.attach(view, _arena(), SimClock.new()), id)
		assert_eq(view.get_child_count(), 0, id)
