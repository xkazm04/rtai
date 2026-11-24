class_name PrologueProps
extends Node2D
## Keep the named cast readable in both the nearby articulated rig and its far card.

const HORN: Texture2D = preload("res://features/characters/art/king/megaphone.png")
const HAIR: Texture2D = preload("res://features/characters/art/ped/head_hair.png")
const BIB: Texture2D = preload("res://features/characters/art/ped/torso_overalls.png")
const POLE: Texture2D = preload("res://features/characters/art/cop/baton.png")
const OVERALLS: Shader = preload("res://boot/prologue/prologue_overalls.gdshader")
const PP: float = SimConst.PX_PER_M
const DRILL: Color = Color("#90926c")
const STRAP: Color = Color("#c7c5a1")

var patrol: ProloguePatrol
var rigs: CharacterRigs
var cards: ArenaWaveCards
var _copies: Array[Sprite2D] = []
var _material: ShaderMaterial = ShaderMaterial.new()


func _ready() -> void:
	_material.shader = OVERALLS


func _process(_dt: float) -> void:
	for copy: Sprite2D in _copies:
		copy.hide()
	var index: int = 0
	for officer: ProloguePatrol.Officer in patrol.officers:
		var h: Fighter = officer.body
		if h.alive() and h.archetype == &"appliance_warden" and not _warden_card():
			var card: Sprite2D = walk_card(rigs, cards, h.id)
			if card != null:
				_dye_card(card, index)
				index += 1
	queue_redraw()


func dress_boss(dress: PrologueCommanderDress, h: Fighter) -> void:
	var at: Vector2 = h.pos * SimConst.PX_PER_M
	var chest: Vector2 = Vector2.UP * 11
	var head: Vector2 = Vector2.UP * 16 + h.facing * 2
	var rig: CutRig = rigs.rig_for(h.id)
	if rig != null and rig.is_visible_in_tree():
		chest = rigs.to_local(rig.torso_spr.global_position) - at
		head = rigs.to_local(rig.head_spr.global_position) - at + Vector2.UP * 2
	var card: Sprite2D = PrologueProps.walk_card(rigs, cards, h.id)
	if card != null:
		chest = rigs.to_local(PrologueProps.card_point(card, 0.55)) - at
		head = rigs.to_local(PrologueProps.card_point(card, 0.30)) - at
	dress.pose(at, chest, head, h.facing, RigHeadCard.frame_of(h.facing.angle()))


static func walk_card(cast: CharacterRigs, far_cards: ArenaWaveCards, id: int) -> Sprite2D:
	var rig: CutRig = cast.rig_for(id)
	if rig != null and rig.is_visible_in_tree():
		if rig.head_card != null and rig.head_card.has_meta(StreetWalkerCards.ON):
			return rig.head_card
		return null
	return far_cards.card_for(id)


static func card_point(card: Sprite2D, height: float) -> Vector2:
	var box: Rect2 = card.get_rect()
	return card.to_global(box.position + box.size * Vector2(0.5, height))


func _dye_card(card: Sprite2D, index: int) -> void:
	if index == _copies.size():
		var fresh: Sprite2D = Sprite2D.new()
		fresh.show_behind_parent = true
		fresh.material = _material
		add_child(fresh)
		_copies.append(fresh)
	var copy: Sprite2D = _copies[index]
	copy.texture = card.texture
	copy.hframes = card.hframes
	copy.vframes = card.vframes
	copy.frame = card.frame
	copy.centered = card.centered
	copy.flip_h = card.flip_h
	copy.offset = card.offset
	copy.global_transform = card.global_transform
	copy.show()


## The cast lane's card draws the warden: no overalls dye, vector pole, straps or bib.
func _warden_card() -> bool:
	return CastCards.current(&"appliance_warden") != null


