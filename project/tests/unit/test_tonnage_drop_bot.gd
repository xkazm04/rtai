extends GutTest
## n31 ghost 2: the gauntlet bot drops Tonnage with one press, the aim in the same word.

var stage: ArenaStage
var actions: PlayerActions
var view: BotViewArena
var bot: GhostDeployBot
var ghost: GhostDeploy


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = ArenaStage.new(ArenaPlan.shipped(), ArenaStations.new())
	stage.setup(World.build_context(bus, data, 24))
	actions = PlayerActions.shipped(true)
	stage.pilot = StagePilot.new(actions)
	stage.pilot.ghosts.transform_unlocked = false
	stage.pilot.ghosts.forms.selected = &"tonnage"
	stage.arena.rivet.pos = Vector2.ZERO
	view = BotViewArena.new(stage, actions, true)
	bot = GhostDeployBot.new(view, actions, RngRegistry.new(24))
	ghost = stage.pilot.ghosts.deploy


func _word() -> TickInput:
	view.refresh()
	var intent: GauntletBot.Intent = GauntletBot.Intent.new()
	intent.aim = Vector2.LEFT
	intent.reach = 12.0
	var bits: int = bot.steer(intent, 0, 1.0)
	return TickInput.new(bits | PlayerCommand.pack_aim(intent.aim, actions, intent.reach))


func test_tonnage_drop_is_one_press_with_the_aim_in_the_same_word() -> void:
	var number: int = 1 << actions.bit(&"ghost_deploy_2")
	var row: GhostAttacks.DeployRow = ghost.strike.attacks.deploy[&"tonnage"]
	var cops: Array[Fighter] = []
	for at: Vector2 in [Vector2(5, 0), Vector2(6, 1), Vector2(6, -1)]:
		var cop: Fighter = stage.arena.squad_ai.spawn_member(stage.arena, at, &"patrol_cop")
		cop.pos = at
		cops.append(cop)
	var press: TickInput = _word()
	assert_eq(press.buttons & number, number)
	stage.tick += 1
	stage.pilot.drive(stage, press)
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE, "the press itself deploys")
	assert_true(ghost.dump.pending())
	assert_ne(ghost.spot, Vector2(-row.range_m, 0), "the planned spot, not the gun's left aim")
	for cop: Fighter in cops:
		assert_lte(ghost.spot.distance_to(cop.pos), row.radius_m)
	assert_eq(_word().buttons & number, 0, "no second press while he charges")
