class_name ArenaWaveCards
extends Node2D
## Living wave members outside the full-rig selection use the same armed walk sheets as the rigs.
## The flat view uses the baked top-down cop. Neither representation occupies a full-rig slot.

const FLAT_COP: String = "res://features/quest/art/collect_call/cast_cop.png"


class Card:
	extends Sprite2D
	var art: String
	var look: int = -1
	var walked: float = 0.0

	func pose(feed: RigFeed, i: int) -> void:
		var view: ViewMode = ViewMode.shared()
		var next_art: String = view.art if view.cards and StreetCopWalk.WALKS.has(view.art) else ""
		if next_art != art or look != feed.look_of(i):
			art = next_art
			look = feed.look_of(i)
			_configure(feed.ids[i])
		if visible:
			walked += position.distance_to(feed.pos[i])
		position = feed.pos[i]
		show()
		if art.is_empty():
			rotation = feed.face[i] + PI * 0.5
			return
		var facing: Vector2i = RigHeadCard.frame_of(feed.face[i])
		var phase: float = walked / (StreetQuestCards.STRIDE_M * SimConst.PX_PER_M)
		var moving: bool = feed.vel[i].length() > StreetWalkerCards.MOVING
		frame_coords = Vector2i(facing.x, StreetWalkerCards.stride_frame(phase, moving))
		flip_h = facing.y != 0

	func _configure(id: int) -> void:
		rotation = 0.0
		flip_h = false
		centered = art.is_empty()
		if centered:
			hframes = 1
			vframes = 1
			texture = StreetStrips.get_tex(FLAT_COP)
			offset = Vector2.ZERO
			scale = Vector2.ONE * (2.83 * SimConst.PX_PER_M / texture.get_height())
			return
		var row: String = "cop/" + RigVariant.crowd(look).head
		var file: String = StreetCopWalk.WALKS[art][row]
		var path: String = StreetWalkerCards.DIR + art + "/" + file
		texture = StreetStrips.get_tex(path)
		hframes = RigHeadCard.FRAMES
		vframes = StreetWalkerCards.STRIDE_FRAMES
		var cell: Vector2 = texture.get_size() / Vector2(hframes, vframes)
		offset = -cell * Vector2(0.5, StreetWalkerCards.FOOT_Y)
		var h: float = StreetWalkerCards.HEIGHT_BY_ART.get(art, StreetWalkerCards.HEIGHT_M)
		var k: float = 1.0 + StreetCrowdCards.SCALE_VAR * StreetCrowdCards.vary(id, 3)
		scale = Vector2.ONE * (h * SimConst.PX_PER_M * k * StreetCopWalk.fill_of(path) / cell.y)


var _standing: Array[Fighter]
var _rigs: CharacterRigs
var _cards: Dictionary[int, Card] = {}


static func attach(rigs: CharacterRigs, standing: Array[Fighter]) -> ArenaWaveCards:
	var layer: ArenaWaveCards = ArenaWaveCards.new()
	layer._rigs = rigs
	layer._standing = standing
	layer.process_priority = rigs.process_priority + 1
	layer.y_sort_enabled = true
	rigs.add_child(layer)
	return layer


func card_for(id: int) -> Sprite2D:
	return _cards.get(id)


func _process(_delta: float) -> void:
	var keep: Dictionary[int, bool] = {}
	for h: Fighter in _standing:
		if not h.alive():
			continue
		var card: Card = _cards.get(h.id)
		var i: int = _rigs.feed.ids.find(h.id)
		if i >= 0 and i < _rigs.feed.count and not _rigs.full_row(i):
			if card == null:
				card = Card.new()
				card.hide()
				add_child(card)
				_cards[h.id] = card
			card.pose(_rigs.feed, i)
		elif card != null:
			card.hide()
		keep[h.id] = true
	for id: int in _cards.keys():
		if not keep.has(id):
			_cards[id].hide()
			_cards[id].queue_free()
			@warning_ignore("return_value_discarded")
			_cards.erase(id)
