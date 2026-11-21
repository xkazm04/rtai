extends GutTest

var bot: GauntletTestPlayer
var session: GauntletSession
var bus: EventBus
var data: DataStore


func before_each() -> void:
	bus = EventBus.new()
	data = DataStore.new()
	var run: GauntletRun = GauntletRun.new()
	bot = GauntletTestPlayer.new()
	bot.configure(&"average", &"greedy", 3)
	session = GauntletSession.open_street(bus, data, run, bot)
	bot.bind(run, session)


func after_each() -> void:
	session.close()
	bus.free()
	data.free()


func test_act_reads_the_post_step_pose_and_the_last_movement_decision() -> void:
	var p: StagePilot = session.pilot
	assert_eq(GauntletTestPlayer.new().act(), &"REST")
	assert_eq(bot.act(), &"REST")
	session.step()
	assert_eq(bot.act(), &"ADVANCE")
	p.ghosts.forms.to_id = &"tonnage"
	assert_eq(bot.act(), &"TONNAGE")
	p.guard = PlayerGuard.new()
	p.guard.step(true, true)
	assert_eq(bot.act(), &"GUARD")
	var roll: PlayerCommand = PlayerCommand.new()
	roll.pressed = 1 << p.actions.bit(&"roll")
	@warning_ignore("return_value_discarded")
	p.motion.step(roll, 5.0, p.actions)
	assert_eq(bot.act(), &"ROLL")
	session.stage.arena.rivet.hp = 0
	assert_eq(bot.act(), &"REST")


func test_attack_distinguishes_claw_and_numbered_slots_and_cover_overrides_attack() -> void:
	var p: StagePilot = session.pilot
	p.melee.combo.hit_index = 1
	assert_eq(bot.act(), &"ATTACK CLAW")
	p.melee.weapon_id = &"katana"
	assert_true(session.bonuses.apply({"kind": "weapon", "ref": "pistol"}))
	p.carry.current = -1
	assert_eq(bot.act(), &"ATTACK PRIMARY")
	for slot: int in RivetCarry.SLOTS:
		p.carry.current = slot
		assert_eq(bot.act(), StringName("ATTACK %d" % (slot + 1)))
	var at: Vector2 = session.stage.arena.rivet.pos
	session.stage.walls.boxes.append(Rect2(at + Vector2(2, -1), Vector2(1, 2)))
	var shot: Shot = Shot.new()
	shot.size = Shot.LARGE
	shot.from_rivet = false
	shot.pos = at + Vector2(7, 0)
	shot.vel = Vector2.LEFT * 60.0
	session.stage.arena.shots.append(shot)
	@warning_ignore("return_value_discarded")
	bot.sample(1)
	assert_eq(bot.cover_threat(), &"large")
	assert_eq(bot.act(), &"COVER")


func test_cover_keeps_its_threat_size_and_clears_when_the_round_passes() -> void:
	var view: BotView = BotView.new()
	var skill: BotProfile = BotProfile.shipped(&"average")
	var brain: GauntletBot = GauntletBot.new(view, session.actions, skill, 3)
	var shot: BotView.Round = BotView.Round.new()
	shot.pos = Vector2(7, 0)
	shot.vel = Vector2.LEFT * 60.0
	view.incoming().append(shot)
	view.solid_props().append(Rect2(2, 1, 1, 1))
	for size_id: StringName in [&"small", &"large"]:
		shot.size = size_id
		@warning_ignore("return_value_discarded")
		brain.sample(1)
		assert_eq(brain.cover_threat, size_id)
	view.incoming().clear()
	@warning_ignore("return_value_discarded")
	brain.sample(2)
	assert_eq(brain.cover_threat, &"")
