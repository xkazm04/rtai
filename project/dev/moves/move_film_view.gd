class_name MoveFilmView
extends Node
## The production arena cast, ordnance, ghost attack layers and stage audio. The readout is
## sampled from this take, so a blocked shot and an open plate report different multipliers.

var take: MoveFilmTake
var heading: Label
var status: Label
var details: Label
var view: CollectCallView


func open(t: MoveFilmTake, ppm: int) -> bool:
	take = t
	view = CollectCallView.new()
	view.stage_view.free()
	view.stage_view = ArenaFloorView.new()
	view.px_per_m = ppm
	view.fx_view.reduced_motion = true
	var stage: ArenaStage = t.stage
	view.focus = (stage.arena.rivet.pos + t.subject.pos) * 0.5 + Vector2(0, -0.55)
	if t.move == MoveTable.OVERKILL:
		view.focus += Vector2(1.8, -0.65)
	view.bind(stage, CollectCallWorld.new(stage), null)
	add_child(view)
	view.hud_view.hide()
	_center.call_deferred()
	var cast: ArenaRigs = ArenaRigs.new()
	add_child(cast)
	if not cast.attach(stage, view, t.ctx):
		return false
	cast.ghost_view.hud.hide()
	@warning_ignore("return_value_discarded")
	GhostAttackViews.attach(GhostAttackViews.layer_of(view), stage, false, true)
	@warning_ignore("return_value_discarded")
	StageAudio.attach(self, stage, null, t.bus, 1)
	PropOcclusion.for_view(view)
	var hud: CanvasLayer = CanvasLayer.new()
	hud.layer = RenderLayers.canvas(&"hud") + 1
	add_child(hud)
	heading = _label(hud, Vector2(58, 47), 36)
	status = _label(hud, Vector2(60, 99), 24)
	details = _label(hud, Vector2(60, 136), 20)
	return true


func _center() -> void:
	var page: PrintStage = view.print_stage
	page.place(view.focus)
	page.camera.make_current()
	page.camera.force_update_scroll()


func screen_point(at: Vector2) -> Vector2:
	return view.fx_view.get_global_transform_with_canvas() * Ink.px(at)


func _label(parent: Node, at: Vector2, px: int) -> Label:
	var label: Label = Label.new()
	label.position = at
	label.add_theme_font_size_override("font_size", px)
	label.add_theme_color_override("font_color", Color("#fff6e5"))
	label.add_theme_color_override("font_outline_color", Color("#29252c"))
	label.add_theme_constant_override("outline_size", 6)
	parent.add_child(label)
	return label


func update_readout(slow: int) -> void:
	var t: MoveFilmTake = take
	var h: Fighter = t.subject
	var stage: ArenaStage = t.stage
	var detail: String = t.last_hit
	match t.move:
		MoveTable.SHORT_CIRCUIT:
			heading.text = tr("Ohm  /  Short circuit")
			status.text = tr("Sentry turret") if t.second else tr("Shield carrier and SWAT")
			if h.alive() and t.mind.stun_until > stage.tick:
				detail = tr("Shorted  %.2f s") % ((t.mind.stun_until - stage.tick) / 60.0)
				if t.last_hit != "":
					detail += "     " + t.last_hit
		MoveTable.ARMOUR_CRACK:
			heading.text = tr("Tonnage  /  Armour crack")
			status.text = tr("War machine")
			var row: MoveTable.ArmourCrack = stage.arena.squad_ai.moves.tonnage_armour_crack
			if TonnageCrack.is_open(t.mind, row, stage.tick):
				var left: int = t.mind.walker.cracked_at + row.open_ticks - stage.tick
				detail = tr("Split open  %.2f s") % (left / 60.0) + "     " + t.last_hit
			elif TonnageCrack.post_stomp(t.mind) and t.first_stomp < 0:
				detail = tr("Stomp recovery")
		MoveTable.BLINK_BEHIND:
			heading.text = tr("Kerf  /  Blink behind")
			detail = _kerf()
		MoveTable.OVERKILL:
			heading.text = tr("Hand cannon  /  Overkill carry")
			status.text = tr("Rank %d  /  One round") % (2 if t.second else 1)
			if stage.shots_fired > 0:
				detail = tr("Carry hits   %d") % t.carry_hits
	if slow > 1:
		detail += ("     " if detail != "" else "") + tr("1/%d speed") % slow
	details.text = detail


func _kerf() -> String:
	status.text = (
		tr("Shield carrier  /  Crossing the face")
		if take.second
		else tr("Shield carrier  /  Head-on")
	)
	if take.compare_slice:
		var enabled: bool = take.stage.arena.squad_ai.moves.kerf_blink_behind.enabled
		status.text = tr("Move on") if enabled else tr("Move off")
		status.text += (
			tr("     Carrier %.2f / %.0f HP     Probe slice ×%s")
			% [take.subject.hp, take.subject.max_hp, take.slice_k]
		)
	if take.stage.pilot.kerf.slices == 0:
		return ""
	var h: Fighter = take.subject
	var side: float = h.facing.dot(h.pos.direction_to(take.stage.arena.rivet.pos))
	var hit: String = "" if take.last_hit.is_empty() else "     " + take.last_hit
	if side <= FoeArmor.REAR_COS:
		return tr("Behind the plate") + hit
	if side >= take.mind.agent.arch.shield_cos:
		return tr("Inside the shield arc") + hit
	return tr("Oblique landing") + hit
