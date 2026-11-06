class_name BossDressing
extends Node2D
## The boss arenas' dressing under an angled view (night n8, lane city; boss_dressing.json):
## Servo's depot (bay doors, conveyors, parcels, cages) and the King's district (scrap, tyres, crown
## crates, cable reels) as standing cards from the library's dressing kits, placed along the arena's
## edges around the fight. A sibling of the arena floor on the printed world canvas, at its scale;
## the art follows the view row's art key (p55 for a boss fight, p70 falls back to p55) and the
## cards rise over the squashed ground by their aspect / ground_k. None under a flat view (`top`
## untouched). View only: reads the boss hook's arena bounds once, never the sim.

const TABLE: String = "res://data/tables/boss_dressing.json"

## the pieces north to south: id, foot (m from the area's centre), drawn width (m)
var ids: Array[String] = []
var feet: Array[Vector2] = []
var widths: Array[float] = []
var origin_m: Vector2 = Vector2.ZERO
var _path: String = ""
var _fallback: Dictionary = {}
var _art: String = "-"
var _rev: int = -1
var _tex: Dictionary[String, Texture2D] = {}


## Adds the dressing of the boss's arena beside `floor` (the arena floor view); null when the
## view is flat, the table has no row for the arena, or the floor has no parent yet.
static func attach(floor: Node2D, arena_id: String, origin: Vector2) -> BossDressing:
	if floor == null or floor.get_parent() == null or ViewMode.shared().is_flat():
		return null
	var d: BossDressing = BossDressing.from_table(arena_id)
	if d == null:
		return null
	d.origin_m = origin
	d.scale = floor.scale
	d.z_index = RenderLayers.z(&"props")
	floor.get_parent().add_child(d)
	return d


static func from_table(arena_id: String) -> BossDressing:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(TABLE)) != OK or not parser.data is Dictionary:
		Log.warn("city", "%s unreadable: no boss dressing" % TABLE)
		return null
	var t: Dictionary = parser.data
	var arenas: Dictionary = t["arenas"]
	if not arenas.has(arena_id):
		return null
	var d: BossDressing = BossDressing.new()
	d._path = t["art"]
	d._fallback = t["art_fallback"]
	var rows: Array = arenas[arena_id]
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["at"][1] < b["at"][1])
	for row: Dictionary in rows:
		var at: Array = row["at"]
		var x: float = at[0]
		var y: float = at[1]
		var w: float = row["w_m"]
		d.ids.append(str(row["piece"]))
		d.feet.append(Vector2(x, y))
		d.widths.append(w)
	return d


func _process(_delta: float) -> void:
	if ViewMode.revision != _rev:  # the combined view's ease: new ground_k, maybe a new art key
		_rev = ViewMode.revision
		queue_redraw()


func _draw() -> void:
	var view: ViewMode = ViewMode.shared()
	if view.art != _art:
		_art = view.art
		_tex.clear()
	var gk: float = maxf(view.ground_k(), 0.05)
	for i: int in ids.size():  # north to south: the nearer piece covers the farther
		var tex: Texture2D = _texture(ids[i])
		if tex == null:
			continue
		var w: float = widths[i] * Ink.PX_PER_M
		var h: float = w * tex.get_height() / float(tex.get_width()) / gk
		var foot: Vector2 = Ink.px(origin_m + feet[i])
		draw_texture_rect(tex, Rect2(foot.x - w * 0.5, foot.y - h, w, h), false)


func _texture(piece: String) -> Texture2D:
	if not _tex.has(piece):
		_tex[piece] = PropCards.art_texture(_path.replace("<piece>", piece), _art, _fallback)
	return _tex[piece]
