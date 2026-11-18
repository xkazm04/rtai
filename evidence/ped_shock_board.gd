extends "res://dev/showcase/street_crowd_run.gd"
## Four full pedestrian rigs on the street board. Land the same uncharged electro round
## separately on each. FightAreas owns damage and stun duration, ReactLink owns the wound.
## The fourth walker is the control. The fixed ids use the ordinary street wardrobe pools.

const CAST_IDS: Array[int] = [1, 2, 4, 3]
const CAST_LOOKS: Array[int] = [0, 7, 4, 7]
const ROWS: Array[String] = ["ped/head_hat", "ped/head_bald", "ped/head_shopper", "ped/head_worker"]
const GAP_M: float = 4.6  # beyond the electro gun's 4 m chain radius
const LANE_CENTRE_M: float = 1.8
const HIT_TICK: int = 30
const LAST_TICK: int = 168
const AIM: Vector2 = Vector2(-1.0, -1.0)

var _arena: CombatArena
var _link: ReactLink


func _cast() -> void:
	var reg: RngRegistry = RngRegistry.new(3)
	_arena = CombatArena.new(CombatTuning.shipped(), _bus, reg.stream(&"combat"))
	_arena.gun = GunHand.make(WeaponTable.shipped(), &"electro_gun", reg.stream(&"gunplay"))
	_arena.areas = FightAreas.new()
	_link = ReactLink.make(_arena)
	for i: int in CAST_IDS.size():
		var at: Vector2 = Vector2((i - (CAST_IDS.size() - 1) * 0.5) * GAP_M, 0)
		var h: Fighter = Fighter.make(Fighter.Kind.GUARD, CAST_IDS[i], at, 1.0)
		_arena.hostiles.append(h)
		@warning_ignore("return_value_discarded")
		_rigs.feed.put(i, h.id, BodyPlan.Kind.PED, at * PX, Vector2.ZERO)
		_rigs.feed.looks[i] = CAST_LOOKS[i]
		_rigs.feed.face[i] = (-AIM).angle()
	_rigs.set_process(false)
	RigCastShadows.attach(_rigs)


func shoot() -> int:
	if DirAccess.make_dir_recursive_absolute(out_dir) != OK:
		return 1
	var view: Vector2 = get_viewport().get_visible_rect().size
	_rigs.zoom = ppm / PX
	var xf: Transform2D = Transform2D(0.0, ViewMode.shared().zoom_of(_rigs.zoom), 0.0, view * 0.5)
	_world.transform = xf
	_world.offset += Vector2.DOWN * LANE_CENTRE_M * ppm
	_actors.transform = xf
	_look.set_shader_parameter("world_px", -view * 0.5)
	var poses: FileAccess = FileAccess.open(out_dir.path_join("poses.csv"), FileAccess.WRITE)
	if poses == null:
		return 1
	@warning_ignore("return_value_discarded")
	poses.store_line("tick,actor,look,strip,facing,row,foot_x,foot_y,rotation")
	for t: int in LAST_TICK + 1:
		_arena.tick = t
		if t == HIT_TICK:
			if not _land():
				return 1
		_arena.areas.step(_arena)
		_link.apply(_rigs)
		_rigs.step_ticks(1)
		_record(poses, t)
		if t % 2 != 0:
			continue
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		if img == null or img.save_jpg(out_dir.path_join("t%04d.jpg" % t), 0.98) != OK:
			return 1
	return 0 if _link.wounds == CAST_IDS.size() and _arena.areas.chain_hits == 0 else 1


func _record(file: FileAccess, t: int) -> void:
	for id: int in CAST_IDS:
		var rig: CutRig = _rigs.rig_for(id)
		var c: Sprite2D = rig.head_card
		var at: Vector2 = c.global_position - rig.global_position
		@warning_ignore("return_value_discarded")
		file.store_line(
			(
				"%d,%d,%s,%s,%d,%d,%.2f,%.2f,%.4f"
				% [
					t,
					id,
					StreetWalkerCards.row_of(rig),
					c.texture.resource_path.get_file(),
					c.frame_coords.x,
					c.frame_coords.y,
					at.x,
					at.y,
					c.global_rotation
				]
			)
		)


func _land() -> bool:
	var shots: Array[Shot] = _arena.gun.pull(_arena.rivet, _arena.rivet.pos + AIM)
	if shots.size() != 1:
		return false
	for i: int in CAST_IDS.size():
		var h: Fighter = _arena.hostiles[i]
		var rig: CutRig = _rigs.rig_for(h.id)
		if rig == null or StreetWalkerCards.row_of(rig) != ROWS[i]:
			Log.error("ped_shock_board", "missing street look %s" % ROWS[i])
			return false
		_arena.areas.land(_arena, shots[0], h, h.pos)
	return true
