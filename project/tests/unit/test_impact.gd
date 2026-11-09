extends GutTest
## Landing resolves damage and secondary effects without needing flight, assets or sim ticks.

var _sim: ProjectileSim
var _w: WeaponSpec
var _p: Projectile


func before_each() -> void:
	_sim = ProjectileSim.new(RngRegistry.new(1).stream(&"impact"), WeaponTable.new())
	_w = WeaponSpec.new()
	_w.damage = 12.0
	_w.hit_class = &"impact_fixture"
	_w.dot_ticks = 8
	_w.dot_dps = 6.0
	_w.stun_ticks = 5
	_w.patch_radius_m = 2.5
	_w.patch_ticks = 0
	_p = Projectile.launch(_w, Vector2.ZERO, Vector2.UP, Projectile.TEAM_PLAYER)
	_p.damage = 20.0
	_p.shooter_id = 42


func test_direct_hit_uses_round_damage_and_reports_direction_and_killer() -> void:
	var t: RangeTarget = _target(Vector2.ZERO)
	t.hp = _p.damage
	watch_signals(_sim)
	Impact.land(_sim, _p, t, t.pos)
	assert_eq(t.hp, 0.0)
	assert_signal_emitted_with_parameters(_sim, "hit", [t, _p.damage, _w.hit_class, Vector2.UP])
	assert_signal_emitted_with_parameters(_sim, "killed", [t, _p.shooter_id, _w.hit_class])


func test_strike_adds_normalized_knock_and_applies_burning_and_flesh_stun() -> void:
	var t: RangeTarget = _target(Vector2.ZERO)
	_w.knockback_mps = 3.0
	t.knock = Vector2.RIGHT
	Impact.land(_sim, _p, t, t.pos)
	assert_eq(t.knock, Vector2.RIGHT + Vector2.UP * _w.knockback_mps)
	assert_eq([t.burn_ticks, t.burn_dps, t.stun_ticks], [_w.dot_ticks, _w.dot_dps, _w.stun_ticks])


func test_reapplying_status_keeps_longest_duration_and_strongest_burn_independently() -> void:
	var t: RangeTarget = _target(Vector2.ZERO)
	t.burn_ticks = 12
	t.burn_dps = 2.0
	t.stun_ticks = 9
	Impact.land(_sim, _p, t, t.pos)
	assert_eq([t.burn_ticks, t.burn_dps, t.stun_ticks], [12, _w.dot_dps, 9])
	t.burn_ticks = 2
	t.burn_dps = 10.0
	t.stun_ticks = 1
	Impact.land(_sim, _p, t, t.pos)
	assert_eq([t.burn_ticks, t.burn_dps, t.stun_ticks], [_w.dot_ticks, 10.0, _w.stun_ticks])


func test_metal_can_burn_but_is_immune_to_stun() -> void:
	var t: RangeTarget = _target(Vector2.ZERO, true)
	Impact.land(_sim, _p, t, t.pos)
	assert_eq([t.burn_ticks, t.burn_dps, t.stun_ticks], [_w.dot_ticks, _w.dot_dps, 0])


func test_disabled_status_effects_leave_existing_status_untouched() -> void:
	var t: RangeTarget = _target(Vector2.ZERO)
	_w.dot_ticks = 0
	_w.dot_dps = 99.0
	_w.stun_ticks = 0
	t.burn_ticks = 4
	t.burn_dps = 2.0
	t.stun_ticks = 3
	Impact.land(_sim, _p, t, t.pos)
	assert_eq([t.burn_ticks, t.burn_dps, t.stun_ticks], [4, 2.0, 3])


func test_splash_falls_off_from_body_edge_and_never_double_hits_direct_victim() -> void:
	_w.splash_radius_m = 4.0
	_w.splash_damage = 40.0
	var direct: RangeTarget = _target(Vector2.ZERO)
	var overlap: RangeTarget = _target(Vector2(0.5, 0.0))
	var halfway: RangeTarget = _target(Vector2(0.0, 3.0))
	var outside: RangeTarget = _target(Vector2(5.25, 0.0))
	var dead: RangeTarget = _target(Vector2.ZERO)
	dead.hp = 0.0
	watch_signals(_sim)
	Impact.land(_sim, _p, direct, Vector2.ZERO)
	assert_eq(direct.hp, direct.max_hp - _p.damage)
	assert_eq(overlap.hp, overlap.max_hp - _w.splash_damage)
	assert_eq(halfway.hp, halfway.max_hp - _w.splash_damage * 0.5)
	assert_eq(outside.hp, outside.max_hp)
	assert_eq(dead.hp, 0.0)
	assert_signal_emit_count(_sim, "hit", 3)


func test_splash_without_direct_victim_strikes_outward_and_applies_status() -> void:
	_w.splash_radius_m = 4.0
	_w.splash_damage = 40.0
	_w.knockback_mps = 3.0
	var at: Vector2 = Vector2(10.0, 10.0)
	var t: RangeTarget = _target(at + Vector2(0.0, -3.0))
	var centre: RangeTarget = _target(at)
	Impact.land(_sim, _p, null, at)
	assert_eq(t.knock, Vector2.UP * _w.knockback_mps)
	assert_almost_eq(centre.knock.length(), _w.knockback_mps, 0.00001)  # any direction, it has none
	assert_eq([t.burn_ticks, t.burn_dps, t.stun_ticks], [_w.dot_ticks, _w.dot_dps, _w.stun_ticks])


