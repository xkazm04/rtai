extends SceneTree
## Fixture for tools/dev/entries.test.mjs (never run, outside project/): an entry that declares
## its own flag list, the way dev/bench/rig_bench_run.gd does. Not a catalogue: only this script.

const KNOWN_FLAGS: PackedStringArray = [
	"--bot",  # the station's scripted player
	"--ppm",
	"--out"
]


func _initialize() -> void:
	quit(0)
