extends Node
## Vehicles evidence frames (lane d-vehicles): the real World + CitySystem + CityView +
## CityCharacters + VehicleService (as World._register_features wires them) and the real camera
## rig, which eases from on_foot (32 px/m) to car (48 px/m, look-ahead) on vehicle_entered. Rivet
## stands beside a parked sedan, gets in, drives a fixed route (full throttle through a pedestrian
## in the lane, an S-bend, a handbrake slide), and frames are saved at fixed sim ticks; --clip
## saves every 2nd tick for 20 s (assemble with ffmpeg at 30 fps). Windowed only. Usage:
##   godot --rendering-driver d3d12 --path project res://dev/showcase/vehicle_frame.tscn --
##     --out=<dir> [--clip] [--look=<id>] [--scene=carnage|yield] [--soul] [--cue-shots]
## --scene=yield: Rivet stays on foot beside the parked sedan while three cars stop behind it;
## --blind hands traffic no obstacles (the behaviour before set_obstacles); --car-zoom starts the
## camera at 48 px/m. --grade=night prints the night grade (car and fire lights on).
## --soul-traffic soul-hijacks the civilian sim cars within 60 m at tick SOUL_TRAFFIC_TICK.
## --cue-shots also saves a frame 1 and 20 ticks after every crash / car_wreck cue.

const MASTER_SEED: int = 31
const SHOTS: Dictionary[int, String] = {
	12: "on-foot-beside-car",
	50: "entered-easing",
	120: "full-throttle",
	205: "s-bend",
	330: "top-speed",
	375: "handbrake-slide",
	440: "slide-recover",
	620: "stopped",
}
const CARNAGE_SHOTS: Dictionary[int, String] = {
	26: "beside-the-taxi",
	34: "hijack-driver-thrown",
	60: "driving-off",
	150: "ram-approach",
	178: "ram-1",
	260: "reverse",
	360: "ram-2",
	450: "reverse-2",
	560: "ram-3",
	660: "aftermath",
	900: "after-the-wreck",
}
const YIELD_SHOTS: Dictionary[int, String] = {
	12: "yield-cars-coming",
	75: "yield-braking",
	180: "yield-queued",
	300: "yield-t300",
	360: "yield-t360",
	420: "yield-still-queued",
	480: "yield-t480",
	540: "yield-t540",
	600: "yield-t600",
	720: "yield-t720",
}
const SOUL_TRAFFIC_TICK: int = 30
const CLIP_TICKS: int = 20 * SimClock.TICK_RATE

var _out: String = "user://vehicle_frame"
var _clip: bool = false
var _look: StringName = &""
var _carnage: bool = false
var _soul: bool = false
var _soul_traffic: bool = false
var _cue_shots: bool = false
var _shots: Dictionary[int, String] = SHOTS.duplicate()
var _world: World = null
var _svc: VehicleService = null
var _done: Dictionary[int, bool] = {}
var _busy: bool = false


func _ready() -> void:
	if not _parse_args():
		get_tree().quit(2)
		return
	_world = World.new()
	_world.start(Events, Data, MASTER_SEED)
	var w: Array[Object] = VehicleFrameSetup.build(_world, self, _look, _carnage)
	_svc = w[0]
	var characters: CityCharacters = w[1]
	var view: CityView = w[2]
	_world.set_process(false)
	_world.loop().set_input(
		VehicleFrameSetup.Carnage.new() if _carnage else VehicleFrameSetup.Route.new()
	)
	if VehicleFrameSetup.chasers:
		_world.loop().set_input(InputSource.new())
	printerr("vehicle_frame: input set at tick %d" % _world.context().clock.tick())
	if _cue_shots:
		_follow_cues()
	add_child(_world)
	await characters.bake()
	await view.prewarm()
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_out)
	_world.set_process(true)


func _process(_delta: float) -> void:
	if _world == null or _busy:
		return
	var tick: int = _world.context().clock.tick()
	if _soul and _svc.driving != null and not _svc.driving.soul_hijacked:
		_svc.soul_hijack(_svc.driving.id)  # Gearbox's ability, once it lands, sets this
	if _soul_traffic and tick >= SOUL_TRAFFIC_TICK and _svc.traffic.state.is_empty():
		_soul_traffic_near()
	var last: int = CLIP_TICKS if _clip else _shots.keys().max()
	if tick > last + 2:
		printerr("vehicle_frame: done at tick %d, cars %d" % [tick, _svc.cars.size()])
		get_tree().quit(0)
		return
	var name: String = ""
	if _clip and tick % 2 == 0 and not _done.has(tick):
		name = "clip-%04d" % (tick >> 1)
	for t: int in _shots:
		if not _clip and tick >= t and not _done.has(t):
			_done[t] = true
			name = "%03d-%s" % [t, _shots[t]]
	if name != "":
		_done[tick] = true
		_shoot(name)


## Wraps the cue sink: each crash / wreck queues two shots (the FX at birth, then the debris).
func _follow_cues() -> void:
	var fire: Callable = _svc.cues.sink
	_svc.cues.sink = func(id: StringName, px: Vector2, a: float, t: int) -> void:
		fire.call(id, px, a, t)
		printerr("vehicle_frame: cue %s at tick %d" % [id, t])
		if id == &"crash" or id == &"car_wreck":
			_shots[t + 1] = "cue-%s" % id
			_shots[t + 20] = "cue-%s-after" % id


func _shoot(name: String) -> void:
	_busy = true
	_world.set_process(false)
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	if img != null:
		@warning_ignore("return_value_discarded")
		img.save_png(_out.path_join(name + ".png"))
	_world.set_process(true)
	_busy = false


func _parse_args() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
		elif arg == "--clip":
			_clip = true
		elif arg == "--soul":
			_soul = true
		elif arg == "--soul-traffic":
			_soul_traffic = true
		elif arg == "--cue-shots":
			_cue_shots = true
		elif arg == "--car-zoom":
			VehicleFrameSetup.car_zoom = true
		elif arg == "--blind":
			VehicleFrameSetup.blind = true
		elif arg == "--scene=yield":
			VehicleFrameSetup.chasers = true
			_shots = YIELD_SHOTS.duplicate()
		elif arg == "--scene=carnage":
			_carnage = true
			_shots = CARNAGE_SHOTS.duplicate()
		elif arg.begins_with("--grade="):
			VehicleFrameSetup.grade = StringName(arg.substr(8))
		elif arg.begins_with("--look="):
			_look = StringName(arg.substr(7))
		else:
			printerr("vehicle_frame: unknown argument %s" % arg)
			return false
	return true


## The Gearbox slice on sim traffic: every civilian car near Rivet shows the hijacked plate.
func _soul_traffic_near() -> void:
	var recs: PackedFloat64Array = _svc.world.cars_near(_svc.world.player_pos(), 60.0)
	for r: int in range(0, recs.size(), VehicleWorld.CAR_STRIDE):
		if recs[r + 1] < 0.5:
			_svc.soul_hijack_traffic(int(recs[r]))
