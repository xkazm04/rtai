class_name GunplayHook
extends ArenaHook
## Lane gunplay in the arena (station `gunplay_range`, data/tables/arena_stations/gunplay.json):
## `--weapon=<weapons.json id>` arms Rivet with that table gun (GunHand) on the arena's real
## CombatArena, so every behaviour of the row runs on the arena's fighters (FightAreas: splash,
## knockdown, burn panic, fire patches, chain, stun), the pit's contractors tell their bursts
## (GuardTell) and every landed round goes through the shared HitLink (knockback slide). Without
## --weapon the arena keeps its own Gloria and GuardBrain, so the arena's scenarios do not move.
## A bot (--bot=...) holds the trigger, so a semi gun re-taps (GunHand.tap). `--cam=fight` (dev
## capture; in the pit it moves the focus, on the city block it leans the view only) frames Rivet
## and the hostile he fights (FightCam), view only.
## `--lone` (dev capture, the 04:00 readability rule) makes every pit wave one guard, so each
## kill is filmed on a victim standing alone (a dev run that does not replay, like --start).

var weapon: StringName = &""
var link: HitLink = null
var _arena: CombatArena = null
var _cam: FightCam = null
var _view: CollectCallView = null
var _lone: bool = false
var _kills_seen: int = 0


func setup(stage: ArenaStage, ctx: WorldContext) -> void:
	var bot: bool = false
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--weapon="):
			weapon = StringName(arg.substr(9))
		bot = bot or arg.begins_with("--bot=")
	if weapon == &"":
		return
	if "--lone" in OS.get_cmdline_user_args() and stage.pit != null:
		lone(stage.pit)
		_lone = true
	var table: WeaponTable = WeaponTable.shipped()
	if not table.weapons.has(weapon):
		Log.warn("gunplay", "arena: no weapon %s in weapons.json; the arena keeps Gloria" % weapon)
		weapon = &""
		return
	_arena = stage.arena
	_arena.gun = GunHand.make(table, weapon, ctx.rng.stream(&"gunplay"))
	_arena.gun.tap = bot
	_arena.guard_tell = GuardTell.from_table(table)
	link = HitLink.make(_arena, HitFeel.shipped(CameraRig.new()), table)
	Log.info("gunplay", "arena: Rivet holds the table %s" % weapon)


## One guard per pit wave, every wave (the lone-victim capture).
static func lone(pit: ArenaPit) -> void:
	pit.first_wave = 1
	pit.grow = 0
	pit.max_wave = 1


func step(stage: ArenaStage, tick: int) -> void:
	if link != null:
		link.step()
		link.hold = 0
	if _lone and stage.pit.kills > _kills_seen:  # the capture's cut points
		_kills_seen = stage.pit.kills
		Log.info("gunplay", "lone kill %d at tick %d" % [_kills_seen, tick])
	if _cam != null:
		var at: Vector2 = _cam.step(_arena, tick)
		if _view.city != null:  # a view-only lean: city.focus (chunk streaming) stays on Rivet
			_view.city_lean_m = at - _arena.rivet.pos
		else:
			_view.focus = at


func attach_view(view: Node) -> void:
	var cc: CollectCallView = view as CollectCallView
	if _arena == null or cc == null:
		return
	if "--cam=fight" in OS.get_cmdline_user_args():
		_view = cc
		_cam = FightCam.new()
		if _lone:
			_cam.lean = FightCam.LONE_LEAN
			_cam.max_lean_m = FightCam.LONE_MAX_LEAN_M
			_cam.hold_ticks = FightCam.LONE_HOLD_TICKS
		if cc.city != null:  # leans the view only (city_lean_m), inside the actor margin
			_cam.max_lean_m = minf(_cam.max_lean_m, FightCam.CITY_MAX_LEAN_M)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(link.hits if link != null else -1)


func telemetry() -> Dictionary:
	if _arena == null:
		return {}
	var out: Dictionary = {"weapon": String(weapon), "shots": _arena.gun.shots_fired}
	out["hits"] = link.hits
	out["kills"] = link.kills
	var a: FightAreas = _arena.areas
	if a != null:
		out["knockdowns"] = a.knockdowns
		out["ignitions"] = a.ignitions
		out["chain_hits"] = a.chain_hits
	return out
