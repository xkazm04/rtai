extends Node
## The combat blood in the REAL city (lane d5-combat evidence): the real World + CitySystem +
## CityView + CityCharacters (as city_frame), a riot of 40 rioters and 8 cops on one street, the
## camera parked on it. At each --at tick the clock is frozen (time_scale 0) and the frame is shot
## at every --zooms zoom, so the zooms show the same moment. The blood mode is the game's own
## flag (-- --blood=noir|ink|both). Windowed only. Usage:
##   godot --rendering-driver d3d12 --path project res://dev/showcase/city_fight.tscn --
##   --blood=<mode> --out=<dir> [--at=<tick>,...] [--zooms=1,1.5,2] [--focus=<i>] [--tag=<name>]
##   [--no-stains]  hides the blood on the dead (CorpseStains): the before frame of that change.
##   [--hit-rivet=<ticks>]  Rivet takes a Robo-tazer hit (Events.player_hit) every <ticks>, wired
##   as boot/world.gd wires the game (fx_triggers.listen): sparks, crackle, his oil.
##   [--rivet-kills=<m>]  DEV STAND-IN: a riot death within <m> metres of Rivet is credited to him
##   (Events.actor_killed with his id), so the rivet_kill cue and the kill beat fire in the riot.
##   [--beat-frames=<n>]  from the first kill beat, saves <n> consecutive frames at the first
##   --zooms zoom (beat-<mode>-<ppm>-fNN.png) and quits; pair with -- --kill-beat=<mode>.
##   [--clip=<from>,<frames>]  saves every 2nd frame from tick <from> for <frames> frames at the
##   first --zooms zoom (clip-<mode>-<ppm>-NNNN.png, 30 fps); run with --fixed-fps 60 so each
##   frame is one sim tick and the clip plays in real time.

const MASTER_SEED: int = 91
const BASE: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)
const FOCI: Array[Vector2] = [Vector2(30.0, -4.0), Vector2(-4.0, 30.0), Vector2(62.0, 30.0)]

var _out: String = "user://city_fight"
var _at: Array[int] = [600, 1200]
var _zooms: Array[float] = [1.0, 1.5, 2.0]
var _focus: int = 0
var _tag: String = ""
var _hit_every: int = 0
var _last_hit: int = 0
var _kill_m: float = 0.0
var _beat_frames: int = 0
var _clip: Vector2i = Vector2i.ZERO
var _no_stains: bool = false
var _world: World = null
var _city: CitySystem = null
var _view: CityView = null
var _chars: CityCharacters = null


func _ready() -> void:
	if not _parse_args():
		get_tree().quit(2)
		return
	_world = World.new()
	_world.start(Events, Data, MASTER_SEED)
	add_child(_world)
	_city = CitySystem.new(true)
	_world.add_system(_city)
	_city.steer_by_input = false
	var p: Vector2 = BASE + FOCI[_focus]
	_city.focus = p
	_city.target = p
	_city.spawner.riot_c = p
	var t: CityTargets = CityTargets.riot(40, 8)
	_city.spawner.targets = t
	_view = CityView.new()
	add_child(_view)
	_view.setup(_city)
	_chars = CityCharacters.new(_city, _view, _world.context())
	_chars.blood.stains.visible = not _no_stains
	await _chars.bake()
	await _view.prewarm()
	_wire()
	if _clip.y > 0 or _beat_frames > 0:
		var ok_dev: bool = await _shoot_dev()
		printerr(_summary())
		get_tree().quit(0 if ok_dev else 1)
		return
	var ok: bool = DirAccess.make_dir_recursive_absolute(_out) == OK
	for tick: int in _at:
		while _world.context().clock.tick() < tick:
			await get_tree().process_frame
			_maybe_hit()
		ok = await _shoot(tick) and ok
	printerr(_summary())
	get_tree().quit(0 if ok else 1)


func _shoot(tick: int) -> bool:
	Engine.time_scale = 0.0
	var ok: bool = true
	for zoom: float in _zooms:
		_view.zoom = zoom
		for f: int in 3:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		var ppm: int = roundi(zoom * SimConst.PX_PER_M)
		var file: String = "fight%s-%s-t%d-%dppm.png" % [_tag, _chars.blood.blood.mode, tick, ppm]
		ok = img != null and img.save_png(_out.path_join(file)) == OK and ok
	Engine.time_scale = 1.0
	return ok


## Rivet's hits and kills wired as boot/world.gd wires the game, plus the dev kill stand-in.
func _wire() -> void:
	var rivet_px: Callable = func() -> Vector2: return _city.target * SimConst.PX_PER_M
	_view.fx_triggers.player_id = CityCharacters.RIVET_ID
	_view.fx_triggers.listen(Events, _world.context().clock, rivet_px)
	@warning_ignore("return_value_discarded")
	_view.fx_triggers.cued.connect(_on_cue)


