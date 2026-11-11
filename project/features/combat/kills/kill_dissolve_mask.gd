class_name KillDissolveMask
extends RefCounted
## The ray gun dissolve's clip mask (n16 kills-polish, split out of KillDissolveFx): an ellipse
## fitted to the drawn figure, which KillDissolveFx.pose() shrinks as the rings eat the body.

const MASK_PX: int = 64
## The mask ellipse's semi-axes over the drawn figure's half-extent: it holds the head, the feet
## and the arms (a rect's corners are empty air on a figure, so less than sqrt 2).
const FIT: float = 1.12
## The root's meta: Rect2(centre, semi-axes) of the mask ellipse in the root's local pixels.
const ELL: StringName = &"dissolve_ell"

static var _disc: ImageTexture = null


## The body group under an elliptic clip mask fitted to the drawn figure (n16 kills-polish: a disc
## on the group's origin, the hips, held only an upright card's legs). `view_ppm` sizes a body
## with no sprites.
static func wrap(body: Node2D, view_ppm: float = 32.0) -> Node2D:
	var root: Node2D = Node2D.new()
	root.name = body.name
	var mask: Sprite2D = Sprite2D.new()
	mask.texture = _disc_texture()
	mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	mask.name = "mask"
	root.add_child(mask)
	body.position = Vector2.ZERO
	KillSplitFx.flatten(body)
	mask.add_child(body)
	root.set_meta(ELL, fit(body, view_ppm))
	return root


## Rect2(centre, semi-axes) of the ellipse holding `body`'s sprites (its local pixels).
static func fit(body: Node2D, view_ppm: float) -> Rect2:
	var box: Rect2 = Rect2()
	var any: bool = false
	for ch: Node in body.get_children():
		if not ch is Sprite2D or (ch as Sprite2D).texture == null:
			continue
		var spr: Sprite2D = ch as Sprite2D
		var r: Rect2 = spr.transform * spr.get_rect()
		box = box.merge(r) if any else r
		any = true
	if not any:
		return Rect2(Vector2.ZERO, Vector2.ONE * KillDissolveFx.BODY_R_M * view_ppm)
	return Rect2(box.get_center(), box.size * 0.5 * FIT)


static func _disc_texture() -> ImageTexture:
	if _disc != null:
		return _disc
	var img: Image = Image.create(MASK_PX, MASK_PX, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 1.0, 1.0, 0.0))
	var c: Vector2 = Vector2.ONE * (MASK_PX * 0.5 - 0.5)
	for y: int in MASK_PX:
		for x: int in MASK_PX:
			if Vector2(x, y).distance_to(c) < MASK_PX * 0.5 - 0.5:
				img.set_pixel(x, y, Color.WHITE)
	_disc = ImageTexture.create_from_image(img)
	return _disc


## The mask ellipse wrap() fitted, in `root`'s local pixels (no fit: a disc of `r`).
static func ell_of(root: Node2D, r: float) -> Rect2:
	var v: Variant = root.get_meta(ELL) if root.has_meta(ELL) else null
	if not v is Rect2:
		return Rect2(Vector2.ZERO, Vector2.ONE * r)
	var e: Rect2 = v
	return e
