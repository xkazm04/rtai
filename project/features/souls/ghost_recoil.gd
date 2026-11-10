class_name GhostRecoil
extends RefCounted
## n11 hero it17: a drawn ghost leans back off its feet when it is hit, so the 10-tick HIT cell
## carries a jolt and not only a pose change. The lean is in screen space about the feet (the
## sprite's origin), away from the drawn facing's screen x; a toward or away facing leans none
## (the cell carries those). Peaks on the hit tick and eases out over GhostDrawn.HIT_TICKS.
## Render only. LEAN_DEG 0 turns it off.

const LEAN_DEG: float = 12.0
## Per form, where the drawn HIT cell already tips: Tonnage's tips about 20 deg, and the full lean
## stacked with it to about 30 (owner call h-5, 2026-11-10: keep the lean, lower Tonnage only).
const LEAN_BY_FORM: Dictionary[String, float] = {"tonnage": 4.0}


## The lean in degrees for a form's card name.
static func lean_of(form: String) -> float:
	return float(LEAN_BY_FORM.get(form, LEAN_DEG))


## The sprite's screen rotation (rad) `since` ticks after a hit (-1 = never hit), facing `look`.
static func tilt(since: int, look: float, lean_deg: float = LEAN_DEG) -> float:
	if since < 0 or since >= GhostDrawn.HIT_TICKS or is_nan(look):
		return 0.0
	var k: float = 1.0 - float(since) / float(GhostDrawn.HIT_TICKS)
	return -cos(look) * deg_to_rad(lean_deg) * k * k
