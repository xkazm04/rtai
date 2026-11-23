class_name ArenaWaveCards
extends Node2D
## Living wave members outside the full-rig selection use the same armed walk sheets as the rigs.
## The flat view uses the baked top-down cop. Neither representation occupies a full-rig slot.


class Card:
	extends Sprite2D
	var art: String
	var look: int = -1
	var walked: float = 0.0
	var patrol: StreetCopWalk.Contact

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
		if centered:
			rotation = feed.face[i] + PI * 0.5
			return
		var facing: Vector2i = RigHeadCard.frame_of(feed.face[i])
		var phase: float = walked / (StreetQuestCards.STRIDE_M * SimConst.PX_PER_M)
		var moving: bool = feed.vel[i].length() > StreetWalkerCards.MOVING
		frame_coords = Vector2i(facing.x, StreetWalkerCards.stride_frame(phase, moving))
		if patrol != null:
			if moving:
				position = patrol.place(feed.pos[i], facing, scale, SimConst.PX_PER_M)
				frame_coords.y = posmod(patrol.cell, StreetWalkerCards.STRIDE_FRAMES)
			else:
				patrol.reset()
		flip_h = facing.y != 0

	func _configure(id: int) -> void:
		rotation = 0.0
		flip_h = false
		var row: String = "cop/" + RigVariant.crowd(look).head
		var sheets: Dictionary = StreetCopWalk.WALKS.get(art, {})
		centered = not sheets.has(row)
		if centered:
			if not art.is_empty():
				Log.warn("arena", "no armed walk for %s/%s, using the flat cop" % [art, row])
			hframes = 1
			vframes = 1
			texture = QuestArt.shared().texture(&"cop")
			offset = Vector2.ZERO
			scale = QuestArt.shared().size_m(&"cop") * SimConst.PX_PER_M / texture.get_size()
			return
		var file: String = sheets[row]
		if patrol != null and file == StreetCopWalk.ORIGINAL:
			file = StreetCopWalk.PLANTED
		var path: String = StreetWalkerCards.DIR + art + "/" + file
		texture = StreetStrips.get_tex(path)
		hframes = RigHeadCard.FRAMES
		vframes = StreetWalkerCards.STRIDE_FRAMES
		var cell: Vector2 = texture.get_size() / Vector2(hframes, vframes)
		var foot_y: float = (
			StreetCopWalk.FOOT_Y if file == StreetCopWalk.PLANTED else StreetWalkerCards.FOOT_Y
		)
		offset = -cell * Vector2(0.5, foot_y)
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
		if not h.alive() or FoeCastView.covers(_rigs, h):
			continue
		var card: Card = _cards.get(h.id)
		var i: int = _rigs.feed.ids.find(h.id)
		if i >= 0 and i < _rigs.feed.count and not _rigs.full_row(i):
			if card == null:
				card = Card.new()
				if h.archetype == &"patrol_cop":
					card.patrol = StreetCopWalk.Contact.new()
				card.hide()
				add_child(card)
				_cards[h.id] = card
			if not card.visible and card.patrol != null:
				card.patrol.reset()
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
