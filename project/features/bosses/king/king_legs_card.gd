class_name KingLegsCard
extends RefCounted
## d9 seams item 2 (the owner, 2026-11-07: "Legs do have white background, redesign legs of the
## character"). Under a card view the King's 2.0x bust card stood on his old top-down leg parts.
## Where the court has a drawn legs sheet for the live pitch (art/p<pitch>/king_legs.png: the assets
## lane's king_legs, 5 facings x [standing + a 4-frame walk], ink outline only), a legs card stands
## under the bust instead: the bust's facing column and flip, a walk row by the rig's gait phase,
## the bust card's scale, its soles on the rig's ground point; the leg parts hide. No sheet for the
## pitch (70 until king_legs v2; `top` never has a card): the parts draw as before. Render only.

const DIR: String = "res://features/bosses/king/art/p%d/king_legs.png"
const NAME: StringName = &"legs_card"
const COLS: int = 5
const ROWS: int = 5
## The soles' line as a fraction of the cell height from the top (the assets lane's cut: 94 %).
const SOLE_Y: float = 0.94
## Walk frames per gait phase unit (RigGait: one unit = one stride cycle).
const FRAMES_PER_CYCLE: float = 4.0
## How far the bust rises onto the legs, as a share of the legs' cell height (the bust card reaches
## the ground: with 0 the legs stand hidden behind it). The owner's call (REPORT call 1).
const LIFT: float = 0.5
## false: the leg parts as before (it1's default, while the arms stayed at the old height).
const ON: bool = true

static var _tex: Dictionary[String, Texture2D] = {}


## After KingArt.dress: the legs card under the bust card, or the leg parts when there is no sheet.
static func step(rig: CutRig) -> void:
	var card: Sprite2D = rig.head_card
	if card == null:
		return
	var legs: Sprite2D = card.get_parent().get_node_or_null(NodePath(NAME)) as Sprite2D
	var tex: Texture2D = sheet(roundi(ViewMode.shared().art_pitch())) if ON else null
	if tex == null:
		if legs != null and legs.visible:
			legs.visible = false
			show_parts(rig, true)
		return
	if legs == null:
		legs = _make(card)
	if legs.texture != tex:
		legs.texture = tex
		var cell: Vector2 = Vector2(tex.get_width() / float(COLS), tex.get_height() / float(ROWS))
		legs.offset = Vector2(-cell.x * 0.5, -cell.y * SOLE_Y)
	legs.visible = card.visible
	show_parts(rig, false)
	legs.frame = row_of(rig) * COLS + card.frame
	legs.flip_h = card.flip_h
	legs.global_rotation = 0.0
	legs.global_scale = card.global_scale
	var lift: float = legs.texture.get_height() / float(ROWS) * LIFT * legs.global_scale.y
	# The whole upper body rises (the torso carries the head, its card, this legs card and the arm
	# parts; RigTilt sets torso.position fresh each step, so this never accumulates), then the
	# legs are pinned back to the ground point.
	if rig.torso != null:
		rig.torso.global_position -= Vector2(0.0, lift)
	legs.global_position = rig.global_position


## The sheet for a pitch (null: none, the parts draw).
static func sheet(pitch: int) -> Texture2D:
	var path: String = DIR % pitch
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _tex[path]


## 0 standing, else 1-4 along the walk cycle by the rig's gait phase.
static func row_of(rig: CutRig) -> int:
	if rig.speed_now <= 6.0 or rig.dead:  # RigGait's moving threshold
		return 0
	return 1 + posmod(floori(rig.phase * FRAMES_PER_CYCLE), 4)


static func show_parts(rig: CutRig, shown: bool) -> void:
	for side: RigLimbs in rig.sides:
		for spr: Sprite2D in [side.thigh, side.shin, side.foot]:
			if spr != null:
				spr.visible = shown


static func _make(card: Sprite2D) -> Sprite2D:
	var legs: Sprite2D = Sprite2D.new()
	legs.name = NAME
	legs.centered = false
	legs.hframes = COLS
	legs.vframes = ROWS
	legs.z_index = card.z_index - 1  # under the bust's hem
	card.get_parent().add_child(legs)
	return legs
