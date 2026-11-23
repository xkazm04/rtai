extends GutTest

const MIN_LANE_M: float = 2.5
const CLOSED_M: float = 0.05

var data: DataTable
var plan: PrologueYard


func before_each() -> void:
	data = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	plan = PrologueYard.from_stage(data)


func _gap(a: Rect2, b: Rect2) -> float:
	return (a.position - b.end).max(b.position - a.end).max(Vector2.ZERO).length()


func _lane(gap: float, between: String) -> void:
	assert_true(gap <= CLOSED_M or gap >= MIN_LANE_M, "%s: %.3f m" % [between, gap])


func test_default_footprints_and_all_passages_including_fence_returns() -> void:
	assert_eq(plan.dressing.id, "line_fire")
	var props: Array[ArenaStation.Prop] = plan.stations.stations[0].props
	assert_eq(props.size(), plan.fences.size() + plan.wrecks.size())
	for i: int in plan.wrecks.size():
		var piece: PrologueYard.Wreck = plan.wrecks[i]
		var box: Rect2 = piece.footprint
		assert_gt(box.get_area(), 0.0, piece.id)
		assert_true(plan.yard.encloses(box), piece.id)
		var prop: ArenaStation.Prop = props[plan.fences.size() + i]
		assert_eq(prop.kind, "cover_low", piece.id)
		assert_eq(prop.at, box.get_center(), piece.id)
		assert_eq(prop.size, box.size, piece.id)
		for edge: float in [
			box.position.x, box.position.y, plan.yard.end.x - box.end.x, plan.yard.end.y - box.end.y
		]:
			_lane(edge, piece.id + " to edge")
		for fence: Rect2 in plan.fences:
			assert_false(box.intersects(fence), piece.id)
			_lane(_gap(box, fence), piece.id + " to fence")
		for j: int in range(i):
			var other: PrologueYard.Wreck = plan.wrecks[j]
			assert_false(box.intersects(other.footprint), piece.id + "/" + other.id)
			_lane(_gap(box, other.footprint), piece.id + "/" + other.id)


func test_script_marks_and_gate_approach_are_clear() -> void:
	var arrival: Dictionary = data.object(data.raw, "arrival")
	var marks: Array[Vector2] = [
		plan.rivet_start,
		data.vec(arrival, "rivet_at"),
		data.vec(arrival, "first_warden_at"),
		data.vec(data.object(data.raw, "payphone"), "at")
	]
	for body: Dictionary in data.array(data.raw, "opening_bodies"):
		marks.append(data.vec(body, "at"))
	_arrival_marks(marks, arrival)
	_command_marks(marks)
	var opening: Vector2 = Vector2.RIGHT * plan.gate_width_m
	var gate: Rect2 = Rect2(plan.gate - opening * 0.5, opening)
	for wreck: PrologueYard.Wreck in plan.wrecks:
		assert_gte(_gap(wreck.footprint, gate), 4.0, wreck.id + " to gate")
		for mark: Vector2 in marks:
			assert_gte(
				_gap(wreck.footprint, Rect2(mark, Vector2.ZERO)), 1.0, "%s to %s" % [wreck.id, mark]
			)


func _arrival_marks(marks: Array[Vector2], arrival: Dictionary) -> void:
	var groups: Array = data.raw["waves"][0]["groups"]
	var rank: int = data.integer(arrival, "rank_size")
	var spacing: float = data.num(arrival, "spacing_m")
	for formation: Dictionary in data.array(arrival, "formations"):
		var first: Vector2 = data.vec(formation, "first")
		for group: Dictionary in groups:
			if group["id"] != formation["id"]:
				continue
			for i: int in data.integer(group, "count"):
				var mark: Vector2 = first + data.vec(formation, "step") * (i % rank)
				marks.append(mark + Vector2.DOWN * floorf(float(i) / rank) * spacing)
				if group["id"] == "frightened_patrol":
					var offset: Array = arrival["patrol_offsets_m"][i]
					marks.append(first + data.vec({"offset": offset}, "offset"))
	for file: int in rank:
		var x: float = (file - (rank - 1) * 0.5) * spacing
		marks.append(plan.gate + Vector2(x, -data.num(arrival, "gate_exit_m")))


func _command_marks(marks: Array[Vector2]) -> void:
	var command: Dictionary = data.object(data.raw, "command")
	var front: Vector2 = data.vec(command, "front_at")
	var spacing: float = data.num(command, "file_spacing_m")
	var gap: float = data.num(command, "rank_spacing_m")
	for group: Dictionary in data.raw["waves"][1]["groups"]:
		var count: int = data.integer(group, "count")
		for i: int in count:
			var side: float = (i - (count - 1) * 0.5) * spacing
			var depth: float = gap if group["role"] == "ranged_line" else 0.0
			if group["role"] == "behind_line":
				side = spacing * 0.5
				depth = 3.0 * gap
			marks.append(front + Vector2(side, depth))


func test_every_named_rifle_post_resolves_once() -> void:
	var ids: Array[String] = []
	for piece: PrologueYard.Wreck in plan.wrecks:
		ids.append(piece.id)
	var posts: Array = data.raw["command"]["rifle_posts"]
	assert_eq(posts, ["burnt_pickup", "press_carcass", "fuel_vessel", "scrap_skip"])
	for id: String in posts:
		assert_eq(ids.count(id), 1, id)


func test_layout_replaces_stage_debris_and_keeps_drag_marks_paint_only() -> void:
	var table: DataTable = DataTable.open(PrologueYardDressing.TABLE, PrologueYardDressing.SCHEMA)
	var layout: Dictionary = table.raw["dressings"]["line_fire"]["layout"]
	_assert_pieces(plan.wrecks, table.array(layout, "cover"))
	_assert_pieces(plan.debris, table.array(layout, "debris"))
	for i: int in plan.debris.size():
		var mark: Dictionary = layout["debris"][i]
		var angle: float = mark.get("rotation_deg", 0.0)
		assert_almost_eq(plan.debris[i].rotation, deg_to_rad(angle), 0.00001)
		assert_eq(plan.debris[i].tint, Color(str(mark.get("tint", "ffffff"))))


func test_legacy_dressings_keep_the_stage_cover_debris_and_solid_kinds() -> void:
	var yard: Dictionary = data.object(data.raw, "yard")
	for id: String in ["plain", "torn_line"]:
		yard["dressing"] = id
		var legacy: PrologueYard = PrologueYard.from_stage(data)
		_assert_pieces(legacy.wrecks, data.array(yard, "cover"))
		_assert_pieces(legacy.debris, data.array(yard, "debris"))
		for prop: ArenaStation.Prop in legacy.stations.stations[0].props.slice(
			legacy.fences.size()
		):
			assert_eq(prop.kind, "cover_high")


func _assert_pieces(pieces: Array[PrologueYard.Wreck], rows: Array) -> void:
	assert_eq(pieces.size(), rows.size())
	for i: int in mini(rows.size(), pieces.size()):
		var row: Dictionary = rows[i]
		var size_m: Vector2 = data.vec(row, "size_m")
		assert_eq(pieces[i].id, data.text(row, "id"))
		assert_eq(pieces[i].art, data.text(row, "art"))
		assert_eq(pieces[i].footprint, Rect2(data.vec(row, "at") - size_m * 0.5, size_m))
		var crop: Rect2 = Rect2(0, 0, 1, 1)
		if row.has("crop"):
			var ink: Dictionary = data.object(row, "crop")
			crop = Rect2(data.vec(ink, "origin"), data.vec(ink, "size"))
		assert_eq(pieces[i].crop, crop)
