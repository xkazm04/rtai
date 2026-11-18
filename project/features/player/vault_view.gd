class_name VaultView
extends Node
## The feed and shadows keep Rivet's ground point. Only the posed rig's canvas item
## receives the height projection (or the flat camera's scale about his feet).

const ACTIVE: StringName = &"rivet_vault_view"

var _rigs: CharacterRigs
var _vault: PlayerVault


## Feed the arena's current motion, including a missing pilot on a bot-driven tick.
static func feed_motion(rigs: CharacterRigs, motion: PlayerMotion) -> void:
	feed(rigs, motion.vault if motion != null else null)


static func feed(rigs: CharacterRigs, vault: PlayerVault) -> void:
	if vault == null or vault.frame < 0:
		if rigs.has_meta(ACTIVE):
			var last: CutRig = rigs.rig_for(rigs.feed.ids[0])
			if last != null:
				MotionRigPose.place(last, Transform2D.IDENTITY)
			var host: VaultView = rigs.get_meta(ACTIVE)
			host.set_process(false)
			host.queue_free()
			_shadow_origin(rigs, false)
			rigs.remove_meta(ACTIVE)
		return
	var f: RigFeed = rigs.feed
	f.flags[0] = 0
	if not rigs.has_meta(ACTIVE):
		var host: VaultView = VaultView.new()
		host._rigs = rigs
		host._vault = vault
		host.process_priority = 102  # after the depth sort and prop occluders
		rigs.add_child(host)
		rigs.set_meta(ACTIVE, host)
		# A node added during the feed first processes next frame. Pose this takeoff
		# after the current frame's rigs and depth sorter have also finished.
		host._place.call_deferred()
		_shadow_origin(rigs, true)
		f.clip[0] = RigClips.Clip.ROLL
		f.clip_arg[0] = (vault.ticks - vault.frame) * SimClock.TICK_DT


static func projection(vault: PlayerVault, view: ViewMode) -> Transform2D:
	var arc: float = vault.lift()
	var scale_k: float = lerpf(1.0, vault.top_scale, arc) if view.is_flat() else 1.0
	return Transform2D(0.0, Vector2.ONE * scale_k, 0.0, view.lift_px(arc * vault.apex_m))


func _process(_delta: float) -> void:
	_place()


func _place() -> void:
	if is_queued_for_deletion() or _vault.frame < 0:
		return
	var rig: CutRig = _rigs.rig_for(_rigs.feed.ids[0])
	if rig == null:
		return
	# The drawn roll spins about its boot pivot. Holding the tucked cell upright keeps
	# its bottom at the projected feet instead of swinging below the crate at the apex.
	if RivetFrames.drawn(rig) and rig.head_card.frame == RivetFrames.Cell.ROLL:
		rig.head_card.global_rotation = 0.0
	var xf: Transform2D = projection(_vault, ViewMode.shared())
	MotionRigPose.place(rig, xf)
	# Only the tilted cameras sort standing cards in front of bodies.
	if not ViewMode.shared().is_flat() and _vault.airborne():
		rig.z_index = RenderLayers.z(&"roof_occluders") + 1 - _rigs.z_index


## The tucked card's smaller contact rings can lose their triangles at city coordinates
## around 17,000 px. Draw them in takeoff-local coordinates for the vault. The shadow
## renderer converts every caster's world feet with to_local(), preserving their ground points.
static func _shadow_origin(rigs: CharacterRigs, active: bool) -> void:
	if rigs.get_parent() == null:
		return
	for sibling: Node in rigs.get_parent().get_children():
		var shadow: RigCastShadows = sibling as RigCastShadows
		if shadow == null:
			continue
		if active:
			shadow.set_meta(ACTIVE, shadow.position)
			shadow.global_position = rigs.feed.pos[0]
		elif shadow.has_meta(ACTIVE):
			shadow.position = shadow.get_meta(ACTIVE)
			shadow.remove_meta(ACTIVE)
