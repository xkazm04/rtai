class_name ArenaGame
extends Node
## The dev arena's scene (dev/arena/arena.tscn): ArenaSession under the player's hands, drawn
## by quest 1's CollectCallView (print pass, D5 look, blood) with ArenaFloorView as its floor.
## Args (after --): --ppm=<32|48|64|128> the zoom, --bot=range|course|pit|rivet|reel plays that
## station's (or the showcase's)
## scripted player, --shot=<png> saves one frame after --shot-tick=<tick> and quits,
## --telemetry=<json> writes the session's telemetry on exit, --arena=city the city proving block,
## --clean hides the dev HUD (clips of the game only), --start=<area id> stands Rivet in that
## area at boot (a station's capture; like the T teleport, a dev run that does not replay),
## --rigs draws the fighters on the cast rigs (ArenaRigs) instead of quest 1's sprites (the default
## since rivet-arsenal 2026-11-04: every weapon, swing and reaction lives on the rigs; --sprites
## opts out).
## Lane gunplay: --weapon=<weapons.json id> arms Rivet with a table gun (GunplayHook);
## --bot=gunplay plays the pit at that weapon's own reach (GunplayBot); --reach=<m> closes that
## reach for a capture (the city's lone kills land nearer Rivet, inside the frame's middle third).
## Lane human-reactions: --bot=react_line shoots each reaction-line dummy from four sides
## (--wide=<m> aims that far beside each, so every round is a near miss).
## --armored[=k]: the pit's humans take gunplay's armored hp (2.5 hits, or k), so the limp plays;
## Rivet's hp scales by as much (the fight lasts longer, its balance holds).
## Lane showcase: --riot makes each pit wave's first guard (from wave 2) a riot cop with a shield.

const TUNE_TICK: int = 300

var session: ArenaSession = null
var view: CollectCallView = null
var px_per_m: float = 32.0
var hud: ArenaHud = ArenaHud.new()
var panel: ArenaPanel = ArenaPanel.new()
var tuning: ArenaTuning = null
## The cast rigs under --rigs (null without).
var cast: ArenaRigs = null
var _shot: String = ""
var _shot_tick: int = 600
var _telemetry: String = ""
var _taken: bool = false
var _tune: String = ""
var _zoom_i: int = 0
var _area_i: int = 0
var _characters: CityCharacters = null


func _ready() -> void:
	RenderingServer.set_default_clear_color(Ink.CREAM)
	var args: ArenaArgs = ArenaArgs.parse()
	px_per_m = args.number("--ppm", 48.0 if args.text("--arena") == "alley" else px_per_m)
	_shot = args.text("--shot")
	_shot_tick = int(args.number("--shot-tick", 600.0))
	_telemetry = args.text("--telemetry")
	_tune = args.text("--tune")
	_open(args)
	_add_view()
	view.hud_view.visible = false
	@warning_ignore("return_value_discarded")
	ArenaKeys.install()
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = RenderLayers.canvas(&"hud")
	add_child(layer)
	hud.session = session
	hud.px_per_m = px_per_m
	layer.add_child(hud)
	ReelCaption.attach(layer, session.stage, view)  # the showcase director cut's title card
	if args.has("--horde"):  # corpse decay: the bodies on the floor against the cap
		HordeOverlay.attach(layer, session.stage)
	FightFrames.attach(self, args, session.world)  # perf-city: --frames=<json> frame log
	hud.visible = not args.has("--clean")  # a clip of the game only (the owner's sample)
	tuning = ArenaTuning.new(session.actions, session.stage.arena.tuning)
	tuning.hooks = session.stage.hooks
	panel.tick_now = session.tick
	panel.build(session.stations, tuning)
	panel.position = Vector2(8.0, 200.0)
	panel.visible = args.has("--panel")
	layer.add_child(panel)
	session.live.viewport = get_viewport()
	session.live.origin_px = func() -> Vector2: return get_viewport().get_visible_rect().size / 2.0
	session.live.px_per_m = func() -> float: return px_per_m


