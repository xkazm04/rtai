class_name ContactInk
extends RefCounted
## n31 contact ink: the nested ellipses of every character contact shadow
## (RigCastShadows.CONTACT_RINGS, so the card foes, the crowd and the kill cells too), as
## (radius share, alpha) printed over one another. The body hides the middle, so the player sees
## the rim below the soles: it darkens in small steps from an outer ring at 0.08 (no disc edge)
## to about 0.70 effective alpha in the core.
## Before: (1.0, 0.22), (0.78, 0.24), (0.55, 0.3): about 0.26 at the core, 0.22 at the rim.
const RINGS: Array[Vector2] = [
	Vector2(1.25, 0.08),
	Vector2(1.12, 0.109),
	Vector2(1.0, 0.146),
	Vector2(0.88, 0.171),
	Vector2(0.76, 0.172),
	Vector2(0.64, 0.167),
	Vector2(0.5, 0.15),
	Vector2(0.35, 0.118),
]
