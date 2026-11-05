class_name StageView
extends Node2D
## Quest 1's places as flat placeholder ink: Factory Row's alley and dumpster, the payphones
## (ringing rings while Patch has a call), the Toner Room basement, Dock 9's floor, gates,
## catwalks and vault cage, the TUCK-IN crate stack with its bolt-through-a-robot mark, the
## Harbor Road skip, and the cash taped under the phone.

const KERB_ROWS: float = 338.0
## Places at least this big (m) get their name stencilled on the city street.
const STENCIL_MIN_R: float = 5.0
## The ghost powers' cars (the arena's powers pad, quest 1's ghost_cars) in the city's traffic
## print: one atlas per VehicleBody.State (intact, d1, d2, the soul-hijacked teal plate, the burnt
## wreck), cell = the car's art id, nose to +x
## (CrowdLayers TRAFFIC_CELL_PX on a 3 x 3 grid), the car-shaped ink shadow under it.
const CAR_ATLAS: Array[Texture2D] = [
	preload("res://features/city/art/vehicles/traffic_atlas.png"),
	preload("res://features/city/art/vehicles/traffic_atlas_d1.png"),
	preload("res://features/city/art/vehicles/traffic_atlas_d2.png"),
	preload("res://features/city/art/vehicles/traffic_atlas_hijack.png"),
	preload("res://features/vehicles/art/traffic_atlas_wreck.png"),
]
const CAR_CELL_PX: Vector2 = Vector2(512.0, 256.0)
const CAR_COLS: int = 3

var stage: CollectCallStage
## The invented arena's floors and labels (off on the city, whose ground is the world).
var zones: bool = true


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if stage == null:
		return
	if zones:
		_zones()
	else:
		_stencils()
	for spot: String in stage.layout.hide_at:
		_sprite("dumpster", stage.layout.hide_at[spot], Vector2(2.4, 1.6))
	for phone: String in stage.layout.phones:
		_phone(phone, stage.layout.phones[phone])
	_crates()
	for b: VehicleBody in stage.cars():
		_car(b)
	draw_set_transform(Vector2.ZERO)


func _zones() -> void:
	var l: StageLayout = stage.layout
	_tiled(Rect2(-9, -9, 18, 18), "dock_floor", 8.0)
	_floor(Rect2(-9, -9, 18, 18), Color(0, 0, 0, 0), "FACTORY ROW")
	var toner: Vector2 = l.marker("The Toner Room").at
	_floor(Rect2(toner - Vector2(9, 7), Vector2(18, 14)), Ink.WASH, "THE TONER ROOM")
	_tiled(Rect2(toner - Vector2(9, 7), Vector2(18, 14)), "basement_floor", 4.0)
	var dock: Vector2 = l.marker("Dock 9 bonded storage").at
	_floor(Rect2(dock - Vector2(18, 18), Vector2(38, 36)), Ink.WASH, "DOCK 9")
	_tiled(Rect2(dock - Vector2(18, 18), Vector2(38, 36)), "dock_floor", 8.0)
	for y: float in [-15.0, 15.0]:
		_tiled(Rect2(dock.x - 12, y - 0.6, 26.0, 1.2), "catwalk", 4.0, 1.2)
	var cage: Vector2 = l.marker("Dock 9 vault cage").at
	var cage_rect: Rect2 = Rect2(Ink.px(cage - Vector2(8, 10)), Vector2(16, 6) * Ink.PX_PER_M)
	_tiled(Rect2(cage - Vector2(8, 10), Vector2(16, 6)), "cage_mesh", 2.0)
	draw_rect(cage_rect, Ink.INK, false, Ink.LINE_PX)
	var road: Vector2 = l.marker("Harbor Road").at
	_road(Rect2(road.x - 22, road.y + 3, 50, 5))
	_kerb(Rect2(road.x - 22, road.y + 3 - KERB_ROWS / 96.0, 50, KERB_ROWS / 96.0))
	_floor(Rect2(road.x - 22, road.y + 3, 50, 5), Color(0, 0, 0, 0), "HARBOR ROAD")


## On the city: each place's name stencilled on the asphalt in road paint (the names are the
## places table's marker ids), above the place.
func _stencils() -> void:
	for name: String in stage.layout.places.markers:
		var m: QuestPlaces.Marker = stage.layout.marker(name)
		if m.radius_m >= STENCIL_MIN_R:
			Ink.label(self, m.at - Vector2(0.0, 2.2), name.to_upper(), 30, Ink.CREAM)


func _floor(r: Rect2, fill: Color, name: String) -> void:
	var p: Rect2 = Rect2(Ink.px(r.position), r.size * Ink.PX_PER_M)
	draw_rect(p, fill, true)
	draw_rect(p, Ink.INK, false, Ink.LINE_PX)
	Ink.label(self, r.position + Vector2(r.size.x * 0.5, 0.8), name, 30, Ink.INK)


## Art by id (data/tables/collect_call_art.json): an art swap never touches this scene.
func _art(name: String) -> Texture2D:
	return QuestArt.shared().texture(StringName(name))


## A texture tiled over a rect in metres, one texture repeat = tile_w x tile_h metres.
func _tiled(r: Rect2, name: String, tile_w: float, tile_h: float = -1.0) -> void:
	var t: Texture2D = _art(name)
	var th: float = tile_w if tile_h < 0.0 else tile_h
	var reps: Vector2 = Vector2(r.size.x / tile_w, r.size.y / th)
	var x: float = 0.0
	while x < reps.x:
		var y: float = 0.0
		while y < reps.y:
			var cell: Vector2 = Vector2(minf(1.0, reps.x - x), minf(1.0, reps.y - y))
			var at: Vector2 = r.position + Vector2(x * tile_w, y * th)
			var dst: Rect2 = Rect2(Ink.px(at), Vector2(cell.x * tile_w, cell.y * th) * Ink.PX_PER_M)
			draw_texture_rect_region(t, dst, Rect2(Vector2.ZERO, Vector2(t.get_size()) * cell))
			y += 1.0
		x += 1.0


