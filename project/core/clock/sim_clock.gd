class_name SimClock
extends RefCounted
## Fixed 60 Hz simulation clock, decoupled from render (SIM-01). advance() is THE choke point for
## the raw frame delta: it clamps it once, and nothing else in the game reads a raw delta (lint
## audits `_process(delta)` and get_*process_delta_time()). The sim only ever sees TICK_DT and the
## tick index; render-side consumers (camera, audio fades) read the clamped frame_delta().

const TICK_RATE: int = 60
const TICK_DT: float = 1.0 / TICK_RATE
## At most 4 catch-up steps per frame (provisional, SIM-01); a longer frame is clamped to this,
## so a stall slows the game down instead of spiralling.
const MAX_STEPS_PER_FRAME: int = 4
const MAX_FRAME_DELTA: float = MAX_STEPS_PER_FRAME * TICK_DT
## Absorbs float error so a frame of exactly n ticks yields n steps.
const EPSILON: float = 1e-9

var _tick: int = 0
var _accumulator: float = 0.0
var _frame_delta: float = 0.0
var _dropped_seconds: float = 0.0


## Clamps the raw frame delta and returns how many fixed steps to run now (0..4).
func advance(raw_delta: float) -> int:
	_frame_delta = clampf(raw_delta, 0.0, MAX_FRAME_DELTA)
	_dropped_seconds += maxf(raw_delta - MAX_FRAME_DELTA, 0.0)
	_accumulator += _frame_delta
	var steps: int = mini(floori((_accumulator + EPSILON) / TICK_DT), MAX_STEPS_PER_FRAME)
	_accumulator = maxf(_accumulator - steps * TICK_DT, 0.0)
	return steps


## Called by SimLoop after every system stepped.
func complete_tick() -> void:
	_tick += 1


## The index of the tick being (or about to be) simulated.
func tick() -> int:
	return _tick


## The clamped frame delta: the only frame delta any consumer may read.
func frame_delta() -> float:
	return _frame_delta


## How far render is between the last two ticks, for interpolation (SIM-08).
func alpha() -> float:
	return clampf(_accumulator / TICK_DT, 0.0, 1.0)


## Wall time thrown away by the clamp (telemetry: long stalls, TEL-03).
func dropped_seconds() -> float:
	return _dropped_seconds


func reset() -> void:
	_tick = 0
	_accumulator = 0.0
	_frame_delta = 0.0
	_dropped_seconds = 0.0
