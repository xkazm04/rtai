class_name CursorSweep
extends ArenaGame
## n11 hero (dev scene `dev/rivet_motion/cursor_sweep.tscn`): the sweep bot and its recorder.
## `-- --rigs --ppm=64 --start=pad --sweep-out=<abs prefix> [--loadout=pistol] [--sweep-form=<id>]`
## A form is held on through the legs (its power's clock kept full), and its drawn octant logged.


func _ready() -> void:
	super._ready()
	var args: ArenaArgs = ArenaArgs.parse()
	var vp: Viewport = get_viewport()
	var centre: Callable = func() -> Vector2: return vp.get_visible_rect().size / 2.0
	var bot: CursorSweepBot = CursorSweepBot.new(session.live, session.actions, centre)
	var form: StringName = StringName(args.text("--sweep-form"))
	if form != &"":
		var order: Array[StringName] = session.stage.pilot.ghosts.forms.table.order
		bot.form_presses(maxi(0, order.find(form)))
	session.world.loop().set_input(bot)
	add_child(CursorSweepRec.new(self, bot, args.text("--sweep-out")))
