class_name VehicleStageCards
extends Node2D
## n8 vehicles: a stage's cars (the arena's powers pad and boss cars, quest 1's ghost cars, which
## StageView prints flat from the top-down traffic atlas) as rotation-set cards under a tilt with
## card art, like VehicleView's traffic; the stage view then keeps only their flat ink shadows.
## `top` (no card atlas): nothing drawn, the flat print as before. Render only: reads the bodies.
## A soul-seized car (VehicleBody.State.HIJACKED, the flat print's teal plate) takes SOUL. Drawn
## over the floor, under the actors (no front grid here). On a printed stage (a PrintStage world
## canvas) the cards ride its actor layer, like the city's cars: the world print crushed the dark
## van art to black ink (the Servo depot's van).

## WHITE: the seize reads by Dent's halo and teal tether; Color(0.62, 0.95, 0.9) tints the card
## (a multiply: it turned the olive depot van and its lamps green, not teal).
const SOUL: Color = Color.WHITE

var cards: VehicleCards = VehicleCards.new()
var _cars: Callable = Callable()
var _on: bool = false
## The stage view whose Ink-px space the cards follow when hosted on a print's actor layer.
var _view: Node2D = null


## Cards for `cars` (() -> Array[VehicleBody]) under `view`, a StageView drawing in Ink px.
static func attach(view: Node2D, cars: Callable) -> VehicleStageCards:
	var node: VehicleStageCards = VehicleStageCards.new()
	node._cars = cars
	node.scale = Vector2.ONE * Ink.PX_PER_M / SimConst.PX_PER_M  # cards place in sim px
	node.add_child(node.cards)
	var up: Node = view.get_parent()
	while up != null and not up is PrintStage:
		up = up.get_parent()
	if up == null:
		view.add_child(node)
		return node
	node._view = view
	(up as PrintStage).actor_layer().add_child(node)
	node._follow()
	return node


## Under a print's actor layer: the stage view's transform, then Ink px -> sim px.
func _follow() -> void:
	var k: float = Ink.PX_PER_M / SimConst.PX_PER_M
	transform = _view.transform * Transform2D(0.0, Vector2(k, k), 0.0, Vector2.ZERO)


## `have`, or new cards for `view`'s stage once it has one under a card view (StageView calls it
## every frame; `top` never adds a node: an empty one on a print's actor layer moved its frames).
static func ensure(
	have: VehicleStageCards, view: Node2D, stage: CollectCallStage
) -> VehicleStageCards:
	if have != null or stage == null or VehicleCards.atlas() == null:  # `top` adds no node
		return have
	return attach(view, stage.cars)


## True when `node` exists and its cards stand this frame (null: the flat print).
static func standing(node: VehicleStageCards) -> bool:
	return node != null and node.on()


## True while the cars stand as cards (the stage view skips their flat bodies).
func on() -> bool:
	return _on


func _process(_delta: float) -> void:
	var tex: Texture2D = VehicleCards.atlas()
	_on = tex != null
	if _view != null:
		_follow()
	cards.visible = _on
	if not _on:
		return
	cards.begin(tex)
	var list: Array[VehicleBody] = _cars.call()
	for b: VehicleBody in list:
		var worn: int = VehicleCards.wear(b.state, b.id) + VehicleCards.duty(b.art, b.vel.length())
		cards.put(b.art, b.pos, b.head, tint_of(b.state), worn)
	cards.finish()


## The card's tint for a car in `state`: SOUL while a soul holds it, else none.
static func tint_of(state: VehicleBody.State) -> Color:
	return SOUL if state == VehicleBody.State.HIJACKED else Color.WHITE
