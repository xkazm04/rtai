extends "res://dev/cast/cast_lineup.gd"
## Rivet's pistol against a door carrier (shield_robot) and a robot gunner that pace in the street,
## 32 px/m tilt 70, cards on. Each foe takes a pistol round every FIRE_EVERY ticks (they have
## plenty of hp); the scene logs every tick a foe's hit flash (rig.is_tinted()) turns on, so the
## film can be cut at those ticks. The hit clip is played by _flinch (see there).
## GTAI_CAST_TICKS sets the length; GTAI_CAST_FLASH_OUT, when set,
## gets one png per logged flash tick (foe_<archetype>_<hit>_<k>.png, k = 0..2).

const CENTRE: Vector2 = Vector2(13, 0)
const FIRE_EVERY: int = 70
const WALK_MPS: float = 0.9
const HOMES: Array[Vector2] = [Vector2(-2.6, -2.0), Vector2(-2.6, 2.6)]
const IDS: Array[StringName] = [&"shield_robot", &"robot_gunner"]

var _host: ArenaRigs
var _foes: Array[Fighter] = []
var _was_lit: Dictionary[int, bool] = {}
var _flashes: Dictionary[int, Array] = {}
var _grab: Dictionary[int, int] = {}


func _ready() -> void:
	_ppm = 32
	var ticks: int = OS.get_environment("GTAI_CAST_TICKS").to_int()
	if ticks <= 0 or get_window().size != Vector2i(1920, 1080):
		_fail("set GTAI_CAST_TICKS at 1920x1080")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(70.0)
	ViewMode.shared().art = "p70"
	CastMulroneyPreview.enable(FoeGunnerCardView.ID)
	add_child(_board)
	_host = _open_wave()
	if _host == null:
		_fail("street rig host unavailable")
		return
	_equip()
	var shots_dir: String = OS.get_environment("GTAI_CAST_FLASH_OUT")
	for tick: int in range(1, ticks + 1):
		_step(tick)
		_clock.complete_tick()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		_watch(tick, shots_dir)
	var ok: bool = true
	for foe: Fighter in _foes:
		var seen: Array = _flashes.get(foe.id, [])
		Log.info("cast", "flash %s id %d at ticks %s" % [foe.archetype, foe.id, seen])
		ok = ok and seen.size() >= 3
	Log.info("cast", "flash fight pass %s" % ok)
	get_tree().quit(0 if ok else 1)


func _studio() -> bool:
	_view.focus = CENTRE
	_view.print_stage.zoom = _ppm / SimConst.PX_PER_M
	_view.print_stage.place(CENTRE)
	_view.print_stage.camera.force_update_scroll()
	for item: Node in _scene.find_children("*", "CanvasLayer", true, false):
		var layer: CanvasLayer = item as CanvasLayer
		if layer.layer >= RenderLayers.canvas(&"hud") or layer is LightLayer:
			layer.hide()
	return true


func _equip() -> void:
	for i: int in IDS.size():
		var foe: Fighter = _arena.squad_ai.spawn_member(_arena, CENTRE, IDS[i])
		@warning_ignore("return_value_discarded")
		_arena.squad_ai.mind_for(foe)
		foe.pos = CENTRE + HOMES[i]
		foe.hp = 5000.0
		foe.max_hp = foe.hp
		_foes.append(foe)
	for other: Fighter in _arena.hostiles:
		if not _foes.has(other):
			other.pos = PARK
	var rivet: Fighter = _arena.rivet
	rivet.pos = CENTRE + Vector2(3.2, 0.3)
	rivet.hp = 9999.0
	rivet.max_hp = rivet.hp
	rivet.weapon = &"pistol"
	_arena.gun = GunHand.make(
		WeaponTable.shipped(), rivet.weapon, _session.world.context().rng.stream(&"gunplay")
	)
	@warning_ignore("return_value_discarded")
	_session.pilot.hold.equip(rivet.weapon)


func _step(tick: int) -> void:
	_arena.tick = tick
	_session.stage.tick = tick
	_session.pilot.hold.step()
	var swing: float = sin(tick * 0.02) * 1.4
	for i: int in _foes.size():
		var foe: Fighter = _foes[i]
		foe.pos = CENTRE + HOMES[i] + Vector2(0.0, swing)
		foe.facing = foe.pos.direction_to(_arena.rivet.pos)
		if tick % FIRE_EVERY == 10 + 35 * i:
			_arena.rivet.facing = _arena.rivet.pos.direction_to(foe.pos)
			@warning_ignore("return_value_discarded")
			_arena.rivet_fire(foe.pos)
	_arena._step_shots()
	_arena.gun.settle()
	_flinch(tick)


## The robot rig host shoves a hit foe but never sends the HIT clip that tints a rig, so this
## scene plays that clip itself (RigClips.hit, what a feed HIT row calls) on the tick of the hit.
func _flinch(tick: int) -> void:
	for foe: Fighter in _foes:
		var rig: CutRig = _rig_of(foe)
		if rig != null and foe.hurt_tick == tick:
			rig.clips.hit(rig, (foe.pos - _arena.rivet.pos).normalized())


func _rig_of(foe: Fighter) -> CutRig:
	var rig: CutRig = _host.rigs.rig_for(foe.id)
	if rig == null and _host.robots != null:
		rig = _host.robots.rig_for(foe.id)
	return rig


## True while the foe's visible card wears the hit-flash material (or the rig itself is tinted).
func _lit(rig: CutRig) -> bool:
	if rig == null:
		return false
	var flash: Material = PartMaterials.get_mat(PartMaterials.PartKind.PART, true, 0)
	for key: StringName in [FoeShieldCardView.CARD, FoeGunnerCardView.CARD]:
		var card: Sprite2D = rig.get_meta(key) if rig.has_meta(key) else null
		if card != null and card.is_visible_in_tree():
			return card.material == flash
	if rig.head_card != null and rig.head_card.is_visible_in_tree():
		return rig.head_card.material == flash or rig.is_tinted()
	return rig.is_tinted()


func _watch(tick: int, shots_dir: String) -> void:
	for foe: Fighter in _foes:
		var rig: CutRig = _rig_of(foe)
		var lit: bool = _lit(rig)
		if lit and not _was_lit.get(foe.id, false):
			var list: Array = _flashes.get(foe.id, [])
			list.append(tick)
			_flashes[foe.id] = list
			_grab[foe.id] = 0
		_was_lit[foe.id] = lit
		if lit and not shots_dir.is_empty() and _grab.get(foe.id, 9) < 3:
			var k: int = _grab[foe.id]
			_grab[foe.id] = k + 1
			var name: String = "foe_%s_%d_%d.png" % [foe.archetype, _flashes[foe.id].size(), k]
			var img: Image = get_viewport().get_texture().get_image()
			@warning_ignore("return_value_discarded")
			img.save_png(shots_dir.path_join(name))
