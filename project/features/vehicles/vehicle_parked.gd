class_name VehicleParked
extends RefCounted
## n8 vehicles: the city's kerb-parked cars (city_textures class "vehicle" props) as rotation-set
## cards under a tilt. The city view hands each loaded chunk's parked cars in with park() and drops
## them with unpark(); VehicleView draws every registered car near the camera as a VehicleCards
## card, and the city view skips the flat prop for any texture id row() maps (row() < 0 = keep the
## flat prop: the bus, which has no card yet). Nothing registers in `top` (no card atlas): unused.

## city_textures id -> VehicleCards art row (the sim car art ids): 44-46 sedans, 47 taxi, 48 van,
## 49 pickup, 50 the wreck (a sedan worn as a burnt wreck), 52 ambulance, 53 police cruiser.
const ROWS: Dictionary[int, int] = {44: 0, 45: 1, 46: 2, 47: 3, 48: 4, 49: 5, 50: 0, 52: 6, 53: 8}
const WRECK_ID: int = 50

## chunk key -> its cars, each Vector4(x m, y m, rotation rad, texture id).
static var _chunks: Dictionary[Vector2i, PackedVector4Array] = {}


## The card row for a city texture id, or -1 (keep the flat prop).
static func row(tex: int) -> int:
	return ROWS.get(tex, -1)


## True when parked cars draw as cards in the shared view (a tilt with a card atlas).
static func carded() -> bool:
	return VehicleCards.atlas() != null


static func park(chunk: Vector2i, cars: PackedVector4Array) -> void:
	_chunks[chunk] = cars


static func unpark(chunk: Vector2i) -> void:
	@warning_ignore("return_value_discarded")
	_chunks.erase(chunk)


static func clear() -> void:
	_chunks.clear()


## Every registered car within `radius` m of `at`, put on `cards` (between begin and finish).
static func put_near(cards: VehicleCards, at: Vector2, radius: float) -> void:
	var r2: float = radius * radius
	for cars: PackedVector4Array in _chunks.values():
		for c: Vector4 in cars:
			var p: Vector2 = Vector2(c.x, c.y)
			var art: int = row(int(c.w))
			if art < 0 or p.distance_squared_to(at) > r2:
				continue
			var worn: int = 0
			if int(c.w) == WRECK_ID:
				worn = VehicleCards.wear(VehicleBody.State.WRECK, int(c.x * 7.0 + c.y * 13.0))
			cards.put(art, p, Vector2.from_angle(c.z), Color.WHITE, worn)
