class_name MotionRigPose
extends RefCounted
## Last movement-specific poses on the ordinary rig feed. The sim and depth sorter keep the feet.

static var _missing: Dictionary[String, bool] = {}


## Project the canvas item about its own ground pivot, after the pose and depth sort.
static func place(rig: Node2D, projection: Transform2D) -> void:
	var draw: Transform2D = rig.transform.scaled_local(projection.get_scale())
	draw.origin += projection.origin
	RenderingServer.canvas_item_set_transform(rig.get_canvas_item(), draw)


## The views publish before the rig is driven. A release clears only its own phase.
static func publish(rigs: CharacterRigs, channel: StringName, pose: StringName) -> void:
	var rig: CutRig = rigs.rig_for(rigs.feed.ids[0]) if rigs.feed.count > 0 else null
	if rig == null:
		return
	var selected: MoveCells = null
	if rig.has_meta(MoveCells.ACTIVE):
		selected = rig.get_meta(MoveCells.ACTIVE)
	elif pose == &"":
		return
	var view: ViewMode = ViewMode.shared()
	var art: String = "" if view.is_flat() else view.art
	var path: String = strip_for(pose, art) if not rigs.feed.has_flag(0, RigFeed.Flag.DEAD) else ""
	if path == "" or (rig.react != null and rig.react.dying):
		if selected != null and selected.owner == channel:
			rig.remove_meta(MoveCells.ACTIVE)
		return
	if selected == null:
		selected = MoveCells.new()
		rig.set_meta(MoveCells.ACTIVE, selected)
	selected.owner = channel
	selected.art = art
	selected.path = path
	selected.resolution = RivetRes.of(RivetStrips.DIR + art + "/" + RivetStrips.BASE)
	selected.foot_y = (RivetFrames.FIG_PX + RivetFrames.PAD_PX) * selected.resolution
	var octant: int = posmod(roundi(rigs.feed.face[0] / (PI * 0.25)), 8)
	selected.frame = MoveCells.frame_of(pose, RivetFrames.LEFT[octant] == 1)
	var height: float = RivetFrames.HEIGHT_BY_ART.get(art, RivetFrames.HEIGHT_M)
	var h_px: float = height * RivetFrames.height_k * PlayerScale.k() * CharacterRigs.PX_PER_M
	var k: float = RigTilt.hip_h(rig) / rig.plan.hip_z
	if channel == MoveCells.VAULT:
		k = RivetFrames.ROLL_SHADOW
	rig.set_meta(RigCastShadows.CAST_HIP, h_px * k / RigCastShadows.BODY_IN_HIPS)


static func strip_for(pose: StringName, art: String) -> String:
	if pose == &"" or art.is_empty():
		return ""
	var density: float = RivetRes.of(RivetStrips.DIR + art + "/" + RivetStrips.BASE)
	var path: String = MoveCells.strip(art, density)
	if RivetStrips.has_file(path):
		return path
	if art in ["p55", "p70"] and not _missing.has(path):
		_missing[path] = true
		Log.warn("move-cells", "missing %s, using the stand-in pose" % path)
	return ""
