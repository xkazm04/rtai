class_name DummyBot
extends InputSource
## Test-only input: holds a random button mask and stick for 10-40 ticks, then changes. Its RNG
## comes from its own registry, so the world's streams are identical when a replay feeds the
## recorded input instead.

var _rng: RandomNumberGenerator
var _next_change: int = 0
var _current: TickInput = TickInput.new()


func _init(seed_value: int) -> void:
	_rng = RngRegistry.new(seed_value).stream(&"dummy_bot")


func sample(tick: int) -> TickInput:
	if tick >= _next_change:
		var axis: int = TickInput.AXIS_MAX
		var mask: int = _rng.randi_range(0, 7)
		_current = TickInput.new(mask, _rng.randi_range(-axis, axis), _rng.randi_range(-axis, axis))
		_next_change = tick + _rng.randi_range(10, 40)
	return _current
