extends GutHookScript
## GUT's pre-run hook (.gutconfig.json pre_run_script): the unit suite runs under the `top` view.
## n9 made combo the boot default; a test that wants a tilt asks for it by id (ViewMode.of or
## ViewMode.select).


func run() -> void:
	ViewMode.select("top")
