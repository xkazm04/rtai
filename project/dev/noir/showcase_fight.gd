extends Node
## D-Noir showcase (lane noir, dev only): Rivet against two cop RIGS at the junction, in rain,
## under the noir pass. The bodies are full cutout rigs (CharacterRigs) driven by
## NoirFightScript; the city around them is the real city (a thin street crowd). Kills go
## through the REAL Events.actor_killed / player_hit, so the blood, the impact frames and the
## hit-stop are NoirCombatFx's. Cop rounds leave a white starburst and light the frame.
## Record with the movie maker for a fixed 60 fps:
##   godot --path project --resolution 1280x720 --write-movie <f.avi> --fixed-fps 60
##     res://dev/noir/showcase_fight.tscn -- --out=<dir> [--zoom=1.5] [--ink] [--d4]
## --d4 draws the same fight in the D4 look (the noir pass off; blood and beats unchanged).

const KNOWN_FLAGS: PackedStringArray = [
	"--out", "--zoom", "--ink", "--d4", "--noir-parts", "--coat"
]
## --noir-parts: the rigs wear the noir part redraws (same sizes, same alpha, same pivots).
const NOIR_ART: String = "res://features/characters/art/noir/"
const END: int = 660
const LIT: float = 0.25

var _out: String = "user://noir"
var _zoom: float = 1.5
var _ink: bool = false
var _d4: bool = false
var _noir_parts: bool = false
var _coats: NoirCoats = null
var _frame: int = 0
var _t: int = 0
var _hold: int = 0
## The hit-stop starts after the flash ticks, so the held pose is the knockback, not the wind-up.
var _hold_in: int = 0
var _hold_len: int = 0
var _live: bool = false
var _heroes: Dictionary[int, String] = {}
var _thresh: float = 0.46
var _world: World = null
var _view: CityView = null
var _rigs: CharacterRigs = CharacterRigs.new()
var _fight: NoirFightScript = NoirFightScript.new()
var _blood: BloodFx = BloodFx.new()
var _flash: MuzzleFlash = MuzzleFlash.new()
var _impact: ImpactFrame = ImpactFrame.new()
var _fx: NoirCombatFx = NoirCombatFx.new()


func _ready() -> void:
	if not _args():
		get_tree().quit(2)
		return
	if DirAccess.make_dir_recursive_absolute(_out) != OK:
		printerr("showcase_fight: cannot create %s" % _out)
	PartMaterials.set_noir(_ink)
	var built: Array = NoirFrames.build_city(self, CityTargets.street(12, 0, 0))
	_world = built[0]
	_view = built[1]
	_view.zoom = _zoom
	_view.set_noir(not _d4)
	var frame: Dictionary = _view.noir.params.get("frame", {})
	_thresh = frame.get("thresh", _thresh)
	var chars: CityCharacters = built[3]
	chars.rivet_on_foot = false
	_fight.origin = NoirFrames.JUNCTION
	_blood.z_index = -1
	_view.actor_layer().add_child(_blood)
	_view.actor_layer().add_child(_rigs)
	_view.actor_layer().add_child(_flash)
	if _noir_parts:
		_wear_noir_parts()
	_rigs.setup(_world.context())
	add_child(_impact)
	_impact.hide_on_flash = [_view, _view.noir]
	add_child(_fx)
	_fx.player_id = NoirFightScript.RIVET
	_fx.locate = func(id: int) -> Vector2: return _fight.origin + _fight.pos.get(id, Vector2.INF)
	_fx.to_screen_uv = _to_uv
	# D4 has no comic beat: --d4 keeps the blood and the hit-stop, not the impact frames.
	_fx.bind(Events, _blood, null if _d4 else _impact)
	@warning_ignore("return_value_discarded")
	_fx.hit_stop.connect(_on_hit_stop)
	await chars.bake()
	await _view.prewarm()
	_live = true


