extends SceneTree
## Fixture for tools/dev/entries.test.mjs (never run, outside project/): a reel that knows its own
## cut length, so the runner derives --fixed-fps 60 --quit-after 900 from it.

const RUN_TICKS: int = 900


func _initialize() -> void:
	quit(0)
