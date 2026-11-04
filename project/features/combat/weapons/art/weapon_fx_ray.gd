class_name WeaponFxRay
extends RefCounted
## weapon-art's ray gun round: a train of paper hoops (the `ray_ring` cells) strung back along the
## beam from its head, each squashed along the travel so it reads as a ring flying edge-on, the
## rings widening and fading toward the tail. Until iteration 8 the ray gun (a BOLT row) drew the
## electro gun's lightning cells, so its ring art was never seen. Render only: reads the shot.

## Rings per round, their spacing along the beam (m) and their squash along the travel.
const RINGS: int = 4
const GAP_M: float = 0.9
const SQUASH: float = 0.42
## Each ring further back draws this much wider and this much fainter.
const GROW: float = 0.18
const FADE: float = 0.2


## Draws the ring train with its head at `at` (m) flying along `dir`; `went` = metres flown.
static func draw_round(ci: CanvasItem, at: Vector2, dir: Vector2, went: float, tick: int) -> void:
	var ang: float = dir.angle()
	for k: int in RINGS:
		var back: float = GAP_M * float(k)
		if back > went - WeaponFxArt.CLEAR_M:
			break
		var size: float = 1.0 + GROW * float(k)
		var frame: int = mini(k, 2) if tick % 2 == 0 else mini(k + 1, 2)
		WeaponFxArt.draw_cell(
			ci,
			&"ray_ring",
			frame,
			at - dir * back,
			ang,
			Vector2(SQUASH, 1.0) * size,
			1.0 - FADE * float(k)
		)
