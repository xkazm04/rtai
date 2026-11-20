class_name TonnageSpectral
extends Node2D
## Press Golem presentation. The shared flight mount owns the root motion and road shadow.

const PPM: float = SimConst.PX_PER_M
const BASELINE: float = 315.0


## GhostFormView advances the rig, then feeds the current combat tick before drawing the frame.
class Feed:
	extends GhostDrawn
	signal sampled(tick: int, hurt: int)

	func feed(seq: int, hurt: int, tick: int, windup: bool = false, release_tick: int = -1) -> void:
		super.feed(seq, hurt, tick, windup, release_tick)
		sampled.emit(tick, hurt)


var pose: TonnagePose
var _sample: TonnagePose.Sample = TonnagePose.Sample.new()
var _drawn: Feed
var _row: GhostHoverRow
var _hauler: HaulerStage
var _ticks: int = 0
var _morph: TonnageMorph = TonnageMorph.new()
var _parts: TonnageParts = TonnageParts.new()
var _cell: Sprite2D = Sprite2D.new()
var _cell_light: Sprite2D
var _glow: Sprite2D = TonnageGlow.halo()
var _vapour: GhostTail = TonnageVapour.make()
var _shadows: Array[Sprite2D] = []
var _art: String = ""
var _poses: GhostSheet
var _acts: GhostSheet
var _strike_yaw: float = 0.0
var _last_stomp: int = -1


func _init(drawn: Feed) -> void:
	_drawn = drawn
	var ahead: float = GhostAttacks.shipped().num(&"tonnage", &"press_ahead_m")
	pose = TonnagePose.new(
		ahead, GhostDrawn.CUT_TICKS, GhostDrawn.FOLLOW_TICKS, GhostDrawn.HIT_TICKS
	)
	_row = GhostHoverRow.of(&"tonnage")
	@warning_ignore("return_value_discarded")
	_drawn.sampled.connect(_combat_tick)


func _ready() -> void:
	for i: int in 2:
		var ink: Sprite2D = GhostRim.soft_glow(GhostShadow.INK, 0.92, 64.0)
		ink.self_modulate.a = 0.0
		var disc: GradientTexture2D = ink.texture as GradientTexture2D
		disc.gradient.add_point(0.55, Color(GhostShadow.INK, 0.8))
		if _drawn.flight != null:
			ink.z_as_relative = false
			ink.z_index = RenderLayers.z(&"actors") - 1
		_shadows.append(ink)
		add_child(ink)
	add_child(_vapour)
	add_child(_glow)
	add_child(_parts)
	_cell.name = &"ghost_drawn"
	_cell.centered = false
	_cell.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_cell_light = TonnageGlow.on_body(_cell)
	add_child(_cell)
	_drawn.voice_parts.assign([_parts, _cell])


func advance(hauler: HaulerStage, facing: float, ticks: int, unfold: float) -> void:
	_hauler = hauler
	_sample.facing = facing
	_ticks = ticks
	_morph.set_progress(unfold, self, _cell, _cell_light)
	if hauler == null:
		_combat_tick(0, -1)


func _combat_tick(tick: int, hurt: int) -> void:
	if not is_visible_in_tree():
		return
	if _hauler != null:
		_sample.velocity = _hauler.form.vel
		_sample.windup = _hauler.form.windup_k()
		_sample.ramming = _hauler.form.ramming()
		_sample.ram_hits = _hauler.ram_hits
		var stomp: int = _hauler.stomp_tick
		_sample.stomp_age = tick - stomp if stomp >= 0 else -1
		if stomp != _last_stomp:
			_strike_yaw = _sample.facing
			_last_stomp = stomp
	_sample.hurt_age = tick - hurt if hurt >= 0 else -1
	if _drawn.flight != null:
		_sample.bob_m = _drawn.flight.hover.lift_m - _row.height_m
	pose.step(_sample, _ticks)
	_present()
	TonnageVapour.seat_column(_drawn.flight, _cell, global_rotation)
	TonnageVapour.present(_vapour, _glow.global_position, _cell, global_rotation, _ticks)
	_ticks = 0


func _present() -> void:
	var vm: ViewMode = ViewMode.shared()
	var flat: bool = vm.is_flat()
	_parts.visible = flat
	_cell.visible = not flat
	scale = Vector2.ONE * _morph.size_k
	var left: Vector2 = _hand(0, pose.left, -1.0)
	var right: Vector2 = _hand(1, pose.right, 1.0)
	var centre: Vector2 = Vector2(pose.torso.x, pose.torso.y) * PPM
	_glow.position = centre
	if flat:
		var fit: float = lerpf(1.0, 1.0 / absf(global_scale.x), pose.plant_k)
		_parts.update_body(pose, left, right, fit)
	else:
		_show_cell(vm, centre - Vector2(TonnagePose.BACK_X * PPM, 0.0))


