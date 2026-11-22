class_name MoveTtkStats
extends RefCounted
## A null kill tick is right-censored at the time limit. It has a rank, but no exact delta.


## The samples belong to this summary and no longer need their original order.
static func median(values: Array[float]) -> float:
	values.sort()
	return 0.5 * (values[(values.size() - 1) / 2] + values[values.size() / 2])


static func kill_median_s(ticks: Array[float]) -> Variant:
	var middle: float = median(ticks)
	if ticks[ticks.size() / 2] > FoeTtkTrial.LIMIT:
		return null
	return middle * SimClock.TICK_DT


static func order_tick(tick: Variant) -> int:
	return tick if tick is int else FoeTtkTrial.LIMIT + 1


static func delta_ticks(off: Variant, on: Variant) -> Variant:
	if off is int and on is int:
		return on - off
	return null


static func summarize(pairs: Array[Dictionary], arm: String) -> Dictionary:
	var off_ticks: Array[float] = []
	var on_ticks: Array[float] = []
	var differences: Array[float] = []
	var off_hurt: Array[float] = []
	var on_hurt: Array[float] = []
	var off_uses: int = 0
	var on_uses: int = 0
	var faster: int = 0
	for pair: Dictionary in pairs:
		var off: Dictionary = pair.off
		var on: Dictionary = pair[arm]
		off_ticks.append(order_tick(off.kill_tick))
		on_ticks.append(order_tick(on.kill_tick))
		faster += int(on_ticks[-1] < off_ticks[-1])
		if on.delta_ticks != null:
			differences.append(on.delta_ticks)
		off_hurt.append(off.damage_to_rivet)
		on_hurt.append(on.damage_to_rivet)
		off_uses += off.move_uses
		on_uses += on.move_uses
	return {
		"off_median_s": kill_median_s(off_ticks),
		"on_median_s": kill_median_s(on_ticks),
		"paired_median_delta_s":
		median(differences) * SimClock.TICK_DT if differences.size() == pairs.size() else null,
		"seeds_faster": faster,
		"off_median_damage": median(off_hurt),
		"on_median_damage": median(on_hurt),
		"off_total_uses": off_uses,
		"on_total_uses": on_uses,
	}
