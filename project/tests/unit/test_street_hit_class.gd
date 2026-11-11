extends GutTest
## n17 npc-react (brief item 5): a living street person's melee and shock blows draw their own class
## cell (StreetHitClass), at the walk's height, for the class's hold.

const ROW: String = "cop/head_cap"


func _cop(kind: StringName, blow: StringName, t: float) -> CutRig:
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = HumanPlan.cop()
	var r: HumanReact = HumanReact.on(rig)
	r.kind = kind
	r.blow = blow
	r.t = t
	return rig


func test_the_blow_class_comes_from_the_weapon_then_the_hit_class() -> void:
	assert_eq(StreetHitClass.blow_of(&"melee", &"claw", &"spin"), &"jab")
	assert_eq(StreetHitClass.blow_of(&"melee", &"katana", &"fold"), &"heavy")
	assert_eq(StreetHitClass.blow_of(&"melee", &"electro_baton", &"spin"), &"shock")
	assert_eq(StreetHitClass.blow_of(&"melee", &"unknown_blade", &"fold"), &"jab", "melee default")
	assert_eq(StreetHitClass.blow_of(&"shock", &"electro_gun", &"stun"), &"shock")
	assert_eq(StreetHitClass.blow_of(&"light", &"pistol", &"flinch"), &"", "a round keeps its site")
	assert_eq(StreetHitClass.blow_of(&"melee", &"claw", &"shield"), &"", "a block keeps its own")
	assert_eq(StreetHitClass.blow_of(&"melee", &"claw", &"cover"), &"")


func test_a_jab_draws_the_jab_cell_inside_its_hold_only() -> void:
	var want: String = str(StreetHitClass.GRIDS[ROW][&"jab"])
	assert_eq(StreetWalkerHit.grid_of(_cop(&"spin", &"jab", 0.05), ROW), want)
	var end: float = StreetHitClass.HOLD_S[&"jab"]
	assert_eq(StreetWalkerHit.grid_of(_cop(&"spin", &"jab", end), ROW), "", "the hold is over")


func test_each_class_draws_a_different_cell() -> void:
	var seen: Dictionary = {}
	for cls: StringName in [&"jab", &"heavy", &"shock"]:
		seen[StreetWalkerHit.grid_of(_cop(&"fold", cls, 0.01), ROW)] = true
	assert_eq(seen.size(), 3)
	assert_false(seen.has(""))


func test_a_class_cell_overrides_the_site_cell_and_off_restores_it() -> void:
	# a stun on a flinch's site row: the shock cell, not the shoulder clutch
	var shock: String = StreetWalkerHit.grid_of(_cop(&"flinch", &"shock", 0.05), ROW)
	assert_eq(shock, "p70/cop_patrol_shock_hit.png")
	var site: String = StreetWalkerHit.grid_of(_cop(&"flinch", &"", 0.05), ROW)
	assert_eq(site, "p70/cop_patrol_shoulder_hit.png")
	assert_eq(StreetWalkerHit.grid_of(_cop(&"spin", &"", 0.05), ROW), "", "no blow: the before")


func test_a_new_family_clears_the_blow() -> void:
	var rig: CutRig = _cop(&"spin", &"heavy", 0.0)
	rig.react.play(rig, &"flinch", Vector2.LEFT, ReactTable.shipped())
	assert_eq(rig.react.blow, &"")


func test_the_dying_never_draw_a_class_cell() -> void:
	var rig: CutRig = _cop(&"death_melee", &"heavy", 0.01)
	rig.react.dying = true
	assert_eq(StreetHitClass.grid(rig.react, ROW), "")


func test_every_class_grid_is_five_facings_at_the_walk_height() -> void:
	# owner: "policemen are changing sizes on hit": the jab stands at the kind's thrown cell (itself at
	# the walk, test_street_walker_hit), the crouched heavy and the shock never taller than it.
	for row: String in StreetHitClass.GRIDS:
		var thrown: String = StreetWalkerCards.DIR + StreetWalkerHit.GRIDS[row]
		var w: float = _mean_h(thrown, 1, StreetWalkerHit.fill_of(thrown))
		for cls: StringName in StreetHitClass.GRIDS[row]:
			var path: String = StreetWalkerCards.DIR + str(StreetHitClass.GRIDS[row][cls])
			var tex: Texture2D = load(path) as Texture2D
			assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, "%s whole facings" % path)
			var h: float = _mean_h(path, 1, StreetWalkerHit.fill_of(path)) / w
			if cls == &"jab":
				assert_almost_eq(h, 1.0, 0.05, "%s %s: %.2f x the walk" % [row, cls, h])
			else:
				assert_between(h, 0.85, 1.06, "%s %s: %.2f x the walk" % [row, cls, h])


## The mean opaque figure height (m) of a 5-facing grid's cells, drawn at `fill` x HEIGHT_M.
func _mean_h(path: String, rows: int, fill: float) -> float:
	var tex: Texture2D = load(path) as Texture2D
	assert_not_null(tex, path)
	if tex == null:
		return 0.0
	var img: Image = tex.get_image()
	if img.is_compressed():
		assert_eq(img.decompress(), OK, path)
	var cw: int = img.get_width() / RigHeadCard.FRAMES
	var ch: int = img.get_height() / rows
	var sum: float = 0.0
	for r: int in rows:
		for c: int in RigHeadCard.FRAMES:
			var used: Rect2i = img.get_region(Rect2i(c * cw, r * ch, cw, ch)).get_used_rect()
			sum += used.size.y * StreetWalkerCards.HEIGHT_M * fill / ch
	return sum / (rows * RigHeadCard.FRAMES)
