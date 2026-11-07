class_name WeaponRackView
extends Node2D
## weapon-art's weapon wall in the arena hub (arena_stations/weapon-art.json): every weapon with
## art hangs muzzle up on a paper board along the hub's north edge, in the brief's order, as its
## pickup side view at its drawn length, so the whole arsenal is seen at 32 to 128 px/m in the
## live print beside the cops. Render only: no sim state, nothing in the replay hash.
## n8-hud: under an angled view (WeaponShowcase.form_of) a weapon with a showcase drawing hangs as
## its flat icon cut (the vendor rack's display piece, already inked: no part print), rebuilt when
## the form changes (combo); `top` and `--showcase=off` hang today's pickup parts.
## n8-hud it9: under a form the handguns (FLAT) hang flat, muzzle forward, from a hook at the
## board's middle, as a gun wall shows them; long guns, blades, the baton and the bottle stand
## muzzle up. An empty FLAT is the it8 wall (every icon muzzle up), one value away.

## The brief's order (the arsenal as designed); ids without art are skipped.
const ORDER: Array[StringName] = [
	&"pistol",
	&"machine_pistol",
	&"rocket_launcher",
	&"flamethrower",
	&"electro_gun",
	&"molotov",
	&"gloria",
	&"katana",
	&"electro_baton",
	&"hand_cannon",
	&"plasma_rifle",
	&"chainsaw",
	&"plasma_sword",
	&"ray_gun",
	&"homing_shard",
	&"mini_nuke",
	&"gatling",
]
const GAP_M: float = 1.0
const BOARD_H_M: float = 1.8
const PEG_M: float = 0.07
const INK_PX: float = 3.0
## The board prints as a light wash of ink over paper, so it reads as a plank, not as wall paper.
const BOARD_WASH: float = 0.14
const FLAT: Array[StringName] = [
	&"pistol",
	&"machine_pistol",
	&"gloria",
	&"hand_cannon",
	&"electro_gun",
	&"ray_gun",
	&"homing_shard",
]
## A flat gun's drawn length (x its length_m: ray gun and homing shard share a 1 m gap) and its
## centre's height above the board's foot; the hook's cord above its top edge.
const FLAT_SCALE: float = 0.9
const FLAT_Y_M: float = 1.0
const HOOK_M: float = 0.12
## n8-hud it20: under a form a showcase piece hangs at least this long: the molotov (0.48 m, an
## icon 3.4x as long as tall) stood a 4 px sliver at 32 px/m; at 0.7 (the floor bottle's cap) it
## reads. Every other weapon is 0.7 m or longer. 0.0 = the drawn lengths, one value away.
const MIN_SHOW_M: float = 0.7

## The board's left end, bottom edge (hub-relative metres + the stage base, set by the hook).
var origin_m: Vector2 = Vector2.ZERO
var art: WeaponArt = WeaponArt.new()
var showcase: WeaponShowcase = WeaponShowcase.new()
var _form: String = "?"
var _sprites: Array[Sprite2D] = []
var _paper: Color = PaletteTokens.shared().color(&"paper")
var _ink: Color = PaletteTokens.shared().color(&"ink")
var _shown: int = 0
## Each hung weapon's peg (world px) and, for a flat one, the top of the gun its cord reaches.
var _pegs: Array[Vector2] = []
var _cords: Array[Vector2] = []


func _process(_delta: float) -> void:
	var form: String = WeaponShowcase.form_of(ViewMode.shared())
	if form != _form:
		_form = form
		_hang()


## Hangs every weapon with art on the board: the showcase icon under a form, else the pickup part.
func _hang() -> void:
	for old: Sprite2D in _sprites:
		old.queue_free()
	_sprites.clear()
	_pegs.clear()
	_cords.clear()
	var k: int = 0
	for id: StringName in ORDER:
		if not art.has(id):
			continue
		var s: Sprite2D = Sprite2D.new()
		var icon: Texture2D = showcase.texture(id, WeaponShowcase.ICON) if _form != "" else null
		s.texture = icon if icon != null else art.pickup_texture(id)
		if s.texture == null:
			continue
		var flat: bool = icon != null and FLAT.has(id)
		var len_m: float = art.length_m(id) if icon == null else maxf(art.length_m(id), MIN_SHOW_M)
		var len_px: float = len_m * SimConst.PX_PER_M * (FLAT_SCALE if flat else 1.0)
		s.scale = Vector2.ONE * len_px / maxf(s.texture.get_width(), 1.0)
		if flat:
			_hang_flat(s, k)
		else:
			s.rotation = -PI * 0.5  # muzzle up: hung on the wall
			s.position = _slot(k) + Vector2(0.0, -len_px * 0.5 - PEG_M * SimConst.PX_PER_M)
			_pegs.append(_slot(k) - Vector2(0.0, PEG_M * SimConst.PX_PER_M))
		if icon == null:
			s.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, 0)
		add_child(s)
		_sprites.append(s)
		k += 1
	_shown = k
	queue_redraw()


func _draw() -> void:
	if _shown == 0:
		return
	var px: float = SimConst.PX_PER_M
	var w: float = (_shown - 1) * GAP_M + GAP_M
	var r: Rect2 = Rect2(
		_slot(0) + Vector2(-GAP_M * 0.5, -BOARD_H_M) * px, Vector2(w, BOARD_H_M) * px
	)
	draw_rect(r, _paper.lerp(_ink, BOARD_WASH))
	draw_rect(r, _ink, false, INK_PX)
	for i: int in range(0, _cords.size(), 2):
		draw_line(_cords[i], _cords[i + 1], _ink, INK_PX * 0.5)
	for peg: Vector2 in _pegs:
		draw_circle(peg, PEG_M * px, _ink)


## Hangs `s` flat at slot k's middle, muzzle forward, from a peg and a short cord above it.
func _hang_flat(s: Sprite2D, k: int) -> void:
	var px: float = SimConst.PX_PER_M
	s.position = _slot(k) - Vector2(0.0, FLAT_Y_M * px)
	var top: Vector2 = s.position - Vector2(0.0, s.texture.get_height() * s.scale.y * 0.5)
	var peg: Vector2 = top - Vector2(0.0, HOOK_M * px)
	_pegs.append(peg)
	_cords.append(peg)
	_cords.append(top + Vector2(0.0, INK_PX))


## The foot of slot k (world px).
func _slot(k: int) -> Vector2:
	return (origin_m + Vector2(k * GAP_M, 0.0)) * SimConst.PX_PER_M
