class_name ArenaTelemetry
extends RefCounted
## What "smooth" is measured with, per arena session (registry: controller-latency-
## instrumentation, encounter-balance-simulation): shots, hits and hit rate, time to kill per
## target, damage taken, input-to-motion latency (ticks from a move press to Rivet moving), the
## peak turn rate and top speed, knockdowns. Sim-side only (ticks, not frames): the view adds
## its frame latency on top. Written as gtai.arena-telemetry/1.

const SCHEMA: String = "gtai.arena-telemetry/1"

var shots: int = 0
var hits: int = 0
var damage_taken: float = 0.0
var latency_ticks: Array[int] = []
var turn_dps_peak: float = 0.0
var top_speed_mps: float = 0.0
var knockdowns: int = 0
var ticks: int = 0
var _press_tick: int = -1
var _was_moving_stick: bool = false
var _last_facing: Vector2 = Vector2.ZERO


## One tick: the stick this tick, how far Rivet moved, his facing, the hp he lost.
func sample(tick: int, stick: Vector2, moved_m: float, facing: Vector2, hp_lost: float) -> void:
	ticks = tick
	var pushing: bool = stick != Vector2.ZERO
	if pushing and not _was_moving_stick:
		_press_tick = tick
	if _press_tick >= 0 and moved_m > 0.0005:
		latency_ticks.append(tick - _press_tick)
		_press_tick = -1
	if not pushing:
		_press_tick = -1
	_was_moving_stick = pushing
	top_speed_mps = maxf(top_speed_mps, moved_m / SimClock.TICK_DT)
	if _last_facing != Vector2.ZERO:
		var dps: float = rad_to_deg(absf(_last_facing.angle_to(facing))) / SimClock.TICK_DT
		turn_dps_peak = maxf(turn_dps_peak, dps)
	_last_facing = facing
	damage_taken += maxf(hp_lost, 0.0)


func hit_rate() -> float:
	return float(hits) / float(shots) if shots > 0 else 0.0


func latency_mean() -> float:
	if latency_ticks.is_empty():
		return -1.0
	var sum: int = 0
	for l: int in latency_ticks:
		sum += l
	return float(sum) / float(latency_ticks.size())


func to_dict(ttk_s: Dictionary[String, Array]) -> Dictionary:
	return {
		"schema": SCHEMA,
		"ticks": ticks,
		"shots": shots,
		"hits": hits,
		"hit_rate": hit_rate(),
		"ttk_s": ttk_s,
		"damage_taken": damage_taken,
		"input_latency_ticks": latency_ticks,
		"input_latency_mean_ticks": latency_mean(),
		"turn_rate_peak_dps": turn_dps_peak,
		"top_speed_mps": top_speed_mps,
		"knockdowns": knockdowns,
	}
