extends Node
## Same city port, rig and car view as play. Stop the automatic clock and advance exactly one
## input per draw, so a shot named for a tick has passed through both the sim and the renderer.

const KNOWN_FLAGS: PackedStringArray = ["--out", "--ppm", "--clip", "--view", "--car-doors"]
const NEEDS_WINDOW: bool = true
const FIXED_FPS: int = 60
const SHOTS: Dictionary[int, String] = {
	119: "on-foot",
	124: "approach",
	131: "seat",
	220: "drive",
	316: "open",
	319: "step-out",
	329: "on-foot-again"
}

var _world: World = World.new()
var _svc: VehicleService
var _out: String
var _clip: bool
var _ready_to_step: bool
var _capturing: bool


func _ready() -> void:
	var args: PackedStringArray = LaunchArgs.unknown()
	var ppm: int = 32
	for arg: String in args:
		if not KNOWN_FLAGS.has(arg.get_slice("=", 0)):
			_fail("unknown argument " + arg)
			return
		if arg.begins_with("--out="):
			_out = arg.substr(6)
		elif arg.begins_with("--ppm="):
			ppm = arg.substr(6).to_int()
	_clip = args.has("--clip")
	if _out.is_empty() or ppm not in [32, 64] or ViewMode.shared().id != &"tilt70":
		_fail("requires --out=<dir>, --ppm=32 or 64 and --view=tilt70")
		return
	if DirAccess.make_dir_recursive_absolute(_out) != OK:
		_fail("cannot create " + _out)
		return
	_world.start(Events, Data, 31)
	var built: Array[Object] = VehicleFrameSetup.build(_world, self, &"", false)
	_svc = built[0]
	var chars: CityCharacters = built[1]
	var view: CityView = built[2]
	view.rig = null
	view.zoom = float(ppm) / SimConst.PX_PER_M
	VehicleDoorRoute.park(_svc, _svc.cars[0], _svc.cars[0].pos)
	_world.loop().set_input(VehicleDoorRoute.new())
	add_child(_world)
	_world.set_process(false)
	await chars.bake()
	await view.prewarm()
	_ready_to_step = true


func _process(_delta: float) -> void:
	if not _ready_to_step or _capturing:
		return
	var tick: int = _world.context().clock.tick()
	if tick == VehicleDoorRoute.END:
		Log.info("car-doors", "captured %d ticks, final %s" % [tick, _world.loop().state_hash()])
		get_tree().quit(0)
		return
	_world.loop().step()
	if not _valid(tick):
		_fail(
			"unexpected driving or door state at tick %d, foot %s" % [tick, _svc.world.player_pos()]
		)
		return
	if SHOTS.has(tick) or (_clip and tick % 2 == 0):
		_capturing = true
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		if SHOTS.has(tick):
			_save(img, "%03d-%s.png" % [tick, SHOTS[tick]])
		if _clip and tick % 2 == 0:
			_save(img, "clip-%04d.png" % (tick >> 1))
		_capturing = false


func _valid(tick: int) -> bool:
	var d: VehicleDoors = _svc.doors
	var seat: int = VehicleDoorRoute.ENTER + (d.enter_ticks - 1 if d.enabled else 0)
	var leave: int = VehicleDoorRoute.EXIT + (d.exit_ticks - 1 if d.enabled else 0)
	if (_svc.driving != null) != (tick >= seat and tick < leave):
		return false
	var walk: bool = (
		(tick >= VehicleDoorRoute.ENTER and tick < seat)
		or (tick >= VehicleDoorRoute.EXIT and tick < leave)
	)
	return (d.car != null) == walk


func _save(img: Image, name: String) -> void:
	if img == null or img.save_png(_out.path_join(name)) != OK:
		_fail("could not save " + name)


func _fail(reason: String) -> void:
	Log.error("car-doors", reason)
	get_tree().quit(1)
