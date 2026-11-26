extends RefCounted
## n31-24: opens the prologue yard or the gauntlet street for a prop walk (see prop_walk.gd): waves
## and the opening encounter held off, the opening line box hidden, tilt 70.

const YARD: PackedScene = preload("res://boot/prologue/prologue.tscn")
const GAUNTLET: PackedScene = preload("res://dev/gauntlet/gauntlet.tscn")

var arena: CombatArena
var loop: SimLoop
var street: GauntletStreet


func yard(parent: Node, ppm: float) -> void:
	ViewMode.select("tilt70")
	var game: PrologueGame = YARD.instantiate() as PrologueGame
	parent.add_child(game)
	game.result_path = ""
	game.world.set_process(false)
	arena = game.stage.arena
	loop = game.world.loop()
	game.stage.hooks.erase(game.encounter)
	for child: Node in game.get_children():
		if child is PrologueView:
			var view: PrologueView = child as PrologueView
			view.hud_feed = HudFeed.new()
			view.px_per_m = ppm
			view.print_stage.zoom = ppm / SimConst.PX_PER_M


func gauntlet(parent: Node, ppm: float) -> void:
	var g: Node = GAUNTLET.instantiate()
	g.set("camera_ppm", ppm)
	parent.add_child(g)
	g.set_physics_process(false)
	var session: GauntletSession = g.get("session")
	var waves: GauntletWaves = g.get("waves")
	session.stage.hooks.erase(waves)
	arena = session.stage.arena
	street = session.street
	loop = session.world.loop()
	session.world.set_process(false)
