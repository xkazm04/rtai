class_name PressureSeedsText
extends RefCounted
## The markdown for the pressure seed table: per-seed rows, pooled totals, Wilson intervals.

const Z: float = 1.96
const NEAR_HEAD: String = (
	"| seed | fired | returned | passed | struck | share | unswung hit | of them mid-swing "
	+ "| missed | shooters down | Rivet hits |"
)
const GUARD_HEAD: String = (
	"| seed | fired | returned | passed | struck | share " + "| shooters down | Rivet hits |"
)
const CURVE: Dictionary[String, float] = {"guard6": 24.3, "blade6": 30.6}


static func wilson(k: int, n: int) -> Vector2:
	if n <= 0:
		return Vector2(NAN, NAN)
	var p: float = float(k) / n
	var z2: float = Z * Z
	var denom: float = 1.0 + z2 / n
	var centre: float = (p + z2 / (2.0 * n)) / denom
	var half: float = Z * sqrt(p * (1.0 - p) / n + z2 / (4.0 * n * n)) / denom
	return Vector2(centre - half, centre + half) * 100.0


static func markdown(rows: Array[Dictionary]) -> String:
	var out: Array[String] = ["# n27 pressure takes, seeds 1 to 10", ""]
	for id: String in ["guard6", "blade6"]:
		out.append_array(_near(id, _of(rows, id)))
	for id: String in ["pair_circle", "pair_dash"]:
		out.append_array(_pair(id, _of(rows, id)))
	return "\n".join(out) + "\n"


static func _of(rows: Array[Dictionary], id: String) -> Array[Dictionary]:
	var picked: Array[Dictionary] = []
	for r: Dictionary in rows:
		if r.take == id:
			picked.append(r)
	return picked


static func _sum(rows: Array[Dictionary], key: String) -> int:
	var total: int = 0
	for r: Dictionary in rows:
		var v: int = r.get(key, 0)
		total += v
	return total


static func _near(id: String, rows: Array[Dictionary]) -> Array[String]:
	var sword: bool = id == "blade6"
	var head: String = NEAR_HEAD if sword else GUARD_HEAD
	var out: Array[String] = ["## %s (6 m)" % id, "", head, _rule(head)]
	for r: Dictionary in rows:
		if not r.opened:
			out.append("| %d | did not open |" % r.seed)
			continue
		var hit: int = r.struck
		var back: int = r.returned
		var cells: Array = [r.seed, r.fired, back, r.passed, hit, _pct(hit, back)]
		if sword:
			cells.append_array([r.fate_unswung_hit, r.fate_unswung_while_busy, r.fate_missed])
		cells.append_array([r.shooter_hits, r.hits])
		out.append("| " + " | ".join(cells.map(str)) + " |")
	out.append_array(_near_pooled(id, rows, sword))
	return out


static func _near_pooled(id: String, rows: Array[Dictionary], sword: bool) -> Array[String]:
	var out: Array[String] = []
	var k: int = _sum(rows, "struck")
	var n: int = _sum(rows, "returned")
	var w: Vector2 = wilson(k, n)
	var pooled: String = (
		"Pooled: fired %d, returned %d, passed %d" % [_sum(rows, "fired"), n, _sum(rows, "passed")]
	)
	if sword:
		pooled += (
			", no deflect %d (blade mid-swing %d), missed %d"
			% [
				_sum(rows, "fate_unswung_hit"),
				_sum(rows, "fate_unswung_while_busy"),
				_sum(rows, "fate_missed"),
			]
		)
	out.append("")
	out.append("%s; struck %d." % [pooled, k])
	var curve: float = CURVE[id]
	var inside: bool = n > 0 and curve >= w.x and curve <= w.y
	out.append(
		(
			"Pooled share %s, Wilson 95%% [%.1f, %.1f]; the curve's %.1f%% lies %s the interval."
			% [_pct(k, n), w.x, w.y, curve, "inside" if inside else "OUTSIDE"]
		)
	)
	out.append("")
	return out


static func _rule(head: String) -> String:
	return "|" + "---:|".repeat(head.count("|") - 1)


static func _pair(id: String, rows: Array[Dictionary]) -> Array[String]:
	var out: Array[String] = [
		"## %s" % id,
		"",
		"| seed | launches | hits | down at (s) | HP at 10 s | dashes |",
		"|---:|---:|---:|---:|---:|---:|",
	]
	var downs: int = 0
	for r: Dictionary in rows:
		if not r.opened:
			out.append("| %d | did not open | | | | |" % r.seed)
			continue
		var down: String = "alive"
		var death: int = r.death_tick
		var hp10: float = r.hp_at_10s
		if death > 0:
			down = "%.1f" % (death / 60.0)
			downs += 1
		out.append(
			(
				"| %d | %d | %d | %s | %s | %d |"
				% [r.seed, r.launches, r.rocket_hits, down, _hp(hp10), r.dashes]
			)
		)
	var k: int = _sum(rows, "rocket_hits")
	var n: int = _sum(rows, "launches")
	var w: Vector2 = wilson(k, n)
	out.append("")
	out.append(
		(
			"Pooled hits/launches %d/%d = %s (Wilson 95%% [%.1f, %.1f]); down in %d of %d seeds."
			% [k, n, _pct(k, n), w.x, w.y, downs, rows.size()]
		)
	)
	out.append("")
	return out


static func _pct(k: int, n: int) -> String:
	return "n/a" if n <= 0 else "%.1f%%" % (100.0 * k / n)


static func _hp(value: float) -> String:
	return "down" if value < 0.0 else "%.1f" % value
