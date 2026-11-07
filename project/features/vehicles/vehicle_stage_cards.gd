class_name VehicleStageCards
extends Node2D
## n8 vehicles: a stage's cars (the arena's powers pad and boss cars, quest 1's ghost cars, which
## StageView prints flat from the top-down traffic atlas) as rotation-set cards under a tilt with
## card art, like VehicleView's traffic; the stage view then keeps only their flat ink shadows.
## `top` (no card atlas): nothing drawn, the flat print as before. Render only: reads the bodies.
## A soul-seized car (VehicleBody.State.HIJACKED, the flat print's teal plate) is tinted SOUL (teal
## is the souls'). Drawn over the stage view's floor, under the actors (no front grid here).

const SOUL: Color = Color(0.62, 0.95, 0.9)

var cards: VehicleCards = VehicleCards.new()
var _cars: Callable = Callable()
var _on: bool = false


## Cards for `cars` (() -> Array[VehicleBody]) under `view`, a StageView drawing in Ink px.
static func attach(view: Node2D, cars: Callable) -> VehicleStageCards:
	var node: VehicleStageCards = VehicleStageCards.new()
	node._cars = cars
	node.scale = Vector2.ONE * Ink.PX_PER_M / SimConst.PX_PER_M  # cards place in sim px
	node.add_child(node.cards)
	view.add_child(node)
	return node


## `have`, or new cards for `view`'s stage once it has one (StageView calls it every frame).
static func ensure(
	have: VehicleStageCards, view: Node2D, stage: CollectCallStage
) -> VehicleStageCards:
	if have != null or stage == null:
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
