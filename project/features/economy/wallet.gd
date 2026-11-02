class_name Wallet
extends RefCounted
## Rivet's cash. The one setter is add(), and it emits Events.cash_changed (ARC-08).

var cash: int = 0
var _events: EventBus


func _init(events: EventBus, starting: int = 0) -> void:
	_events = events
	cash = starting


func add(delta: int) -> void:
	if delta == 0:
		return
	cash += delta
	_events.cash_changed.emit(cash, delta)
