extends Node
## LaunchArgs autoload: user args after `--`. Unknown ones are kept for unknown(); the main scene
## (boot/boot.gd) warns about each, so a misspelt flag is not silently ignored.

const KNOWN_FLAGS: PackedStringArray = [
	"--seed",
	"--replay",
	"--record",
	"--devtools",
	"--look",
	"--reduced-motion",
	"--blood",
	"--kill-beat",
	"--gore",
	"--rigs",
	# d7-calls: the old defaults of the owner's 2026-11-05 picks on the main-scene paths (quest 1)
	"--ghosts-free",
	"--rivet-form",
	"--rivet-visor",
	"--rivet-tan",
	"--gun-grey",
	# d7-held: the befores of the hold A/Bs (read straight from the OS args by RigOffClaw / RigGrip)
	"--torch-off-arm",
	"--gun-off-claw",
	# n7-ranged: --feel=off turns the shared hit feel's camera effects off (before clips)
	"--feel",
	# n7-ranged: --react-snap=off drops the hit snap of a reaction family (the electro bolt's before)
	"--react-snap",
	# n7-ranged: --shard-pop=<ticks> the homing shard victim's freeze before the pop (owner call)
	"--shard-pop",
	# n7-ranged: --end-cue=off drops the weapons rows' end_cue (the rocket and nuke blast sound)
	"--end-cue",
	# n7-ranged: --quest-guns=off keeps quest 1's evening gun path (the before of the table guns)
	"--quest-guns",
	# n7-ranged: --flash-at=side prints the muzzle flash beside the aim line (the before of HeldMuzzle)
	"--flash-at",
	# n7-ranged: --throw-windup=off holds a ready molotov out at the aim (the before of RigThrow)
	"--throw-windup",
	# n7-ranged: --throw-sync=off starts the throw clip from 0 when the view sees it (the before)
	"--throw-sync",
	# n7-ranged: --wound-hold=off starts a light kill's stop on the hit tick (the before)
	"--wound-hold",
	# n7-ranged: --shot-trail=off draws no fading path behind a round that hit (the before)
	"--shot-trail",
	# n8-hud: --autostart presses quest 1's Start (debug builds; films the opening without a click)
	"--autostart",
	# n7-melee: --quest-blade=off gives quest 1 no carried blade (the before); =<id> another one
	"--quest-blade",
	# n7-melee: --hit-cues=off gives melee and ghost hits no sound of their own (the before)
	"--hit-cues",
	# n7-melee: --tell-cues=off gives the ghost attacks' wind-ups and whiffs no sound (the before)
	"--tell-cues",
	# n7-melee: --whiff makes the ghost reel's Tonnage slam once onto empty road (dev film)
	"--whiff",
	# n7-melee: --pullback=off cocks every timed strike back at the night's depth (the before)
	"--pullback",
	# n7-melee: --strike-sync=off starts Rivet's view strike from 0 when it is seen (the before)
	"--strike-sync",
	# n7-melee: --saw-part=off parts the chainsaw's halves sideways, under Rivet (the before)
	"--saw-part",
	# n7-melee: --melee-dir=off leaves a melee kill the last round's line (the before)
	"--melee-dir",
	# n7-melee: --kerf-glide=off snaps the camera with each Kerf blink (the before)
	"--kerf-glide",
	# view lab: the camera projection (data/tables/view.json; default top = the shipped view)
	"--view",
	# d8-weapons: --held-pitch=off draws the top-down held weapon under a tilt (the before);
	# =squash keeps the camera squash on the 55 part
	"--held-pitch",
	# d8-weapons: --shot-lift=off draws rounds and hits on the ground under a tilt (the before)
	"--shot-lift",
	# n8-hud: --showcase=off keeps the shipped pickup parts under a tilt (the before)
	"--showcase",
	# n8-hud: --pickup-hover=off lays a floor gun's showcase drawing on its disc (no hover)
	"--pickup-hover",
]

var _values: Dictionary[String, String] = {}
var _unknown: Array[String] = []


func _init() -> void:
	parse(OS.get_cmdline_user_args())


## Parses `--flag` and `--flag=value` pairs; unknown ones are kept for unknown().
func parse(args: PackedStringArray) -> void:
	_values.clear()
	_unknown.clear()
	for arg: String in args:
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			_unknown.append(arg)
			continue
		_values[flag] = arg.substr(flag.length() + 1) if arg.contains("=") else ""


func has(flag: String) -> bool:
	return _values.has(flag)


func value(flag: String) -> String:
	return _values.get(flag, "")


func unknown() -> PackedStringArray:
	return PackedStringArray(_unknown)
