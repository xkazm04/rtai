extends SceneTree
## n8-hud boss-taunt shot (windowed, d3d12, dev only, never shipped): runs the live arena (the
## boss fights) with the game's own args (e.g. --boss=king --view=combo --rigs) and lays a boss
## taunt over the live fight (BossTaunt's strip or the dialogue box with the face). The boss
## fight has no line system yet: the words are the voice bible's illustrative lines
## (boss_taunt_lines.json), shown for layout only. Loads BossTauntRun at run time (a -s main script
## must not name global classes at parse time). Its own settings come from the environment, so the
## game's LaunchArgs see only the game's flags: GTAI_TAUNT_AT=<frame of the first line> (default
## 150), GTAI_TAUNT_HOLD=<frames per line> (default 240), GTAI_TAUNT_FORM=strip|box (default
## BossTaunt.FORM: strip = under the boss bar, box = the quest dialogue box with the face).
## Usage: GTAI_TAUNT_AT=150 <godot> --rendering-driver d3d12 --path project
##   -s res://dev/showcase/boss_taunt.gd --write-movie <abs.avi> --fixed-fps 60 --quit-after 900
##   -- --boss=king --view=combo --rigs

const RUN: String = "res://dev/showcase/boss_taunt_run.gd"
const GAME: String = "res://dev/arena/arena.tscn"


func _initialize() -> void:
	var script: GDScript = load(RUN) as GDScript
	if script == null or not script.can_instantiate():
		printerr("boss_taunt: %s does not compile" % RUN)
		quit(1)
		return
	var run: Node = script.new()
	run.set("at_frame", OS.get_environment("GTAI_TAUNT_AT").to_int())
	run.set("hold_frames", OS.get_environment("GTAI_TAUNT_HOLD").to_int())
	run.set("game_scene", GAME)
	run.set("form", StringName(OS.get_environment("GTAI_TAUNT_FORM")))
	root.add_child(run)
