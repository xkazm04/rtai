class_name GauntletLandmarks
extends RefCounted
## The same station footprints used by combat receive neighbourhood-specific city furniture.
## The artist's overhead prop is also available when a view has no standing card for it.

const FLAT: String = GauntletPropArt.FLAT
const COPING: Texture2D = preload("res://features/city/art/ground/roof_edge_tone.png")
const BARRIER: Texture2D = preload("res://features/city/art/props/barricade.png")


static func ground(ci: CanvasItem, block: GauntletSegment) -> void:
	var road: Rect2 = block.road_bounds(0.0)
	var use: String = block.dressing["landmark"]
	if use == "square":
		var square: Rect2 = Rect2(road.position + Vector2(4.0, 0.0), road.size - Vector2(8.0, 0.0))
		GauntletFrontage.tile(ci, square, GauntletFrontage.SLABS, 5.0)
		ci.draw_rect(GauntletFrontage.px(square.grow(-0.35)), Ink.INK, false, 4.0)
	else:
		for x: int in range(2, int(block.length_m), 5):
			var dash: Rect2 = Rect2(block.start_x + x, -0.06, 2.0, 0.12)
			if not block.crossing.grow(0.8).intersects(dash):
				ci.draw_rect(GauntletFrontage.px(dash), Ink.CREAM)
	if use == "signals":
		var zebra: Rect2 = block.crossing
		var y: float = zebra.position.y
		while y < zebra.end.y:
			var stripe: Rect2 = Rect2(zebra.position.x, y, zebra.size.x, minf(0.5, zebra.end.y - y))
			ci.draw_rect(GauntletFrontage.px(stripe), Ink.CREAM)
			y += 1.0
		ci.draw_rect(GauntletFrontage.px(Rect2(zebra.position.x - 1.2, 0.3, 0.2, 4.8)), Ink.CREAM)
		ci.draw_rect(GauntletFrontage.px(Rect2(zebra.end.x + 1.0, -5.1, 0.2, 4.8)), Ink.CREAM)
	elif use == "dock":
		_hatch(ci, Rect2(block.start_x + 2.0, road.position.y, block.length_m - 4.0, 3.25))
	elif use == "viaduct":
		_viaduct(ci, road)
	elif use == "market":
		for side: float in [-4.0, 4.0]:
			var strip: Rect2 = Rect2(block.start_x + 6.0, side - 1.2, block.length_m - 12.0, 2.4)
			GauntletFrontage.tile(ci, strip, GauntletFrontage.SLABS, 3.0)
	elif use == "bus":
		var bay: Rect2 = Rect2(block.start_x + 10.0, road.position.y + 0.4, 12.0, 3.5)
		ci.draw_rect(GauntletFrontage.px(bay), Ink.CREAM, false, 5.0)


static func _hatch(ci: CanvasItem, rect: Rect2) -> void:
	ci.draw_rect(GauntletFrontage.px(rect), Ink.CREAM, false, 5.0)
	var x: float = rect.position.x
	while x + rect.size.y < rect.end.x:
		ci.draw_line(
			Ink.px(Vector2(x, rect.end.y)),
			Ink.px(Vector2(x + rect.size.y, rect.position.y)),
			Ink.CREAM,
			5.0
		)
		x += 2.0


static func furniture(ci: CanvasItem, block: GauntletSegment) -> void:
	var deck: Dictionary = block.dressing
	var road: Rect2 = block.road_bounds(0.0)
	var width: float = deck["sidewalk_m"]
	for row: Dictionary in deck["fixtures"]:
		var at: Array = row["at"]
		var x: float = at[0]
		var y: float = at[1]
		var art: String = row["art"]
		var size: float = row["scale"]
		var edge: float = road.end.y if y > road.get_center().y else road.position.y - width
		var walk: Rect2 = Rect2(block.start_x, edge, block.length_m, width)
		GauntletPropArt.fixture(ci, art, Vector2(block.start_x + x, y), size, walk)
	for p: ArenaStation.Prop in block.station.props:
		var r: Rect2 = Rect2(p.at - p.size * 0.5, p.size)
		if p.kind == "wall_high":
			if p.size.x < block.length_m:
				_wing(ci, r)
			else:
				_edge(ci, r)
			continue
		var entry: String = "high" if p.kind == "cover_high" else "low"
		var art: String = deck[entry]
		if deck["landmark"] == "viaduct" and p.kind == "cover_high":
			_pier(ci, r)
			continue
		if deck["landmark"] == "barriers":
			ArenaFloorStatic.barrier(ci, GauntletFrontage.px(r))
			ci.draw_texture_rect(BARRIER, GauntletFrontage.px(r.grow(-0.08)), false)
			continue
		# The dark contact base is the exact solid footing (one rule with the yard).
		PropBase.draw(ci, r)
		var scale_m: float = deck[entry + "_scale"]
		GauntletPropArt.cover(ci, art, r, scale_m)


