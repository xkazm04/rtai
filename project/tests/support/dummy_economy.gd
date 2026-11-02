class_name DummyEconomy
extends WorldSystem
## Test-only sim system (F-05 replay scenario): cash and wanted level, each changed through one
## setter that emits (ARC-08), driven by input bits and the system's own RNG stream.

const WANTED_MAX: int = 5
const DECAY_EVERY: int = 600

var _ctx: WorldContext
var _rng: RandomNumberGenerator
var _cash: int = 0
var _wanted: int = 0


func setup(ctx: WorldContext) -> void:
	_ctx = ctx
	_rng = ctx.rng.stream(&"dummy_economy")


func step(tick: int, input: TickInput) -> void:
	if input.is_pressed(1) and _rng.randf() < 0.05:
		set_cash(_cash + _rng.randi_range(5, 50))
	if input.is_pressed(2) and _rng.randf() < 0.02:
		set_wanted(_wanted + 1)
	if tick % DECAY_EVERY == DECAY_EVERY - 1:
		set_wanted(_wanted - 1)


func set_cash(amount: int) -> void:
	var delta: int = amount - _cash
	_cash = amount
	_ctx.events.cash_changed.emit(_cash, delta)


func set_wanted(level: int) -> void:
	var clamped: int = clampi(level, 0, WANTED_MAX)
	if clamped == _wanted:
		return
	_wanted = clamped
	_ctx.events.wanted_changed.emit(_wanted)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_64(_cash)
	out.put_64(_wanted)
