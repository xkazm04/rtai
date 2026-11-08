extends Node
## The true-70 block test (d10), on the real city: stills of a building's south wall at the game's
## camera. Usage: godot --rendering-driver d3d12 --path project
##     res://dev/showcase/block70_still.tscn -- --out=<dir> --tag=<s> [--zoom=<z>] [--view=<id>]

const SHOOT_TICKS: Array[int] = [30, 90, 200]

var _out: String = "user://block70"
var _tag: String = "x"
var _zoom: float = 1.0


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
		elif arg.begins_with("--tag="):
			_tag = arg.substr(6)
		elif arg.begins_with("--zoom="):
			_zoom = arg.substr(7).to_float()
	var world: World = World.new()
	world.start(Events, Data, 53)
	add_child(world)
	var city: CitySystem = CitySystem.new(true)
	world.add_system(city)
	city.steer_by_input = false
	city.spawner.targets = CityTargets.street(30, 4, 0)
	var drive: Block70Drive = Block70Drive.new(city)
	world.add_system(drive)
	var view: CityView = CityView.new()
	add_child(view)
	view.setup(city)
	var characters: CityCharacters = CityCharacters.new(city, view, world.context())
	await characters.bake()
	await view.prewarm()
	view.zoom = _zoom
	world.set_process(false)
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_out)
	while world.context().clock.tick() <= SHOOT_TICKS[-1]:
		world.loop().step()
		await get_tree().process_frame
		if world.context().clock.tick() in SHOOT_TICKS:
			await RenderingServer.frame_post_draw
			var img: Image = get_viewport().get_texture().get_image()
			@warning_ignore("return_value_discarded")
			img.save_png(_out.path_join("%s_t%d.png" % [_tag, world.context().clock.tick()]))
	printerr("block70: spot=%s" % drive.spot)
	get_tree().quit(0)
