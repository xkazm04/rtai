extends GutTest
## Cash (economy): the one setter adds and emits cash_changed(amount, delta).


func test_add_emits_cash_changed() -> void:
	var bus: EventBus = autofree(EventBus.new())
	watch_signals(bus)
	var wallet: Wallet = Wallet.new(bus, 20)
	wallet.add(1500)
	assert_eq(wallet.cash, 1520)
	assert_signal_emitted_with_parameters(bus, "cash_changed", [1520, 1500])
