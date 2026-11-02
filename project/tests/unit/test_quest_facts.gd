extends GutTest
## Bark event tags mapped to the typed Events (F-04 + the planned combat/madness signals): each
## signal records its fact with qualifiers, a fact holds for event_window_s, and detach() stops
## listening (GDS-10).

const WINDOW: int = 120

var _bus: EventBus
var _world: StubQuestWorld
var _facts: QuestFacts


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_world = StubQuestWorld.new(QuestFixture.cc_places())
	_world.wanted = 2
	_facts = QuestFacts.new(WINDOW)
	_facts.attach(_bus, _world)
	_facts.begin_tick(10, _world)


func after_each() -> void:
	_facts.detach()


func test_kill_counts_only_when_rivet_is_the_killer() -> void:
	_bus.actor_killed.emit(99, 5, &"shot")
	assert_true(_facts.recent("actor_killed"))
	assert_false(_facts.recent("actor_killed:by_player"))
	_bus.actor_killed.emit(StubQuestWorld.PLAYER_ID, 6, &"shot")
	assert_true(_facts.recent("actor_killed:by_player"))


func test_wanted_changes_record_their_direction() -> void:
	_bus.wanted_changed.emit(3)
	assert_eq(
		[_facts.recent("wanted_changed:rising"), _facts.recent("wanted_changed:falling")],
		[true, false]
	)
	_bus.wanted_changed.emit(1)
	assert_true(_facts.recent("wanted_changed:falling"))


func test_weapon_qualified_facts() -> void:
	_bus.attack_telegraphed.emit(&"robo-tazer")
	_bus.player_hit.emit(&"rifle")
	assert_true(_facts.recent("attack_telegraphed:robo-tazer"))
	assert_true(_facts.recent("player_hit"))
	assert_false(_facts.recent("player_hit:robo-tazer"))


func test_combat_and_madness_signals() -> void:
	_bus.wave_started.emit(&"Dock 9 bonded storage", 1)
	_bus.boss_engaged.emit(&"quartermaster-mertz")
	_bus.whispers_spiked.emit()
	for fact: String in ["wave_started", "boss_engaged", "whispers_spiked"]:
		assert_true(_facts.recent(fact), fact)


func test_a_fact_holds_for_the_window_then_lapses() -> void:
	_bus.whispers_spiked.emit()
	_facts.begin_tick(10 + WINDOW, _world)
	assert_true(_facts.recent("whispers_spiked"))
	_facts.begin_tick(11 + WINDOW, _world)
	assert_false(_facts.recent("whispers_spiked"))


func test_state_snapshot_and_detach() -> void:
	_world.weapon = "gloria"
	_world.soul = "gearbox"
	_facts.begin_tick(11, _world)
	assert_eq([_facts.weapon, _facts.soul, _facts.heat], ["gloria", "gearbox", 2])
	_facts.detach()
	assert_false(_bus.is_connected("whispers_spiked", _facts._on_whispers_spiked))
	_bus.whispers_spiked.emit()
	assert_false(_facts.recent("whispers_spiked"), "no longer listening")