## The session (the dev arena, or the city proving block with --arena=city) and the bot.
func _open(args: ArenaArgs) -> void:
	var on_city: bool = args.text("--arena") == "city"
	var seed_v: int = int(args.number("--seed", ArenaSession.MASTER_SEED))  # a bot's seed sweep
	session = ArenaSession.open(Events, Data, seed_v, null, on_city)
	_dev_fight(args, on_city)
	if args.text("--bot") == "range":
		session.world.loop().set_input(ArenaRangeBot.new(session.stage, session.actions))
	elif args.text("--bot") == "course":
		session.world.loop().set_input(ArenaCourseBot.new(session.stage))
	elif args.text("--bot") == "pit":
		session.world.loop().set_input(ArenaPitBot.new(session.stage, session.actions))
	elif args.text("--bot") == "alley":  # lane look: the alley's close-up fight (features/alley)
		session.world.loop().set_input(AlleyBot.new(session.stage, session.actions))
	elif args.text("--bot") == "rivet":  # rivet-arsenal: walk, strafe, sprint, roll, claw combo
		session.world.loop().set_input(ArenaRivetBot.new(session.stage, session.actions))
	elif args.text("--bot") == "reel":  # the showcase lane's scripted fight (dev/showcase)
		session.world.loop().set_input(CombatReel.new(session.stage, session.actions))
	elif args.text("--bot") == "ghosts":  # lane ghost-powers: the ghost attacks' beat
		session.world.loop().set_input(GhostReelInput.attach(session.stage, session.actions))
	elif args.text("--bot") == "forms":  # lane ghost-forms: walk, transform, walk, transform back
		session.world.loop().set_input(FormsTourBot.of(session.stage, session.actions, args))
	elif args.text("--bot") == "arsenal":  # rivet-arsenal: the pit fight, a switch every 4 s
		session.world.loop().set_input(ArenaArsenalBot.new(session.stage, session.actions))
	elif args.text("--bot") == "lob":  # rivet-arsenal: molotovs at the claw cops from 9-14 m
		session.world.loop().set_input(ArenaLobBot.new(session.stage, session.actions))
	elif args.text("--bot") == "gunplay":  # lane gunplay: the pit at the --weapon's own reach
		session.world.loop().set_input(_gunplay_bot(args))
	elif args.text("--bot") == "react_line":  # lane human-reactions: each look from four sides
		session.world.loop().set_input(_react_line_bot(args))
	elif args.text("--bot") == "boss":  # n7-king: plays the --boss fight (dodges; --bot-stand)
		session.world.loop().set_input(_boss_bot(args))
	add_child(session.world)
	for a: ArenaPlan.Area in session.plan.areas:
		if a.id == args.text("--start") or (a.id == "alley" and args.text("--arena") == "alley"):
			teleport(a)


## `--bot=boss` (n7-king; its `--ghost=<id>` is BossBotGhost inside BossBot); with
## `--servo-ghost=<id>` (n7-servo, dev) the ghost's attack aimed at the knots of drones instead.
func _boss_bot(args: ArenaArgs) -> InputSource:
	var bot: BossBot = BossBot.new(session.stage, session.actions)
	var ghost: String = args.text("--servo-ghost")
	if ghost == "dent":  # Dent seizes the depot's van and drives it into Servo
		return ServoDentBot.wrap(bot)
	return ServoGhostBot.wrap(bot, ghost) if ghost != "" else bot


## lane gunplay: the pit bot at the --weapon's own reach (--lone films the burn death).
func _gunplay_bot(args: ArenaArgs) -> GunplayBot:
	var w_id: StringName = StringName(args.text("--weapon", "pistol"))
	var w: WeaponSpec = WeaponTable.shipped().weapon(w_id)
	var bot: GunplayBot = GunplayBot.new(session.stage, session.actions, w.range_m)
	bot.follow_burning = args.has("--lone")  # the lone capture films the burn death
	bot.reach_m = minf(bot.reach_m, args.number("--reach", bot.reach_m))
	return bot


## lane human-reactions: each look from four sides (--wide aims beside each dummy).
func _react_line_bot(args: ArenaArgs) -> ReactLineBot:
	var line: ReactLineBot = ReactLineBot.new(session.stage, session.actions)
	line.wide_m = args.number("--wide", 0.0)  # aim beside each dummy: near misses
	return line


## Dev flags that dress the fight before the bot takes it: --crowd, --armored, --riot.
func _dev_fight(args: ArenaArgs, on_city: bool) -> void:
	if on_city and args.has("--crowd"):  # lane human-reactions: a fuller street for the crowd clips
		session.city.spawner.targets = CityTargets.street(int(args.number("--crowd", 120.0)), 0, 0)
	if args.has("--armored"):  # lane human-reactions: pit humans live through hits (the limp)
		var t: WeaponTable = WeaponTable.shipped()
		var k: float = args.number("--armored", t.target_hp[&"armored"] / t.target_hp[&"human"])
		session.stage.arena.tuning.human["hp"] = k
		var r: Fighter = session.stage.arena.rivet  # and Rivet by as much: the same fight, longer
		r.max_hp *= k
		r.hp = r.max_hp
	if args.has("--riot"):  # lane showcase: riot cops in the pit (armored hp, the shield look)
		session.stage.pit.riot_hp = ArenaPit.armored_hp()
	if args.has("--horde"):  # corpse decay: back-to-back pit hordes, Rivet hard to kill
		session.stage.pit.horde()
		var rivet: Fighter = session.stage.arena.rivet
		rivet.max_hp *= ArenaPit.HORDE_RIVET_HP
		rivet.hp = rivet.max_hp


