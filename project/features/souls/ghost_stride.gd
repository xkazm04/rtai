class_name GhostStride
extends RefCounted
## n11 hero it12: a drawn walk's frame by the ground walked, timed by its measured strides.
## `steps[i]`: the stance foot's drawn travel from frame i to i + 1 (cell px, the profile row).
## Frame i shows from half of step i - 1 before it to half of step i after, so the foot is drawn
## where the ground is; even steps are the even cycle. A frame's share is floored at MIN_SHARE of
## the mean so a near-still pair of frames still shows. No table: the even cycle.

const MIN_SHARE: float = 0.4
## Each drawn walk's measured stride, "<name>/<art>": the profile row's stance travel a frame
## (contact centres, tools foot_travel.py; a foot switch takes the mean). No entry: the even cycle.
const TABLES: Dictionary[String, Array] = {
	"ohm/p70": [0.0, 47.7, 6.8, 17.2, 29.0, 12.5, 7.0, 17.2],
	"tonnage/p70": [47.0, 14.0, 58.5, 29.4, 25.0, 31.5, 29.4, 0.5],
}

## Run rows ("<name>/<art>", 0 = toward) drawn as a gallop (both halves lead with one leg): that
## facing walks at the cadence cap instead. Dent's 3/4 away run row failed three redraws (it13).
const RUN_ROWS_OFF: Dictionary[String, Array] = {"dent/p70": [3]}


## True when `name`'s run grid under `art` may show on the drawn row `row`.
static func runs(name: String, art: String, row: int) -> bool:
	var off: Array = RUN_ROWS_OFF.get(name + "/" + art, [])
	return not off.has(row)


## The table of `name`'s walk under the art key `art`, empty for the even cycle.
static func table_of(name: String, art: String) -> PackedFloat32Array:
	var row: Array = TABLES.get(name + "/" + art, [])
	return PackedFloat32Array(row)


## The column at `phase` (0..1 of a cycle).
static func col_of(phase: float, steps: PackedFloat32Array) -> int:
	var n: int = steps.size()
	if n == 0:
		return mini(int(phase * 8.0), 7)
	var dwell: PackedFloat32Array = dwell_of(steps)
	var total: float = 0.0
	for d: float in dwell:
		total += d
	var at: float = fposmod(phase, 1.0) * total
	for i: int in n:
		at -= dwell[i]
		if at < 0.0:
			return i
	return n - 1


## Each frame's share of the cycle: half the step into it plus half the step out of it, floored.
static func dwell_of(steps: PackedFloat32Array) -> PackedFloat32Array:
	var n: int = steps.size()
	var mean: float = 0.0
	for d: float in steps:
		mean += d / n
	var out: PackedFloat32Array = PackedFloat32Array()
	@warning_ignore("return_value_discarded")
	out.resize(n)
	for i: int in n:
		out[i] = maxf((steps[posmod(i - 1, n)] + steps[i]) * 0.5, mean * MIN_SHARE)
	return out
