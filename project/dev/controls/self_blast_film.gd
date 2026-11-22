extends Node
## A live range dummy across a firing port. The same sidestep carries Rivet behind concrete
## while the rocket is in flight. Both takes use the same input tape and the same target.
## Run at --fixed-fps 60 with -- --beat=hit|wall --out=<absolute frame directory>.

const KNOWN_FLAGS: PackedStringArray = ["--beat", "--out", "--ppm", "--still-only", "--still-age"]
const RUN_TICKS: int = 480
const START: Vector2 = Vector2(-4.5, 1.05)
const TARGET: Vector2 = Vector2(0.0, -1.32)
const RESOLUTION: Vector2i = Vector2i(1920, 1080)

var stage: ArenaStage
var ctx: WorldContext
var actions: PlayerActions
var wall: bool
var tick: int = 0
var fire_tick: int = -1
var impact_tick: int = -1
var hp_before: float
var hp_lost: float
var shielded: bool
var in_range: bool
var ppm: float
var still_only: bool
var still_age: int
var out_dir: String
var capturing: bool = false
@onready var heading: Label = %Heading
@onready var health: Label = %Health
@onready var impact: Label = %Impact


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var beat: String = args.text("--beat", "hit")
	if beat not in ["hit", "wall"]:
		_fail("Use --beat=hit or --beat=wall.")
		return
	wall = beat == "wall"
	ppm = args.number("--ppm", 32.0)
	still_only = args.has("--still-only")
	# The fireball contracts before these frames. The dummy and Rivet read through the ring.
	still_age = int(args.number("--still-age", 24 if wall else 23))
	out_dir = args.text("--out")
	if not out_dir.is_empty():
		if not out_dir.is_absolute_path() or DirAccess.make_dir_recursive_absolute(out_dir) != OK:
			_fail("Use an absolute, writable frame directory.")
			return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_window().size = RESOLUTION
	ViewMode.select("tilt70")
	_build_arena()
	if DisplayServer.get_name() != "headless":
		_build_view()
	heading.text = tr("Rocket launcher / High wall") if wall else tr("Rocket launcher / Open floor")
	process_priority = -1000


func _build_arena() -> void:
	var plan: ArenaPlan = ArenaPlan.shipped()
	var deck: ArenaPlan.Area = ArenaPlan.Area.new()
	deck.rect = Rect2(-42, -23, 84, 46)
	deck.stenciled = false
	plan.areas.assign([deck])
	plan.rivet_start = START
	var station: ArenaStation = ArenaStation.new()
	var dummy: ArenaStation.Spawn = ArenaStation.Spawn.new()
	dummy.id = "range_target"
	dummy.kind = "target"
	dummy.at = TARGET
	station.spawns.append(dummy)
	for at: Vector2 in [Vector2(-6, -4), Vector2(6, -4), Vector2(-6, 4), Vector2(6, 4)]:
		_prop(station, "cone", at, Vector2.ONE * 0.7)
	if wall:
		_prop(station, "wall_high", Vector2(-4.17, -0.34), Vector2(8, 0.36))
		_prop(station, "wall_high", Vector2(4.17, -0.34), Vector2(8, 0.36))
	var stations: ArenaStations = ArenaStations.new()
	stations.stations.append(station)
	ctx = World.build_context(Events, Data, 7)
	actions = PlayerActions.shipped(true)
	stage = ArenaStage.new(plan, stations)
	stage.pilot = StagePilot.new(actions)
	stage.setup(ctx)
	stage.arena.rivet.weapon = &""
	var carry: RivetCarry = RivetWheel.carry_for(stage.arena)
	stage.pilot.carry = carry
	carry.take(&"rocket_launcher", stage.arena)


func _prop(station: ArenaStation, kind: String, at: Vector2, size_m: Vector2) -> void:
	var prop: ArenaStation.Prop = ArenaStation.Prop.new()
	prop.kind = kind
	prop.at = at
	prop.size = size_m
	station.props.append(prop)


