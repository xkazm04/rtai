class_name GunplayHook
extends ArenaHook
## Lane gunplay in the arena (station `gunplay_range`, data/tables/arena_stations/gunplay.json):
## `--weapon=<weapons.json id>` arms Rivet with that table gun (GunHand) on the arena's real
## CombatArena, so every behaviour of the row runs on the arena's fighters (FightAreas: splash,
## knockdown, burn panic, fire patches, chain, stun), the pit's contractors tell their bursts
## (GuardTell) and every landed round goes through the shared HitLink (knockback slide). Without
## --weapon the arena keeps its own Gloria and GuardBrain, so the arena's scenarios do not move.
## A bot (--bot=...) holds the trigger, so a semi gun re-taps (GunHand.tap). `--cam=fight` (dev
## capture, the pit only) frames Rivet and the hostile he fights (FightCam), view only.

var weapon: StringName = &""
var link: HitLink = null
var _arena: CombatArena = null
var _cam: FightCam = null
var _view: CollectCallView = null


func setup(stage: ArenaStage, ctx: WorldContext) -> void:
	var bot: bool = false
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--weapon="):
			weapon = StringName(arg.substr(9))
		bot = bot or arg.begins_with("--bot=")
	if weapon == &"":
		return
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


func step(_stage: ArenaStage, tick: int) -> void:
	if link != null:
		link.step()
		link.hold = 0
	if _cam != null:
		_view.focus = _cam.step(_arena, tick)


func attach_view(view: Node) -> void:
	var cc: CollectCallView = view as CollectCallView
	if _arena == null or cc == null or cc.city != null:
		return  # the city's camera follows city.focus, which also streams the chunks: left alone
	if "--cam=fight" in OS.get_cmdline_user_args():
		_view = cc
		_cam = FightCam.new()


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
