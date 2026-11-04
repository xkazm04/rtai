class_name HeldFeedLine
extends RefCounted
## n5-look: the line from the part on Rivet's back to the weapon in his claws (RivetHeldView):
## the flamethrower's hose (an ink line with a cream core) or the gatling's ammo belt (a wider ink
## edge round a brass core cut into links, so it reads as rounds, not a hose). Render only.

## The shell brass (gun_fx.json palette.casing; red is blood only).
const BRASS: Color = Color("b8913f")
## One link of the belt along the line (px), the dark seam between links.
const LINK_PX: int = 7
const SEAM_PX: int = 2
const HOSE: Array[Vector2] = [Vector2(3.2, 0.0), Vector2(1.4, 1.0)]  # width, ink (0) or core (1)
const BELT: Array[Vector2] = [Vector2(6.0, 0.0), Vector2(4.0, 1.0)]

static var _links_tex: ImageTexture = null


## The lines (ink edge first) under `owner`, styled as a hose or as a belt.
static func make(owner: Node2D, belt: bool) -> Array[Line2D]:
	var out: Array[Line2D] = []
	for spec: Vector2 in BELT if belt else HOSE:
		var line: Line2D = Line2D.new()
		line.width = spec.x
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		line.z_index = 1
		line.default_color = RivetMagView.INK
		if spec.y > 0.5:
			line.default_color = BRASS if belt else RivetMagView.SHINE
		if spec.y > 0.5 and belt:
			line.texture = _links()
			line.texture_mode = Line2D.LINE_TEXTURE_TILE
			line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		owner.add_child(line)
		out.append(line)
	return out


## White links with dark seams: the line's brass colour tints the white.
static func _links() -> ImageTexture:
	if _links_tex == null:
		var img: Image = Image.create(LINK_PX + SEAM_PX, 4, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		img.fill_rect(Rect2i(LINK_PX, 0, SEAM_PX, 4), Color(0.25, 0.2, 0.18))
		_links_tex = ImageTexture.create_from_image(img)
	return _links_tex
