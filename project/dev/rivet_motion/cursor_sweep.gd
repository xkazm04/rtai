class_name CursorSweep
extends ArenaGame
## n11 hero (dev scene `dev/rivet_motion/cursor_sweep.tscn`): the sweep bot and its recorder.
## `-- --rigs --ppm=64 --start=pad --sweep-out=<abs prefix> [--loadout=pistol]`


func _ready() -> void:
	super._ready()
	var args: ArenaArgs = ArenaArgs.parse()
	var vp: Viewport = get_viewport()
	var centre: Callable = func() -> Vector2: return vp.get_visible_rect().size / 2.0
	var bot: CursorSweepBot = CursorSweepBot.new(session.live, session.actions, centre)
	session.world.loop().set_input(bot)
	add_child(CursorSweepRec.new(self, bot, args.text("--sweep-out")))