## Quest 1's view on the arena's floor; on the city its CityView and baked characters as well.
func _add_view() -> void:
	view = CollectCallView.new()
	view.px_per_m = px_per_m
	view.stage_view = ArenaFloorView.new()
	if session.city != null:
		view.city = session.city
		view.city_view = CityView.new()
		view.city_view.clock = session.world.context().clock
	view.bind(session.stage, CollectCallWorld.new(session.stage), null)
	add_child(view)
	if view.print_stage != null and ArenaArgs.parse().has("--look"):  # n5-look: A/B of the print
		view.print_stage.look_id = StringName(ArenaArgs.parse().text("--look"))
	for hook: ArenaHook in session.stage.hooks:
		hook.attach_view(view)
	if not ArenaArgs.parse().has("--sprites"):  # the cast rigs (--rigs), not quest 1's sprites
		cast = ArenaRigs.new()
		add_child(cast)
		Log.info(
			"arena", "cast rigs: %s" % cast.attach(session.stage, view, session.world.context())
		)
	if session.city != null:
		_characters = CityCharacters.new(session.city, view.city_view, session.world.context())
		if cast != null:  # human-reactions: the street trips over the fight's dead
			cast.crowd = _characters.crowd
		_characters.rivet_on_foot = false
		_characters.bake()


func _process(_delta: float) -> void:
	if _tune != "" and session.tick() >= TUNE_TICK:
		var ok: bool = panel.set_live(_tune.get_slice(":", 0), _tune.get_slice(":", 1).to_float())
		hud.note = "tuned %s live (%s)" % [_tune, ok]
		_tune = ""
	if _shot != "" and not _taken and session.tick() >= _shot_tick:
		_taken = true
		_save_shot.call_deferred()


func _input(event: InputEvent) -> void:
	if session != null:
		session.live.note_event(event)  # rivet-arsenal: the wheel's weapon switch latches here


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"arena_panel"):
		panel.visible = not panel.visible
	elif event.is_action_pressed(&"arena_zoom"):
		_zoom_i = (_zoom_i + 1) % session.plan.zoom_ppm.size()
		set_zoom(session.plan.zoom_ppm[_zoom_i])
	elif event.is_action_pressed(&"arena_teleport"):
		_area_i = (_area_i + 1) % session.plan.areas.size()
		teleport(session.plan.areas[_area_i])
	elif event.is_action_pressed(&"arena_save_telemetry"):
		var path: String = _telemetry if _telemetry != "" else "user://arena/telemetry.json"
		hud.note = "telemetry -> %s (%s)" % [path, session.write_telemetry(path)]


func set_zoom(ppm: float) -> void:
	px_per_m = ppm
	hud.px_per_m = ppm
	if view.print_stage != null:
		view.print_stage.zoom = ppm / SimConst.PX_PER_M


## Dev teleport (outside the input tape: a live run that teleports does not replay; logged).
func teleport(area: ArenaPlan.Area) -> void:
	session.stage.arena.rivet.pos = area.rect.get_center()
	session.pilot.stop()
	hud.note = "teleported to %s (this run no longer replays)" % area.name
	Log.info("arena", "teleport to %s at tick %d" % [area.id, session.tick()])


func _save_shot() -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_shot.get_base_dir())
	var err: Error = img.save_png(_shot)
	Log.info("arena", "frame %s at tick %d (%s)" % [_shot, session.tick(), error_string(err)])
	_quit()


func _quit() -> void:
	if _telemetry != "":
		@warning_ignore("return_value_discarded")
		session.write_telemetry(_telemetry)
	get_tree().quit(0)


## Window closed, or the engine's --quit-after ended a clip capture: the telemetry is written.
func _notification(what: int) -> void:
	var leaving: bool = what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE
	if leaving and _telemetry != "" and session != null:
		@warning_ignore("return_value_discarded")
		session.write_telemetry(_telemetry)
	if leaving and cast != null and cast.react != null:  # human-reactions: the fight's reactions
		var r: ReactLink = cast.react
		var n: Array[int] = [r.wounds, r.blocks, r.deaths, r.near.ducks]
		Log.info("arena", "react: %d wounds (%d on a shield), %d deaths, %d ducks" % n)
		cast = null
	if leaving and _characters != null:  # lane human-reactions: the street's reactions, counted
		var c: CrowdReact = _characters.crowd
		var n: Array[int] = [c.cowers, c.startles, c.trips, c.deaths]
		Log.info("arena", "crowd: %d cowers (%d at a death), %d trips, %d deaths" % n)
		_characters = null
