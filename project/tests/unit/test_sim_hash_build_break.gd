extends GutTest
## Build histories attack touched-cell clearing and prefix offsets (n15 Codex tester, t-5's
## O(actors) build): each query is checked against SimHashOracle's naive answer and a fresh hash.

var _o: SimHashOracle


func before_each() -> void:
	_o = SimHashOracle.new()


func test_first_build_and_repeated_empty_builds_have_no_phantom_members() -> void:
	for cam: Vector2 in [Vector2.ZERO, _o.point(Vector2i(-3, 7)), Vector2.ZERO]:
		_o.build(cam)
		_o.check(self, cam, 0)
		_o.check(self, cam, SimConst.HW)
	for id: int in SimConst.CAP:
		_o.place(id, Vector2i.ZERO)
		_o.s.tier[id] = 1 + id % 2
	_o.build(Vector2.ZERO)
	_o.check(self, Vector2.ZERO, SimConst.HW)
	_o.s.tier[SimConst.CAP - 1] = 0
	_o.build(Vector2.ZERO)
	_o.check(self, Vector2.ZERO, 0)


func test_first_populated_build_orders_cells_before_ids_and_never_duplicates() -> void:
	var lo: Vector2i = _o.origin(Vector2.ZERO)
	var cells: Array[Vector2i] = [
		lo,
		lo + Vector2i(SimConst.HW - 1, 0),
		lo + Vector2i(0, 1),
		lo + Vector2i(SimConst.HW - 1, SimConst.HW - 1),
		Vector2i.ZERO
	]
	for id: int in SimConst.CAP:
		_o.place(id, cells[(SimConst.CAP - 1 - id) % cells.size()])
	_o.build(Vector2.ZERO)
	_o.check(self, Vector2.ZERO, SimConst.HW)
	for cell: Vector2i in cells:
		_o.check(self, _o.point(cell), 0)
		_o.check(self, _o.point(cell), 1)


func test_vacated_cells_stay_empty_across_empty_builds_and_repopulation() -> void:
	var old: Vector2i = Vector2i(-2, -1)
	var next: Vector2i = Vector2i(3, 2)
	for id: int in SimConst.CAP:
		_o.place(id, old)
	_o.build(Vector2.ZERO)
	_o.check(self, _o.point(old), 0)
	for phase: int in 6:
		_o.s.alive.fill(0)
		if phase % 3 == 0:
			_o.place(SimConst.CAP - 1, next)
		elif phase % 3 == 2:
			_o.place(0, old)
		_o.build(Vector2.ZERO)
		_o.check(self, _o.point(old), 0)
		_o.check(self, _o.point(next), 0)
		_o.check(self, Vector2.ZERO, SimConst.HW)


func test_death_revival_and_both_tier_transitions_replace_membership_each_build() -> void:
	for id: int in SimConst.CAP:
		_o.place(id, Vector2i(id % 3 - 1, id % 5 - 2))
	for phase: int in 9:
		for id: int in SimConst.CAP:
			var status: int = (id + phase) % 4
			_o.s.alive[id] = 0 if status == 0 else 1
			_o.s.tier[id] = maxi(0, status - 1)
		_o.build(Vector2.ZERO)
		_o.check(self, Vector2.ZERO, SimConst.HW)
		for y: int in range(-2, 3):
			for x: int in range(-1, 2):
				_o.check(self, _o.point(Vector2i(x, y)), 0)


func test_hundreds_of_cells_merge_split_and_reverse_without_stale_prefixes() -> void:
	var lo: Vector2i = _o.origin(Vector2.ZERO)
	var count: int = mini(SimConst.CAP, SimConst.HW * SimConst.HW)
	for phase: int in 5:
		for id: int in count:
			var index: int = count - 1 - id if phase % 2 == 0 else id
			var cell: Vector2i = (
				lo + Vector2i(index % SimConst.HW, floori(float(index) / SimConst.HW))
			)
			_o.place(id, Vector2i.ZERO if phase == 2 else cell)
		_o.build(Vector2.ZERO)
		_o.check(self, Vector2.ZERO, SimConst.HW)
		_o.check(self, Vector2.ZERO, 0)
		for index: int in count:
			var cell: Vector2i = (
				lo + Vector2i(index % SimConst.HW, floori(float(index) / SimConst.HW))
			)
			_o.check(self, _o.point(cell), 0)
