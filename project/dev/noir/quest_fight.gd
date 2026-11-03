extends Node
## D-Noir on the REAL fight (lane noir): quest 1 (collect-call) played by its bot, drawn by
## CollectCallView (placeholder ink) under the noir pass, with NoirCombatFx bound to the play's
## own EventBus (actor_killed / player_hit from CombatArena.damage), MuzzleFlash on every new
## round (one lit frame), and hit-stop (the play is held for impact.hit_stop_ticks). Fast-
## forwards to the first fight, then plays 1 tick per frame. Record with the movie maker:
##   godot --path project --write-movie <f.avi> --fixed-fps 60 res://dev/noir/quest_fight.tscn
##     -- --out=<dir> [--flashes=off]  (off = the flashes-off accessibility mode)
## --phone: fast-forward to the first ringing payphone instead (the objective cue), framed on it.

const KNOWN_FLAGS: PackedStringArray = ["--out", "--flashes", "--phone"]
const SKIP_PER_FRAME: int = 600
const HUD_SHADER: String = "res://assets/shaders/look_noir_hud.gdshader"
const LIVE_FRAMES: int = 900
const HEROES: PackedInt32Array = [120, 300, 600, 899]

var _out: String = "user://noir"
var _play: CollectCallPlay
var _view: CollectCallView = CollectCallView.new()
var _noir: NoirLook = NoirLook.new()
var _blood: BloodFx = BloodFx.new()
var _flash: MuzzleFlash = MuzzleFlash.new()
var _stains: BloodStains = BloodStains.new()
var _impact: ImpactFrame = ImpactFrame.new()
var _fx: NoirCombatFx = NoirCombatFx.new()
var _live: int = -1
var _hold: int = 0
var _shots_seen: Dictionary[Shot, bool] = {}
## --phone: the ringing payphone the camera holds on ("" = the fight).
var _phone: String = ""
var _want_phone: bool = false
## --phone: the objective cue in the noir style (white arcs in an ink casing) over the D4 ring.
var _cue: NoirCue = null


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			get_tree().quit(2)
			return
		if flag == "--out":
			_out = arg.substr(6)
		elif flag == "--phone":
			_want_phone = true
		else:
			_impact.budget.enabled = arg != "--flashes=off"
	var made: bool = DirAccess.make_dir_recursive_absolute(_out) == OK
	if not made:
		printerr("quest_fight: cannot create %s" % _out)
	_play = CollectCallPlay.begin()
	_view.bind(_play.stage, _play.port, _play.system)
	add_child(_view)
	# The HUD prints above the noir pass and the comic beat (no rain or threshold over the text).
	(_view.hud_view.get_parent() as CanvasLayer).layer = ImpactFrame.LAYER + 1
	var hud_print: ShaderMaterial = ShaderMaterial.new()
	hud_print.shader = load(HUD_SHADER) as Shader
	_view.hud_view.material = hud_print
	_view.add_child(_blood)
	_view.add_child(_flash)
	_view.add_child(_stains)
	_flash.budget = _impact.budget
	for n: Node in [_noir, _impact, _fx]:
		add_child(n)
	_fx.px_per_m = Ink.PX_PER_M
	_fx.player_id = _play.stage.arena.rivet.id
	_fx.locate = _locate
	_fx.to_screen_uv = _to_uv
	_fx.set_stains(_stains)
	_fx.bind(_play.bus(), _blood, _impact)
	_add_player_fluid()
	@warning_ignore("return_value_discarded")
	_fx.hit_stop.connect(func(t: int) -> void: _hold = t)


func _process(_delta: float) -> void:
	if not _play.running():
		_done()
		return
	if _live < 0:
		for i: int in SKIP_PER_FRAME:
			_play.tick_once()
			if _started():
				_live = 0
				break
		return
	_live += 1
	_impact.step_ticks(1)
	_flash.step_ticks(1)
	_stains.step_ticks(1)
	if _hold > 0:
		_hold -= 1
	else:
		_play.tick_once()
		_blood.step_ticks(1)
		_fx.step_ticks(1)
	_new_shots()
	_view.focus = _frame_focus()
	_ring_cue()
	var light: Dictionary = {"flash": 1.0 if _flash.lit() else 0.0}
	if _flash.lit():
		light["flash_uv"] = _to_uv(_flash.lit_at())
	_noir.apply(light)
	_noir.update(_view.get_viewport().get_canvas_transform().origin * -1.0, float(_live))
	if HEROES.has(_live):
		_save.call_deferred(_live)
	if _live >= LIVE_FRAMES:
		_done()


## Rivet's own fluid (blood_fx.json `player`: oil) just above the blood.
func _add_player_fluid() -> void:
	var oil: BloodFx = _fx.make_player_fx()
	if oil != null:
		_view.add_child(oil)
		_view.move_child(oil, _blood.get_index() + 1)


## --phone: the noir cue rings while the phone does.
func _ring_cue() -> void:
	if _phone.is_empty():
		return
	if _cue == null:
		_cue = NoirCue.new()
		_view.add_child(_cue)
	var stage: CollectCallStage = _play.stage
	_cue.visible = stage.router.ringing(_phone)
	if _cue.visible:
		_cue.show_ring(Ink.px(stage.layout.phones[_phone]), stage.tick)


## True once the part to film has begun: the first fight, or with --phone the first ringing phone.
func _started() -> bool:
	if not _want_phone:
		return _play.stage.arena.hostiles_alive() > 0
	for phone: String in _play.stage.layout.phones:
		if _play.stage.router.ringing(phone):
			_phone = phone
			return true
	return false


## The camera between Rivet and the nearest live hostile, so the fight is in frame (with
## --phone: between Rivet and the ringing phone).
func _frame_focus() -> Vector2:
	if not _phone.is_empty():
		return _play.stage.arena.rivet.pos.lerp(_play.stage.layout.phones[_phone], 0.5)
	var arena: CombatArena = _play.stage.arena
	var best: Vector2 = arena.rivet.pos
	var d: float = INF
	for h: Fighter in arena.hostiles:
		if h.alive() and h.pos.distance_to(arena.rivet.pos) < d:
			d = h.pos.distance_to(arena.rivet.pos)
			best = h.pos
	return arena.rivet.pos.lerp(best, 0.5)


func _new_shots() -> void:
	for s: Shot in _play.stage.arena.shots:
		if not _shots_seen.has(s):
			_shots_seen[s] = true
			_flash.fire(Ink.px(s.pos), s.vel)


func _save(f: int) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	if img.save_png(_out.path_join("quest-fight-48ppm-f%03d.png" % f)) != OK:
		printerr("quest_fight: frame %d not saved" % f)


func _done() -> void:
	printerr(
		(
			"quest_fight: live %d kills %d hits %d decals %d"
			% [_live, _fx.kills, _fx.hits, _blood.live_decals()]
		)
	)
	get_tree().quit(0)


func _locate(id: int) -> Vector2:
	var arena: CombatArena = _play.stage.arena
	if id == arena.rivet.id:
		return arena.rivet.pos
	for h: Fighter in arena.hostiles:
		if h.id == id:
			return h.pos
	return Vector2.INF


func _to_uv(px: Vector2) -> Vector2:
	var xf: Transform2D = get_viewport().get_canvas_transform()
	return (xf * px) / get_viewport().get_visible_rect().size
