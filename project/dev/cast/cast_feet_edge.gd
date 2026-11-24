class_name CastFeetEdge
extends RefCounted
## Frozen live, raw and empty exposures of the subject card at 64 px/m (cast_foe_edge.py).


static func shoot(view: Node, scene: Node, host: ArenaRigs, h: Fighter, out: String) -> bool:
	var rig: CutRig = host.rigs.rig_for(h.id)
	if rig == null or rig.head_card == null:
		return true
	var card: Sprite2D = rig.head_card
	var folder: String = out.path_join(
		"edge_%s_%d" % [h.archetype, int(ViewMode.shared().pitch_deg)]
	)
	if DirAccess.make_dir_recursive_absolute(folder) != OK:
		return false
	var mode: Node.ProcessMode = scene.process_mode
	scene.process_mode = Node.PROCESS_MODE_DISABLED
	var material: Material = card.material
	var inherit: bool = card.use_parent_material
	var ok: bool = await _expose(view, folder, "live", h)
	card.use_parent_material = false
	card.material = null
	ok = await _expose(view, folder, "raw", h) and ok
	card.hide()
	ok = await _expose(view, folder, "ground", h) and ok
	card.show()
	card.material = material
	card.use_parent_material = inherit
	scene.process_mode = mode
	return ok


static func _expose(view: Node, folder: String, label: String, h: Fighter) -> bool:
	await view.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var port: Viewport = view.get_viewport()
	var foot: Vector2 = port.get_canvas_transform() * (h.pos * SimConst.PX_PER_M)
	var rect: Rect2i = Rect2i(Vector2i(foot.round()) - Vector2i(192, 192), Vector2i(384, 320))
	var im: Image = port.get_texture().get_image().get_region(rect)
	return im.save_png(folder.path_join(label + ".png")) == OK
