class_name CardContactShadow
extends Node2D
## n31 ground: the one contact shadow a whole-sprite foe card (gunner, thug, turret, door carrier)
## draws under its soles: RigCastShadows' soft ink ellipse and rings, placed on the fighter's ground
## point (the sim position, in the card's parent px), never on the card's transform, so the
## drawing's bounce and placement steps leave it on the ground. A child of the card drawn behind it.

## Radius in drawn cell widths: the card's cell (texture / hframes) times its scale.
const WIDTH_SHARE: float = 0.16
## Never smaller than the patrol's contact under a 0.8 m hip (RigCastShadows.CONTACT_R_HIPS): a
## narrow-scaled sheet (the gunner's) would otherwise get a dot under a full-size body.
const FLOOR_HIP_M: float = 0.8

var radius: float = 0.0


## A new shadow behind `card` (its child).
static func mount(card: Sprite2D) -> CardContactShadow:
	var s: CardContactShadow = CardContactShadow.new()
	s.show_behind_parent = true
	card.add_child(s)
	return s


## The contact radius (parent px) under `card` as drawn now: WIDTH_SHARE of its cell width, floored.
static func radius_of(card: Sprite2D) -> float:
	if card.texture == null:
		return 0.0
	var cell_w: float = card.texture.get_width() / float(maxi(card.hframes, 1))
	var floor_r: float = RigCastShadows.CONTACT_R_HIPS * FLOOR_HIP_M * SimConst.PX_PER_M
	return maxf(cell_w * absf(card.scale.x) * WIDTH_SHARE, floor_r)


## After the card has posed this tick: the shadow on `ground` (the card's parent px), upright and
## unscaled in that space whatever the card's transform; shown only when the view casts shadows.
func follow(card: Sprite2D, ground: Vector2) -> void:
	visible = ViewMode.shared().cast_k > 0.0
	transform = card.transform.affine_inverse() * Transform2D(0.0, ground)
	var r: float = radius_of(card)
	if not is_equal_approx(r, radius):
		radius = r
		queue_redraw()


func _draw() -> void:
	for ring: Vector2 in RigCastShadows.CONTACT_RINGS:
		draw_colored_polygon(
			RigCastShadows.contact_ellipse(Vector2.ZERO, radius * ring.x),
			Color(RigCastShadows.SHADOW, ring.y)
		)
