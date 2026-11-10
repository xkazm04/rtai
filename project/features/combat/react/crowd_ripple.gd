class_name CrowdRipple
extends RefCounted
## n12 E3 (crowd panic ripple): the sim scares everyone within 9 m of a bang on one tick, and a
## death startled everyone within CrowdReact.STARTLE_M on one frame, so a crowd ducked as one. Here
## each person's cower waits for the news to reach them: `ticks_from(dist)` = dist / `mps` at 60
## ticks a second, at most `max_ticks`, so the duck runs outward from the bang like a wave. Render
## only: it delays a pose CrowdReact already plays; the sim's flight is untouched, no RNG.
## The bangs are the host's (ArenaRigs: the fight's live rounds' muzzles and its blasts); with none
## (the riot) a flight's cower keeps CrowdReact.DELAY_TICKS. human_reactions.json crowd_ripple;
## mps 0, no row or --feel=off = the before (every cower on one tick).

const TICKS_PER_S: float = 60.0

var mps: float = 0.0
var max_ticks: int = 0
## World px of this frame's bangs (the host refills it).
var bangs: PackedVector2Array = PackedVector2Array()


static func shipped() -> CrowdRipple:
	var r: CrowdRipple = CrowdRipple.new()
	var v: Vector2 = ReactTable.crowd_ripple()
	r.mps = v.x
	r.max_ticks = int(v.y)
	return r


func on() -> bool:
	return mps > 0.0 and max_ticks > 0


## The wait (ticks) of a person `dist_px` from the bang; 0 when off.
func ticks_from(dist_px: float) -> int:
	if not on():
		return 0
	var t: float = dist_px / SimConst.PX_PER_M / mps * TICKS_PER_S
	return mini(max_ticks, roundi(t))


## The wait of a person at `at_px` from the nearest of this frame's bangs (0 with none).
func ticks_to(at_px: Vector2) -> int:
	if not on() or bangs.is_empty():
		return 0
	var best: float = INF
	for b: Vector2 in bangs:
		best = minf(best, at_px.distance_squared_to(b))
	return ticks_from(sqrt(best))


## The fight's bangs this frame (world px): each live round's muzzle (where it is now when it
## carries none: quest 1's rounds, one tick out of the muzzle, as CityScare reads them) and each
## live blast.
static func bangs_of(arena: CombatArena) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	if arena == null:
		return out
	for s: Shot in arena.shots:
		var at: Vector2 = s.origin if s.origin != Vector2.ZERO else s.pos
		@warning_ignore("return_value_discarded")
		out.push_back(at * SimConst.PX_PER_M)
	if arena.areas != null:
		for b: Vector3 in arena.areas.blasts:
			@warning_ignore("return_value_discarded")
			out.push_back(Vector2(b.x, b.y) * SimConst.PX_PER_M)
	return out
