class_name VehicleStageCards
extends Node2D
## n8 vehicles: a stage's cars (the arena's powers pad and boss cars, quest 1's ghost cars, which
## StageView prints flat from the top-down traffic atlas) as rotation-set cards under a tilt with
## card art, like VehicleView's traffic; the stage view then keeps only their flat ink shadows.
## `top` (no card atlas): nothing drawn, the flat print as before. Render only: reads the bodies.
## A soul-seized car (VehicleBody.State.HIJACKED, the flat print's teal plate) takes SOUL. On a
## printed stage (a PrintStage world canvas) the cards ride its actor layer, like the city's cars
## (the world print crushed the dark van art to black ink: the Servo depot's van), in the vehicles
## band over the actors when over (a fighter behind a car is covered by it under a tilt), dropping
## just under them when a fighter stands in front (VehicleFront fed with the arena's living
## fighters); else, and off a print, over the floor and under the actors.

## WHITE: the seized card's teal is the shader's soul paint (VehicleCards.SOUL in its wear); a
## multiply tint Color(0.62, 0.95, 0.9) turned the olive depot van and its lamps green, not teal.
const SOUL: Color = Color.WHITE
## A fighter wider than this (radius, m) adds its edges to the front grid (people are 0.45).
const WIDE_M: float = 0.6
## True: on a print the cards draw in the vehicles band over the actors with the front grid (the
## depot van stands in front of its bay's shutter, a fighter behind it is covered). On since view's
## GhostAttackViews.dent_dz drew the tether and the seized car's halo over the vehicles band (and
## ServoBodyView the bay's apron mark, view 73a78455). False: the iteration-11 look.
static var over: bool = true
## True: with no VehicleView in the scene (quest 1 and the arena's city block), these cards also
## stand the city's kerb-parked cars (VehicleParked, handed over by city's ChunkLift while `live`),
## which else stay flat top-down props under a tilt. False: the kerb cars stay flat (the before).
static var kerb: bool = true
## True while a stage view holds the kerb-car registry (claim()); its cards draw the kerb cars.
static var _claimed: bool = false

var cards: VehicleCards = VehicleCards.new()
var _cars: Callable = Callable()
## () -> PackedVector2Array: the ground points (m) of the stage's living fighters.
var _people: Callable = Callable()
var _on: bool = false
## The stage view whose Ink-px space the cards follow when hosted on a print's actor layer.
var _view: Node2D = null
## True when this node draws the kerb-car registry (a stage view claimed it).
var _parked: bool = false
## True when the cards stand in the vehicles band with the front grid (a print, or the city).
var _banded: bool = false


## Cards for `cars` (() -> Array[VehicleBody]) under `view`, a StageView drawing in Ink px.
static func attach(view: Node2D, cars: Callable) -> VehicleStageCards:
	var node: VehicleStageCards = VehicleStageCards.new()
	node._cars = cars
	node.scale = Vector2.ONE * Ink.PX_PER_M / SimConst.PX_PER_M  # cards place in sim px
	node.add_child(node.cards)
	node._parked = _claimed
	var up: Node = view.get_parent()
	while up != null and not up is PrintStage:
		up = up.get_parent()
	if up == null:
		view.add_child(node)
		if view.get_parent() is CanvasLayer:  # on the city's actor layer (quest 1 on the city)
			node._band()
		return node
	node._view = view
	node._band()
	(up as PrintStage).actor_layer().add_child(node)
	node._follow()
	return node


## A stage view entering the tree claims the kerb cars (VehicleParked.live) under a card view when
## no VehicleView holds them, BEFORE the city chunks are drawn (quest 1 fills its street in _ready
## and ChunkLift hands a chunk's cars over only as it orders it). `top`: no atlas, no claim.
static func claim() -> void:
	if kerb and not VehicleParked.live and VehicleCards.atlas() != null:
		VehicleParked.clear()  # no cars of an earlier city (ChunkLift hands them in from here on)
		VehicleParked.live = true
		_claimed = true


## The stage view leaving the tree hands the registry back (the kerb cars flat again).
static func release() -> void:
	if _claimed:
		VehicleParked.live = false
		_claimed = false


## With `over`: the vehicles band over the actors, a card with a fighter in front just under them.
func _band() -> void:
	_banded = over
	if over:
		z_index = RenderLayers.z(&"vehicles")
		cards.under.z_as_relative = false
		cards.under.z_index = RenderLayers.z(&"actors") - 1


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
	var node: VehicleStageCards = attach(view, stage.cars)
	node._people = fighters.bind(stage.arena)
	node.refresh()  # stand this frame: the stage view's _draw follows and asks standing()
	return node


## The ground points (m) of `arena`'s living fighters: Rivet, the hostiles, the boss. A body wider
## than WIDE_M also gives its left and right edges (a boss's centre can sit past the front box's
## HALF_M while its arm reaches over the car: Servo beside the depot van's wreck).
static func fighters(arena: CombatArena) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	if arena == null:
		return out
	var all: Array[Fighter] = arena.hostiles.duplicate()
	all.append_array([arena.rivet, arena.boss])
	for f: Fighter in all:
		if f == null or not f.alive():
			continue
		@warning_ignore("return_value_discarded")
		out.append(f.pos)
		if f.radius_m > WIDE_M:
			out.append_array([f.pos - Vector2(f.radius_m, 0.0), f.pos + Vector2(f.radius_m, 0.0)])
	return out


## True when `node` exists and its cards stand this frame (null: the flat print).
static func standing(node: VehicleStageCards) -> bool:
	return node != null and node.on()


## True while the cars stand as cards (the stage view skips their flat bodies).
func on() -> bool:
	return _on


func _process(_delta: float) -> void:
	refresh()


## True when this node draws the city's kerb-parked cars.
func parked() -> bool:
	return _parked


## Puts this frame's cards (none and hidden without a card atlas); `_process` runs it every frame.
func refresh() -> void:
	var tex: Texture2D = VehicleCards.atlas()
	_on = tex != null
	if _view != null:
		_follow()
	cards.visible = _on
	if not _on:
		return
	cards.begin(tex)
	cards.front.clear()
	if _banded and over and _people.is_valid():
		for p: Vector2 in _people.call():
			cards.front.add(p)
	var list: Array[VehicleBody] = _cars.call()
	for b: VehicleBody in list:
		var worn: int = VehicleCards.wear(b.state, b.id) + VehicleCards.duty(b.art, b.vel.length())
		cards.put(b.art, b.pos, b.head, tint_of(b.state), worn)
	if _parked:  # the kerb cars round the screen (stage metres are the city's on the city)
		var seen: Rect2 = VehicleCull.screen_m(cards, VehicleCards.CELL_M)
		if seen.has_area():
			var at: Vector2 = seen.get_center()
			VehicleParked.put_near(cards, at, VehicleCull.reach_m(seen, at))
	cards.finish()


## The card's tint for a car in `state`: SOUL while a soul holds it, else none.
static func tint_of(state: VehicleBody.State) -> Color:
	return SOUL if state == VehicleBody.State.HIJACKED else Color.WHITE
