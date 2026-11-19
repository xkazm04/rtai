extends GutTest
## n17 rivet-strike (DEFECTS #11): a gun with drawn diagonal fire cells fires them on the diagonal
## octants, aimed against the drawn gun's angle; the flashless twin holds the pose past the flare.

const EQ: String = RivetStrips.DIR + "p70/rivet_eq_pistol.png"
const DIAG: String = RivetStrips.DIR + "p70/rivet_eq_pistol_diag.png"


func after_each() -> void:
	RivetGunDiag.enabled = true
	RivetStrips.diag = true


func _rig(octant: int, aim_deg: float = NAN) -> CutRig:
	var rig: CutRig = add_child_autofree(CutRig.new())
	var head: Node2D = Node2D.new()
	rig.add_child(head)
	rig.head = head
	head.rotation = octant * PI * 0.25
	rig.face_to = octant * PI * 0.25
	rig.set_meta(RivetFrames.FIRE, true)
	rig.set_meta(RivetNoFlash.AGE, 0)
	if not is_nan(aim_deg):
		rig.aiming = true
		rig.aim_at = rig.global_position + Vector2.from_angle(deg_to_rad(aim_deg)) * 100.0
	return rig


func test_a_diagonal_shot_fires_the_drawn_diagonal_strip() -> void:
	assert_true(RivetGunDiag.draws("p70", &"pistol"))
	assert_true(RivetGunDiag.draws("p55", &"pistol"), "drawn at p55 too")
	assert_false(RivetGunDiag.draws("p70", &"no_diag"), "no drawn diagonal")
	for pitch: String in ["p55", "p70"]:
		for gun: StringName in [&"homing_shard", &"ray_gun"]:
			assert_true(RivetGunDiag.draws(pitch, gun), pitch + "/" + String(gun))
	for o: int in [1, 3, 5, 7]:
		assert_eq(RivetStrips.diag_or(_rig(o), "p70", &"pistol", EQ), DIAG, "octant %d" % o)
	assert_eq(RivetStrips.diag_or(_rig(0), "p70", &"pistol", EQ), EQ, "the side keeps its cell")


func test_the_shot_counts_as_drawn_against_the_drawn_guns_angle() -> void:
	# octant 1 (3/4 toward right): the drawn gun points 32 deg down-right on screen
	assert_almost_eq(rad_to_deg(RivetGunDiag.gun_rad(&"pistol", 1, "p70")), 32.0, 0.01)
	assert_almost_eq(rad_to_deg(RivetGunDiag.gun_rad(&"pistol", 0, "p70")), 0.0, 0.01, "side")
	assert_almost_eq(rad_to_deg(RivetGunDiag.gun_rad(&"no_diag", 3, "p55")), 180.0, 0.01, "undrawn")
	assert_true(RivetGunDiag.fits(_rig(1, 50.0), &"pistol", 1, "p70"), "18 deg off")
	assert_false(RivetGunDiag.fits(_rig(1, 60.0), &"pistol", 1, "p70"), "28 deg: the camera's")
	assert_false(RivetGunDiag.fits(_rig(1, 5.0), &"pistol", 1, "p70"), "27 deg: the side's")
	assert_true(RivetGunDiag.fits(_rig(7, -40.0), &"pistol", 7, "p70"), "away right")
	assert_eq(RivetStrips.diag_or(_rig(1, 60.0), "p70", &"pistol", EQ), EQ, "a steep shot")


func test_off_keeps_the_side_fire_cell_on_the_diagonals() -> void:
	var was: bool = CastFlags._read
	CastFlags._read = false
	CastFlags.apply(PackedStringArray(["--rivet-gun-diag=off"]))
	CastFlags._read = was
	assert_false(RivetGunDiag.enabled)
	assert_eq(RivetStrips.diag_or(_rig(1), "p70", &"pistol", EQ), EQ)


func test_the_strip_has_the_pistols_cells_its_pad_and_a_muzzle_per_cell() -> void:
	var tex: Texture2D = load(DIAG) as Texture2D
	var eq: Texture2D = load(EQ) as Texture2D
	assert_eq(tex.get_width() / RivetStrips.DIAG_CELLS, eq.get_width() / RivetFrames.EQ_CELLS)
	assert_eq(tex.get_height(), eq.get_height())
	assert_true(RivetGunDiag.owns(DIAG))
	assert_false(RivetGunDiag.owns(RivetStrips.DIR + "p70/rivet_eq_flamethrower_diag.png"))
	assert_false(RivetGunDiag.owns(EQ), "the equipped strip is not a diagonal")
	assert_false(RivetGunDiag.owns(DIAG.trim_suffix(".png") + RivetNoFlash.SUFFIX), "the twin")
	assert_eq(RivetStrips.foot_px(DIAG), RivetGunDiag.FOOT_PX["p70/pistol"])
	var w: float = tex.get_width() / float(RivetStrips.DIAG_CELLS) / RivetRes.of(DIAG)
	for c: int in RivetStrips.DIAG_CELLS:
		var p: Vector2 = RivetMuzzle.point(DIAG, c)
		assert_eq(p.x > w * 0.5, c < 2, "cell %d: the muzzle on its gun's side" % c)
		assert_eq(p.y > 60.0, c % 2 == 0, "cell %d: toward = low, away = high" % c)


