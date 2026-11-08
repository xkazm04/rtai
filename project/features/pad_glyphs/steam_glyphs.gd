class_name SteamGlyphs
extends RefCounted
## n10-handheld: Steam Input's own origin glyph for a prompt's label ("A", "RB"), when the backend
## has one (a remapped pad draws the button the player really pressed). Under Steam Input the pad
## reads as Xbox-style, so the prompt's label is the Xbox label the backend asks for. Empty until
## GodotSteam is vendored: the one call that fills it in is SteamBackend.action_glyph_path. A PNG
## file read as image data (Image.load_from_file, never a Resource), one read per path.

static var _textures: Dictionary[String, Texture2D] = {}


## Steam's glyph for `label`, or null: the caller keeps the drawn cell.
static func texture(label: String) -> Texture2D:
	var path: String = Platform.action_glyph_path(label)
	if path == "":
		return null
	if not _textures.has(path):
		_textures[path] = _read(path)
	return _textures[path]


static func _read(path: String) -> Texture2D:
	var image: Image = null
	if FileAccess.file_exists(path):
		image = Image.load_from_file(path)
	if image == null or image.is_empty():
		Log.warn("platform", "steam glyph unreadable: %s" % path)
		return null
	return ImageTexture.create_from_image(image)
