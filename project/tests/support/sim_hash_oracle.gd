class_name SimHashOracle
extends RefCounted
## Test support for CitySimHash build histories (n15 Codex tester): a naive answer read only from
## CitySimState arrays and SimConst (cell row, column, then id), a reused hash and a fresh one.

var s: CitySimState
var cam: Vector2 = Vector2.ZERO
var _h: CitySimHash
var _fresh: CitySimHash


func _init() -> void:
	s = CitySimState.new()
	s.init(1)
	_h = CitySimHash.new(s)


func place(id: int, cell: Vector2i) -> void:
	var at: Vector2 = point(cell)
	s.alive[id] = 1
	s.tier[id] = 0
	s.px[id] = at.x
	s.py[id] = at.y


func point(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2.ONE * 0.25) * SimConst.HC


func origin(camera: Vector2) -> Vector2i:
	var half: int = SimConst.HW >> 1
	return Vector2i(floori(camera.x / SimConst.HC) - half, floori(camera.y / SimConst.HC) - half)


func _cell(id: int) -> Vector2i:
	return Vector2i(floori(s.px[id] / SimConst.HC), floori(s.py[id] / SimConst.HC))


func _before(a: int, b: int) -> bool:
	var ac: Vector2i = _cell(a)
	var bc: Vector2i = _cell(b)
	if ac.y != bc.y:
		return ac.y < bc.y
	if ac.x != bc.x:
		return ac.x < bc.x
	return a < b


func expected(at: Vector2, radius: int) -> Array[int]:
	var out: Array[int] = []
	var lo: Vector2i = origin(cam)
	var centre: Vector2i = Vector2i(floori(at.x / SimConst.HC), floori(at.y / SimConst.HC))
	for id: int in SimConst.CAP:
		if s.alive[id] == 0 or s.tier[id] != 0:
			continue
		var cell: Vector2i = _cell(id)
		if cell.x < lo.x or cell.x >= lo.x + SimConst.HW:
			continue
		if cell.y < lo.y or cell.y >= lo.y + SimConst.HW:
			continue
		if absi(cell.x - centre.x) <= radius and absi(cell.y - centre.y) <= radius:
			out.append(id)
	out.sort_custom(_before)
	return out


func build(camera: Vector2) -> void:
	cam = camera
	_h.build(camera.x, camera.y)
	_fresh = CitySimHash.new(s)
	_fresh.build(camera.x, camera.y)


func check(t: GutTest, at: Vector2, radius: int) -> void:
	var actual: Array[int] = _h.query(at.x, at.y, radius)
	var label: String = "camera %s point %s radius %d" % [cam, at, radius]
	t.assert_eq(actual, expected(at, radius), "naive: " + label)
	t.assert_eq(actual, _fresh.query(at.x, at.y, radius), "fresh: " + label)
