class_name KillFallCells
extends RefCounted
## The drawn fall of an n16 death (lane kills-new), render only: under a card view the victim is
## one drawn street card, so the death's body copy also carries the person's own drawn fall grid
## (StreetWalkerFall: buckle, mid-fall, lying; the between rows where a kind has them), hidden,
## facing the way the row makes him fall. KillNewStyles shows it from the row's `cells_at` tick
## and steps its frames over `cells_ticks` (row fx): the existing drawings play the fall until
## the death's own drawn cells land. No card (a parts rig, a headless run) = no grid.

const META: StringName = &"kill_fall_cells"


## Adds the hidden fall grid to `body` (the BODY group, still at its centroid `body.position`,
## in the rig parent's px relative to the rig) facing `toward` (world, unit). Returns it or null.
static func attach(rig: CutRig, body: Node2D, toward: Vector2) -> Sprite2D:
	if rig == null or body == null or not StreetWalkerCards.hides_parts(rig):
		return null
	var art: String = ViewMode.shared().art
	var path: String = StreetWalkerFall.path_of(art, StreetWalkerCards.row_of(rig))
	if path.is_empty():
		return null
	var tex: Texture2D = StreetStrips.get_tex(StreetWalkerCards.DIR + path)
	if tex == null:
		return null
	var c: Sprite2D = Sprite2D.new()
	c.name = "fall_cells"
	c.texture = tex
	c.hframes = RigHeadCard.FRAMES
	c.vframes = StreetFallBetween.rows_of(path)
	c.centered = true  # the fall grids draw the feet at the cell centre
	face(c, toward.angle())
	c.scale = Vector2.ONE * _scale(rig, path)
	c.position = feet_of(rig, body)
	c.material = rig.head_card.material
	c.z_index = rig.head_card.z_index
	c.visible = false
	body.add_child(c)
	body.set_meta(META, c)
	return c


## The grid a body copy carries (null = none).
static func of(body: Node) -> Sprite2D:
	if body == null or not body.has_meta(META):
		return null
	var c: Variant = body.get_meta(META)
	return c if c is Sprite2D else null


## The frame row for the fall's progress `u` (0..1), as StreetWalkerFall steps a dying card.
static func row_at(cells: Sprite2D, u: float) -> int:
	return StreetWalkerFall.fall_frame(clampf(u, 0.0, 1.0), cells.vframes)


## StreetWalkerFall.draw's size: the art's standing height at the still strip's px per metre,
## times the person's crowd scale.
static func _scale(rig: CutRig, path: String) -> float:
	var art: String = path.get_slice("/", 0)
	var h: float = StreetWalkerCards.HEIGHT_BY_ART.get(art, StreetWalkerCards.HEIGHT_M)
	var k: float = 1.0 + StreetCrowdCards.SCALE_VAR * StreetCrowdCards.vary(rig.actor_id, 3)
	return h * CharacterRigs.PX_PER_M * k / StreetWalkerFall.STILL_PX


## The victim's standing height on the street (px at `ppm`): the view art's figure height times
## his crowd scale (StreetWalkerCards), the length a card victim's drawn figure stands.
static func height_px(rig: CutRig, ppm: float) -> float:
	var art: String = ViewMode.shared().art
	var h: float = StreetWalkerCards.HEIGHT_BY_ART.get(art, StreetWalkerCards.HEIGHT_M)
	var k: float = 1.0 + StreetCrowdCards.SCALE_VAR * StreetCrowdCards.vary(rig.actor_id, 3)
	return h * ppm * k


## The drawn figure's feet in `body` (the BODY group at its centroid, before the wrap): the copy
## of his street card stands on its own origin, which a living hit shoves off the rig's
## (StreetWalkerHit.shove); no card copy = the rig's origin.
static func feet_of(rig: CutRig, body: Node2D) -> Vector2:
	if rig != null and rig.head_card != null:
		for ch: Node in body.get_children():
			if ch is Sprite2D and ch.name == rig.head_card.name:
				return (ch as Sprite2D).position
	return -body.position


## Turns the grid to the facing whose fall points along `angle` (world rad), as a dying card does.
static func face(cells: Sprite2D, angle: float) -> void:
	var oct: Vector2i = RigHeadCard.frame_of(angle)
	cells.frame_coords = Vector2i(oct.x, cells.frame_coords.y)
	cells.flip_h = oct.y == 1
