extends GutTest
## n8-view it14: quest 1's contractors stay on the cast view (hi-vis cards), not police rigs.


func test_quest_guards_go_to_the_cast_view() -> void:
	var guard: Fighter = Fighter.make(Fighter.Kind.GUARD, 1, Vector2.ZERO, 10.0)
	assert_true(QuestGuardCast.takes(null, guard), "a quest 1 contractor is drawn by the cast view")


func test_rivet_and_the_boss_keep_their_rigs() -> void:
	var rivet: Fighter = Fighter.make(Fighter.Kind.RIVET, 0, Vector2.ZERO, 10.0)
	var boss: Fighter = Fighter.make(Fighter.Kind.BOSS, 2, Vector2.ZERO, 10.0)
	assert_false(QuestGuardCast.takes(null, rivet))
	assert_false(QuestGuardCast.takes(null, boss))


func test_the_dev_arena_keeps_every_fighter_on_the_rigs() -> void:
	var stage: ArenaStage = ArenaStage.new(ArenaPlan.shipped(), ArenaStations.shipped())
	var guard: Fighter = Fighter.make(Fighter.Kind.GUARD, 1, Vector2.ZERO, 10.0)
	assert_false(QuestGuardCast.takes(stage, guard), "the arena's fighters dress as cops")