## The deck is cut away above the playable road. Its two visible ends, abutments and girder
## shadows identify the underpass while the camera can still see every fighter below it.
static func _viaduct(ci: CanvasItem, road: Rect2) -> void:
	var mid: float = road.get_center().x
	var width: float = 12.0
	var left: float = mid - width * 0.5
	for y: float in [road.position.y - 30.0, road.end.y]:
		var deck: Rect2 = Rect2(left, y, width, 30.0)
		GauntletFrontage.tile(ci, deck, GauntletFrontage.ASPHALT, 8.0)
		for side: float in [left, left + width - 0.4]:
			var rail: Rect2 = Rect2(side, y, 0.4, 30.0)
			ArenaFloorStatic.barrier(ci, GauntletFrontage.px(rail))
		for i: int in 6:
			var mark: Rect2 = Rect2(mid - 0.075, y + i * 5.0 + 1.0, 0.15, 2.6)
			ci.draw_rect(GauntletFrontage.px(mark), Ink.CREAM)
	# Show the deck's thickness and transverse beams over the pier ends at each portal.
	for y: float in [road.position.y - 1.1, road.end.y]:
		var lip: Rect2 = Rect2(left - 0.15, y, width + 0.3, 1.1)
		ArenaFloorStatic.barrier(ci, GauntletFrontage.px(lip))
		ci.draw_texture_rect(COPING, GauntletFrontage.px(lip.grow(-0.12)), false)
	var shade: Rect2 = Rect2(left, road.position.y, width, road.size.y)
	ci.draw_rect(GauntletFrontage.px(shade), Ink.WASH)
	for i: int in 4:
		var beam: Rect2 = Rect2(left + i * 3.4 + 0.5, road.position.y, 0.25, road.size.y)
		ci.draw_rect(GauntletFrontage.px(beam), Ink.WASH)


## A capped parapet separates the playable carriageway from the pavement and upper deck.
static func _edge(ci: CanvasItem, r: Rect2) -> void:
	ArenaFloorStatic.barrier(ci, GauntletFrontage.px(r))
	var coping: Rect2 = Rect2(r.position + Vector2(0.0, 0.08), Vector2(r.size.x, 0.30))
	ci.draw_texture_rect(COPING, GauntletFrontage.px(coping), false)
	for i: int in range(0, ceili(r.size.x), 3):
		var post: Rect2 = Rect2(r.position + Vector2(i, 0.0), Vector2(0.30, r.size.y))
		ci.draw_rect(GauntletFrontage.px(post), Ink.INK)


static func _pier(ci: CanvasItem, r: Rect2) -> void:
	ArenaFloorStatic.barrier(ci, GauntletFrontage.px(r))
	var cap: Rect2 = Rect2(r.position, Vector2(r.size.x, r.size.y * 0.65))
	var face: Rect2 = Rect2(r.position.x, cap.end.y, r.size.x, r.end.y - cap.end.y)
	ci.draw_texture_rect(GauntletFrontage.FRONTS["masonry"], GauntletFrontage.px(face), false)
	ci.draw_texture_rect(COPING, GauntletFrontage.px(cap), false)
	ci.draw_rect(GauntletFrontage.px(cap), Ink.INK, false, 4.0)


static func _wing(ci: CanvasItem, r: Rect2) -> void:
	# The short inner walls of the alley are the stepped ends of the adjoining buildings.
	var rect: Rect2 = Rect2(r.position, Vector2(r.size.x, r.size.y * 0.65))
	ci.draw_texture_rect(GauntletFrontage.ROOFS["masonry"], GauntletFrontage.px(rect), false)
	var edge: Rect2 = Rect2(rect.position.x, rect.end.y, r.size.x, r.end.y - rect.end.y)
	ci.draw_texture_rect(GauntletFrontage.FRONTS["masonry"], GauntletFrontage.px(edge), false)
