extends RefCounted
## quest1_city_fit's body, loaded once the autoloads exist (a -s script that names the game's
## classes directly does not compile before them).

const R: float = 0.5
const SQUASH: Array[float] = [0.15, 0.2, 0.25, 0.3]
const NEAR: Vector2 = Vector2(268.0, 270.0)
## The bot's walked route in stage metres, with the reach offsets it stands at (world metres).
const LEGS: Array[Array] = [
	[Vector2(-3, 2), Vector2.ZERO],
	[Vector2(0, 0), Vector2.ZERO],
	[Vector2(16, -6), Vector2(0, 1.1)],
	[Vector2(40, 20), Vector2(0, 1.6)],
	[Vector2(44, 18), Vector2(0, 1.6)],
	[Vector2(48, 20), Vector2(0, 1.6)],
	[Vector2(44, 25), Vector2(0, 1.6)],
	[Vector2(100, 2), Vector2.ZERO],
	[Vector2(112, -6), Vector2.ZERO],
	[Vector2(96, -6), Vector2.ZERO],
	[Vector2(112, -13), Vector2(0, 2)],
	[Vector2(92, 30), Vector2(0, 1.1)],
	[Vector2(84, 34), Vector2.ZERO],
	[Vector2(92, 30), Vector2(0, 1.1)],
]


func run() -> int:
	var cells: StageCells = StageCells.shipped()
	var layout: StageLayout = StageLayout.shipped()
	var fits: Array[Array] = []
	for ky: float in SQUASH:
		for row: int in range(3, 7):
			for dy: float in [-1.0, 0.0, 1.0]:
				var oy: float = row * 64.0 + 12.0 + dy - 10.5 * ky
				for ox: int in range(128, 640, 4):
					var o: Vector2 = Vector2(ox, oy)
					if _misses(cells, layout, o, Vector2(1, ky)) == 0:
						fits.append([o.distance_to(NEAR), o, ky])
	fits.sort_custom(_wider_then_nearer)
	printerr("quest1_city_fit: %d clear fits" % fits.size())
	for f: Array in fits.slice(0, 12):
		printerr("  origin %s squash %.2f (%.0f m from start)" % [f[1], f[2], f[0]])
	return 0 if not fits.is_empty() else 1


func _misses(cells: StageCells, l: StageLayout, o: Vector2, k: Vector2) -> int:
	var n: int = 0
	var prev: Vector2 = Vector2.INF
	for leg: Array in LEGS:
		var at: Vector2 = leg[0]
		var off: Vector2 = leg[1]
		var p: Vector2 = o + at * k + off
		if prev != Vector2.INF and not cells.swept_clear(prev, p, R):
			return 1
		prev = p
	var points: Array[Vector2] = []
	points.append_array(l.spawn_points.values())
	points.append_array(l.hide_at.values())
	for p: StageLayout.Patrol in l.patrols:
		points.append_array(p.route)
	for a: QuestPlaces.Actor in l.places.actors.values():
		points.append(a.at)
	for p: Vector2 in points:
		n += 0 if cells.clear(o + p * k, R) else 1
	return n


## The least squash first loses the stage's shape most; prefer the widest, then the nearest.
static func _wider_then_nearer(a: Array, b: Array) -> bool:
	var ka: float = a[2]
	var kb: float = b[2]
	var da: float = a[0]
	var db: float = b[0]
	return ka > kb or (ka == kb and da < db)
