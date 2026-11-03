extends Node
## Lane gunplay: the pistol's full hit chain on the REAL fight. Quest 1 (collect-call) played by
## its bot in the printed D5 view (CollectCallView: the real Rivet rig art with claw_pistol, the
## dock contractors, d5-combat's blood), but Rivet's gun is the weapons.json pistol (GunHand,
## tapped by the bot), and every landed round goes through the shared HitFeel (HitLink): the
## kill hit-stop held here, the impact star (the victim flash) and the knockback slide. The
## camera is a CameraRig on foot (32 px/m). Fast-forwards to the first fight, then 1 tick a frame:
##   godot --path project --write-movie <f.avi> --fixed-fps 60 res://dev/gunplay/pistol_fight.tscn
##     -- --out=<dir> [--armored]  (contractors take the table's `armored` hp: 2.5 rounds)
##        [--ppm=48]  [--dodge]  (a scripted player strafes across each locked aim line)

const SKIP_PER_FRAME: int = 600
const LIVE_FRAMES: int = 1200
const HEROES: PackedInt32Array = [60, 240, 480, 900]
const RNG_SEED: int = 20261103
const HIT_SHOTS: int = 4
const FOCUS_EASE: float = 0.06
## --dodge: the strafe speed (a jog; the collisions lane's tackle needs a sprint over 5) and how
## long it runs past the lock (the burst's flight).
const STRAFE_MPS: float = 4.5
const STRAFE_AFTER: int = 24

var _out: String = "user://pistol_fight"
var _play: CollectCallPlay
var _view: CollectCallView = CollectCallView.new()
var _link: HitLink
var _rig: CameraRig = CameraRig.new()
var _live: int = -1
var _hold: int = 0
var _holds: int = 0
var _focus: Vector2 = Vector2.INF
## Rounds fired before the live part began (the first HIT_SHOTS live shots save a still too).
var _shots_at_live: int = 0
## Live frames on which a round landed (the first HIT_SHOTS also save a still: the impact star).
var _hit_frames: PackedInt32Array = PackedInt32Array()
## --armored: Fighter hp for each contractor (table armored hp / human hp); 0 = quest 1's own.
var _armored_hp: float = 0.0
## Enemy rounds that landed on Rivet (the rest of GuardTell.rounds missed or were dodged).
var _rivet_hits: int = 0
var _dodge: bool = false
## --spread=<k>: overrides the table's lock_spread_scale (GuardTell.spread_scale); <0 keeps it.
var _spread: float = -1.0
var _one_slot: bool = false  # --one-slot: GuardTell.one_slot (one gunner tells at a time)
var _dodges: int = 0
var _strafe_left: int = 0
var _strafe_dir: Vector2 = Vector2.ZERO


func _ready() -> void:
	if not _parse_args():
		get_tree().quit(2)
		return
	if DirAccess.make_dir_recursive_absolute(_out) != OK:
		Log.error("pistol_fight", "cannot create %s" % _out)
	_play = CollectCallPlay.begin()
	if _dodge:
		_play.after_act = _strafe
	var arena: CombatArena = _play.stage.arena
	var table: WeaponTable = WeaponTable.shipped()
	if _armored_hp > 0.0:
		_armored_hp = table.target_hp[&"armored"] / table.target_hp[&"human"]
	var rng: RngRegistry = RngRegistry.new(RNG_SEED)
	arena.gun = GunHand.make(table, &"pistol", rng.stream(&"gunplay"))
	arena.gun.tap = true
	arena.guard_tell = GuardTell.from_table(table)  # readable bursts: tell, lock, slow rounds
	arena.guard_tell.one_slot = _one_slot
	if _spread >= 0.0:
		arena.guard_tell.spread_scale = _spread
	arena.rivet.weapon = &"gloria"  # the view's armed state (the rig's claw_pistol cell)
	_link = HitLink.make(arena, HitFeel.shipped(_rig), table)
	@warning_ignore("return_value_discarded")
	arena.struck.connect(_on_struck)
	_view.bind(_play.stage, _play.port, _play.system)
	_view.cast_view.hit_link = _link
	add_child(_view)
	_view.print_stage.rig = _rig
	# a clean frame: quest 1's dialogue box would cover the lower third of the fight
	(_view.hud_view.get_parent() as CanvasLayer).visible = false


## The user args; false on an unknown one.
func _parse_args() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
		elif arg == "--armored":
			_armored_hp = 1.0
		elif arg == "--dodge":
			_dodge = true
		elif arg == "--one-slot":
			_one_slot = true
		elif arg.begins_with("--ppm="):
			_view.px_per_m = arg.substr(6).to_float()
		elif arg.begins_with("--spread="):
			_spread = arg.substr(9).to_float()
		else:
			return false
	return true


