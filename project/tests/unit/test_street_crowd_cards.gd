extends GutTest
## Lane n8 street: the crowd's nine pedestrian types (StreetCrowdCards).


func test_every_pooled_row_has_a_whole_frame_strip_at_both_pitches() -> void:
	for art: String in ["p55", "p70"]:
		var rows: Dictionary[String, Array] = RigHeadCard.rows_of(art)
		for tag: String in StreetCrowdCards.POOLS:
			var pool: PackedStringArray = StreetCrowdCards.POOLS.get(tag)
			for key: String in pool:
				assert_true(rows.has(key), "%s %s" % [art, key])
				var tex: Texture2D = load(str(rows[key][0])) as Texture2D
				assert_not_null(tex, "%s %s" % [art, key])
				assert_true(
					str(rows[key][0]).contains("/%s/" % art), "%s drawn for its pitch" % key
				)
				if tex != null:
					assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, "%s whole frames" % key)


func test_the_pick_is_stable_and_reaches_every_type_of_a_pool() -> void:
	for tag: String in StreetCrowdCards.POOLS:
		var seen: Dictionary[String, bool] = {}
		for id: int in range(1, 41):
			var a: String = StreetCrowdCards.pick(tag, id)
			assert_eq(a, StreetCrowdCards.pick(tag, id), "same actor, same card")
			seen[a] = true
		var pool: PackedStringArray = StreetCrowdCards.POOLS.get(tag)
		assert_eq(seen.size(), pool.size(), "%s draws all its types" % tag)


func test_a_look_without_a_pool_keeps_its_own_head() -> void:
	assert_eq(StreetCrowdCards.pick("coat-hat", 7), "")
	assert_eq(StreetCrowdCards.pick("patrol", 7), "")


func test_the_nine_library_types_are_all_drawn() -> void:
	var rows: Dictionary[String, Array] = RigHeadCard.rows_of("p70")
	var strips: Dictionary[String, bool] = {}
	for look: int in [0, 1, 2, 3, 4, 7]:
		var v: RigVariant = RigVariant.crowd(look)
		var keys: PackedStringArray = StreetCrowdCards.POOLS.get(v.tag, ["ped/" + v.head])
		for key: String in keys:
			strips[str(rows[key][0]).get_file()] = true
	assert_eq(strips.size(), 9, "suit, punk, shopper, jogger, elder, worker, hat, hood, cap")


func test_without_a_card_nothing_is_swapped() -> void:
	var rig: CutRig = autofree(CutRig.new())
	rig.variant = RigVariant.crowd(1)
	StreetCrowdCards.step(rig)
	assert_null(rig.head_card)


func test_the_variety_is_stable_bounded_and_spread() -> void:
	var lo: float = 1.0
	var hi: float = -1.0
	for id: int in range(1, 201):
		var a: float = StreetCrowdCards.vary(id, 3)
		assert_eq(a, StreetCrowdCards.vary(id, 3), "same actor, same draw")
		lo = minf(lo, a)
		hi = maxf(hi, a)
	assert_between(lo, -1.0, -0.8, "reaches the small end")
	assert_between(hi, 0.8, 1.0, "reaches the big end")
	assert_ne(StreetCrowdCards.vary(5, 3), StreetCrowdCards.vary(5, 17), "scale and value differ")


func test_the_lone_victim_capture_draws_every_cop_as_the_asked_row() -> void:
	GunplayHook.victim("thug")
	assert_eq(StreetCrowdCards.key_for("", 7, "cop"), "thug", "the lone guard is drawn as a thug")
	assert_eq(
		StreetCrowdCards.key_for("jacket-hair", 7, "ped"),
		StreetCrowdCards.pick("jacket-hair", 7),
		"a passer-by keeps his own row"
	)
	GunplayHook.victim("")
	assert_eq(StreetCrowdCards.key_for("", 7, "cop"), "", "no capture: the cop's own card")


func test_a_cop_build_stays_within_eight_percent_and_a_ped_keeps_sixteen() -> void:
	var cop_lo: float = 9.0
	var cop_hi: float = 0.0
	var ped_lo: float = 9.0
	var ped_hi: float = 0.0
	for id: int in 1000:
		var cop: float = StreetCrowdCards.body_scale(id, StreetCrowdCards.COP_SCALE_VAR)
		cop_lo = minf(cop_lo, cop)
		cop_hi = maxf(cop_hi, cop)
		var ped: float = StreetCrowdCards.body_scale(id)
		assert_eq(ped, 1.0 + 0.16 * StreetCrowdCards.vary(id, 3), "ped id %d unchanged" % id)
		ped_lo = minf(ped_lo, ped)
		ped_hi = maxf(ped_hi, ped)
	assert_between(cop_lo, 0.92, 0.93)
	assert_between(cop_hi, 1.07, 1.08)
	assert_between(ped_lo, 0.84, 0.85)
	assert_between(ped_hi, 1.15, 1.16)


func test_body_scale_of_picks_the_cop_spread_only_for_a_cop_plan() -> void:
	var rig: CutRig = CutRig.new()
	autofree(rig)
	rig.actor_id = 230
	assert_eq(StreetCrowdCards.body_scale_of(rig), StreetCrowdCards.body_scale(230), "no plan")
	rig.plan = BodyPlan.new()
	rig.plan.art_dir = "cop"
	assert_eq(StreetCrowdCards.body_scale_of(rig), StreetCrowdCards.body_scale(230, 0.08), "cop")
	rig.plan.art_dir = "walker"
	assert_eq(StreetCrowdCards.body_scale_of(rig), StreetCrowdCards.body_scale(230), "not a cop")
