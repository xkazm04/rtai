class_name RivetTour
extends ArenaGame
## n10 rivet (dev scene, `dev/rivet_motion/rivet_tour.tscn`): the arena under RivetTourBot with the
## recorder. `-- --rigs --loadout=<weapon> --tour-out=<abs path prefix> --start=pad --ppm=64`.
## Without --loadout Rivet keeps the arena's Gloria.


func _ready() -> void:
	super._ready()
	var args: ArenaArgs = ArenaArgs.parse()
	var area: ArenaPlan.Area = null
	for a: ArenaPlan.Area in session.plan.areas:
		area = a if a.id == args.text("--start", "pad") else area
	var home: Vector2 = area.rect.get_center()
	var bot: RivetTourBot = RivetTourBot.new(session.stage, session.actions, home)
	if args.text("--tour-kind") == "trans":
		bot = RivetTransBot.new(session.stage, session.actions, home)
	if args.text("--tour-kind") == "bare":  # the bare walk and run, 8 octants, nothing else
		session.stage.arena.gun = null
		session.stage.arena.rivet.weapon = &""
		bot.lens = RivetTourBot.LEN_BARE
	session.world.loop().set_input(bot)
	add_child(RivetTourRec.new(self, bot, args.text("--tour-out")))
