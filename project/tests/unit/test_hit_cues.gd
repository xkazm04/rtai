extends GutTest
## n7-melee: a melee or ghost hit plays its weapon's `hits` cue (audio_cues.json) where the victim
## stands on the hit tick; the chainsaw grind plays once per strike; a gun plays nothing here; every
## `hits` row names a cue that exists.

var _ids: Array[StringName] = []
var _at: Array[Vector2] = []


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _guard(arena: CombatArena, at: Vector2, hp: float) -> Fighter:
	var f: Fighter = Fighter.make(Fighter.Kind.GUARD, 7, at, hp)
	arena.hostiles.append(f)
	return f


func _record(id: StringName, at: Vector2, tick: int) -> bool:
	assert_gte(tick, 0)
	_ids.append(id)
	_at.append(at)
	return true


func _cues(arena: CombatArena) -> HitCues:
	_ids.clear()
	_at.clear()
	return HitCues.attach(arena, AudioTables.shipped().hits, _record)


func test_a_non_lethal_claw_jab_plays_the_claw_knock_at_the_victim() -> void:
	var arena: CombatArena = _arena()
	var h: HitCues = _cues(arena)
	arena.damage(_guard(arena, Vector2(1.0, 0.5), 2.0), 1.0, arena.rivet.id, &"claw")
	assert_eq(h.played, 1)
	assert_eq(_ids[0], &"melee_claw")
	assert_eq(_at[0], Vector2(1.0, 0.5), "where the victim stands")


func test_a_kill_plays_the_weapon_cue_too() -> void:
	var arena: CombatArena = _arena()
	var h: HitCues = _cues(arena)
	arena.damage(_guard(arena, Vector2(1.0, 0.0), 1.0), 9.0, arena.rivet.id, &"kerf_slice")
	assert_eq(h.played, 1)
	assert_eq(_ids[0], &"melee_cut")


func test_the_chainsaw_grind_plays_once_per_strike() -> void:
	var arena: CombatArena = _arena()
	var h: HitCues = _cues(arena)
	var f: Fighter = _guard(arena, Vector2(1.0, 0.0), 100.0)
	for t: int in MeleeWound.GAP_TICKS * 2:
		arena.tick = t
		arena.damage(f, 0.1, arena.rivet.id, &"chainsaw")
	assert_eq(h.played, 2, "one bite per gap, not one per tick")


func test_a_gun_hit_plays_nothing_of_its_own() -> void:
	var arena: CombatArena = _arena()
	var h: HitCues = _cues(arena)
	arena.damage(_guard(arena, Vector2(1.0, 0.0), 1.0), 9.0, arena.rivet.id, &"pistol")
	assert_eq(h.played, 0)


func test_every_hits_row_names_a_shipped_cue() -> void:
	var t: AudioTables = AudioTables.shipped()
	assert_gt(t.hits.size(), 0)
	for w: StringName in t.hits:
		assert_not_null(t.cue(t.hits[w]), "%s -> %s" % [w, t.hits[w]])
