class_name GhostAttackViews
extends RefCounted
## Lane ghost-powers: the four ghosts' attack views on a printed actors' layer, render only, for
## one stage's StagePilot: Tonnage's slam telegraph (and its landing ring and crack), Dent's
## tether, heat and blast, Kerf's blink lines, afterimages and cut, Ohm's bolts. The arena's
## TonnageHook and quest 1 (the shipped sprite cast and the dev `--rigs` cast) share it, so every
## live path that runs a ghost's attack also draws it. Headless runs never attach a view.

var tonnage: TonnageView = null
var dent: DentView = null
var kerf: KerfView = null
var ohm: OhmView = null


## The printed actors' layer of `cc` (the print stage's, else the city block's); null = none.
static func layer_of(cc: CollectCallView) -> CanvasLayer:
	if cc == null:
		return null
	if cc.print_stage != null:
		return cc.print_stage.actor_layer()
	return cc.city_view.actor_layer() if cc.city_view != null else null


## Adds the four views under `layer` for `stage`'s pilot. `marks` false leaves Tonnage's landing
## ring and crack to the caller (quest 1's CastView draws them already). Null without a pilot.
static func attach(
	layer: CanvasLayer, stage: CollectCallStage, reduced_motion: bool, marks: bool
) -> GhostAttackViews:
	if layer == null or stage == null or stage.pilot == null or stage.pilot.hauler == null:
		return null
	var v: GhostAttackViews = GhostAttackViews.new()
	v.tonnage = TonnageView.new()
	v.tonnage.hauler = stage.pilot.hauler
	v.tonnage.marks = marks
	_add(layer, v.tonnage, stage, reduced_motion, -2)
	if stage.pilot.dent != null:
		v.dent = DentView.new()
		v.dent.dent = stage.pilot.dent
		_add(layer, v.dent, stage, reduced_motion, 1)
	v.kerf = KerfView.new()
	_add(layer, v.kerf, stage, reduced_motion, 1)
	v.ohm = OhmView.new()
	_add(layer, v.ohm, stage, reduced_motion, 2)
	return v


## Quest 1 (both casts): the views on `cc`'s printed layer, CastView keeping Tonnage's marks.
static func attach_quest(
	cc: CollectCallView, stage: CollectCallStage, reduced_motion: bool
) -> GhostAttackViews:
	return attach(layer_of(cc), stage, reduced_motion, false)


static func _add(
	layer: CanvasLayer, node: Node2D, stage: CollectCallStage, reduced_motion: bool, dz: int
) -> void:
	node.z_index = RenderLayers.z(&"actors") + dz
	node.set(&"ppm", SimConst.PX_PER_M)
	node.set(&"reduced_motion", reduced_motion)
	node.set(&"stage", stage)
	layer.add_child(node)
