extends GutTest
## rivet-motion: the charged shock. A short hold is a tap (the combo's), a hold past the threshold
## discharges with a stun that grows with the charge, and the arc chains through metal only, in
## range, never twice. Planted fault: a zero chain radius must stop the chain at the first target.

var shock: MeleeShock


func before_each() -> void:
	var t: DataTable = DataTable.open(MeleeTable.TABLE, MeleeTable.SCHEMA)
	shock = MeleeShock.from_row(t, t.object(t.raw, "shock"))
	assert_true(t.ok(), str(t.errors()))


func test_tap_is_not_a_shock() -> void:
	assert_eq(_hold(shock.charge_min - 1), -1)


func test_stun_grows_with_charge() -> void:
	var low: int = _hold(shock.charge_min)
	var full: int = _hold(shock.charge_full + 30)
	assert_eq(low, shock.stun_min, "a threshold release stuns the minimum")
	assert_eq(full, shock.stun_full, "a full charge (held longer is capped) stuns the most")


func test_chain_hops_metal_in_range_once() -> void:
	var pos: PackedVector2Array = PackedVector2Array(
		[Vector2(0, 0), Vector2(2, 0), Vector2(4, 0), Vector2(1, 1), Vector2(30, 0)]
	)
	var metal: PackedByteArray = PackedByteArray([1, 1, 1, 0, 1])
	var hit: PackedInt32Array = shock.chain(pos, metal, 0)
	assert_eq(hit, PackedInt32Array([0, 1, 2]), "the human (3) and the far robot (4) are skipped")


func test_planted_fault_zero_radius_stops_the_chain() -> void:
	var pos: PackedVector2Array = PackedVector2Array([Vector2(0, 0), Vector2(2, 0)])
	var metal: PackedByteArray = PackedByteArray([1, 1])
	assert_eq(shock.chain(pos, metal, 0).size(), 2)
	shock.chain_radius_m = 0.0
	assert_eq(shock.chain(pos, metal, 0).size(), 1, "the fault is caught")


func _hold(ticks: int) -> int:
	for _k: int in ticks:
		assert_eq(shock.step(true), 0)
	return shock.step(false)
