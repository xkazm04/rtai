class_name ContactCostMetric
extends RefCounted
## All times in ms. Pool frames for arm percentiles, but pair only within a round for inference.
## A block's 10% trimmed mean keeps sub-microsecond shifts visible with the integer writer timer.

const ROUNDS: int = 24
const T_CRITICAL: float = 2.068658  # two-sided 95%, 23 df
const ARMS: Array[String] = ["on", "off", "on_repeat"]

var _pooled: Array[PackedFloat64Array] = [[], [], []]
var _blocks: Array[PackedFloat64Array] = [[], [], []]


func add_block(arm: int, samples: PackedFloat64Array) -> void:
	_pooled[arm].append_array(samples)
	var sorted: PackedFloat64Array = samples.duplicate()
	sorted.sort()
	var trim: int = floori(sorted.size() * 0.1)
	@warning_ignore("return_value_discarded")
	_blocks[arm].append(_mean(sorted.slice(trim, sorted.size() - trim)))


func result(instances: PackedInt32Array) -> Dictionary:
	var arms: Dictionary[String, Dictionary] = {}
	for arm: int in ARMS.size():
		var data: PackedFloat64Array = _pooled[arm]
		data.sort()
		var p50: float = _percentile(data, 0.5)
		arms[ARMS[arm]] = {
			"frames": data.size(),
			"p50_ms": p50,
			"p95_ms": _percentile(data, 0.95),
			"p50_us_per_shadow": 1000.0 * p50 / instances[arm],
			"block_trimmed_means_ms": _blocks[arm],
		}
	var effect: Dictionary = _paired(1)
	var twin: Dictionary = _paired(2)
	var twin_deltas: PackedFloat64Array = twin["round_deltas_ms"]
	var abs_twin: PackedFloat64Array = twin_deltas.duplicate()
	for i: int in abs_twin.size():
		abs_twin[i] = absf(abs_twin[i])
	abs_twin.sort()
	var noise: float = _percentile(abs_twin, 0.95)
	var delta: float = effect["mean_ms"]
	return {
		"arms": arms,
		"on_minus_off": effect,
		"on_minus_repeat": twin,
		"aa_floor_ms": noise,
		"below_floor": absf(delta) <= noise,
		"delta_us_per_on_shadow": 1000.0 * delta / instances[0],
		"floor_us_per_on_shadow": 1000.0 * noise / instances[0],
	}


func _paired(other: int) -> Dictionary:
	var ds := PackedFloat64Array()
	for r: int in ROUNDS:
		@warning_ignore("return_value_discarded")
		ds.append(_blocks[0][r] - _blocks[other][r])
	var mean: float = _mean(ds)
	var sum_sq: float = 0.0
	for d: float in ds:
		sum_sq += (d - mean) * (d - mean)
	var half: float = T_CRITICAL * sqrt(sum_sq / (ROUNDS * (ROUNDS - 1)))
	return {"round_deltas_ms": ds, "mean_ms": mean, "ci95_ms": [mean - half, mean + half]}


static func _mean(values: PackedFloat64Array) -> float:
	var total: float = 0.0
	for value: float in values:
		total += value
	return total / values.size()


static func _percentile(sorted: PackedFloat64Array, q: float) -> float:
	var at: float = q * (sorted.size() - 1)
	return lerpf(sorted[floori(at)], sorted[ceili(at)], at - floorf(at))