## The city's D4 pavement + kerb (curb_straight_tone rows 0..KERB_ROWS, 96 px/m) along the road's
## north edge, 8 m repeats clipped at the end; the road band brings its own edge line.
func _kerb(r: Rect2) -> void:
	var t: Texture2D = _art("curb_straight_tone")
	var x: float = 0.0
	while x < r.size.x:
		var w: float = minf(8.0, r.size.x - x)
		var src: Rect2 = Rect2(0.0, 0.0, 96.0 * w, KERB_ROWS)
		var at: Vector2 = Ink.px(r.position + Vector2(x, 0.0))
		draw_texture_rect_region(t, Rect2(at, Vector2(w, r.size.y) * Ink.PX_PER_M), src)
		x += 8.0


## The city's D4 road tile between its two edge lines (texture rows 20..748), scaled uniformly
## so that band is the road's height, repeated along x and clipped at the end.
func _road(r: Rect2) -> void:
	var band: Rect2 = Rect2(0.0, 20.0, 768.0, 728.0)
	var rep: float = r.size.y * band.size.x / band.size.y
	var x: float = 0.0
	var k: int = 0
	while x < r.size.x:
		var tile: String = ["road_straight_tone", "road_straight_tone_b", "road_straight_tone_c"][
			k % 3
		]
		var t: Texture2D = _art(tile)
		var w: float = minf(rep, r.size.x - x)
		var src: Rect2 = Rect2(band.position, Vector2(band.size.x * w / rep, band.size.y))
		var dst: Rect2 = Rect2(
			Ink.px(r.position + Vector2(x, 0.0)), Vector2(w, r.size.y) * Ink.PX_PER_M
		)
		draw_texture_rect_region(t, dst, src)
		x += rep
		k += 1


func _sprite(name: String, at: Vector2, size: Vector2) -> void:
	draw_texture_rect(_art(name), Rect2(Ink.px(at - size * 0.5), size * Ink.PX_PER_M), false)


func _phone(phone: String, at: Vector2) -> void:
	_sprite("payphone", at, Vector2(1.3, 1.3))
	if stage.router.ringing(phone):
		var pulse: float = float(stage.tick % 30) / 30.0
		for k: int in 3:
			var r: float = (0.8 + k * 0.5 + pulse * 0.5) * Ink.PX_PER_M
			draw_arc(Ink.px(at), r, -2.4, -0.7, 16, Ink.VERMILION, Ink.LINE_PX, true)
	if stage.cash_phone == phone:
		_cash(at + Vector2(1.6, -0.3))


func _cash(env: Vector2) -> void:
	_sprite("cash_taped", env, Vector2(1.4, 0.8))


func _crates() -> void:
	var at: Vector2 = stage.layout.crates_at
	for row: int in 2:
		for col: int in 5:
			var c: Vector2 = at + Vector2(-4.0 + col * 2.0, -1.0 + row * 1.6)
			var crate: String = "tuckin_crate_hit" if stage.crates_burning else "tuckin_crate"
			_sprite(crate, c, Vector2(1.8, 1.4))
	Ink.label(self, at + Vector2(0.0, -2.1), stage.layout.crates_label, 22, Ink.INK)


## The stencil: a little robot head with a lightning bolt through it.
func _bolt_robot(c: Vector2) -> void:
	Ink.box(self, c, Vector2(0.45, 0.4), Ink.CREAM)
	draw_circle(Ink.px(c + Vector2(-0.1, -0.05)), 2.5, Ink.INK)
	draw_circle(Ink.px(c + Vector2(0.1, -0.05)), 2.5, Ink.INK)
	var bolt: Array[Vector2] = []
	for v: Vector2 in [
		Vector2(-0.3, -0.35), Vector2(0.05, 0.0), Vector2(-0.05, 0.05), Vector2(0.3, 0.4)
	]:
		bolt.append(Ink.px(c + v))
	draw_polyline(PackedVector2Array(bolt), Ink.VERMILION, 3.0, true)
	Ink.label(self, c + Vector2(-0.95, 0.0), "TUCK-IN", 11, Ink.INK)


## One car: its shadow offset down-right, then its body cell, both turned to its heading.
func _car(b: VehicleBody) -> void:
	var size: Vector2 = Vector2(VehicleView.CAR_L, VehicleView.CAR_W) / SimConst.PX_PER_M
	var r: Rect2 = Rect2(-size * 0.5 * Ink.PX_PER_M, size * Ink.PX_PER_M)
	var shadow: Vector2 = VehicleView.SHADOW_OFF / SimConst.PX_PER_M
	var cell: Rect2 = Rect2(
		Vector2(b.art % CAR_COLS, floorf(float(b.art) / CAR_COLS)) * CAR_CELL_PX, CAR_CELL_PX
	)
	var tex: Texture2D = CAR_ATLAS[clampi(b.state, 0, CAR_ATLAS.size() - 1)]
	draw_set_transform(Ink.px(b.pos + shadow), b.head.angle())
	draw_texture_rect_region(tex, r, cell, VehicleView.SHADOW)
	draw_set_transform(Ink.px(b.pos), b.head.angle())
	draw_texture_rect_region(tex, r, cell)
