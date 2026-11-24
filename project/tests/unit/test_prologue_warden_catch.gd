extends GutTest

const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")


func _warden(game: PrologueGame) -> Fighter:
	for h: Fighter in game.stage.arena.hostiles:
		if h.archetype == FoeWardenCardView.ID:
			return h
	return null


func test_stage_drives_the_wardens_catch_view_from_the_catcher() -> void:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	add_child_autofree(game)
	var stage: PrologueStage = game.stage as PrologueStage
	var combat: PrologueCombat = stage.arena as PrologueCombat
	var warden: Fighter = _warden(game)
	assert_not_null(warden)
	combat.catcher = warden
	combat.pinned_until = stage.tick + 600
	stage._move()
	assert_true(warden.has_meta(FoeWardenCardView.HELD_FROM))
	combat.catcher = null
	stage._move()
	assert_false(warden.has_meta(FoeWardenCardView.HELD_FROM))
	assert_true(warden.has_meta(FoeWardenCardView.RELEASED))


func test_warden_card_gate_follows_the_cast_card() -> void:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	add_child_autofree(game)
	var props: PrologueProps = PrologueProps.new()
	props.patrol = game.encounter.patrol
	add_child_autofree(props)
	assert_eq(props._warden_card(), CastCards.current(&"appliance_warden") != null)