func test_past_the_flare_the_diagonal_cell_draws_its_flashless_twin() -> void:
	var rig: CutRig = _rig(1)
	var card: Sprite2D = autoqfree(Sprite2D.new())
	card.texture = StreetStrips.get_tex(DIAG)
	card.hframes = RivetStrips.DIAG_CELLS
	card.set_meta(RivetFrames.ON, DIAG)
	RivetNoFlash.show(rig, card, 0)
	assert_eq(card.texture, StreetStrips.get_tex(DIAG), "the shot's tick: the painted flash")
	rig.set_meta(RivetNoFlash.AGE, 5)
	RivetNoFlash.show(rig, card, 0)
	assert_eq(card.texture, StreetStrips.get_tex(DIAG.trim_suffix(".png") + RivetNoFlash.SUFFIX))


func test_each_diagonal_cell_stands_on_his_helmets_centre() -> void:
	var card: Sprite2D = autoqfree(Sprite2D.new())
	card.texture = StreetStrips.get_tex(DIAG)
	card.hframes = RivetStrips.DIAG_CELLS
	card.set_meta(RivetFrames.ON, DIAG)
	var xs: PackedFloat32Array = RivetGunDiag.HELMET_X.get("p70/pistol", [])
	for c: int in RivetStrips.DIAG_CELLS:
		RivetCellFeet.show(card, c)
		assert_almost_eq(card.offset.x, -xs[c], 0.01, "cell %d" % c)
	assert_almost_eq(xs[1], 93.5, 0.01, "the away right cell: his body left of the canvas centre")


func test_every_listed_gun_ships_its_strip_twin_and_rows() -> void:
	for key: String in RivetGunDiag.DEG:
		var art: String = key.get_slice("/", 0)
		var gun: StringName = StringName(key.get_slice("/", 1))
		var path: String = RivetStrips.DIR + art + "/rivet_eq_" + String(gun) + RivetStrips.DIAG
		assert_true(RivetGunDiag.draws(art, gun), key)
		assert_true(RivetStrips.has_file(path.trim_suffix(".png") + RivetNoFlash.SUFFIX), key)
		assert_true(RivetGunDiag.HELMET_X.has(key) and RivetGunDiag.FOOT_PX.has(key), key)
		var eq: String = RivetStrips.DIR + art + "/rivet_eq_" + String(gun) + ".png"
		assert_eq(RivetRes.of(path), RivetRes.of(eq), key + ": at its equipped strip's res")
		for c: int in RivetStrips.DIAG_CELLS:
			assert_gt(RivetMuzzle.point(path, c).x, 0.0, "%s cell %d: a muzzle" % [key, c])


func test_quest_rifle_uses_its_own_strips_at_both_pitches() -> void:
	var rifle: StringName = &"assault-rifle"
	assert_eq(WeaponArtKey.of(rifle), &"assault_rifle")
	assert_eq(RivetStrips.strip_of("p55", rifle).get_file(), "rivet_eq_assault_rifle.png")
	assert_eq(RivetStrips.left_of("p55", rifle).get_file(), "rivet_eq_assault_rifle_left.png")
	assert_true(RivetGunDiag.draws("p55", rifle))
	assert_eq(RivetStrips.strip_of("p70", rifle).get_file(), "rivet_eq_assault_rifle.png")
	assert_true(RivetGunDiag.draws("p70", rifle))


func test_plasma_west_uses_its_side_shot_and_flashless_twin() -> void:
	var rig: CutRig = _rig(4, 180.0)
	rig.gun_out = true
	rig.set_meta(RivetFrames.WEAPON, &"plasma_rifle")
	for pitch: String in ["p55", "p70"]:
		var left: String = RivetStrips.DIR + pitch + "/rivet_eq_plasma_rifle_left.png"
		var fire: String = left.trim_suffix(".png") + "_fire.png"
		assert_eq(RivetWindup.path_or(rig, pitch, &"plasma_rifle", left), fire)
		assert_eq(RivetStrips.cells_of(fire, false), 1)
		assert_eq(RivetFrames.cell_of(rig, 1), Vector2i.ZERO)
		var card: Sprite2D = autofree(Sprite2D.new())
		card.set_meta(RivetFrames.ON, fire)
		card.texture = StreetStrips.get_tex(fire)
		rig.set_meta(RivetNoFlash.AGE, RivetNoFlash.ticks_of(&"plasma_rifle"))
		RivetNoFlash.show(rig, card, 0)
		assert_eq(card.texture.resource_path, fire.trim_suffix(".png") + "_noflash.png")
		rig.set_meta(RivetNoFlash.AGE, 0)
		RivetNoFlash.show(rig, card, 0)
		assert_eq(card.texture.resource_path, fire)
