extends GutTest
## Build histories that move the camera or the actors far enough that the same cell index means
## another place (n15 Codex tester, t-5's O(actors) build); oracle in SimHashOracle.

var _o: SimHashOracle


func before_each() -> void:
	_o = SimHashOracle.new()


func test_unequal_cell_counts_swap_prefix_offsets_without_losing_the_last_slot() -> void:
	var cells: Array[Vector2i] = [Vector2i(-2, -2), Vector2i.ZERO, Vector2i(2, 2)]
	for phase: int in 6:
		for id: int in SimConst.CAP:
			var bucket: int = 0 if id < SimConst.CAP - 2 else id - SimConst.CAP + 3
			_o.place(id, cells[(bucket + phase) % cells.size()])
		_o.build(Vector2.ZERO)
		for cell: Vector2i in cells:
			_o.check(self, _o.point(cell), 0)
			_o.check(self, _o.point(cell), 1)
		_o.check(self, Vector2.ZERO, SimConst.HW)


func test_camera_shifts_reuse_indices_without_leaking_old_world_members() -> void:
	var far: int = SimConst.HW * 4
	var cameras: Array[Vector2i] = [
		Vector2i.ZERO,
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(far, -far),
		Vector2i(-far, far),
		Vector2i.ZERO
	]
	for id: int in SimConst.CAP:
		var home: Vector2i = cameras[id % cameras.size()]
		var edge: int = (SimConst.HW >> 1) - 1
		_o.place(id, home + Vector2i(edge if id % 2 == 0 else -edge, id % 3 - 1))
	for camera: Vector2i in cameras:
		_o.build(_o.point(camera))
		_o.check(self, _o.cam, SimConst.HW)
		var lo: Vector2i = _o.origin(_o.cam)
		for offset: Vector2i in [Vector2i.ZERO, Vector2i(SimConst.HW - 1, SimConst.HW - 1)]:
			_o.check(self, _o.point(lo + offset), 1)
		_o.check(self, _o.point(Vector2i.ZERO), 0)


func test_translated_actors_reuse_cell_indices_then_leave_them_empty() -> void:
	for phase: int in 6:
		var shift: Vector2i = Vector2i(phase * SimConst.HW, -phase * SimConst.HW)
		_o.s.alive.fill(0)
		for id: int in SimConst.CAP:
			if phase % 2 == 0 or id % 3 == 0:
				_o.place(id, shift + Vector2i(id % 7 - 3, id % 11 - 5))
		_o.build(_o.point(shift))
		_o.check(self, _o.cam, SimConst.HW)
		for y: int in range(-5, 6):
			for x: int in range(-3, 4):
				_o.check(self, _o.point(shift + Vector2i(x, y)), 0)


func test_patterned_build_history_matches_naive_state_after_every_transition() -> void:
	for phase: int in 32:
		var camera: Vector2i = Vector2i(phase % 7 - 3, phase * 3 % 7 - 3)
		if phase % 8 == 4:
			camera *= SimConst.HW * 3
		for id: int in SimConst.CAP:
			var cell: Vector2i = (
				camera
				+ Vector2i(
					(id * 37 + phase * 11) % (SimConst.HW * 2 + 1) - SimConst.HW,
					(id * 53 + phase * 17) % (SimConst.HW * 2 + 1) - SimConst.HW
				)
			)
			if phase % 4 == 0:
				cell = camera + Vector2i(id % 3 - 1, id % 3 - 1)
			_o.place(id, cell)
			_o.s.alive[id] = 0 if (id + phase) % 5 == 0 else 1
			_o.s.tier[id] = (id + phase) % 3
		_o.build(_o.point(camera))
		_o.check(self, _o.cam, SimConst.HW)
		for probe: int in 12:
			var id: int = (phase * 53 + probe * 37) % SimConst.CAP
			_o.check(self, Vector2(_o.s.px[id], _o.s.py[id]), probe % 3)
