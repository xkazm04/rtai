class_name HudSee
extends RefCounted
## n8-hud: the HUD's top corners turn see-through when something the player must see sits under
## them (HudState.clear_px: Rivet and the objective's goal, in screen px). Under the angled view
## at 32 px/m the corner panels cover a fifth of the street; quest 1's Dock 9 crate row sat under
## the ammo ticket. A covered corner eases to SEE_A in FADE_S and back when the point leaves.
## SEE false = the opaque corners (today's HUD), one value away. Render only.

const SEE: bool = true
const SEE_A: float = 0.35
const FADE_S: float = 0.2
## How far round a point the panel counts as covering it (screen px at the HUD's scale).
const PAD_PX: float = 40.0


## True when any of `points` lies within PAD_PX of `rect`.
static func covers(rect: Rect2, points: PackedVector2Array) -> bool:
	if not SEE or rect.size == Vector2.ZERO:
		return false
	var grown: Rect2 = rect.grow(PAD_PX)
	for p: Vector2 in points:
		if grown.has_point(p):
			return true
	return false


## The corner's alpha one step of `dt` seconds on from `alpha`, toward SEE_A when covered, else 1.
static func step(alpha: float, covered: bool, dt: float) -> float:
	var target: float = SEE_A if covered else 1.0
	return move_toward(alpha, target, (1.0 - SEE_A) * dt / FADE_S)
