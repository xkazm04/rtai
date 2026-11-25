extends "res://dev/cast/cast_lineup.gd"
## Every enabled card foe spawned (spawn_member, the game's path) beside a spawned patrol cop and
## Rivet on the fight street, all standing, at 64 and 32 px/m. Writes build/look/n29-size/:
## <id>_<ppm>.png (beside), <id>_<ppm>_body.png and _gone.png (shadow hidden, figure parked) and
## shots.json (each figure's screen point) for tools/art/cast_size_measure.py.

const NEEDS_WINDOW: bool = true
const RUN_TICKS: int = 6000
const SETTLE: int = 44
const CENTRE: Vector2 = Vector2(13, 0)
const SLOT_FOE: Vector2 = Vector2(-3.0, 0.0)
const SLOT_COP: Vector2 = Vector2(0.0, 0.0)
const SLOT_RIVET: Vector2 = Vector2(3.0, 0.0)
const LOOK: Vector2 = Vector2(1, 1)
const PPMS: Array[int] = [64, 32]
## n29 part B: two more spawns (new actor ids) of one human and the gunner, the jitter proof.
const EXTRA: Array[StringName] = [
	&"contractor_x2", &"contractor_x3", &"robot_gunner_x2", &"robot_gunner_x3"
]

var _host: ArenaRigs
var _cop: Fighter
var _dir: String
var _shots: Array[Dictionary] = []


func _ready() -> void:
	get_window().size = Vector2i(1920, 1080)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	_dir = (
		ProjectSettings.globalize_path("res://").path_join("../build/look/n29-size").simplify_path()
	)
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_dir)
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(70.0)
	ViewMode.shared().art = "p70"
	_ppm = PPMS[0]
	add_child(_board)
	_host = _open_wave()
	if _host == null:
		_fail("street rig host unavailable")
		return
	_cop = _arena.squad_ai.spawn_member(_arena, CENTRE, &"patrol_cop")
	@warning_ignore("return_value_discarded")
	_arena.squad_ai.mind_for(_cop)
	var ids: Array[StringName] = _card_foes()
	Log.info("cast", "size beside: card foes %s" % [ids])
	var foes: Dictionary[StringName, Fighter] = {}
	for key: StringName in ids + EXTRA:
		var id: StringName = StringName(String(key).get_slice("_x", 0))
		foes[key] = _arena.squad_ai.spawn_member(_arena, CENTRE, id)
		@warning_ignore("return_value_discarded")
		_arena.squad_ai.mind_for(foes[key])
	for ppm: int in PPMS:
		if not await _pass(ppm, foes):
			_fail("pass %d px/m failed" % ppm)
			return
	await _lineup_probe(foes[&"contractor"] if foes.has(&"contractor") else null)
	var file: FileAccess = FileAccess.open(_dir.path_join("shots.json"), FileAccess.WRITE)
	@warning_ignore("return_value_discarded")
	file.store_string(JSON.stringify({"shots": _shots}, "  ", true))
	file.close()
	Log.info("cast", "size beside saved %d shots to %s" % [_shots.size(), _dir])
	get_tree().quit(0)


func _studio() -> bool:
	_view.focus = CENTRE
	for child: Node in _view.print_stage.actor_layer().get_children():
		if child is RigCastShadows:
			_shadow = child
	for item: Node in _scene.find_children("*", "CanvasLayer", true, false):
		var layer: CanvasLayer = item as CanvasLayer
		if layer.layer >= RenderLayers.canvas(&"hud") or layer is LightLayer:
			layer.hide()
	return _shadow != null


func _card_foes() -> Array[StringName]:
	var out: Array[StringName] = []
	var table: DataTable = DataTable.open(CastCards.TABLE, CastCards.SCHEMA)
	var rows: Dictionary = table.object(table.raw, "archetypes")
	var keys: Array = rows.keys()
	keys.sort()
	for key: String in keys:
		if CastCards.shipped().lookup(StringName(key), "p70") != null:
			out.append(StringName(key))
	return out


func _pass(ppm: int, foes: Dictionary[StringName, Fighter]) -> bool:
	_ppm = ppm
	_view.print_stage.zoom = ppm / SimConst.PX_PER_M
	_view.print_stage.place(CENTRE)
	_view.print_stage.camera.force_update_scroll()
	_stand(null, foes)
	await _settle(SETTLE)
	var zoom: float = get_viewport().get_canvas_transform().x.length()
	if not is_equal_approx(zoom * SimConst.PX_PER_M, ppm):
		return false
	await _take("patrol_only", null)
	for id: StringName in foes:
		_stand(foes[id], foes)
		await _settle(SETTLE)
		await _take(String(id), foes[id])
	return true