func test_zero_splash_radius_disables_area_damage() -> void:
	_w.splash_radius_m = 0.0
	_w.splash_damage = 40.0
	var nearby: RangeTarget = _target(Vector2.ZERO)
	Impact.land(_sim, _p, null, Vector2.ZERO)
	assert_eq(nearby.hp, nearby.max_hp)


func test_chain_selects_nearest_living_metal_from_each_hop_without_revisiting() -> void:
	_w.chain_hops = 2
	_w.chain_radius_m = 4.0
	var first: RangeTarget = _target(Vector2.ZERO, true)
	var farther: RangeTarget = _target(Vector2(0.0, 3.0), true)
	var nearest: RangeTarget = _target(Vector2(2.0, 0.0), true)
	var next: RangeTarget = _target(Vector2(5.0, 0.0), true)
	var beyond_hops: RangeTarget = _target(Vector2(7.0, 0.0), true)
	var flesh: RangeTarget = _target(Vector2(0.5, 0.0))
	var dead: RangeTarget = _target(Vector2(1.0, 0.0), true)
	dead.hp = 0.0
	Impact.land(_sim, _p, first, first.pos)
	assert_eq(first.hp, first.max_hp - _p.damage)
	var first_hop: float = nearest.max_hp - nearest.hp  # one ratio per hop, the tuning number unnamed
	assert_lt(first_hop, _p.damage)
	assert_almost_eq((next.max_hp - next.hp) / first_hop, first_hop / _p.damage, 0.00001)
	for untouched: RangeTarget in [farther, beyond_hops, flesh]:
		assert_eq(untouched.hp, untouched.max_hp)
	assert_eq(dead.hp, 0.0)
	assert_eq(
		_sim.chain_arcs,
		[PackedVector2Array([first.pos, nearest.pos]), PackedVector2Array([nearest.pos, next.pos])]
	)


func test_chain_includes_exact_radius_then_stops_when_no_conductor_is_in_reach() -> void:
	_w.chain_hops = 4
	_w.chain_radius_m = 4.0
	var first: RangeTarget = _target(Vector2.ZERO, true)
	var boundary: RangeTarget = _target(Vector2(4.0, 0.0), true)
	var outside: RangeTarget = _target(Vector2(8.25, 0.0), true)
	Impact.land(_sim, _p, first, first.pos)
	assert_lt(boundary.hp, boundary.max_hp)
	assert_eq(outside.hp, outside.max_hp)
	assert_eq(_sim.chain_arcs.size(), 1)
	assert_eq(first.hp, first.max_hp - _p.damage, "never jump back to an earlier t")


func test_chain_requires_a_metal_direct_victim_and_positive_hop_count() -> void:
	_w.chain_hops = 2
	_w.chain_radius_m = 4.0
	var flesh: RangeTarget = _target(Vector2.ZERO)
	var metal: RangeTarget = _target(Vector2(2.0, 0.0), true)
	Impact.land(_sim, _p, flesh, flesh.pos)
	Impact.land(_sim, _p, null, Vector2.ZERO)
	assert_eq(metal.hp, metal.max_hp)
	assert_eq(_sim.chain_arcs.size(), 0)
	_w.chain_hops = 0
	Impact.land(_sim, _p, metal, metal.pos)
	assert_eq(metal.hp, metal.max_hp - _p.damage)
	assert_eq(_sim.chain_arcs.size(), 0)


func test_patch_is_created_at_ground_impact_with_weapon_radius_duration_and_dps() -> void:
	_w.patch_ticks = 9
	var at: Vector2 = Vector2(12.0, -8.0)
	Impact.land(_sim, _p, null, at)
	assert_eq(_sim.patches, [Vector4(at.x, at.y, _w.patch_radius_m, _w.dot_dps)])
	assert_eq(_sim.patch_ticks, [_w.patch_ticks])


func test_thrown_hit_leaves_a_patch_but_other_body_hits_do_not() -> void:
	_w.patch_ticks = 9
	var t: RangeTarget = _target(Vector2(12.0, -8.0))
	_w.kind = WeaponSpec.Kind.ROCKET
	Impact.land(_sim, _p, t, t.pos)
	assert_eq(_sim.patches.size(), 0)
	_w.kind = WeaponSpec.Kind.THROWN
	Impact.land(_sim, _p, t, t.pos)
	assert_eq(_sim.patches, [Vector4(12.0, -8.0, _w.patch_radius_m, _w.dot_dps)])
	assert_eq(_sim.patch_ticks, [_w.patch_ticks])


func test_zero_patch_duration_disables_ground_fire_even_for_thrown_rounds() -> void:
	_w.kind = WeaponSpec.Kind.THROWN
	_w.patch_ticks = 0
	Impact.land(_sim, _p, null, Vector2.ZERO)
	assert_eq(_sim.patches.size(), 0)
	assert_eq(_sim.patch_ticks.size(), 0)


func _target(at: Vector2, metal: bool = false) -> RangeTarget:
	var target: RangeTarget = RangeTarget.make(_sim.targets.size() + 1, at, 100.0, 1.0)
	target.metal = metal
	_sim.targets.append(target)
	return target
