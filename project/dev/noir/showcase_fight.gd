extends Node
## D-Noir showcase (lane noir, dev only): Rivet against two cop RIGS at the junction, in rain,
## under the noir pass. The bodies are full cutout rigs (CharacterRigs) driven by
## NoirFightScript; the city around them is the real city (a thin street crowd). Kills go
## through the REAL Events.actor_killed / player_hit, so the blood, the impact frames and the
## hit-stop are NoirCombatFx's. Cop rounds leave a white starburst and light the frame.
## Record with the movie maker for a fixed 60 fps:
##   godot --path project --resolution 1280x720 --write-movie <f.avi> --fixed-fps 60
##     res://dev/noir/showcase_fight.tscn -- --out=<dir> [--zoom=1.5] [--ink] [--d4]
## --flashes=off: the flashes-off accessibility mode (calm beats, no muzzle light).
## --car-pass: a scripted car brakes in and parks with its headlights on the fight.
## --at=<x>,<y>: the fight (and the camera) at that world point in metres, not the junction.
## --d4 draws the same fight in the D4 look (the noir pass off; blood and beats unchanged).

const END: int = 660

var _a: NoirShowcaseArgs = NoirShowcaseArgs.new()
var _coats: NoirCoats = null
## --car-pass: a scripted car brakes in and stops with its headlights on the fight (noir only).
var _car: NoirCarPass = null
var _frame: int = 0
var _t: int = 0
var _hold: int = 0
## The hit-stop starts after the flash ticks, so the held pose is the knockback, not the wind-up.
var _hold_in: int = 0
var _hold_len: int = 0
var _live: bool = false
var _heroes: Dictionary[int, String] = {}
var _world: World = null
var _view: CityView = null
var _rigs: CharacterRigs = CharacterRigs.new()
var _fight: NoirFightScript = NoirFightScript.new()
var _blood: BloodFx = BloodFx.new()
## Rivet's own fluid (oil: sparks, then black) from blood_fx.json `player`; null = blood.
var _oil: BloodFx = null
var _flash: MuzzleFlash = MuzzleFlash.new()
var _city: CitySystem = null
var _stains: BloodStains = BloodStains.new()
var _impact: ImpactFrame = ImpactFrame.new()
var _fx: NoirCombatFx = NoirCombatFx.new()


func _ready() -> void:
	if not _args():
		get_tree().quit(2)
		return
	if DirAccess.make_dir_recursive_absolute(_a.out) != OK:
		printerr("showcase_fight: cannot create %s" % _a.out)
	PartMaterials.set_noir(_a.ink)
	var built: Array = NoirFrames.build_city(self, CityTargets.street(12, _a.cars, 0))
	_world = built[0]
	_view = built[1]
	_view.zoom = _a.zoom
	_view.set_noir(not _a.d4)
	var chars: CityCharacters = built[3]
	_city = built[2]
	chars.rivet_on_foot = false
	_stage()
	_blood.z_index = -1
	_view.actor_layer().add_child(_blood)
	_view.actor_layer().add_child(_rigs)
	_view.actor_layer().add_child(_flash)
	_view.actor_layer().add_child(_stains)
	_flash.budget = _impact.budget
	if _a.noir_parts:
		_wear_noir_parts()
	_rigs.setup(_world.context())
	add_child(_impact)
	_impact.hide_on_flash = [_view, _view.noir]
	add_child(_fx)
	_fx.player_id = NoirFightScript.RIVET
	_fx.locate = func(id: int) -> Vector2: return _fight.origin + _fight.pos.get(id, Vector2.INF)
	_fx.to_screen_uv = _to_uv
	_fx.set_stains(_stains)
	# D4 has no comic beat: --d4 keeps the blood and the hit-stop, not the impact frames.
	_fx.bind(Events, _blood, null if _a.d4 else _impact)
	_add_player_fluid()
	@warning_ignore("return_value_discarded")
	_fx.hit_stop.connect(_on_hit_stop)
	await chars.bake()
	await _view.prewarm()
	_live = true


func _args() -> bool:
	if not _a.parse(OS.get_cmdline_user_args()):
		return false
	_car = NoirCarPass.new() if _a.car_pass else null
	_coats = NoirCoats.new() if _a.coat else null
	if _a.flashes != "":
		_impact.budget.enabled = _a.flashes != "off"
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
	_rigs.zoom = _a.zoom
	_impact.step_ticks(1)
	_blood.step_ticks(1)
	_flash.step_ticks(1)
	_stains.step_ticks(1)
	if not held:
		_fx.step_ticks(1)
		_t += 1
		for cue: Array in _fight.step(_t, _rigs.feed):
			_cue(cue)
		_drive_car()
		if _coats != null:
			_coats.step(_rigs, PackedInt32Array([NoirFightScript.COP_A, NoirFightScript.COP_B]))
	if not _a.d4:
		var lit: bool = _flash.lit()
		var light: Dictionary = {"flash": 1.0 if lit else 0.0}
		if lit:
			light["flash_uv"] = _to_uv(_flash.lit_at())
		_view.noir.apply(light)
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
				_heroes[_frame] = "lit"
				_heroes[_frame + 1] = "shot"
		"hit":
			Events.player_hit.emit(&"pistol")
		"kill":
			Events.actor_killed.emit(NoirFightScript.RIVET, id, &"melee")
			for k: int in [1, 2, 4, 7, 30]:
				_heroes[_frame + k] = "kill%d" % id


## The fight, the city's focus and its camera at _a.at (the junction unless --at).
func _stage() -> void:
	_fight.origin = _a.at
	_city.focus = _a.at
	_city.target = _a.at


## --car-pass: the scripted car's nose and heading (world metres) for this live tick.
func _drive_car() -> void:
	if _car != null:
		var c: Vector4 = _car.at(_t)
		_view.noir.extra_cars = PackedVector4Array(
			[Vector4(c.x + _a.at.x, c.y + _a.at.y, c.z, c.w)]
		)


## The blood splats on the sim's walls; Rivet's own fluid (blood_fx.json `player`) lies on the
## ground under the rigs like the blood.
func _add_player_fluid() -> void:
	_blood.solid = _solid
	_oil = _fx.make_player_fx()
	if _oil != null:
		_oil.z_index = -1
		_view.actor_layer().add_child(_oil)


## Fills the shared part caches with the noir redraws before the showcase rigs are built.
func _wear_noir_parts() -> void:
	@warning_ignore("return_value_discarded")
	NoirParts.wear(PackedStringArray(["cop", "rivet"]))


func _on_hit_stop(ticks: int) -> void:
	if _a.d4 or _impact.calm():
		_hold = ticks
	else:
		_hold_in = _impact.sequence.size()
		_hold_len = ticks


func _save(f: int, tag: String) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	var ppm: int = roundi(_a.zoom * SimConst.PX_PER_M)
	var look: String = "d4" if _a.d4 else "noir"
	var file: String = "show-%s-%dppm-f%03d-%s.png" % [look, ppm, f, tag]
	if img.save_png(_a.out.path_join(file)) != OK:
		printerr("showcase_fight: frame %d not saved" % f)


## The sim's building cells are the walls the blood splats on.
func _solid(px: Vector2) -> bool:
	return _city.sim.cell_at(px.x / SimConst.PX_PER_M, px.y / SimConst.PX_PER_M) >= SimConst.C_BUILD


func _to_uv(px: Vector2) -> Vector2:
	var cam: Vector2 = _view.camera.position
	var view: Vector2 = get_viewport().get_visible_rect().size
	return ((px - cam) * _a.zoom + view * 0.5) / view
