class_name FrameDeltaSmoother
extends RefCounted
## n9-perf: the engine's delta smoothing for vsync modes it skips. Godot 4.7.2 smooths the frame
## delta only under VSYNC_ENABLED (main/main_timer_sync.cpp, DeltaSmoother::smooth_delta), so under
## the mailbox default (F-19) World._process gets the raw, load-jittered delta and the sim clock
## steps 0 or 2 ticks in some frames (a skipped tick image; LEDGER "Pacing A/B on the mailbox
## default"). This snaps each delta to whole display intervals and carries the remainder, as the
## engine does: a delta within TOLERANCE of a whole number of intervals passes as that number, a
## long or very short delta (a hitch, a resume, vsync not holding) passes raw and resets the carry.

## How far (in intervals) a delta may sit off a whole interval count and still be snapped.
const TOLERANCE: float = 0.35
## Deltas longer than this (s) pass raw (a resume, a load), as the engine's 1 s rule.
const LONG_S: float = 1.0

var _interval: float = 0.0
var _carry: float = 0.0


## `interval_s` = 1 / the display refresh rate; 0 or less = off (every delta passes raw).
func _init(interval_s: float) -> void:
	_interval = interval_s


func active() -> bool:
	return _interval > 0.0


## The delta the sim clock should advance by for a frame that took `delta` seconds.
func smooth(delta: float) -> float:
	if _interval <= 0.0 or delta <= 0.0 or delta > LONG_S:
		_carry = 0.0
		return delta
	var avail: float = delta + _carry
	var units: int = maxi(roundi(avail / _interval), 1)
	if absf(avail / _interval - units) > TOLERANCE:
		_carry = 0.0
		return delta
	_carry = avail - units * _interval
	return units * _interval
