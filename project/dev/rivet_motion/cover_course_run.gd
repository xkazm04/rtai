extends Node
## The same fixed-tick directions and fire presses in both arms. A stationary drill guard
## sends real rifle rounds from the south-east. The arena performs all culling and damage.

const CHAPTER: int = 315
const CENTER: Vector2 = Vector2(8, 16)
const GUARD_OFFSET: Vector2 = Vector2(5.4, 3.2)

var stage: ArenaStage
var guard: Fighter
var ctx: WorldContext
var set_root: Node
var args: ArenaArgs = ArenaArgs.parse()
var ppm: int
var stills: Array[int] = []
var output: String
var drawing: bool


func play(known: PackedStringArray) -> int:
	drawing = DisplayServer.get_name() != "headless"
	if not _options(known):
		return 2
	ViewMode.select(args.text("--view", "top"))
	for chapter: int in 2:
		_open("cover_low" if chapter == 0 else "cover_high")
		for k: int in CHAPTER:
			var tick: int = chapter * CHAPTER + k
			if not _step(k, tick):
				Log.warn("cover-course", "unexpected cover phase at tick %d" % tick)
				return 1
			if drawing:
				await RenderingServer.frame_post_draw
				if tick in stills and not _save(tick):
					return 1
			await get_tree().process_frame
		if stage.dodges.blocked == 0 or stage.shots_fired == 0:
			Log.warn("cover-course", "chapter %d missed its shot checks" % (chapter + 1))
			return 1
		Log.info(
			"cover-course",
			(
				"chapter %d stopped %d, fired %d, guard hp %.2f"
				% [chapter + 1, stage.dodges.blocked, stage.shots_fired, guard.hp]
			)
		)
	return 0


func _options(known: PackedStringArray) -> bool:
	for flag: String in args.values:
		if not known.has(flag):
			Log.warn("cover-course", "unknown argument " + flag)
			return false
	if args.text("--ppm", "32") not in ["32", "64"]:
		return false
	ppm = int(args.text("--ppm", "32"))
	if args.text("--view", "top") not in ["top", "tilt", "tilt70"]:
		return false
	output = args.text("--out")
	for s: String in args.text("--stills").split(",", false):
		if not s.is_valid_int() or int(s) < 0 or int(s) >= 2 * CHAPTER:
			return false
		stills.append(int(s))
	return (
		stills.is_empty()
		or (drawing and output != "" and DirAccess.make_dir_recursive_absolute(output) == OK)
	)


func _open(kind: String) -> void:
	if set_root != null:
		set_root.free()
	set_root = Node.new()
	add_child(set_root)
	ctx = World.build_context(Events, Data, 1904)
	var stations: ArenaStations = ArenaStations.new()
	var station: ArenaStation = ArenaStation.new()
	var prop: ArenaStation.Prop = ArenaStation.Prop.new()
	prop.kind = kind
	prop.at = CENTER
	prop.size = Vector2(3.2, 1.0)
	station.props.append(prop)
	stations.stations.append(station)
	stage = ArenaStage.new(ArenaPlan.shipped(), stations)
	stage.setup(ctx)
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	var arena: CombatArena = stage.arena
	arena.rivet.pos = CENTER + Vector2(-0.35, -3.1)
	arena.rivet.weapon = &"machine_pistol"
	arena.gun = GunHand.make(
		WeaponTable.shipped(), arena.rivet.weapon, ctx.rng.stream(&"course_gun")
	)
	guard = Fighter.make(Fighter.Kind.GUARD, 904, CENTER + GUARD_OFFSET, 20.0)
	guard.radius_m = arena.tuning.human["radius_m"]
	guard.weapon = &"assault-rifle"
	guard.cooldown = 10000
	arena.hostiles.append(guard)
	if drawing:
		_make_view()


func _make_view() -> void:
	var view: CollectCallView = CollectCallView.new()
	view.stage_view.free()
	view.stage_view = ArenaFloorView.new()
	view.px_per_m = ppm
	view.bind(stage, CollectCallWorld.new(stage), null)
	set_root.add_child(view)
	view.hud_view.hide()
	var cast: ArenaRigs = ArenaRigs.new()
	set_root.add_child(cast)
	@warning_ignore("return_value_discarded")
	cast.attach(stage, view, ctx)
	cast.ghost_view.hud.hide()
	PropOcclusion.for_view(view)
	view.focus = CENTER + Vector2(1.2, 0.1)


func _step(k: int, tick: int) -> bool:
	var arena: CombatArena = stage.arena
	if k in [58, 90, 120, 169, 200, 268]:
		var dir: Vector2 = guard.pos.direction_to(arena.rivet.pos)
		guard.facing = dir
		arena.shots.append(Shot.fire(guard, dir, arena.tuning.weapon(guard.weapon)))
	stage.step(tick, _tape(k))
	ctx.clock.complete_tick()
	for s: Shot in arena.shots:
		if not s.from_rivet and stage.walls.blocks(s.pos, s.pos + s.vel * SimClock.TICK_DT):
			Log.info("cover-course", "tick %d hostile round at %s stops next tick" % [tick, s.pos])
	var cover: PlayerCover = stage.pilot.motion.cover
	if cover.enabled:
		if k in [40, 116, 219] and cover.phase != PlayerCover.Phase.IN:
			return false
		if k == 168 and (cover.phase != PlayerCover.Phase.PEEK or cover.blocks_fire()):
			return false
	return k != 246 or cover.phase == PlayerCover.Phase.OFF


func _tape(k: int) -> TickInput:
	var a: PlayerActions = stage.pilot.actions
	var move: Vector2 = Vector2.ZERO
	var aim: Vector2 = Vector2.ZERO
	var bits: int = 0
	if k >= 8 and k < 29:
		move = Vector2.DOWN
	if k == 29:
		bits |= 1 << a.bit(&"cover")
	if k >= 45 and k < 98:
		aim = Vector2.RIGHT
	if k >= 98 and k < 140:
		move = Vector2.RIGHT
	if k >= 150 and k < 194:
		aim = (GUARD_OFFSET - Vector2(2.4, -1.1)).normalized()
		if k >= 160 and k < 186:
			bits |= 1 << a.bit(&"fire")
	if k >= 241 and k < 271:
		move = Vector2.UP
	var axes: Vector2 = move * TickInput.AXIS_MAX
	return TickInput.new(bits | PlayerCommand.pack_aim(aim, a), roundi(axes.x), roundi(axes.y))


func _save(tick: int) -> bool:
	var arm: String = "after" if stage.pilot.motion.cover.enabled else "before"
	var file: String = "%s_%d_%s_t%03d.png" % [ViewMode.shared().id, ppm, arm, tick]
	return get_viewport().get_texture().get_image().save_png(output.path_join(file)) == OK
