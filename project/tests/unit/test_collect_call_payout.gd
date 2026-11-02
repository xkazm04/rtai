extends GutTest
## Quest 1 payout: +$1,500 exactly once, through the economy's setter (cash_changed once), less
## Juno's tape bill for each time Rivet was destroyed.

var _bus: EventBus
var _data: DataStore


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_data = autofree(DataStore.new())
	watch_signals(_bus)


func test_the_last_beat_pays_1500_once_however_long_it_runs_after() -> void:
	var world: JobStubWorld = JobStubWorld.new(JobStubWorld.collect_call_places())
	var runner: QuestRunner = QuestRunner.new(
		JobStubWorld.collect_call().package, world, _bus, QuestRules.shipped()
	)
	runner.offer()
	runner.start()
	runner.lines = QuestLinePlayer.new(runner.pkg, QuestRules.shipped())
	runner.call("_begin_beat", 5)
	world.reach(QuestWorld.Goal.PHONE_CONNECTED, "Harbor Road")
	for tick: int in 60 * 60:
		runner.step(tick)
	assert_eq(runner.state, QuestRunner.State.SUCCEEDED)
	assert_eq(world.calls.count("pay 1500"), 1)
	assert_eq(world.cash, 1500)
	assert_signal_emit_count(_bus, "contract_completed", 1)


func test_the_stage_pays_through_the_wallet_and_takes_the_tape_bill() -> void:
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	stage.setup(World.build_context(_bus, _data, 1))
	var port: CollectCallWorld = CollectCallWorld.new(stage)
	var before: int = stage.wallet.cash
	port.pay(1500)
	assert_eq(stage.wallet.cash - before, 1500)
	assert_signal_emit_count(_bus, "cash_changed", 1)
	assert_signal_emitted_with_parameters(_bus, "cash_changed", [before + 1500, 1500])
	stage.deaths = 1
	port.pay(1500)
	assert_eq(stage.wallet.cash - before, 1500 + 1500 - stage.layout.tape_bill)
