extends SceneTree
## d5-close evidence (iteration 10): King's plan-view sprite moving (sub-pixel drift + a slow turn)
## over flat asphalt, every frame shot twice from the same pose: trilinear (d4-walk-NN.png) and
## look_d5_ui (d5-walk-NN.png), as a crop that follows him. masters tools/shimmer.py <out>
## then gives the look_d5_ui / trilinear ratio of the frame-to-frame change (extra = shimmer).
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/d5_king_move.gd
##        -- --out=<dir> [--ppm=<px per m>] (default 64) [--sharp=<k>] (look_d5_ui sharp)

const KING: String = "res://features/characters/art/d5/king/king_top.png"
const UI_SHADER: String = "res://assets/shaders/look_d5_ui.gdshader"
const KING_W_M: float = 3.6
const ASPHALT: Color = Color(0.31, 0.27, 0.28)
const FRAMES: int = 40
const STEP: Vector2 = Vector2(0.37, 0.21)  # screen px per frame
const TURN: float = 0.004  # rad per frame


func _initialize() -> void:
	var out: String = ""
	var ppm: float = 64.0
	var sharp: float = -1.0
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		elif arg.begins_with("--ppm="):
			ppm = arg.substr(6).to_float()
		elif arg.begins_with("--sharp="):
			sharp = arg.substr(8).to_float()
		else:
			printerr("d5_king_move: unknown argument %s" % arg)
			quit(2)
			return
	if out == "":
		printerr("d5_king_move: --out is required")
		quit(2)
		return
	_shoot(out, ppm, sharp)


func _shoot(out: String, ppm: float, sharp: float) -> void:
	RenderingServer.set_default_clear_color(ASPHALT)
	var king: Sprite2D = Sprite2D.new()
	king.texture = load(KING) as Texture2D
	king.scale = Vector2.ONE * KING_W_M * ppm / king.texture.get_width()
	king.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	root.add_child(king)
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = load(UI_SHADER) as Shader
	if sharp >= 0.0:
		mat.set_shader_parameter(&"sharp", sharp)
	var start: Vector2 = root.get_visible_rect().size * 0.5 - STEP * FRAMES * 0.5
	var box: int = int(KING_W_M * ppm * 1.2)
	var err: int = DirAccess.make_dir_recursive_absolute(out)
	for t: int in FRAMES:
		king.position = start + STEP * t
		king.rotation = 0.6 + TURN * t
		for ui: bool in [false, true]:
			king.material = mat if ui else null
			await process_frame
			await RenderingServer.frame_post_draw
			var img: Image = root.get_texture().get_image()
			var at: Vector2i = Vector2i(king.position.round()) - Vector2i(box, box) / 2
			var name: String = "%s-walk-%02d.png" % ["d5" if ui else "d4", t]
			if err == OK:
				err = img.get_region(Rect2i(at, Vector2i(box, box))).save_png(out.path_join(name))
	printerr("d5_king_move: exit %d" % err)
	quit(err)
