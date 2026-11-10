class_name InkHit
extends RefCounted
## n12 C1 (ink line weight on impact): a struck figure's ink line is pressed harder for its hit
## class's `flash_ticks`: `ink_edge_px` (hit_feel.json classes, screen px) on the hit tick, easing
## back to the plain line by the window's end, with a hand wobble (ink_line.gdshader). Under a card
## view the figure is its drawn card, so the card carries the line material while it lasts and gets
## its own material back after (one shared material per STEP_PX level: batching kept). ReactLink
## calls hit() on each landed hit and step() once a frame with the arena tick. Render only.
## 0 in a row, or `--feel=off`, draws the line as before; nothing at rest carries the material.

const SHADER: String = "res://features/combat/hit_feel/ink_line.gdshader"
const STEP_PX: float = 0.5
const MAX_LEVEL: int = 8
const META: StringName = &"ink_hit_was"

static var _rows: Dictionary[StringName, Vector2i] = {}  # class -> (level, ticks)
static var _loaded: bool = false
static var _mats: Dictionary[int, ShaderMaterial] = {}
## Rigs in a pulse, by instance id.
static var _live: Dictionary[int, Pulse] = {}


## A hit of `hit_class` landed on `rig` at `tick`: its pulse starts (a later hit restarts it).
static func hit(rig: CutRig, hit_class: StringName, tick: int) -> void:
	var row: Vector2i = row_of(hit_class)
	if row.x <= 0 or row.y <= 0 or rig == null:
		return
	var p: Pulse = Pulse.new()
	p.rig = rig
	p.level = row.x
	p.start = tick
	p.ticks = row.y
	_live[rig.get_instance_id()] = p


## Once a frame: each pulsing card at its level for `tick`; a finished pulse gives the card back.
static func step(tick: int) -> void:
	for id: int in _live.keys():
		var p: Pulse = _live[id]
		var rig: CutRig = p.rig if is_instance_valid(p.rig) else null
		var lvl: int = level_at(p.level, tick - p.start, p.ticks) if rig != null else 0
		if rig != null:
			_dress(rig.head_card, lvl)
		if lvl <= 0:
			@warning_ignore("return_value_discarded")
			_live.erase(id)


## The level `age` ticks into a pulse of `ticks` that starts at `level`: full on the hit tick,
## eased back (quadratic) to 0 by the end.
static func level_at(level: int, age: int, ticks: int) -> int:
	if age < 0 or age >= ticks:
		return 0
	var k: float = 1.0 - float(age) / float(ticks)
	return clampi(ceili(float(level) * k * k), 0, MAX_LEVEL)


## (level, ticks) of a class (0, 0 when none or the feel is off).
static func row_of(hit_class: StringName) -> Vector2i:
	if not _loaded:
		_load()
	return _rows.get(hit_class, Vector2i.ZERO)


static func px_of(level_n: int) -> float:
	return float(clampi(level_n, 0, MAX_LEVEL)) * STEP_PX


## Forgets the table and every pulse (tests).
static func reset() -> void:
	_loaded = false
	_rows.clear()
	_live.clear()


static func live() -> int:
	return _live.size()


## The card wears level `lvl`'s material (keeping what it had), or gets it back at 0.
static func _dress(card: Sprite2D, lvl: int) -> void:
	if card == null:
		return
	if lvl > 0:
		if not card.has_meta(META):
			card.set_meta(META, card.material)
		var m: ShaderMaterial = material(lvl, Vector2i(card.hframes, card.vframes))
		if card.material != m:  # a level held over frames costs no re-assignment
			card.material = m
	elif card.has_meta(META):
		var was: Material = card.get_meta(META)
		card.material = was
		card.remove_meta(META)


## Level `lvl` for a card of frame grid `grid` (shared by every card of that grid).
## Compiles the line's shader behind the load (its first struck card cost a 100+ ms frame): a 4 px
## sprite at 1 % alpha wears the material under `parent` for a tenth of a second, then goes.
static func warm(parent: Node) -> void:
	if parent == null or not parent.is_inside_tree() or row_of(&"light").x <= 0:
		return
	var img: Image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	var s: Sprite2D = Sprite2D.new()
	s.texture = ImageTexture.create_from_image(img)
	s.material = material(1)
	s.modulate = Color(1.0, 1.0, 1.0, 0.01)
	parent.add_child(s)
	@warning_ignore("return_value_discarded")
	parent.get_tree().create_timer(0.1).timeout.connect(s.queue_free)


static func material(lvl: int, grid: Vector2i = Vector2i.ONE) -> ShaderMaterial:
	var key: int = lvl * 10000 + grid.x * 100 + grid.y
	if not _mats.has(key):
		var m: ShaderMaterial = ShaderMaterial.new()
		m.shader = load(SHADER) as Shader
		m.set_shader_parameter("hit_edge", px_of(lvl))
		m.set_shader_parameter("cells", Vector2(maxi(1, grid.x), maxi(1, grid.y)))
		_mats[key] = m
	return _mats[key]


static func _load() -> void:
	_loaded = true
	if HitFeel.feel_flag() == "off":
		return
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(HitFeel.TABLE)) != OK:
		return
	var doc: Dictionary = parser.data
	for row: Dictionary in doc.get("classes", []):
		var px: float = row.get("ink_edge_px", 0.0)
		var flash: float = row.get("flash_ticks", 0.0)
		var ticks: int = roundi(flash)
		var lvl: int = clampi(roundi(px / STEP_PX), 0, MAX_LEVEL)
		_rows[StringName(str(row["id"]))] = Vector2i(lvl, ticks)


class Pulse:
	var rig: CutRig = null
	var level: int = 0
	var start: int = 0
	var ticks: int = 0