func _build_view() -> void:
	var view: CollectCallView = CollectCallView.new()
	view.stage_view = preload("self_blast_range.gd").new()
	view.px_per_m = ppm
	view.focus = Vector2(0, 0.2)
	view.bind(stage, CollectCallWorld.new(stage), null)
	add_child(view)
	view.hud_view.hide()
	var cast: ArenaRigs = ArenaRigs.new()
	add_child(cast)
	@warning_ignore("return_value_discarded")
	cast.attach(stage, view, ctx)
	cast.ghost_view.hud.hide()
	cast.hidden[stage.targets.targets[0].fighter.id] = true
	PropOcclusion.for_view(view)
	add_child(preload("self_blast_status.gd").new(stage))


func _process(_delta: float) -> void:
	if capturing:
		return
	capturing = true
	tick += 1
	if tick == RUN_TICKS:
		set_process(false)
	var r: Fighter = stage.arena.rivet
	stage.step(tick, _shot_input(r))
	var areas: FightAreas = stage.arena.areas
	if impact_tick < 0 and areas != null and not areas.blasts.is_empty():
		_measure(areas.blasts[-1])
	health.text = (
		tr("Target   %.1f m") % r.pos.distance_to(TARGET)
		if impact_tick < 0
		else tr("%.1f → %.1f HP") % [hp_before, hp_before - hp_lost]
	)
	if (
		not out_dir.is_empty()
		and (not still_only or (impact_tick >= 0 and tick == impact_tick + still_age))
	):
		await RenderingServer.frame_post_draw
		if not _save_frame():
			_fail("Could not capture the full 1920 by 1080 viewport.")
			return
	capturing = false
	if tick >= RUN_TICKS or (still_only and impact_tick >= 0 and tick == impact_tick + still_age):
		var hit_target: bool = stage.targets.total_hits() == 1 and stage.shots_fired == 1
		var correct: bool = hp_lost == 0.0 if wall else hp_lost > 0.0
		if not in_range or not hit_target or shielded != wall or not correct:
			_fail("Take failed its hit, line-of-sight or HP check.")
		else:
			get_tree().quit()


func _shot_input(r: Fighter) -> TickInput:
	var aim: Vector2 = TARGET - r.pos
	var input: TickInput = TickInput.new(
		PlayerCommand.pack_aim(aim.normalized(), actions, aim.length())
	)
	if tick == 28:
		input.buttons |= 1 << actions.bit(&"weapon_slot_3")
	if tick >= 194 and r.pos.x < 1.05:
		input.move_x = TickInput.AXIS_MAX
	if fire_tick < 0 and r.pos.x >= -0.12:
		input.buttons |= 1 << actions.bit(&"fire")
		fire_tick = tick
		hp_before = r.hp
	return input


func _save_frame() -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.get_size() != RESOLUTION:
		return false
	if impact_tick >= 0 and tick == impact_tick + still_age:
		if img.save_png(out_dir.path_join("impact.png")) != OK:
			return false
	return still_only or img.save_jpg(out_dir.path_join("frame-%04d.jpg" % tick), 0.97) == OK


func _measure(blast: Vector3) -> void:
	var r: Fighter = stage.arena.rivet
	var at: Vector2 = Vector2(blast.x, blast.y)
	impact_tick = tick
	hp_lost = hp_before - r.hp
	in_range = at.distance_to(r.pos) - r.radius_m < blast.z
	shielded = stage.walls.blocks_kinds(at, r.pos, RivetBlast.HIGH)
	impact.text = tr("Blast damage   %.2f HP") % hp_lost
	Log.info(
		"self_blast_film",
		(
			"fire %d, hit %d at %s, Rivet %s, HP %.6f -> %.6f, shielded %s"
			% [fire_tick, impact_tick, at, r.pos, hp_before, r.hp, shielded]
		)
	)


func _fail(reason: String) -> void:
	set_process(false)
	Log.error("self_blast_film", reason)
	get_tree().quit(1)
