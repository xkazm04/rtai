class_name KingLegsCard
extends RefCounted
## d9 seams item 2 (the owner, 2026-11-07: "Legs do have white background, redesign legs of the
## character"). Under a card view the King's 2.0x bust card stood on his old top-down leg parts.
## Where the court has a drawn legs sheet for the live pitch (art/p<pitch>/king_legs.png: the assets
## lane's king_legs, 5 facings x [standing + a 4-frame walk], ink outline only), a legs card stands
## under the bust instead: the bust's facing column and flip, a walk row by the rig's gait phase,
## the bust card's scale, its soles on the rig's ground point; the leg parts hide. No sheet for the
## pitch (`top` never has a card): the parts draw as before. Render only. it3: 70 from
## king_legs_70_v3 (A: no hip ring, the thigh tops start under the hem), 55 from king_legs_55_v2
## (A: the profile strides).

const DIR: String = "res://features/bosses/king/art/p%d/%s.png"
const NAME: StringName = &"legs_card"
const COLS: int = 5
const ROWS: int = 5
## The soles' line as a fraction of the cell height from the top (the assets lane's cut: 94 %).
const SOLE_Y: float = 0.94
## Walk frames per gait phase unit (RigGait: one unit = one stride cycle).
const FRAMES_PER_CYCLE: float = 4.0
## Ground travel per drawn walk cycle, in legs-cell px, per art pitch: the profile column's two
## heel-to-heel steps (measured it10: 55 contact rows 180/173 px wide, a foot 64 -> 2 x 116; 70
## 95/92, a foot ~55 -> 2 x 40). The walk row follows the distance walked over this, so a planted
## boot keeps pace with the ground. it2-it9 stepped by the gait phase: the King's gait cycle is
## 64 world px, the 55 sheet's 125 at his card scale, so his boots skated at twice the ground speed.
## A pitch not listed steps by the gait phase.
const CYCLE_CELL: Dictionary[int, float] = {55: 232.0, 70: 80.0}
const META_PH: StringName = &"legs_walk_phase"
const META_AT: StringName = &"legs_walk_at"
## How far the bust rises onto the legs, as a share of the legs' cell height (the bust card reaches
## the ground: with 0 the legs stand hidden behind it), per art pitch. The owner's call (REPORT
## call 1).
## 70's legs are drawn foreshortened (cells 246 x 76): the hem overlaps their top ~20 %.
const LIFT: Dictionary[int, float] = {55: 0.5, 70: 0.74}
## false: the leg parts as before (it1's default, while the arms stayed at the old height).
const ON: bool = true
## Whose bust stands on drawn legs, and which sheet (art/p<pitch>/<sheet>.png); an art_dir not
## here keeps its leg parts. it10: the gang's bodyguards stand on the King's sheet too (it was so
## by accident since it2: KingArt.dress runs for every court rig); on their own gang_parts legs
## they sprawl grey top-down limbs with a pale rim under the upright bust (filmed phase 1, combo,
## 32 and 64 px/m). it11: their own steel sheet (assets gang_legs_55/70, the King's layout,
## hip and sole lines); "king_legs" puts them back on his, drop "gang" for the parts. n9 world (the
## owner's s-1 C): the King walks under his long drawn robe (assets king_robe_55 / _70_v2, the legs'
## layout cell for cell, packed by tools/art/king_robe.py on the legs' scale and sole line); the
## hem swings with the stride rows, the boots show at its front. "king_legs" = the bare d9 legs.
const SHEETS: Dictionary[String, String] = {"king": "king_robe", "gang": "gang_legs"}

static var _tex: Dictionary[String, Texture2D] = {}


## After KingArt.dress: the legs card under the bust card, or the leg parts when there is no sheet.
static func step(rig: CutRig) -> void:
	var card: Sprite2D = rig.head_card
	if card == null or rig.plan == null or not SHEETS.has(rig.plan.art_dir):
		return
	var legs: Sprite2D = card.get_parent().get_node_or_null(NodePath(NAME)) as Sprite2D
	var pitch: int = roundi(ViewMode.shared().art_pitch())
	var tex: Texture2D = sheet(pitch, SHEETS[rig.plan.art_dir]) if ON else null
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
	legs.flip_h = card.flip_h
	legs.global_rotation = 0.0
	legs.global_scale = card.global_scale
	var cycle: float = CYCLE_CELL.get(pitch, 0.0)
	legs.frame = walk_row(rig, legs, cycle * legs.global_scale.x) * COLS + card.frame
	var cell_h: float = legs.texture.get_height() / float(ROWS)
	var lift: float = cell_h * LIFT.get(pitch, 0.5) * legs.global_scale.y
	# The whole upper body rises (the torso carries the head, its card, this legs card and the arm
	# parts; RigTilt sets torso.position fresh each step, so this never accumulates), then the
	# legs are pinned back to the ground point.
	if rig.torso != null:
		rig.torso.global_position -= Vector2(0.0, lift)
	legs.global_position = rig.global_position


## The sheet for a pitch (null: none, the parts draw).
static func sheet(pitch: int, sheet_name: String = "king_legs") -> Texture2D:
	var path: String = DIR % [pitch, sheet_name]
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _tex[path]


## 0 standing, else 1-4 along the walk cycle by the ground walked since the last call (`cycle`:
## world px per drawn cycle; 0 = by the gait phase). The legs card keeps its own phase.
static func walk_row(rig: CutRig, legs: Node, cycle: float) -> int:
	var at: Vector2 = legs.get_meta(META_AT, rig.global_position)
	legs.set_meta(META_AT, rig.global_position)
	if cycle <= 0.0:
		return row_of(rig)
	var ph: float = legs.get_meta(META_PH, 0.0)
	ph = fposmod(ph + rig.global_position.distance_to(at) / cycle, 1.0)
	legs.set_meta(META_PH, ph)
	if rig.speed_now <= 6.0 or rig.dead:  # RigGait's moving threshold
		return 0
	return 1 + mini(floori(ph * 4.0), 3)


## 0 standing, else 1-4 along the walk cycle by the rig's gait phase.
static func row_of(rig: CutRig) -> int:
	if rig.speed_now <= 6.0 or rig.dead:  # RigGait's moving threshold
		return 0
	return 1 + posmod(floori(rig.phase * FRAMES_PER_CYCLE), 4)


## The leg parts and the pelvis (it3: the pelvis stays at ground height while the torso rises, so
## under the lifted bust it showed as a rimmed disc between the drawn boots).
static func show_parts(rig: CutRig, shown: bool) -> void:
	if rig.pelvis_spr != null:
		rig.pelvis_spr.visible = shown
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