func _args() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("showcase_fight: unknown argument %s" % arg)
			return false
		var v: String = arg.substr(flag.length() + 1)
		if flag == "--out":
			_out = v
		elif flag == "--zoom":
			_zoom = v.to_float()
		elif flag == "--d4":
			_d4 = true
		elif flag == "--noir-parts":
			_noir_parts = true
		elif flag == "--coat":
			_coats = NoirCoats.new()
		else:
			_ink = true
	return true


func _process(_delta: float) -> void:
	if not _live:
		return
	_frame += 1
	if _hold_in > 0:
		_hold_in -= 1
		_hold = _hold_len if _hold_in == 0 else _hold
	var held: bool = _hold > 0
	_world.process_mode = Node.PROCESS_MODE_DISABLED if held else Node.PROCESS_MODE_INHERIT
	_hold = maxi(_hold - 1, 0)
	_view.noir.fixed_phase = float(_frame)
	_rigs.focus = _fight.origin * SimConst.PX_PER_M
	_rigs.zoom = _zoom
	_impact.step_ticks(1)
	_blood.step_ticks(1)
	_flash.step_ticks(1)
	if not held:
		_fx.step_ticks(1)
		_t += 1
		for cue: Array in _fight.step(_t, _rigs.feed):
			_cue(cue)
		if _coats != null:
			_coats.step(_rigs, PackedInt32Array([NoirFightScript.COP_A, NoirFightScript.COP_B]))
	if not _d4:
		_view.noir.apply({"thresh": _thresh + (LIT if _flash.lit() else 0.0)})
	var opening: bool = _t == 40 and not held
	if _heroes.has(_frame) or opening:
		_save.call_deferred(_frame, _heroes.get(_frame, "beat"))
	if _t >= END:
		printerr("showcase_fight: kills %d hits %d frames %d" % [_fx.kills, _fx.hits, _frame])
		get_tree().quit(0)


func _cue(cue: Array) -> void:
	var id: int = cue[1]
	match cue[0]:
		"shot":
			var rig: CutRig = _rigs.rig_for(id)
			if rig != null:
				var at: Vector2 = rig.muzzle_local()
				var target: Vector2 = (
					(_fight.origin + _fight.pos[NoirFightScript.RIVET]) * SimConst.PX_PER_M
				)
				_flash.fire(at, target - at)
				_heroes[_frame + 1] = "shot"
		"hit":
			Events.player_hit.emit(&"pistol")
		"kill":
			Events.actor_killed.emit(NoirFightScript.RIVET, id, &"melee")
			for k: int in [1, 2, 4, 7, 30]:
				_heroes[_frame + k] = "kill%d" % id


## Fills the shared part caches with the noir redraws before the showcase rigs are built.
## Every png in art/noir/<kind>/ replaces the part of that name (the coat png is unused here).
func _wear_noir_parts() -> void:
	for kind: String in ["cop", "rivet"]:
		var lib: PartLibrary = PartLibrary.of(kind)
		for file: String in ResourceLoader.list_directory(NOIR_ART + kind):
			if file.ends_with(".png"):
				var path: String = NOIR_ART + kind + "/" + file
				lib.textures[file.get_basename()] = load(path) as Texture2D


func _on_hit_stop(ticks: int) -> void:
	if _d4:
		_hold = ticks
	else:
		_hold_in = _impact.sequence.size()
		_hold_len = ticks


func _save(f: int, tag: String) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	var ppm: int = roundi(_zoom * SimConst.PX_PER_M)
	var look: String = "d4" if _d4 else "noir"
	var file: String = "show-%s-%dppm-f%03d-%s.png" % [look, ppm, f, tag]
	if img.save_png(_out.path_join(file)) != OK:
		printerr("showcase_fight: frame %d not saved" % f)


func _to_uv(px: Vector2) -> Vector2:
	var cam: Vector2 = _view.camera.position
	var view: Vector2 = get_viewport().get_visible_rect().size
	return ((px - cam) * _zoom + view * 0.5) / view
