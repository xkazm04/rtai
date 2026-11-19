extends Node
## One simulation tick per film frame. Only the cuts reposition Rivet. The normal pilot,
## collision, rig feed, projection, occlusion and city chunk renderer handle each approach.

var stage: ArenaStage
var ctx: WorldContext
var city: CitySystem
var view: CollectCallView
var set_root: Node
var route: VaultCourseRoute = VaultCourseRoute.new()
var args: ArenaArgs = ArenaArgs.parse()
var stills: Array[int] = []
var drawing: bool
var ppm: int
var output: String


func play(known: PackedStringArray) -> int:
	drawing = DisplayServer.get_name() != "headless"
	if not _options(known):
		return 2
	ViewMode.select(args.text("--view", "combo"))
	for i: int in VaultCourseRoute.SUBJECTS.size():
		if i in [0, 3]:
			_open(i == 3)
		if not route.set_shot(stage, i):
			Log.warn("vault-course", "no clear approach for " + VaultCourseRoute.SUBJECTS[i])
			return 1
		_place()
		for k: int in VaultCourseRoute.SHOT:
			var tick: int = i * VaultCourseRoute.SHOT + k
			if not _step(k, tick):
				return 1
			if drawing:
				await RenderingServer.frame_post_draw
				if tick in stills and not _save(tick):
					return 1
			await get_tree().process_frame
	return 0


func _options(known: PackedStringArray) -> bool:
	for flag: String in args.values:
		if not known.has(flag):
			Log.warn("vault-course", "unknown argument " + flag)
			return false
	if args.text("--ppm", "32") not in ["32", "64"]:
		return false
	ppm = int(args.text("--ppm", "32"))
	if args.text("--view", "combo") not in ["top", "tilt", "tilt70", "combo"]:
		return false
	output = args.text("--out")
	for s: String in args.text("--stills").split(",", false):
		if not s.is_valid_int() or int(s) < 0 or int(s) >= VaultCourseRoute.SHOT * 5:
			return false
		stills.append(int(s))
	if stills.is_empty():
		return true
	return drawing and output != "" and DirAccess.make_dir_recursive_absolute(output) == OK


func _open(street: bool) -> void:
	if set_root != null:
		set_root.free()
	set_root = Node.new()
	add_child(set_root)
	ctx = World.build_context(Events, Data, 1918)
	var stations: ArenaStations = ArenaStations.new()
	var plan: ArenaPlan = ArenaPlan.shipped()
	stations.add_file(ArenaStations.DIR + "/arena.json")
	for station: ArenaStation in stations.stations:
		station.spawns.clear()
	if street:
		plan = ArenaPlan.shipped(plan.city_base)
	else:
		var wall: ArenaStation.Prop = ArenaStation.Prop.new()
		wall.kind = "cover_high"
		wall.size = Vector2(2.4, 0.8)
		wall.at = Vector2(15, 13.95)
		stations.stations[0].props.append(wall)
	stage = ArenaStage.new(plan, stations)
	if street:
		stage.cells = StageCells.shipped()
		city = CitySystem.new(true)
		city.setup(ctx)
		city.steer_by_input = false
		city.spawner.targets = CityTargets.street(0, 0, 0)
	stage.setup(ctx)
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	view = null


func _place() -> void:
	stage.pilot.stop()
	stage.pilot.motion.mover.facing = route.dir
	stage.arena.rivet.pos = route.start
	stage.arena.rivet.facing = route.dir
	if city != null:
		city.focus = route.focus
		city.target = route.start
		@warning_ignore("return_value_discarded")
		city.residency.update(city.focus)
	if drawing and view == null:
		view = CollectCallView.new()
		view.stage_view.free()
		view.stage_view = ArenaFloorView.new()
		view.px_per_m = ppm
		if city != null:
			view.city = city
			view.city_view = CityView.new()
			view.city_view.clock = ctx.clock
		view.bind(stage, CollectCallWorld.new(stage), null)
		set_root.add_child(view)
		view.hud_view.visible = false
		var cast: ArenaRigs = ArenaRigs.new()
		set_root.add_child(cast)
		@warning_ignore("return_value_discarded")
		cast.attach(stage, view, ctx)
		cast.ghost_view.hud.hide()
		PropOcclusion.for_view(view)
	if view != null:
		view.focus = route.focus
		@warning_ignore("return_value_discarded")
		view.fill_street()


func _step(k: int, tick: int) -> bool:
	var input: TickInput = route.input(k, stage.pilot.actions)
	stage.step(tick, input)
	ctx.clock.complete_tick()
	if city != null:
		city.target = stage.arena.rivet.pos
		city.step(tick, TickInput.new())
	if k != VaultCourseRoute.PRESS:
		return true
	var motion: PlayerMotion = stage.pilot.motion
	if not motion.vault.enabled:
		Log.info("vault-course", "%d %s roll" % [tick, route.subject])
		return motion.phase == PlayerMotion.Phase.ROLL
	var hit: VaultProbe.Hit = motion.vault.hit
	var reason: StringName = hit.reason if hit != null else &"unprobed"
	Log.info(
		"vault-course", "%d %s %s at %s" % [tick, route.subject, reason, stage.arena.rivet.pos]
	)
	if route.subject == "cover_high":
		return reason == &"too_high"
	if route.subject == "landing_blocked":
		return reason == &"landing_blocked" and motion.velocity() == Vector2.ZERO
	return reason == &"ok" and motion.phase == PlayerMotion.Phase.VAULT


func _save(tick: int) -> bool:
	var path: String = (
		"%s_%d_%s_t%03d.png"
		% [
			ViewMode.shared().id,
			ppm,
			"after" if stage.pilot.motion.vault.enabled else "before",
			tick
		]
	)
	return get_viewport().get_texture().get_image().save_png(output.path_join(path)) == OK