func _draw() -> void:
	for officer: ProloguePatrol.Officer in patrol.officers:
		var h: Fighter = officer.body
		if not h.alive() or (h != patrol.dale and h.archetype != &"appliance_warden"):
			continue
		if h.archetype == &"appliance_warden" and _warden_card():
			continue
		var at: Vector2 = h.pos * PP
		var chest: Vector2 = at + Vector2.UP * 10
		var head: Vector2 = at + Vector2.UP * 16
		var hand: Vector2 = chest + h.facing * 8 + h.facing.orthogonal() * 8
		var rig: CutRig = rigs.rig_for(h.id)
		if rig != null and rig.is_visible_in_tree():
			chest = to_local(rig.torso_spr.global_position)
			head = to_local(rig.head_spr.global_position)
			hand = to_local(rig.torso.to_global(rig.sides[BodyPlan.R].j_hand))
		var card: Sprite2D = walk_card(rigs, cards, h.id)
		if card != null:
			head = to_local(card_point(card, 0.24))
			chest = to_local(card_point(card, 0.52))
			hand = chest + h.facing * 9 + h.facing.orthogonal() * 4
		if h == patrol.dale:
			_dale(head, h.facing)
		else:
			if card == null:
				if rig != null and rig.is_visible_in_tree():
					_sleeves(rig)
				_warden(chest, head, h.facing)
			else:
				draw_set_transform(chest, h.facing.x * 0.15)
				for x: int in [-4, 4]:
					draw_line(Vector2(x * 1.3, -6), Vector2(x, 1), STRAP, 2, true)
				draw_rect(Rect2(-5, 0, 10, 5), DRILL.darkened(0.30))
			_pole(hand, h.facing)
	draw_set_transform(Vector2.ZERO)


func _dale(head: Vector2, facing: Vector2) -> void:
	draw_set_transform(head, facing.angle())
	draw_texture_rect(HAIR, Rect2(-9, -10, 19, 20), false, Color("#bbac94"))
	# The narrow end meets his mouth. The light cone and black flared bell sit
	# outside the shoulder silhouette even when he faces north.
	draw_set_transform(head + facing * 7 + facing.orthogonal() * 5, facing.angle())
	var cone: PackedVector2Array = PackedVector2Array(
		[
			Vector2(0, -3),
			Vector2(31, -12),
			Vector2(33, -10),
			Vector2(33, 10),
			Vector2(31, 12),
			Vector2(0, 3)
		]
	)
	draw_colored_polygon(cone, Ink.CREAM)
	draw_texture_rect(HORN, Rect2(0, -11, 33, 22), false)
	draw_line(Vector2(31, -10), Vector2(31, 10), Ink.INK, 3, true)
	draw_line(Vector2(33, -10), Vector2(33, 10), Ink.CREAM, 1.5, true)


func _sleeves(rig: CutRig) -> void:
	draw_set_transform(Vector2.ZERO)
	for limb: RigLimbs in rig.sides:
		var shoulder: Vector2 = to_local(rig.torso.to_global(limb.j_shoulder))
		var elbow: Vector2 = to_local(rig.torso.to_global(limb.j_elbow))
		var wrist: Vector2 = to_local(rig.torso.to_global(limb.j_hand))
		draw_line(shoulder, elbow, DRILL.darkened(0.20), 5, true)
		draw_line(elbow, wrist.lerp(elbow, 0.3), DRILL, 5, true)
		draw_line(elbow, elbow.lerp(wrist, 0.2), STRAP, 5, true)
		var knee: Vector2 = to_local(limb.shin.global_position)
		var boot: Vector2 = to_local(limb.foot.global_position)
		draw_line(knee, knee.lerp(boot, 0.75), DRILL.darkened(0.30), 5, true)


func _warden(chest: Vector2, head: Vector2, facing: Vector2) -> void:
	draw_set_transform(chest, facing.angle())
	draw_texture_rect(BIB, Rect2(-13, -13, 26, 26), false, DRILL)
	for side: int in [-1, 1]:
		draw_line(Vector2(8, 8 * side), Vector2(0, 5 * side), STRAP, 3, true)
	draw_rect(Rect2(-8, -6, 11, 12), Color("#777d57"))
	draw_line(Vector2(-2, -4), Vector2(-2, 4), STRAP, 1.5)
	# Work cap above the bib. A patrol helmet retains its round blue crown.
	draw_set_transform(head, facing.angle(), Vector2(1.15, 0.88))
	draw_circle(Vector2(2, 0), 8.0, Ink.INK, true, -1, true)
	draw_circle(Vector2.ZERO, 7.5, DRILL, true, -1, true)
	draw_line(Vector2(5, -5), Vector2(5, 5), STRAP, 1.5, true)


func _pole(hand: Vector2, facing: Vector2) -> void:
	draw_set_transform(hand, facing.angle())
	draw_texture_rect(POLE, Rect2(-9, -2.5, 52, 5), false)
	draw_line(Vector2(8, -1), Vector2(48, -1), STRAP, 2, true)
	draw_set_transform(hand + facing * 54, facing.angle(), Vector2(1.25, 0.7))
	draw_arc(Vector2.ZERO, 7, 0, TAU, 20, Ink.INK, 4, true)
	draw_arc(Vector2.ZERO, 7, 0, TAU, 20, STRAP, 2, true)
