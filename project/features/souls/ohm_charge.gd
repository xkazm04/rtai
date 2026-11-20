class_name OhmCharge
extends RefCounted
## Presentation of the live bolt gap. All envelopes use absolute simulation ticks.

const VENT_TICKS: int = 24
const FLASH_TICKS: int = 6

var _fill: float = 0.0
var _flash: float = 0.0
var _vent: float = 0.0
var _vent_tick: int = -VENT_TICKS
var _pending: bool = false
var _bolts: int = 0


func step(o: OhmStage, tick: int) -> void:
	var pending: bool = o.cast.due_tick >= 0
	if _pending and not pending and o.bolts == _bolts:
		_vent_tick = tick
	_pending = pending
	_bolts = o.bolts
	_vent = maxf(0.0, 1.0 - float(tick - _vent_tick) / VENT_TICKS)
	_flash = 0.0
	_fill = 0.0
	if o.on():
		var total: int = PowerDef.ticks(o.num(&"bolt_gap_s"))
		_fill = 3.0 if pending else 3.0 * (total - o.gap_left()) / total
		if o.bolt_tick >= 0:
			_flash = maxf(0.0, 1.0 - float(tick - o.bolt_tick) / FLASH_TICKS)
			if o.bolt_tick == tick:
				_fill = 0.0


func jar(i: int) -> float:
	return clampf(_fill - i, 0.0, 1.0)


func vent() -> float:
	return _vent


func flash() -> float:
	return _flash


func ready() -> bool:
	return _fill >= 3.0
