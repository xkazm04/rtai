class_name WeaponRackView
extends Node2D
## weapon-art's weapon wall in the arena hub (arena_stations/weapon-art.json): every weapon with
## art hangs muzzle up on a paper board along the hub's north edge, in the brief's order, as its
## pickup side view at its drawn length, so the whole arsenal is seen at 32 to 128 px/m in the
## live print beside the cops. Render only: no sim state, nothing in the replay hash.

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
]
const GAP_M: float = 1.0
const BOARD_H_M: float = 1.8
const PEG_M: float = 0.07
const INK_PX: float = 3.0
## The board prints as a light wash of ink over paper, so it reads as a plank, not as wall paper.
const BOARD_WASH: float = 0.14

## The board's left end, bottom edge (hub-relative metres + the stage base, set by the hook).
var origin_m: Vector2 = Vector2.ZERO
var art: WeaponArt = WeaponArt.new()
var _paper: Color = PaletteTokens.shared().color(&"paper")
var _ink: Color = PaletteTokens.shared().color(&"ink")
var _shown: int = 0


func _ready() -> void:
	var k: int = 0
	for id: StringName in ORDER:
		if not art.has(id):
			continue
		var s: Sprite2D = Sprite2D.new()
		s.texture = art.pickup_texture(id)
		if s.texture == null:
			continue
		var len_px: float = art.length_m(id) * SimConst.PX_PER_M
		s.scale = Vector2.ONE * len_px / maxf(s.texture.get_width(), 1.0)
		s.rotation = -PI * 0.5  # muzzle up: hung on the wall
		s.position = _slot(k) + Vector2(0.0, -len_px * 0.5 - PEG_M * SimConst.PX_PER_M)
		s.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, 0)
		add_child(s)
		k += 1
	_shown = k


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
	for k: int in _shown:
		draw_circle(_slot(k) - Vector2(0.0, PEG_M * px), PEG_M * px, _ink)


## The foot of slot k (world px).
func _slot(k: int) -> Vector2:
	return (origin_m + Vector2(k * GAP_M, 0.0)) * SimConst.PX_PER_M