func _on_cue(id: StringName, pos_px: Vector2, _angle: float, _tick: int) -> void:
	var rivet: Vector2 = _city.target * SimConst.PX_PER_M
	if id == &"death" and _kill_m > 0.0 and pos_px.distance_to(rivet) <= _kill_m * 32.0:
		Events.actor_killed.emit(CityCharacters.RIVET_ID, 0, &"melee")


## The dev captures (a clip or a kill beat) at the first --zooms zoom.
func _shoot_dev() -> bool:
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_out)
	_view.zoom = _zooms[0]
	if _clip.y > 0:
		return await _shoot_clip()
	return await _shoot_beat()


## Every 2nd frame from tick _clip.x, _clip.y frames: the fight as a 30 fps clip.
func _shoot_clip() -> bool:
	while _world.context().clock.tick() < _clip.x:
		await get_tree().process_frame
		_maybe_hit()
	var ppm: int = roundi(_zooms[0] * SimConst.PX_PER_M)
	var mode: String = _chars.blood.blood.mode
	var ok: bool = true
	for f: int in _clip.y:
		await RenderingServer.frame_post_draw
		_maybe_hit()
		if f % 2 == 0:
			var img: Image = get_viewport().get_texture().get_image()
			var file: String = "clip%s-%s-%dppm-%04d.png" % [_tag, mode, ppm, f / 2]
			ok = img != null and img.save_png(_out.path_join(file)) == OK and ok
	return ok


## Waits for the first beat, then saves _beat_frames frames in a row (the beat as a clip).
func _shoot_beat() -> bool:
	var beat: KillBeat = _chars.blood.beat
	var guard: int = 0
	while beat.beats == 0 and guard < 3600:
		guard += 1
		await get_tree().process_frame
		_maybe_hit()
	var ppm: int = roundi(_zooms[0] * SimConst.PX_PER_M)
	var ok: bool = beat.beats > 0
	for f: int in _beat_frames:
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		var file: String = "beat%s-%s-%dppm-f%02d.png" % [_tag, beat.mode, ppm, f]
		ok = img != null and img.save_png(_out.path_join(file)) == OK and ok
	return ok


func _maybe_hit() -> void:
	var now: int = _world.context().clock.tick()
	if _hit_every > 0 and now - _last_hit >= _hit_every:
		_last_hit = now
		Events.player_hit.emit(&"robo-tazer")


func _summary() -> String:
	var b: CombatBlood = _chars.blood.blood
	var f: Dictionary = _view.fx_triggers.fired
	return (
		(
			"city_fight: tick=%d deaths=%d shots=%d kills=%d aimed=%d decals=%d draw_us=%d"
			+ " avg_us_per_frame=%.1f frames=%d beats=%d calm=%d soaked=%d missed=%d"
		)
		% [
			_world.context().clock.tick(),
			f[&"death"],
			f[&"shot"],
			b.kills,
			b.aimed,
			b.blood.live_decals(),
			b.blood.draw_us,
			float(b.spent_us) / maxi(b.frames, 1),
			b.frames,
			_chars.blood.beat.beats,
			_chars.blood.beat.calm_beats,
			_chars.blood.stains.soaked,
			_chars.blood.stains.missed
		]
	)


func _parse_args() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
		elif arg.begins_with("--at="):
			_at.clear()
			for v: String in arg.substr(5).split(","):
				_at.append(v.to_int())
		elif arg.begins_with("--zooms="):
			_zooms.clear()
			for v: String in arg.substr(8).split(","):
				_zooms.append(v.to_float())
		elif arg.begins_with("--focus="):
			_focus = arg.substr(8).to_int()
		elif arg.begins_with("--hit-rivet="):
			_hit_every = arg.substr(12).to_int()
		elif arg.begins_with("--rivet-kills="):
			_kill_m = arg.substr(14).to_float()
		elif arg.begins_with("--clip="):
			var v: PackedStringArray = arg.substr(7).split(",")
			_clip = Vector2i(v[0].to_int(), v[1].to_int() if v.size() > 1 else 600)
		elif arg.begins_with("--beat-frames="):
			_beat_frames = arg.substr(14).to_int()
		elif arg == "--no-stains":
			_no_stains = true
		elif arg.begins_with("--tag="):
			_tag = "-" + arg.substr(6)
		elif not (arg.begins_with("--blood=") or arg.begins_with("--kill-beat=")):
			printerr("city_fight: unknown argument %s" % arg)
			return false
	return true
