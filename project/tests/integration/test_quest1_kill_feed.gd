extends GutTest
## n31 melee 03p2: quest 1 feeds signature kills (QuestKillFeed, behind --kill-feed with the rig
## cast). A chainsaw kill on a shieldless patrol cop in a headless quest 1 session plays the
## owner's `chainsaw_grind` (his variant) and consumes the body; the feed's state folds into the
## world hash; reduced gore leaves the standard death; the flag off installs nothing.
## n31 melee 03p3: on by default with the rig cast; the manual feeds below open with it off.

var session: Quest1Session
var rows: Array[StringName] = []
var _on_city: bool = true
var _flags: Dictionary[String, String] = {}


func before_each() -> void:
	_on_city = Quest1Session.on_city
	Quest1Session.on_city = false  # the invented arena: no city stream needed for the feed
	_flags = LaunchArgs._values.duplicate()
	LaunchArgs._values["--kill-feed"] = "off"  # the tests install their own feed (_feed)
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	session = Quest1Session.open(bus, data)
	rows.clear()


func after_each() -> void:
	Quest1Session.on_city = _on_city
	LaunchArgs._values = _flags
	if session != null:
		session.world.free()


func _on_killed(_id: int, _serial: int, row: SignatureKill, _at: Vector2, _dir: Vector2) -> void:
	rows.append(row.id)


func _feed(gore_full: bool) -> QuestKillFeed:
	var feed: QuestKillFeed = QuestKillFeed.install(session.world.add_system, session.stage)
	feed.kills.table.gore_full = gore_full
	@warning_ignore("return_value_discarded")
	feed.kills.killed.connect(_on_killed)
	return feed


func _cop_killed_by(weapon: StringName) -> Fighter:
	var arena: CombatArena = session.stage.arena
	var cop: Fighter = Fighter.make(Fighter.Kind.GUARD, 9001, arena.rivet.pos + Vector2.DOWN, 1.0)
	cop.archetype = &"patrol_cop"
	cop.hp = 0.0
	arena.kill_landed.emit(cop, weapon, Vector2.DOWN, cop.pos, &"melee")
	return cop


func test_the_chainsaw_kill_plays_chainsaw_grind_in_quest_1() -> void:
	assert_not_null(session, "quest 1 opens")
	var feed: QuestKillFeed = _feed(true)
	var cop: Fighter = _cop_killed_by(&"chainsaw")
	assert_eq(rows.size(), 1, "one signature kill")
	assert_eq(rows[0] if not rows.is_empty() else &"", &"chainsaw_grind_patrol_cop")
	assert_true(feed.kills.consumed.has(cop.id), "the cop's body is consumed by the kill")
	var count: int = feed.telemetry().get("signature_kills", 0)
	assert_eq(count, 1, "telemetry counts it")


func test_the_feed_folds_into_the_world_hash() -> void:
	var before: String = session.world.loop().state_hash()
	var feed: QuestKillFeed = _feed(true)
	var empty: String = session.world.loop().state_hash()
	assert_ne(before, empty, "the feed's state is part of the hash")
	@warning_ignore("return_value_discarded")
	_cop_killed_by(&"chainsaw")
	assert_ne(session.world.loop().state_hash(), empty, "a kill moves it")
	assert_eq(feed.kills.consumed.size(), 1)


func test_reduced_gore_leaves_the_standard_death() -> void:
	var feed: QuestKillFeed = _feed(false)
	@warning_ignore("return_value_discarded")
	_cop_killed_by(&"chainsaw")
	assert_true(rows.is_empty(), "no signature kill row at reduced gore")
	assert_true(feed.kills.consumed.is_empty())


func _reopen(kill_feed: String) -> void:
	session.world.free()
	LaunchArgs._values = _flags.duplicate()
	LaunchArgs._values["--rigs"] = ""  # the rig cast (a debug build: QuestKillFeed.rig_cast)
	if kill_feed != "":
		LaunchArgs._values["--kill-feed"] = kill_feed
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	session = Quest1Session.open(bus, data)


func test_the_feed_is_on_by_default_with_the_rigs() -> void:
	_reopen("")
	assert_not_null(session.kills_feed, "n31 melee 03p3: quest 1's rig cast feeds kills")


func test_kill_feed_off_installs_nothing() -> void:
	_reopen("off")
	assert_null(session.kills_feed, "--kill-feed=off: the generic deaths")
