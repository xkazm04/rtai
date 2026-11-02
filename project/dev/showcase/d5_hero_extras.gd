class_name D5HeroExtras
extends RefCounted
## d5-close hero shot street life (gap 2): a parked cruiser and sedan, the gunfight FX and the
## teal soul trail, loaded from a folder OUTSIDE the project (the masters' keyed sprites:
## gtai-masters/night/d5-close/borrowed/; vehicles and FX are the d4-production lane's raw D4
## sheets, the souls this lane's D5 sheet). Dev evidence only: nothing here ships, and a missing
## file is skipped, so the scene still shoots without the folder.

## sprite -> [x m, y m, length m along the art's long axis, rotation deg]
const SPOTS: Array[Array] = [
	["cruiser", 13.2, 2.3, 4.8, -18.0],
	["sedan_dark", 2.9, -10.2, 4.6, 90.0],
	["manhole", -6.5, 1.8, 1.25, 0.0],
	["drain_grate", 12.9, -3.45, 1.5, 0.0],
	["skid_marks", 8.0, 3.2, 6.0, -8.0],
	["oil_stain", 2.4, -7.4, 1.4, 0.0],
	["splat", 1.7, 0.5, 1.5, 20.0],
	["casing", 9.3, -0.2, 0.22, 35.0],
	["casing", 9.0, 0.3, 0.22, 110.0],
	["soul_wisp", 10.0, -3.5, 1.0, -90.0],
	["soul_3", 8.8, -3.3, 1.3, -96.0],
	["soul_2", 7.6, -3.05, 1.2, -98.0],
	["soul_1", 6.4, -2.8, 1.3, -100.0],
]
## cop 2 fires at Rivet: flash + tracer laid along the shot (from = cop 2's muzzle in the posed
## frame, to = Rivet; metres)
const SHOT_FROM: Vector2 = Vector2(7.25, -1.6)
const SHOT_TO: Vector2 = Vector2(4.8, -2.4)


## souls go to soul_parent (the actor layer, above the world print) with soul_mat;
## the rest to parent
static func place(
	parent: Node, dir: String, px: float, soul_parent: Node, soul_mat: Material
) -> int:
	var placed: int = 0
	for spot: Array in SPOTS:
		var name: String = spot[0]
		if name.begins_with("soul"):
			placed += _put(soul_parent, dir, spot, px, soul_mat)
		else:
			placed += _put(parent, dir, spot, px)
	var d: Vector2 = (SHOT_TO - SHOT_FROM).normalized()
	var deg: float = rad_to_deg(d.angle())
	var flash: Vector2 = SHOT_FROM + d * 0.5
	var tracer: Vector2 = SHOT_FROM + d * 1.4
	placed += _put(parent, dir, ["flash", flash.x, flash.y, 1.1, deg], px)
	placed += _put(parent, dir, ["tracer", tracer.x, tracer.y, 1.3, deg], px)
	return placed


static func _put(parent: Node, dir: String, spot: Array, px: float, mat: Material = null) -> int:
	var name: String = spot[0]
	var path: String = dir.path_join(name + ".png")
	if not FileAccess.file_exists(path):
		return 0
	var img: Image = Image.load_from_file(path)
	if img == null or img.is_empty():
		return 0
	if img.generate_mipmaps() != OK:
		return 0
	var s: Sprite2D = Sprite2D.new()
	s.texture = ImageTexture.create_from_image(img)
	var x: float = spot[1]
	var y: float = spot[2]
	var length: float = spot[3]
	var deg: float = spot[4]
	var long_px: float = maxf(img.get_width(), img.get_height())
	s.scale = Vector2.ONE * length * px / long_px
	s.position = Vector2(x, y) * px
	s.rotation_degrees = deg
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	s.material = mat
	parent.add_child(s)
	return 1
