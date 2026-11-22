extends Node
## Two matched 8 s takes. Walk across the muzzle line and fire past the end of the wall.
## The rocket hits the same range dummy in both takes. Rivet keeps walking during its flight.
## Run at --fixed-fps 60 with -- --beat=hit|wall --out=<absolute frame directory>.

const KNOWN_FLAGS: PackedStringArray = ["--beat", "--out"]
const RUN_TICKS: int = 480
const START: Vector2 = Vector2(-1.2, -7.5)
const TARGET: Vector2 = Vector2(1.9, -0.65)
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
	heading.text = tr("Rocket launcher · High wall") if wall else tr("Rocket launcher · Open floor")
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
	for at: Vector2 in [Vector2(-8, -4), Vector2(7, -4), Vector2(-8, 5), Vector2(7, 5)]:
		_prop(station, "cone", at, Vector2.ONE * 0.7)
	if wall:
		_prop(station, "wall_high", Vector2(-0.2, 2.72), Vector2(0.4, 6.0))
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
	view.stage_view = ArenaFloorView.new()
	view.px_per_m = 32
	view.focus = Vector2(0, -1)
	view.bind(stage, CollectCallWorld.new(stage), null)
	add_child(view)
	view.hud_view.hide()
	var cast: ArenaRigs = ArenaRigs.new()
	add_child(cast)
	@warning_ignore("return_value_discarded")
	cast.attach(stage, view, ctx)
	PropOcclusion.for_view(view)


func _process(_delta: float) -> void:
	if capturing:
		return
	capturing = true
	tick += 1
	if tick == RUN_TICKS:
		set_process(false)
	var r: Fighter = stage.arena.rivet
	var aim: Vector2 = TARGET - r.pos
	var input: TickInput = TickInput.new(
		PlayerCommand.pack_aim(aim.normalized(), actions, aim.length())
	)
	if tick == 28:
		input.buttons |= 1 << actions.bit(&"weapon_slot_3")
	if tick >= 180 and r.pos.y < 1.15:
		input.move_y = TickInput.AXIS_MAX
	if fire_tick < 0 and r.pos.y >= -0.7:
		input.buttons |= 1 << actions.bit(&"fire")
		fire_tick = tick
		hp_before = r.hp
	stage.step(tick, input)
	var areas: FightAreas = stage.arena.areas
	if impact_tick < 0 and areas != null and not areas.blasts.is_empty():
		_measure(areas.blasts[-1])
	health.text = tr("Health   %.2f / %.0f") % [r.hp, r.max_hp]
	if not out_dir.is_empty():
		await RenderingServer.frame_post_draw
		if not _save_frame():
			_fail("Could not capture the full 1920 by 1080 viewport.")
			return
	capturing = false
	if tick >= RUN_TICKS:
		var hit_target: bool = stage.targets.total_hits() == 1 and stage.shots_fired == 1
		var correct: bool = hp_lost == 0.0 if wall else hp_lost > 0.0
		if not in_range or not hit_target or shielded != wall or not correct:
			_fail("Take failed its hit, line-of-sight or HP check.")
		else:
			get_tree().quit()


func _save_frame() -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.get_size() != RESOLUTION:
		return false
	if impact_tick >= 0 and tick == impact_tick + 4:
		if img.save_png(out_dir.path_join("impact.png")) != OK:
			return false
	return img.save_jpg(out_dir.path_join("frame-%04d.jpg" % tick), 0.97) == OK


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
