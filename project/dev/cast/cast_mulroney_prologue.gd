extends "res://dev/prologue/prologue_stills.gd"
## One unmodified pilot frame with the shipping card and the yard's own costume layer.


func _squad_event(battle: PrologueBattle, _tick: int) -> String:
	return "mulroney" if battle.ranged and battle.formation.boss.alive() else ""


func _capture(_shot: String, tick: int) -> void:
	await RenderingServer.frame_post_draw
	var boss: Fighter = _game.encounter.battle.formation.boss
	for child: Node in _game.get_children():
		if child is ArenaRigs:
			var rig: CutRig = (child as ArenaRigs).rigs.rig_for(boss.id)
			if rig == null or rig.head_card == null:
				continue
			var card: Sprite2D = rig.head_card
			if (
				not card.is_visible_in_tree()
				or not card.texture.resource_path.get_file().begins_with("sergeant_mulroney_")
			):
				continue
			var at: Vector2 = card.get_global_transform_with_canvas() * card.get_rect().get_center()
			if not get_viewport().get_visible_rect().has_point(at):
				continue
			var path: String = _out.path_join("mulroney_prologue_card.png")
			var photo: Image = get_viewport().get_texture().get_image()
			if photo.save_png(path) != OK:
				get_tree().quit(1)
				return
			Log.info(
				"cast",
				"prologue card tick %d %s centre %s" % [tick, card.texture.resource_path, at]
			)
			get_tree().quit()
			return
	set_process(true)
