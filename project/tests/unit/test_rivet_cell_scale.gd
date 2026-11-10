extends GutTest
## n10 rivet: a fire or swing cell draws the same Rivet as the facings it pops to. Before the
## re-cut gloria's shot drew him 17 % narrower than his stance (the mini-nuke 26 % at p55), and
## the p70 baton's left strip stood on its baton tip 25 px above his feet.

## The helmet width: at rows 10, 14 and 18 px below the figure's top, the alpha run holding the
## top's centre column; the widest of the three.
const ROWS: PackedInt32Array = [10, 14, 18]
## A shot's helmet stays within this of the facing cells' median.
const MIN_RATIO: float = 0.90
const MAX_RATIO: float = 1.12
## The body's half width in strip px around the helmet's centre.
const BODY_PX: int = 28
const FIRE_CELLS: PackedInt32Array = [5, 7]
const FACE_CELLS: PackedInt32Array = [0, 1, 2, 3, 4]
const STRIPS: Array[String] = [
	"p70/rivet_eq_gloria.png",
	"p70/rivet_eq_plasma_rifle.png",
	"p70/rivet_eq_mini_nuke.png",
	"p55/rivet_eq_gloria.png",
	"p55/rivet_eq_plasma_rifle.png",
	"p55/rivet_eq_mini_nuke.png",
	"p70/rivet_eq_plasma_sword.png",
]


func _strip(rel: String) -> Image:
	var path: String = ProjectSettings.globalize_path(RivetStrips.DIR + rel)
	var img: Image = Image.load_from_file(path)
	img.convert(Image.FORMAT_RGBA8)
	return img


func _run_at(img: Image, cell_x: int, cell_w: int, y: int, x_mid: int) -> int:
	var a: int = x_mid
	while a > cell_x and img.get_pixel(a, y).a > 0.24:
		a -= 1
	var b: int = x_mid
	while b < cell_x + cell_w - 1 and img.get_pixel(b, y).a > 0.24:
		b += 1
	return b - a - 1


func _dome(img: Image, cell: int, cell_w: int) -> int:
	var x0: int = cell * cell_w
	var top: int = -1
	var xs: Array[int] = []
	for y: int in img.get_height():
		for x: int in range(x0, x0 + cell_w):
			if img.get_pixel(x, y).a > 0.24:
				xs.append(x)
		if not xs.is_empty():
			top = y
			break
	if top < 0:
		return 0
	var mid: int = xs[xs.size() / 2]
	var best: int = 0
	for dy: int in ROWS:
		best = maxi(best, _run_at(img, x0, cell_w, top + dy, mid))
	return best


func _median(values: Array[int]) -> float:
	values.sort()
	return float(values[values.size() / 2])


func test_a_shot_draws_the_same_rivet_as_his_stance() -> void:
	for rel: String in STRIPS:
		var img: Image = _strip(rel)
		var cell_w: int = img.get_width() / RivetFrames.EQ_CELLS
		var face: Array[int] = []
		for c: int in FACE_CELLS:
			face.append(_dome(img, c, cell_w))
		var ref: float = _median(face)
		for c: int in FIRE_CELLS:
			var k: float = _dome(img, c, cell_w) / ref
			assert_between(k, MIN_RATIO, MAX_RATIO, "%s cell %d helmet / facing %.2f" % [rel, c, k])


func test_the_baton_left_strip_stands_on_his_feet() -> void:
	var rel: String = "p70/rivet_eq_electro_baton_left.png"
	var path: String = RivetStrips.DIR + rel
	var img: Image = _strip(rel)
	var cell_w: int = img.get_width() / RivetFrames.LEFT_CELLS
	var foot: float = RivetStrips.foot_px(path)
	assert_gt(foot, RivetFrames.PAD_PX, "the baton tip reaches below his feet")
	for c: int in RivetFrames.LEFT_CELLS:
		var bottom: int = _body_bottom(img, c, cell_w)
		assert_almost_eq(
			float(img.get_height() - 1 - bottom), foot, 3.0, "cell %d: feet on the foot line" % c
		)


## The lowest alpha row within BODY_PX of the helmet's centre column (the baton lies outside it).
func _body_bottom(img: Image, cell: int, cell_w: int) -> int:
	var x0: int = cell * cell_w
	var mid: int = _dome_mid(img, x0, cell_w)
	var last: int = 0
	for y: int in img.get_height():
		for x: int in range(maxi(x0, mid - BODY_PX), mini(x0 + cell_w, mid + BODY_PX)):
			if img.get_pixel(x, y).a > 0.35:
				last = y
				break
	return last


func _dome_mid(img: Image, x0: int, cell_w: int) -> int:
	for y: int in img.get_height():
		var xs: Array[int] = []
		for x: int in range(x0, x0 + cell_w):
			if img.get_pixel(x, y).a > 0.35:
				xs.append(x)
		if not xs.is_empty():
			return xs[xs.size() / 2]
	return x0 + cell_w / 2


func test_a_left_baton_keeps_the_game_smear_running() -> void:
	var saved: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt70")
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.head_card = autofree(Sprite2D.new())
	rig.head_card.hframes = RivetFrames.LEFT_CELLS
	rig.gun_out = true
	rig.set_meta(RivetFrames.WEAPON, &"electro_baton")
	var left: String = RivetStrips.DIR + "p70/rivet_eq_electro_baton_left.png"
	var eq: String = RivetStrips.DIR + "p70/rivet_eq_electro_baton.png"
	rig.head_card.set_meta(RivetFrames.ON, left)
	assert_false(RivetStrips.hides_held(rig), "the left strip has no strike cell")
	rig.head_card.hframes = RivetWindup.LEFT_CELLS  # n14: its wind-up neither (the smear runs on)
	rig.head_card.set_meta(RivetFrames.ON, left.trim_suffix(".png") + "_windup.png")
	assert_false(RivetStrips.hides_held(rig), "the left wind-up keeps the smear")
	rig.head_card.hframes = RivetFrames.EQ_CELLS
	rig.head_card.set_meta(RivetFrames.ON, eq)
	assert_true(RivetStrips.hides_held(rig), "the right cells draw the swing")
	rig.set_meta(RivetFrames.WEAPON, &"pistol")
	rig.head_card.set_meta(RivetFrames.ON, RivetStrips.DIR + "p70/rivet_eq_pistol_left.png")
	assert_true(RivetStrips.hides_held(rig), "a gun has no smear to keep")
	ViewMode._shared = saved