func _hand(i: int, hand: Vector3, side: float) -> Vector2:
	var flight: GhostFlight = _drawn.flight
	hand = _morph.hand(hand, side)
	var local: Vector2 = Vector2(hand.x, hand.y) * PPM
	var road: Vector2 = to_global(local)
	var ground: Vector2 = global_position
	if flight != null:
		ground = flight.shadow.global_position
		road -= ViewMode.shared().lift_px(flight.hover.lift_m)
	var landing: Vector3 = pose.landing(side)
	var target: Vector2 = ground + Vector2(landing.x, landing.y).rotated(_sample.facing) * PPM
	if pose.plant_k > 0.0 and _hauler != null:
		target = _hauler.stomp_at * PPM + Vector2(0.3, landing.y).rotated(_strike_yaw) * PPM
		# Undo the mount's lag, yaw and enlarged silhouette at the ground contact.
		var nominal: Vector2 = to_global(Vector2(landing.x, landing.y) * PPM)
		var correction: Vector2 = target - nominal
		local = to_local(to_global(local) + correction * pose.plant_k)
		road = to_global(local)
		if flight != null:
			road -= ViewMode.shared().lift_px(flight.hover.lift_m) * (1.0 - pose.plant_k)
	elif pose.act and pose.column == TonnagePose.Act.RAISE:
		road = target
	_cast_shadow(_shadows[i], road, hand.z)
	return local


func _cast_shadow(shadow: Sprite2D, road: Vector2, height: float) -> void:
	shadow.global_position = road
	shadow.global_rotation = _sample.facing
	var high: float = clampf(height / 2.6, 0.0, 1.0)
	var width: float = lerpf(1.0, 1.55, high)
	var alpha: float = lerpf(0.88, 0.36, high)
	if pose.act and pose.column == TonnagePose.Act.RAISE:
		width = lerpf(1.55, 1.0, _sample.windup)
		alpha = lerpf(0.7, 1.0, _sample.windup)
	shadow.global_scale = Vector2(1.45, 0.85) * (PPM / 64.0) * width
	shadow.self_modulate.a = alpha * pose.fist_shadow_k


func _show_cell(vm: ViewMode, centre: Vector2) -> void:
	var art: String = (
		vm.art if vm.art in ["p55", "p70"] else ("p55" if vm.pitch_deg < 62.5 else "p70")
	)
	if art != _art:
		_art = art
		_poses = GhostSheet.of(GhostDrawn.path_of(art, "tonnage", "spectral_pose"), 4)
		_acts = GhostSheet.of(GhostDrawn.path_of(art, "tonnage", "spectral_act"), 4)
	var sheet: GhostSheet = _acts if pose.act else _poses
	var look: float = global_rotation
	var oct: int = _drawn.octant(look)
	sheet.show(_cell, oct, pose.column)
	sheet.show(_cell_light, oct, pose.column)
	_cell_light.offset.y = -BASELINE
	_cell.offset.y = -BASELINE
	var host: Node2D = get_parent() as Node2D
	var fit: float = absf(host.scale.x if _drawn.flight != null else host.global_scale.x)
	var s: float = _drawn.height_m * _morph.size_k * PPM * fit / (215.5 if art == "p70" else 216.0)
	var bank: float = 0.0
	var stretch: Vector2 = Vector2.ONE
	if _drawn.flight != null:
		bank = _drawn.flight.hover.bank
		stretch = _drawn.flight.body_scale()
	var roll: float = bank * 0.4 + cos(look) * pose.pitch * 0.25
	_cell.global_rotation = roll
	if not pose.act and pose.column == TonnagePose.Pose.RECOIL:
		stretch *= TonnagePose.recoil_fit(_cell.frame_coords.y, art)
	if _sample.hurt_age >= 0 and _sample.hurt_age < GhostDrawn.HIT_TICKS:
		_hit_lean.call_deferred(look, roll)  # GhostActs supplies the blow immediately after feed.
	_cell.global_scale = Vector2(s, s / vm.ground_k()) * stretch
	var h: float = pose.torso.z - TonnagePose.CHEST_H - _sample.bob_m
	_cell.global_position = to_global(centre) + vm.lift_px(h * fit * _morph.size_k)
	_glow.global_position = _cell.to_global(TonnageGlow.GLOW_CELL_CENTRE)
	_cell.modulate.a = TonnageGlow.body_alpha(pose)


func _hit_lean(look: float, roll: float) -> void:
	var tilt: float = GhostRecoil.tilt(
		_sample.hurt_age, look, GhostRecoil.lean_of("tonnage"), _drawn.blow
	)
	_cell.global_rotation = roll + tilt * pose.lean_k
