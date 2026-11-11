extends GutTest
## Lane kills-new (n16): the deaths of the weapons that had none. Each row passes the schema and
## plays its own style; --gore=reduced drops the victim whole (the standard death); the pose
## track (KillTrack) leans, buckles and lays the body copy on its feet, the same at the same tick.

## weapon -> the n16 style its kill takes.
const NEW: Dictionary[StringName, StringName] = {
	&"pistol": &"snap",
	&"machine_pistol": &"stitch",
	&"gloria": &"pin",
}


func _kills(gore: String = "full") -> SignatureKills:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	table.gore_full = SignatureKillTable.gore_from_args(gore)
	return SignatureKills.new(table, RngRegistry.new(5).stream(&"brutality"))


func _ev(weapon: StringName) -> KillEvent:
	var e: KillEvent = KillEvent.make(3, Vector2(2.0, 2.0), Vector2(1.0, 0.0), weapon)
	e.human = true
	return e


func test_each_new_row_loads_with_its_style_and_track() -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	assert_eq(table.problems.size(), 0, str(table.problems))
	for w: StringName in NEW:
		var row: SignatureKill = table.for_weapon(w)
		assert_not_null(row, "%s has a row" % w)
		assert_eq(row.style, NEW[w])
		assert_true(KillNewStyles.owns(row.style), "%s is drawn by KillNewStyles" % w)
		assert_gt(KillTrackRows.of(row.id).track.size(), 1, "%s has a pose track" % row.id)
		assert_lte(row.hitstop_ticks, 6, "%s holds the fight at most ~6 ticks" % row.id)


func test_each_new_kill_replaces_the_standard_death() -> void:
	for w: StringName in NEW:
		var k: SignatureKills = _kills()
		assert_true(k.on_kill(_ev(w)), "%s takes the death" % w)
		var n: int = k.by_style.get(NEW[w], 0)
		assert_eq(n, 1)


func test_reduced_gore_drops_every_new_victim_whole() -> void:
	for w: StringName in NEW:
		var k: SignatureKills = _kills("reduced")
		assert_false(k.on_kill(_ev(w)), "%s: --gore=reduced = the standard death" % w)
		assert_true(k.consumed.is_empty())


func test_robots_never_take_a_new_kill() -> void:
	var e: KillEvent = _ev(&"pistol")
	e.human = false
	assert_false(_kills().on_kill(e))


func test_track_samples_linearly_and_holds_its_ends() -> void:
	var keys: Array[PackedFloat32Array] = [
		PackedFloat32Array([0, 0, 1, 0]),
		PackedFloat32Array([10, 10, 0.5, 0]),
		PackedFloat32Array([20, 0, 0.5, 1]),
	]
	assert_eq(KillTrack.sample(keys, -3), Vector3(0, 1, 0))
	assert_almost_eq(KillTrack.sample(keys, 5).x, 5.0, 0.001)
	assert_almost_eq(KillTrack.sample(keys, 5).y, 0.75, 0.001)
	assert_almost_eq(KillTrack.sample(keys, 15).z, 0.5, 0.001)
	assert_eq(KillTrack.sample(keys, 99), Vector3(0, 0.5, 1))


func test_basis_stands_upright_then_lies_toward_the_fall() -> void:
	var dir: Vector2 = Vector2.RIGHT
	var fall: Vector2 = KillTrack.fall_vec(dir, &"forward", 1.0)
	var up: Transform2D = KillTrack.basis(dir, fall, Vector3(0, 1, 0), 1.0)
	assert_almost_eq(up.x, Vector2.RIGHT, Vector2.ONE * 0.001)
	assert_almost_eq(up.y, Vector2.DOWN, Vector2.ONE * 0.001)
	var flat: Transform2D = KillTrack.basis(dir, fall, Vector3(0, 1, 1), 1.0)
	var head: Vector2 = -flat.y  # local up (feet -> head) after the fall
	var to_shooter: Vector2 = head.normalized()
	assert_almost_eq(to_shooter, Vector2.LEFT, Vector2.ONE * 0.001, "face down, head to him")
	var lean: Transform2D = KillTrack.basis(dir, fall, Vector3(14, 1, 0), 1.0)
	assert_gt((-lean.y).x, 0.0, "a + lean tips the head back along the shot")


func test_the_lay_pivots_on_the_feet() -> void:
	var node: Node2D = Node2D.new()
	var feet: Vector2 = Vector2(3.0, 40.0)
	var b: Transform2D = KillTrack.basis(Vector2.DOWN, Vector2.UP, Vector3(0, 0.8, 0.6), 1.0)
	KillTrack.lay(node, feet, b, Vector2.ZERO)
	assert_almost_eq(node.transform * feet, feet, Vector2.ONE * 0.001)
	node.free()


func test_the_same_tick_poses_the_same_body() -> void:
	var a: Transform2D = _posed(20)
	assert_eq(a, _posed(20))
	assert_ne(a, _posed(8), "the track moves the body between ticks")


func _posed(age: int) -> Transform2D:
	var k: SignatureKills = _kills()
	var fx: KillNewStyles = KillNewStyles.new()
	fx.bind(k, 32.0, false)
	var body: Node2D = KillNewStyles.wrap_body(GibBlob.new())
	var row: SignatureKill = k.table.for_weapon(&"pistol")
	fx.add(0, body, row, Vector2.ZERO, Vector2.RIGHT)
	k.tick = age
	fx.pose()
	var out: Transform2D = (body.get_child(0) as Node2D).transform
	body.free()
	fx.free()
	return out


func test_the_blot_is_per_row_and_the_old_rows_keep_theirs() -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	assert_eq(table.for_weapon(&"rocket_launcher").blot_m, 0.5, "kills-polish's rows: unchanged")
	assert_lt(table.for_weapon(&"pistol").blot_m, 0.5, "the pistol: a small splat")
	assert_eq(table.for_weapon(&"machine_pistol").blot_m, 0.0, "the stitch: the dotted line only")
	var k: SignatureKills = _kills()
	@warning_ignore("return_value_discarded")
	k.on_kill(_ev(&"pistol"))
	var last: KillMarks.Mark = k.marks.marks[k.marks.marks.size() - 1]
	assert_eq(last.blot_m, table.for_weapon(&"pistol").blot_m)
