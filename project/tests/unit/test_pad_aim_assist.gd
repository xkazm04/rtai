extends GutTest
## features/player PadAimAssist: the gunplay lane's pad aim assist is wired into the live input on
## an aim_assist row (the handheld rows) and nowhere else; its targets are the arena's living
## hostiles and boss.

var _saved: DeviceProfile = null


func before_each() -> void:
	_saved = DeviceProfile.shared()


func after_each() -> void:
	DeviceProfile._shared = _saved


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(7)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func test_the_desktop_aims_raw() -> void:
	DeviceProfile._shared = DeviceProfile.of("desktop")
	var live: LiveInput = LiveInput.new(PlayerActions.shipped())
	var arena: CombatArena = _arena()
	PadAimAssist.wire(live, func() -> CombatArena: return arena)
	assert_null(live.assist)


func test_every_handheld_row_wires_the_assist() -> void:
	for id: String in DeviceProfile.of("").ids:
		var p: DeviceProfile = DeviceProfile.of(id)
		assert_eq(p.aim_assist, p.is_handheld(), id)
	DeviceProfile._shared = DeviceProfile.of("deck")
	var live: LiveInput = LiveInput.new(PlayerActions.shipped())
	var arena: CombatArena = _arena()
	arena.rivet.pos = Vector2(3, 4)
	PadAimAssist.wire(live, func() -> CombatArena: return arena)
	assert_not_null(live.assist)
	var at: Vector2 = live.aim_origin.call()
	assert_eq(at, Vector2(3, 4))


func test_targets_are_the_living_hostiles_and_the_boss() -> void:
	var arena: CombatArena = _arena()
	var a: Fighter = arena.spawn_guard(Vector2(5, 0))
	var b: Fighter = arena.spawn_guard(Vector2(0, 5))
	b.hp = 0.0
	arena.boss = Fighter.make(Fighter.Kind.GUARD, 99, Vector2(9, 9), 10.0)
	var t: Array[RangeTarget] = PadAimAssist.targets_of(arena)
	assert_eq(t.size(), 2)
	assert_eq(t[0].pos, a.pos)
	assert_eq(t[1].pos, Vector2(9, 9))


func test_the_bend_pulls_a_pad_heading_toward_a_hostile() -> void:
	var arena: CombatArena = _arena()
	var g: Fighter = arena.spawn_guard(Vector2(10, 0))
	g.pos = Vector2(10, 0).rotated(deg_to_rad(5.0))
	var assist: AimAssist = WeaponTable.shipped().aim_assist
	var out: Vector2 = assist.bend(
		Vector2.RIGHT, Vector2.ZERO, PadAimAssist.targets_of(arena), true
	)
	assert_gt(out.angle(), 0.0)
	assert_lt(out.angle(), deg_to_rad(5.0))
