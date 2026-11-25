extends "res://dev/cast/cast_lineup.gd"
## n28 item 4: live, raw and empty exposures of each card's hit pose at 64 px/m, with the hit flash
## (CutRig.set_tint) on and off on the same frozen frame. GTAI_CAST_OUT is an absolute directory.

const SUBJECTS: Array[StringName] = [
	&"patrol_cop",
	&"riot_cop",
	&"swat",
	&"rocket_trooper",
	&"shield_robot",
	&"appliance_warden",
	&"robot_gunner",
]
const CARD_KEYS: Array[StringName] = [FoeShieldCardView.CARD, FoeGunnerCardView.CARD]

var _host: ArenaRigs
var _notes: Array[Dictionary] = []


func _ready() -> void:
	_out = OS.get_environment("GTAI_CAST_OUT")
	_ppm = 64
	_pitch = 55 if OS.get_environment("GTAI_CAST_PITCH") == "55" else 70
	if not _out.is_absolute_path():
		_fail("set GTAI_CAST_OUT")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(float(_pitch))
	ViewMode.shared().art = "p%d" % _pitch
	CastMulroneyPreview.enable(&"appliance_warden")
	_host = _open_wave()
	if _host == null:
		_fail("missing street host")
		return
	_arena.rivet.pos = MARK + Vector2.RIGHT * 8.0
	var ok: bool = true
	for id: StringName in SUBJECTS:
		ok = await _subject(id) and ok
	var file: FileAccess = FileAccess.open(_out.path_join("notes.json"), FileAccess.WRITE)
	ok = file != null and file.store_string(JSON.stringify(_notes, " ")) and ok
	Log.info("cast", "impact edge complete %s" % ok)
	get_tree().quit(0 if ok else 1)


func _advance() -> void:
	_arena.tick += 1
	_clock.complete_tick()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw


func _subject(id: StringName) -> bool:
	var foe: Fighter = _arena.squad_ai.spawn_member(_arena, MARK, id)
	@warning_ignore("return_value_discarded")
	_arena.squad_ai.mind_for(foe)
	foe.hp = 500.0
	foe.pos = MARK
	foe.facing = Vector2(1, 1).normalized()
	for tick: int in 30:
		await _advance()
	var direction: Vector2 = Vector2(1, 1).normalized()
	_arena.hit_at = foe.pos
	_arena.hit_dir = direction
	_arena.damage(foe, 1.0, _arena.rivet.id, &"pistol")
	_arena.struck.emit(foe, direction, false, &"pistol")
	foe.pos = MARK
	for tick: int in 3:
		await _advance()
	var rig: CutRig = _host.rigs.rig_for(foe.id)
	if rig == null and _host.robots != null:
		rig = _host.robots.rig_for(foe.id)
	var card: Sprite2D = _card_of(rig)
	if card == null:
		_notes.append({"id": id, "error": "no visible card"})
		return false
	var note: Dictionary = {"id": id, "texture": card.texture.resource_path.get_file()}
	note["natural_tint"] = rig.is_tinted()
	var ok: bool = true
	for pulse: bool in [true, false]:
		_flash(rig, card, pulse)
		note["material_%s" % pulse] = (
			card.material.get_instance_id() if card.material != null else 0
		)
		ok = await _shoot(foe, card, "edge_%s_%s" % [id, "pulse" if pulse else "calm"]) and ok
	rig.set_tint(false)
	_notes.append(note)
	foe.pos = PARK
	for tick: int in 4:
		await _advance()
	return ok


## The whole-sprite views sync the tint on their next step; this scene is frozen, so do it here.
func _flash(rig: CutRig, card: Sprite2D, on: bool) -> void:
	rig.set_tint(on)
	if card is CastFarCard:
		(card as CastFarCard).sync_tint(on)


func _card_of(rig: CutRig) -> Sprite2D:
	if rig == null:
		return null
	for key: StringName in CARD_KEYS:
		var sprite: Sprite2D = rig.get_meta(key) if rig.has_meta(key) else null
		if sprite != null and sprite.is_visible_in_tree():
			return sprite
	return rig.head_card if rig.head_card != null and rig.head_card.is_visible_in_tree() else null


func _shoot(foe: Fighter, card: Sprite2D, name: String) -> bool:
	var folder: String = _out.path_join(name)
	if DirAccess.make_dir_recursive_absolute(folder) != OK:
		return false
	var mode: ProcessMode = _scene.process_mode
	_scene.process_mode = Node.PROCESS_MODE_DISABLED
	var material: Material = card.material
	var inherit: bool = card.use_parent_material
	var ok: bool = await _expose(foe, folder, "live")
	card.use_parent_material = false
	card.material = null
	ok = await _expose(foe, folder, "raw") and ok
	card.hide()
	ok = await _expose(foe, folder, "ground") and ok
	card.show()
	card.material = material
	card.use_parent_material = inherit
	_scene.process_mode = mode
	return ok


func _expose(foe: Fighter, folder: String, label: String) -> bool:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var foot: Vector2 = get_viewport().get_canvas_transform() * (foe.pos * SimConst.PX_PER_M)
	var rect: Rect2i = Rect2i(Vector2i(foot.round()) - Vector2i(192, 256), Vector2i(384, 320))
	var image: Image = get_viewport().get_texture().get_image().get_region(rect)
	return image.save_png(folder.path_join(label + ".png")) == OK
