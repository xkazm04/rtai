class_name PlayerGuardPose
extends Sprite2D
## Four painted phases, each with five facings from front to back. The sprite shares the
## standing card's foot anchor. The card continues to pose underneath for the release.

enum Phase { REST = -1, LOW, MID, HELD, STAGGER }

const CHILD: NodePath = ^"guard_pose"
const STRIP: String = "rivet_guard.png"
const PHASES: int = 4

var _art: String
var _px: float


static func apply(card: Sprite2D, art: String, phase: Phase, octant: int) -> void:
	var pose: PlayerGuardPose = card.get_node_or_null(CHILD) as PlayerGuardPose
	if phase == Phase.REST or art not in ["p55", "p70"]:
		if pose != null and pose.visible:
			if card.self_modulate.a == 0.0:
				card.self_modulate.a = pose.self_modulate.a
			pose.hide()
		return
	if pose == null:
		pose = PlayerGuardPose.new()
		pose.name = CHILD.get_name(0)
		pose.centered = false
		pose.use_parent_material = true
		pose.hide()
		card.add_child(pose)
	if pose._art != art:
		pose._set_strip(art)
	# The combo pitch mixer can write a fresh card alpha between consecutive guard frames.
	if not pose.visible or card.self_modulate.a != 0.0:
		pose.self_modulate = card.self_modulate
		card.self_modulate.a = 0.0
	pose.show()
	pose.frame = phase * RigHeadCard.FRAMES + RigHeadCard.OCT_FRAME[octant]
	pose.flip_h = RigHeadCard.OCT_FLIP[octant] == 1
	var size_k: float = pose._px * RivetFrames.height_k * PlayerScale.k()
	pose.global_transform = Transform2D(0.0, Vector2.ONE * size_k, 0.0, card.global_position)


func _set_strip(art: String) -> void:
	_art = art
	var path: String = RivetStrips.DIR.path_join(art).path_join(STRIP)
	texture = StreetStrips.get_tex(path)
	hframes = PHASES * RigHeadCard.FRAMES
	var cell_width: float = texture.get_width() / float(hframes)
	offset = Vector2(-cell_width * 0.5, RivetStrips.foot_px(path) - texture.get_height())
	var height: float = RivetFrames.HEIGHT_BY_ART.get(art, RivetFrames.HEIGHT_M)
	_px = height * CharacterRigs.PX_PER_M / (RivetFrames.FIG_PX * RivetRes.of(path))
