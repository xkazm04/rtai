class_name CastStride
extends RefCounted
## Measure a held drawing or a visible planted foot in the stationary lineup camera.

var _cell: int = -1
var _origin: Vector2
var _feet: Array[Vector2] = [Vector2.INF, Vector2.INF]
var _card_samples: int = 0
var _foot_samples: int = 0
var _hold_px: float = 0.0
var _plant_px: float = 0.0


func measure(foe: Fighter, view: ArenaRigs, clock: SimClock, label: String) -> void:
	var mark: Vector2 = foe.pos
	foe.facing = Vector2.RIGHT
	for tick: int in 136:
		if tick >= 24:
			foe.pos.x += 2.4 * SimClock.TICK_DT
		clock.complete_tick()
		await view.get_tree().process_frame
		await RenderingServer.frame_post_draw
		if tick < 48:
			continue
		var rig: CutRig = view.rigs.rig_for(foe.id)
		if rig == null and view.robots != null:
			rig = view.robots.rig_for(foe.id)
		if rig != null:
			_sample(rig)
	foe.pos = mark
	(
		Log
		. info(
			"cast",
			(
				"%s stride at 2.4 m/s: held card %.2f px (%d samples), planted foot %.2f px (%d samples)"
				% [label, _hold_px, _card_samples, _plant_px, _foot_samples]
			)
		)
	)


func _sample(rig: CutRig) -> void:
	var card: Sprite2D = rig.head_card
	if card != null and card.is_visible_in_tree() and card.vframes == 4:
		var at: Vector2 = card.get_global_transform_with_canvas().origin
		if card.frame == _cell:
			_card_samples += 1
			_hold_px = maxf(_hold_px, _origin.distance_to(at))
		else:
			_cell = card.frame
			_origin = at
		return
	_cell = -1
	for i: int in rig.sides.size():
		var leg: RigLimbs = rig.sides[i]
		if leg.stepping or leg.foot == null or not leg.foot.is_visible_in_tree():
			_feet[i] = Vector2.INF
			continue
		var at: Vector2 = leg.foot.get_global_transform_with_canvas().origin
		if _feet[i].is_finite():
			_foot_samples += 1
			_plant_px = maxf(_plant_px, _feet[i].distance_to(at))
		else:
			_feet[i] = at
