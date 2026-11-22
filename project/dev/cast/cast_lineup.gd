extends Node
## Native-scale portraits from the wave spawner and the two prologue-only officers.
## GTAI_CAST_OUT is an absolute directory. GTAI_CAST_PITCH is 55 or 70, GTAI_CAST_PPM 32 or 64.

const MARK: Vector2 = Vector2(12, -100)
const PARK: Vector2 = Vector2(100, 40)
const FACE: Array[Vector2] = [Vector2(1, 1), Vector2.UP]

var _session: GauntletSession
var _game: PrologueGame
var _scene: Node
var _view: CollectCallView
var _clock: SimClock
var _arena: CombatArena
var _board: CastPlate = CastPlate.new()
var _shadow: RigCastShadows
var _ppm: int
var _pitch: int
var _out: String


func _ready() -> void:
	_out = OS.get_environment("GTAI_CAST_OUT")
	_pitch = OS.get_environment("GTAI_CAST_PITCH").to_int()
	_ppm = OS.get_environment("GTAI_CAST_PPM").to_int()
	if not _out.is_absolute_path() or _pitch not in [55, 70] or _ppm not in [32, 64]:
		_fail("set GTAI_CAST_OUT, GTAI_CAST_PITCH and GTAI_CAST_PPM")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	var mode: ViewMode = ViewMode.shared()
	mode.set_pitch(float(_pitch))
	mode.art = "p%d" % _pitch
	add_child(_board)
	var host: ArenaRigs = _open_wave()
	if host == null:
		_fail("could not open wave cast")
		return
	if OS.get_environment("GTAI_CAST_LANCER") == "1":
		await CastLancerStills.capture(host, _session, MARK, _ppm, _out)
		return
	if not await _capture_wave():
		_fail("wave capture failed")
		return
	_session.close()
	_scene.free()
	if not await _capture_prologue():
		_fail("prologue capture failed")
		return
	_game.free()
	var path: String = _out.path_join("audit_lineup_%dppm_tilt%d.png" % [_ppm, _pitch])
	if not await _board.save_sheet(path, _ppm, _pitch):
		_fail("could not save %s" % path)
		return
	Log.info("cast", "saved %s" % path)
	get_tree().quit()


func _open_wave() -> ArenaRigs:
	_scene = Node.new()
	add_child(_scene)
	var run: GauntletRun = GauntletRun.new()
	run.controls = &"wheel"
	_session = GauntletSession.open_street(Events, Data, run)
	if _session == null:
		return null
	_scene.add_child(_session.world)
	_session.world.set_process(false)
	_arena = _session.stage.arena
	_clock = _session.world.context().clock
	_view = GauntletView.new(_session.street)
	_view.bind(_session.stage, CollectCallWorld.new(_session.stage), null)
	_scene.add_child(_view)
	var cast: ArenaRigs = ArenaRigs.new()
	_scene.add_child(cast)
	if not cast.attach(_session.stage, _view, _session.world.context()):
		return null
	return cast if _studio() else null


func _studio() -> bool:
	_view.set_process(false)
	_view.print_stage.zoom = _ppm / SimConst.PX_PER_M
	_view.print_stage.place(MARK)
	_view.print_stage.camera.force_update_scroll()
	var layer: CanvasLayer = _view.print_stage.actor_layer()
	for child: Node in layer.get_children():
		if child is RigCastShadows:
			_shadow = child
	var matte: ColorRect = ColorRect.new()
	matte.color = CastPlate.PAPER
	matte.position = MARK * SimConst.PX_PER_M - Vector2(2000, 1500)
	matte.size = Vector2(4000, 3000)
	matte.z_index = -4096
	layer.add_child(matte)
	for c: Node in _scene.find_children("*", "CanvasLayer", true, false):
		var canvas: CanvasLayer = c as CanvasLayer
		if canvas.layer >= RenderLayers.canvas(&"hud"):
			canvas.hide()
	return _shadow != null


func _capture_wave() -> bool:
	var roster: DataTable = DataTable.open(EnemyRoster.TABLE, EnemyRoster.SCHEMA)
	if not roster.ok():
		return false
	if not await _portrait(_arena.rivet, "Rivet"):
		return false
	for row: Dictionary in roster.array(roster.raw, "archetypes"):
		var id: StringName = StringName(roster.text(row, "id"))
		if id in [&"sergeant_mulroney", &"appliance_warden"]:
			continue
		var foe: Fighter = _arena.squad_ai.spawn_member(_arena, MARK, id)
		@warning_ignore("return_value_discarded")
		_arena.squad_ai.mind_for(foe)
		if not await _portrait(foe, String(id)):
			return false
		if id == &"patrol_cop":
			await _far_patrol(foe)
	return true


func _capture_prologue() -> bool:
	_game = PrologueGame.new()
	_scene = _game
	add_child(_game)
	_game.world.set_process(false)
	_clock = _game.world.context().clock
	_arena = _game.stage.arena
	for child: Node in _game.get_children():
		if child is PrologueView:
			_view = child
	if not _studio():
		return false
	await _far_patrol(_game.encounter.patrol.dale)
	var warden: Fighter
	for officer: ProloguePatrol.Officer in _game.encounter.patrol.officers:
		if officer.body.archetype == &"appliance_warden":
			warden = officer.body
			break
	if warden == null or not await _portrait(warden, "appliance_warden"):
		return false
	var formation: PrologueFormation = _game.encounter.battle.formation
	formation.enter(_arena)
	return await _portrait(formation.boss, "sergeant_mulroney")


func _far_patrol(foe: Fighter) -> void:
	for other: Fighter in _arena.hostiles:
		other.pos = PARK
	_arena.rivet.pos = MARK
	foe.pos = MARK + Vector2.RIGHT * 26
	for t: int in 8:
		_clock.complete_tick()
		await get_tree().process_frame
	var full: bool = false
	var far: bool = false
	for node: Node in _scene.find_children("*", "", true, false):
		if node is ArenaRigs:
			full = (node as ArenaRigs).rigs.rig_for(foe.id) != null
		if node is ArenaWaveCards:
			var card: Sprite2D = (node as ArenaWaveCards).card_for(foe.id)
			far = far or (card != null and card.is_visible_in_tree())
	Log.info("cast", "26 m patrol id %d: full rig %s, far card %s" % [foe.id, full, far])


func _portrait(subject: Fighter, id: String) -> bool:
	for other: Fighter in _arena.hostiles:
		other.pos = PARK
	_arena.rivet.pos = MARK + Vector2.RIGHT * 12.0
	subject.pos = MARK
	for i: int in FACE.size():
		subject.facing = FACE[i].normalized()
		for t: int in 32:
			_clock.complete_tick()
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var zoom: float = get_viewport().get_canvas_transform().x.length()
		if not is_equal_approx(zoom * SimConst.PX_PER_M, _ppm):
			return false
		var crop: Rect2i = Rect2i(640, 64, 640, 704)
		var photo: Image = get_viewport().get_texture().get_image().get_region(crop)
		_shadow.hide()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var body: Image = get_viewport().get_texture().get_image().get_region(crop)
		_shadow.show()
		if not _board.add_portrait(id, i, photo, body, Vector2i(960, 540) - crop.position):
			return false
	if OS.get_environment("GTAI_CAST_STRIDE") == "1" and id not in ["Rivet", "sentry_turret"]:
		for child: Node in _scene.get_children():
			if child is ArenaRigs:
				await CastStride.new().measure(subject, child as ArenaRigs, _clock, id)
	subject.pos = PARK
	return true


func _fail(message: String) -> void:
	Log.error("cast", message)
	get_tree().quit(1)
