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
	for id: String in ["guard6", "blade6", "blade6_spaced"]:
		out.append_array(_near(id, _of(rows, id)))
	out.append_array(_contrast(_of(rows, "blade6"), _of(rows, "blade6_spaced")))
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
	var sword: bool = id.begins_with("blade6")
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
	var line: String = "Pooled share %s, Wilson 95%% [%.1f, %.1f]" % [_pct(k, n), w.x, w.y]
	if CURVE.has(id):
		var curve: float = CURVE[id]
		var inside: bool = n > 0 and curve >= w.x and curve <= w.y
		line += (
			"; the curve's %.1f%% lies %s the interval" % [curve, "inside" if inside else "OUTSIDE"]
		)
	out.append(line + ".")
	out.append("")
	return out


## The two sword takes side by side: how often a return hits a shooter, and how many fired rounds
## the sword turns back at all.
static func _contrast(shipped: Array[Dictionary], spaced: Array[Dictionary]) -> Array[String]:
	var out: Array[String] = [
		"## Sword cadence contrast (blade6 against blade6_spaced)",
		"",
		(
			"| take | fired | returned | struck | (a) returns that hit a shooter | Wilson 95% "
			+ "| (b) fired rounds turned back | Wilson 95% | no deflect, mid-swing |"
		),
		"|---|---:|---:|---:|---:|---|---:|---|---:|",
	]
	for pair: Array in [["blade6", shipped], ["blade6_spaced", spaced]]:
		var rows: Array[Dictionary] = pair[1]
		var fired: int = _sum(rows, "fired")
		var back: int = _sum(rows, "returned")
		var hit: int = _sum(rows, "struck")
		var wa: Vector2 = wilson(hit, back)
		var wb: Vector2 = wilson(back, fired)
		var cells: Array = [pair[0], fired, back, hit, _pct(hit, back)]
		cells.append_array(["[%.1f, %.1f]" % [wa.x, wa.y], _pct(back, fired)])
		cells.append_array(["[%.1f, %.1f]" % [wb.x, wb.y], _sum(rows, "fate_unswung_while_busy")])
		out.append("| " + " | ".join(cells.map(str)) + " |")
	out.append("")
	return out


static func _rule(head: String) -> String:
	return "|" + "---:|".repeat(head.count("|") - 1)


static func _pair(id: String, rows: Array[Dictionary]) -> Array[String]:
	var out: Array[String] = [
		"## %s" % id,
		"",
		"| seed | rockets | direct | splash | other | HP lost | down at (s) | HP at 10 s | dashes |",
		"|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
	]
	var downs: int = 0
	var lost: Array[float] = []
	for r: Dictionary in rows:
		if not r.opened:
			out.append("| %d | did not open | | | | | | | |" % r.seed)
			continue
		var down: String = "alive"
		var death: int = r.death_tick
		if death > 0:
			down = "%.1f" % (death / 60.0)
			downs += 1
		var taken: float = r.hp_lost
		var hp10: float = r.hp_at_10s
		lost.append(taken)
		var cells: Array = [r.seed, r.launches, r.direct, r.splash, r.other, "%.1f" % taken]
		cells.append_array([down, _hp(hp10), r.dashes])
		out.append("| " + " | ".join(cells.map(str)) + " |")
	out.append_array(_pair_pooled(rows, lost, downs))
	return out


static func _pair_pooled(rows: Array[Dictionary], lost: Array[float], downs: int) -> Array[String]:
	var n: int = _sum(rows, "launches")
	var k: int = _sum(rows, "direct")
	var w: Vector2 = wilson(k, n)
	var s: int = _sum(rows, "splash")
	var ws: Vector2 = wilson(s, n)
	lost.sort()
	@warning_ignore("integer_division")
	var half: int = lost.size() / 2
	var middle: float = (lost[half] + lost[maxi(half - 1 + lost.size() % 2, 0)]) / 2.0
	return [
		"",
		(
			"Pooled direct/rockets %d/%d = %s (Wilson 95%% [%.1f, %.1f]); other %d."
			% [k, n, _pct(k, n), w.x, w.y, _sum(rows, "other")]
		),
		(
			"Pooled splash/rockets %d/%d = %s (Wilson 95%% [%.1f, %.1f])."
			% [s, n, _pct(s, n), ws.x, ws.y]
		),
		(
			"HP lost median %.1f per seed (max %.1f); down in %d of %d seeds."
			% [middle, lost[-1], downs, rows.size()]
		),
		"",
	]


static func _pct(k: int, n: int) -> String:
	return "n/a" if n <= 0 else "%.1f%%" % (100.0 * k / n)


static func _hp(value: float) -> String:
	return "down" if value < 0.0 else "%.1f" % value