func _process(_delta: float) -> void:
	if not _play.running():
		_done()
		return
	if _live < 0:
		for i: int in SKIP_PER_FRAME:
			_tick()
			if _play.stage.arena.hostiles_alive() > 0:
				_live = 0
				_hold = 0
				_shots_at_live = _play.stage.arena.gun.shots_fired
				break
		return
	_live += 1
	if _hold > 0:
		_hold -= 1
	else:
		_tick()
	# eased, so a kill (the nearest hostile changes) never cuts the camera
	var want: Vector2 = _frame_focus()
	_focus = want if _focus == Vector2.INF else _focus.lerp(want, FOCUS_EASE)
	_view.focus = _focus
	if HEROES.has(_live):
		_save.call_deferred(_live)
	if _live >= LIVE_FRAMES:
		_done()


func _tick() -> void:
	var hits_before: int = _link.hits
	var shots_before: int = _play.stage.arena.gun.shots_fired
	_play.tick_once()
	_armor()
	_link.step()
	var shots_now: int = _play.stage.arena.gun.shots_fired
	if _live >= 0 and shots_now > shots_before and shots_now - _shots_at_live <= HIT_SHOTS:
		_save.call_deferred(_live)
	if _live >= 0 and _link.hits > hits_before:
		@warning_ignore("return_value_discarded")
		_hit_frames.append(_live)
		if _hit_frames.size() <= HIT_SHOTS:
			_save.call_deferred(_live)
	if _link.hold > 0:
		_hold = _link.hold
		_holds += 1
		_link.hold = 0


## --armored: a contractor not yet armoured takes the armoured hp (before any round lands).
func _armor() -> void:
	for h: Fighter in _play.stage.arena.hostiles:
		if _armored_hp > 0.0 and h.max_hp < _armored_hp:
			h.max_hp = _armored_hp
			h.hp = _armored_hp


## --dodge (after the bot acted, before the step): on a lock, Rivet strafes across the locked
## line instead of holding the bot's post (alternating sides per dodge).
func _strafe() -> void:
	var arena: CombatArena = _play.stage.arena
	for h: Fighter in arena.hostiles:
		if h.alive() and h.tell_left == arena.guard_tell.lock_ticks - 1:
			# a strafe already running keeps its side (flipping walks back into the first line)
			if _strafe_left <= 0:
				_strafe_dir = h.facing.orthogonal() * (1.0 if _dodges % 2 == 0 else -1.0)
				_dodges += 1
			_strafe_left = arena.guard_tell.lock_ticks + STRAFE_AFTER
	if _strafe_left > 0 and arena.rivet.alive():
		_strafe_left -= 1
		_play.stage.intent.move_to = Vector2.INF
		_play.stage.intent.move_by = _strafe_dir * STRAFE_MPS * SimClock.TICK_DT


## Between Rivet and the nearest live hostile, so the fight is in frame.
func _frame_focus() -> Vector2:
	var arena: CombatArena = _play.stage.arena
	var best: Vector2 = arena.rivet.pos
	var d: float = INF
	for h: Fighter in arena.hostiles:
		if h.alive() and h.pos.distance_to(arena.rivet.pos) < d:
			d = h.pos.distance_to(arena.rivet.pos)
			best = h.pos
	return arena.rivet.pos.lerp(best, 0.5)


func _save(f: int) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	var png: String = "pistol-fight-%dppm-f%04d.png" % [roundi(_view.px_per_m), f]
	if img.save_png(_out.path_join(png)) != OK:
		Log.error("pistol_fight", "frame %d not saved" % f)


func _done() -> void:
	var arena: CombatArena = _play.stage.arena
	var line: String = (
		"pistol_fight: live %d shots %d hits %d kills %d hitstops %d rivet_hp %.2f enemy %d/%d"
		% [
			_live,
			arena.gun.shots_fired,
			_link.hits - _rivet_hits,
			_link.kills,
			_holds,
			arena.rivet.hp,
			_rivet_hits,
			arena.guard_tell.rounds,
		]
	)
	line += " dodges %d" % _dodges
	Log.info("pistol_fight", line + " hit_frames %s" % str(_hit_frames))
	printerr(line)
	get_tree().quit(0)


func _on_struck(victim: Fighter, _dir: Vector2, _lethal: bool, _weapon: StringName) -> void:
	if victim.kind == Fighter.Kind.RIVET:
		_rivet_hits += 1
