extends SceneTree
## d5-close evidence (iteration 10): one full-screen D5 card (loading art, finisher, boss intro;
## 1920x1081, no mipmaps) drawn as the HUD would, covering the window, and saved as <out>/card.png.
## Shows the minification at a 1280x800 window (0.74x) as plain linear vs look_d5_ui.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/d5_card.gd
##        -- --out=<dir> --card=<res:// png> [--ui] (--ui = through look_d5_ui at its defaults)

const UI_SHADER: String = "res://assets/shaders/look_d5_ui.gdshader"


func _initialize() -> void:
	var out: String = ""
	var card: String = ""
	var ui: bool = false
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		elif arg.begins_with("--card="):
			card = arg.substr(7)
		elif arg == "--ui":
			ui = true
		else:
			printerr("d5_card: unknown argument %s" % arg)
			quit(2)
			return
	if out == "" or card == "":
		printerr("d5_card: --out and --card are required")
		quit(2)
		return
	_shoot(out, card, ui)


func _shoot(out: String, card: String, ui: bool) -> void:
	var tex: TextureRect = TextureRect.new()
	tex.texture = load(card) as Texture2D
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tex.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if ui:
		var mat: ShaderMaterial = ShaderMaterial.new()
		mat.shader = load(UI_SHADER) as Shader
		tex.material = mat
	root.add_child(tex)
	tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for i: int in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	var made: int = DirAccess.make_dir_recursive_absolute(out)
	var err: int = made
	if err == OK:
		err = root.get_texture().get_image().save_png(out.path_join("card.png"))
	printerr("d5_card: exit %d" % err)
	quit(err)
