extends GutTest


func test_catch_only_holds_the_successful_warden_and_recovers_on_release() -> void:
	var holder: Fighter = Fighter.new()
	var partner: Fighter = Fighter.new()
	holder.archetype = FoeWardenCardView.ID
	partner.archetype = holder.archetype
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(1).stream(&"combat")
	)
	arena.tick = 42
	FoeWardenCardView.set_catch(holder, true, 42)
	assert_eq(FoeCastView.attack_row(holder, arena), 1)
	assert_eq(FoeCastView.attack_row(partner, arena), -1)
	for tick: int in range(43, 84):
		arena.tick = tick
		FoeWardenCardView.set_catch(holder, true, tick)
		assert_eq(FoeCastView.attack_row(holder, arena), 2)
	for tick: int in range(84, 90):
		arena.tick = tick
		FoeWardenCardView.set_catch(holder, false, tick)
		assert_eq(FoeCastView.attack_row(holder, arena), 3)
	arena.tick = 90
	assert_eq(FoeCastView.attack_row(holder, arena), -1)


func test_missed_and_cancelled_swings_use_the_roster_tell() -> void:
	var h: Fighter = Fighter.new()
	var roster: EnemyRoster = EnemyRoster.shipped(EnemyRoster.TABLE, true)
	var mind: SquadMind = SquadMind.new(h, roster.archetype(FoeWardenCardView.ID))
	h.swing_tick = 8
	var ticks: int = mind.agent.arch.telegraph_ticks
	assert_eq(ticks, 33)
	for left: int in range(ticks, 0, -1):
		h.swing_left = left
		assert_eq(FoeWardenCardView.attack_row(h, mind, 8 + ticks - left), 0)
	h.swing_left = 0
	var active: int = 8 + ticks
	assert_eq(FoeWardenCardView.attack_row(h, mind, active), -1, "interrupted tell")
	mind.agent.cooldown = mind.agent.arch.weapon.cooldown_ticks
	assert_eq(FoeWardenCardView.attack_row(h, mind, active - 1), -1)
	assert_eq(FoeWardenCardView.attack_row(h, mind, active), 1)
	for tick: int in range(active + 1, active + 7):
		assert_eq(FoeWardenCardView.attack_row(h, mind, tick), 3)
	assert_eq(FoeWardenCardView.attack_row(h, mind, active + 7), -1)


func test_both_hosts_select_the_registered_eight_and_survive_a_reversal() -> void:
	var table: DataTable = DataTable.open(CastCards.TABLE, CastCards.SCHEMA)
	table.raw.archetypes.appliance_warden.enabled = true
	var library: CastCards = CastCards.from_table(table)
	for pitch: String in ["p70", "p55"]:
		var path: String = library.lookup(FoeWardenCardView.ID, pitch).walk
		assert_eq(path.get_file(), CastWardenAnchors.WALK)
		if path.get_file() != CastWardenAnchors.EIGHT:
			continue
		var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
		contact.configure(path)
		assert_eq(contact.drawings, 8)
		assert_eq(contact.step_m, CastWardenAnchors.STEP_M)
		var height: float = StreetWalkerCards.HEIGHT_BY_ART.get(pitch, StreetWalkerCards.HEIGHT_M)
		var scale_px: Vector2 = Vector2.ONE * (32.0 * height * 1.10 / 192.0)
		for speed: float in [2.8, 3.8]:
			var worst: float = _reversal(contact, speed, scale_px)
			Log.info("cast", "%s %.1f m/s reversal %.3f px at 32 px/m" % [pitch, speed, worst])
			assert_lte(worst, 12.0)


func _reversal(contact: StreetCopWalk.Contact, speed: float, scale_px: Vector2) -> float:
	contact.reset()
	var at: Vector2 = Vector2.ZERO
	var previous: Vector2 = Vector2.INF
	var worst: float = 0.0
	for tick: int in 120:
		var direction: Vector2 = Vector2(1, 1).normalized()
		var face: Vector2i = Vector2i(1, 0)
		if tick >= 50:
			direction = -direction
			face = Vector2i(3, 1)
		at += direction * speed * 32.0 * SimClock.TICK_DT
		var xf: Transform2D = contact.place(at, face, scale_px, 32.0)
		var ink: Vector4 = contact.registered.marks[face.x * 8 + posmod(contact.cell, 8)]
		var body: Vector2 = xf * Vector2(-ink.z if face.y else ink.z, ink.w)
		if previous.is_finite():
			worst = maxf(worst, body.distance_to(previous))
		previous = body
	return worst
