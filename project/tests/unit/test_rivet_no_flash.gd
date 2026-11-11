extends GutTest
## n17 rivet-strike (DEFECTS #9): a gun's fire cell shows its painted flash for the flare's
## muzzle_ticks only, then the flashless twin (same canvas); off = the painted cell held (before).

const PISTOL: String = "res://features/characters/art/view/p70/rivet_eq_pistol.png"
const TWIN: String = "res://features/characters/art/view/p70/rivet_eq_pistol_noflash.png"


func after_each() -> void:
	RivetNoFlash.enabled = true


func _card() -> Sprite2D:
	var card: Sprite2D = autofree(Sprite2D.new())
	card.texture = StreetStrips.get_tex(PISTOL)
	card.hframes = RivetFrames.EQ_CELLS
	card.set_meta(RivetFrames.ON, PISTOL)
	return card


func _rig(age: int) -> CutRig:
	var rig: CutRig = autofree(CutRig.new())
	rig.gun_out = true
	rig.set_meta(RivetFrames.WEAPON, &"pistol")
	rig.set_meta(RivetNoFlash.AGE, age)
	return rig


func test_the_painted_flash_holds_the_flares_ticks_then_the_twin() -> void:
	var card: Sprite2D = _card()
	var n: int = RivetNoFlash.ticks_of(&"pistol")
	assert_eq(n, 3, "gun_fx.json pistol muzzle_ticks")
	for age: int in n:
		RivetNoFlash.show(_rig(age), card, RivetFrames.Eq.FIRE_SIDE)
		assert_eq(card.texture, StreetStrips.get_tex(PISTOL), "age %d: the painted flash" % age)
	RivetNoFlash.show(_rig(n), card, RivetFrames.Eq.FIRE_CAM)
	assert_eq(card.texture, StreetStrips.get_tex(TWIN), "past the flare: flashless")
	RivetNoFlash.show(_rig(n), card, 2)
	assert_eq(card.texture, StreetStrips.get_tex(PISTOL), "a facing cell: the strip itself")


func test_off_holds_the_painted_cell() -> void:
	RivetNoFlash.enabled = false
	var card: Sprite2D = _card()
	RivetNoFlash.show(_rig(6), card, RivetFrames.Eq.FIRE_SIDE)
	assert_eq(card.texture, StreetStrips.get_tex(PISTOL))


func test_the_twin_shares_the_strips_canvas() -> void:
	for art: String in ["p70", "p55"]:
		for gun: String in ["pistol", "gatling", "plasma_rifle", "rocket_launcher"]:
			var base: String = RivetStrips.DIR + "%s/rivet_eq_%s.png" % [art, gun]
			var twin: Texture2D = load(base.trim_suffix(".png") + RivetNoFlash.SUFFIX) as Texture2D
			assert_not_null(twin, base)
			assert_eq(twin.get_size(), (load(base) as Texture2D).get_size(), base)


func test_a_gun_without_a_flare_keeps_the_minimum() -> void:
	assert_eq(RivetNoFlash.ticks_of(&"rocket_launcher"), RivetNoFlash.MIN_TICKS)
	assert_eq(RivetNoFlash.ticks_of(&"hand_cannon"), 4)


func test_the_before_flag_routes_through_cast_flags() -> void:
	var was: bool = CastFlags._read
	CastFlags._read = false
	CastFlags.apply(PackedStringArray(["--rivet-noflash=off", "--rivet-fire-turn=keep"]))
	assert_false(RivetNoFlash.enabled)
	assert_false(RivetFireTurn.enabled)
	RivetFireTurn.enabled = true
	CastFlags._read = was