func _stand(foe: Fighter, foes: Dictionary[StringName, Fighter]) -> void:
	var park: int = 0
	for other: Fighter in foes.values():
		park += 1
		other.pos = PARK + Vector2(4.0 * park, 0.0)
	if foe != null:
		foe.pos = CENTRE + SLOT_FOE
		foe.facing = LOOK.normalized()
	_cop.pos = CENTRE + SLOT_COP
	_cop.facing = LOOK.normalized()
	_arena.rivet.pos = CENTRE + SLOT_RIVET
	_arena.rivet.facing = LOOK.normalized()


## Beside still with shadow, then shadow hidden: all standing (_body), each figure parked in turn.
func _take(stem: String, foe: Fighter) -> void:
	var tag: String = "%s_%d" % [stem, _ppm]
	_save(tag + ".png")
	_shadow.hide()
	await _settle(2)
	_save(tag + "_body.png")
	var who: Dictionary[String, Fighter] = {stem: foe}
	if foe == null:
		who = {"patrol_cop": _cop, "rivet": _arena.rivet}
	for who_id: String in who:
		var body: Fighter = who[who_id]
		var home: Vector2 = body.pos
		var point: Vector2 = get_viewport().get_canvas_transform() * (home * SimConst.PX_PER_M)
		_shots.append(_entry(tag, who_id, point, body))
		body.pos = PARK + Vector2(0.0, 30.0)
		await _settle(4)
		_save("%s_gone_%s.png" % [tag, who_id])
		body.pos = home
		await _settle(6)
	_shadow.show()


func _entry(tag: String, who_id: String, point: Vector2, body: Fighter) -> Dictionary:
	var full: bool = _host.rigs.rig_for(body.id) != null
	if _host.robots != null:
		full = full or _host.robots.rig_for(body.id) != null
	var card: Sprite2D = _host.wave_cards.card_for(body.id) if _host.wave_cards != null else null
	var far: bool = card != null and card.is_visible_in_tree()
	var row: Dictionary = {"tag": tag, "who": who_id, "ppm": _ppm, "x": point.x, "y": point.y}
	row["full_rig"] = full
	row["far_card"] = far
	row["actor_id"] = body.id
	row["actor_scale"] = StreetCrowdCards.body_scale(body.id)
	var rig: CutRig = _host.rigs.rig_for(body.id)
	row["whole_card"] = (
		rig != null and rig.head_card != null and rig.head_card.has_meta(StreetWalkerCards.ON)
	)
	Log.info("cast", "%s %s %s" % [tag, who_id, JSON.stringify(row, "", true)])
	return row


## The lineup's layout (cast_lineup.gd _portrait): subject on the mark, Rivet 12 m to the right.
func _lineup_probe(contractor: Fighter) -> void:
	_ppm = 64
	_view.print_stage.zoom = _ppm / SimConst.PX_PER_M
	_view.print_stage.camera.force_update_scroll()
	for subject: Fighter in [_cop, contractor]:
		if subject == null:
			continue
		for other: Fighter in _arena.hostiles:
			other.pos = PARK + Vector2(0.0, -20.0)
		_arena.rivet.pos = CENTRE + Vector2.RIGHT * 12.0
		subject.pos = CENTRE
		subject.facing = LOOK.normalized()
		await _settle(SETTLE)
		var tag: String = "lineup_%s_%d" % [subject.archetype, _ppm]
		_shadow.hide()
		await _settle(2)
		_save(tag + "_body.png")
		var point: Vector2 = (
			get_viewport().get_canvas_transform() * (subject.pos * SimConst.PX_PER_M)
		)
		_shots.append(_entry(tag, String(subject.archetype), point, subject))
		subject.pos = PARK + Vector2(0.0, 30.0)
		await _settle(4)
		_save("%s_gone_%s.png" % [tag, subject.archetype])
		_shadow.show()


func _settle(ticks: int) -> void:
	for t: int in ticks:
		_clock.complete_tick()
		await get_tree().process_frame
	await RenderingServer.frame_post_draw


func _save(file: String) -> void:
	var err: Error = get_viewport().get_texture().get_image().save_png(_dir.path_join(file))
	if err != OK:
		Log.error("cast", "could not save %s (%d)" % [file, err])
