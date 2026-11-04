class_name EnemyRigFight
extends D5ShowcaseRun
## enemy-ai evidence (owner direction 21:25): the pit fight (PitLayout + PitDummy as Rivet) on the
## cast rigs in the D5 look at 32 px/m, never debug circles. Cops are CharacterRigs rows from
## EnemyRigFeed; robots ride their own rig (ThugPlan, the thug's own proportions; King's parts
## until its sheet lands). The full chain on screen: the tell (EnemyFightFx aim line / windup
## arc), the shot (SHOOT recoil, muzzle star, tracer), the impact (HIT clip shoved along the
## blow, red blood on humans, sparks and oil on robots, a hit-stop hold on a kill, camera shake
## when Rivet is hit), DEATH. One sim tick per step; every `every`-th tick saved as a PNG.

const FLOOR_M: Vector2 = Vector2(44.0, 32.0)
const CRATE: String = "res://features/city/art/props/crate_stack.png"
const HOLD_FRAMES: int = 3
const SHAKE_TICKS: int = 8
const SHAKE_PX: float = 5.0
const CAM_EASE: float = 0.06
## A near-miss flinch shoves the rig sideways (no tint, no blood: it must not read as a hit).
const FLINCH_SHOVE: float = 70.0
## The camera keeps a fresh corpse in frame this long (the 04:00 rule: 1-2 s of aftermath).
const AFTERMATH_TICKS: int = 180

var pit: EnemyPit = null
var dummy: PitDummy = null
var every: int = 2
## The view zoom (1.0 = 32 px/m; 1.5 = the 48 px/m follow camera; 2.0 = the 64 px/m close-up).
var zoom: float = 1.0
var ticks: int = 900
var stats: Dictionary[String, float] = {}
var _bots: Node2D = Node2D.new()
var _bot_rigs: Dictionary[int, CutRig] = {}
var _bot_feed: RigFeed = RigFeed.new(8)
var _fx: EnemyFightFx = EnemyFightFx.new()
var _blood: CombatBlood = null
var _pipe: DeathPipe = DeathPipe.make(ReactTable.shipped())
var _frame_no: int = 0
var _nails: float = 0.0
var _rivet_dmg: float = 0.0
var _shake: int = 0
var _cam_m: Vector2 = Vector2.ZERO


func _init() -> void:
	zooms = [1.0]


func _ready() -> void:
	super._ready()
	_actors.add_child(_bots)
	_blood = CombatBlood.new()
	_actors.add_child(_blood)
	_actors.add_child(_fx)
	_fx.ppm = PX
	_fx.rig_of = _rig_of
	RigDetail.enabled = true
	overlay.set_shader_parameter("amount", amount_at(zoom))


func _ground() -> void:
	var field: Polygon2D = Polygon2D.new()
	var e: Vector2 = FLOOR_M * 0.5 * PX
	field.polygon = PackedVector2Array(
		[Vector2(-e.x, -e.y), Vector2(e.x, -e.y), Vector2(e.x, e.y), Vector2(-e.x, e.y)]
	)
	field.color = D5HeroKerbs.ASPHALT
	_world.add_child(field)
	for b: Rect2 in PitLayout.BOXES:
		var s: Sprite2D = Sprite2D.new()
		s.texture = load(CRATE) as Texture2D  # the striped barricade prints vermilion: danger only
		s.scale = b.size * PX / s.texture.get_size()
		s.position = b.get_center() * PX
		s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		_world.add_child(s)


func _cast() -> void:
	_rigs.feed.count = 0


## Runs the fight to `ticks`, saving frames to out_dir; returns the exit code.
func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	_fx.pit = pit
	overlay.set_shader_parameter("amount", amount_at(zoom))  # zoom is set after _ready
	_cam_m = _mid()
	while pit.tick < ticks:
		_step()
		if pit.tick % every != 0:
			continue
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var holds: int = 1 + (HOLD_FRAMES if _killed_now() else 0)
		for _h: int in holds:
			ok = _save_frame() and ok
	stats["frames"] = _frame_no
	stats["rivet_hp"] = pit.rivet_hp
	for k: String in pit.stats:
		stats[k] = pit.stats[k]
	return 0 if ok else 1


func _step() -> void:
	dummy.step(pit)
	pit.step()
	_feed_rows()
	_impacts()
	_rigs.focus = _cam_m * PX  # full rigs within RADIUS_M of the frame centre
	_rigs.step_ticks(1)
	for id: int in _bot_rigs:
		_bot_rigs[id].drive(SimClock.TICK_DT)
		RigDetail.sync(_bot_rigs[id])
	_follow()
	_fx.rivet_rig = _rigs.rig_for(0)
	_fx.queue_redraw()
	var z: float = _rigs.zoom
	var view: Vector2 = get_viewport().get_visible_rect().size
	_blood.step(pit.tick, (cam * z).round() - view * 0.5)


## Rivet as row 0, cops after it; each robot as a row of the bot feed applied to its own rig.
func _feed_rows() -> void:
	var f: RigFeed = _rigs.feed
	f.count = 0
	var target: EnemyAgent = _nearest()
	@warning_ignore("return_value_discarded")
	f.put(0, 0, BodyPlan.Kind.RIVET, pit.rivet_pos * PX, pit.rivet_vel * PX)
	if target != null:
		f.face[0] = (target.pos - pit.rivet_pos).angle()
		f.aim[0] = target.pos * PX
		f.flags[0] = RigFeed.Flag.GUN_OUT | RigFeed.Flag.AIMING
	if pit.stats["nails"] > _nails:
		_nails = pit.stats["nails"]
		f.clip[0] = RigClips.Clip.SHOOT
		f.clip_arg[0] = 1.0
		_fx.rivet_shot_tick = pit.tick
	var n: int = 1
	_bot_feed.count = 0
	for e: EnemyAgent in pit.agents:
		if e.arch.body == &"robot":
			var b: int = _bot_feed.count
			EnemyRigFeed.row(e, pit.tick, _bot_feed, b, PX)
			RigInput.apply(_bot_rig(e), _bot_feed, b)
			continue
		EnemyRigFeed.row(e, pit.tick, f, n, PX)
		f.looks[n] = RigVariant.SWAT if e.arch.id == &"swat" else (6 if e.melee() else 5)
		n += 1


## A flinch shove on a near miss, blood on a hurt human, sparks on a hurt robot, sparks on
## Rivet when he is hit (+ a shake).
func _impacts() -> void:
	for e: EnemyAgent in pit.agents:
		if e.flinch_tick == pit.tick and _rig_of(e.id) != null:
			_rig_of(e.id).hit(e.flinch_dir, FLINCH_SHOVE)
			stats["flinch_frame_%d" % e.id] = _frame_no + 1  # the next saved frame (evidence)
		if e.hurt_tick != pit.tick:
			continue
		var at: Vector2 = e.pos * PX
		if e.arch.body == &"robot":
			var fx: BloodFx = _blood.oil if _blood.oil != null else _blood.blood
			fx.splash(at, e.hurt_dir, "robot_hit")
			if e.died_tick == pit.tick:
				stats["robot_death_frame_%d" % e.id] = _frame_no + 1
				@warning_ignore("return_value_discarded")
				_pipe.kill_robot(_bot_rig(e), e.hurt_dir)
		elif e.died_tick == pit.tick:
			_blood.kill_human(at, e.hurt_dir)
		else:
			_blood.blood.splash(at, e.hurt_dir, "player_hit")
	if pit.stats["rivet_damage"] > _rivet_dmg:
		_rivet_dmg = pit.stats["rivet_damage"]
		var from: EnemyAgent = _nearest()
		var dir: Vector2 = Vector2.RIGHT if from == null else pit.rivet_pos - from.pos
		_rigs.feed.clip[0] = RigClips.Clip.HIT
		_rigs.feed.clip_arg[0] = dir.angle()
		var fx: BloodFx = _blood.oil if _blood.oil != null else _blood.blood
		fx.splash(pit.rivet_pos * PX, dir.normalized(), "robot_hit")
		_shake = SHAKE_TICKS


## The camera eases toward the fight's middle (Rivet and the living enemies); a hit shakes it.
func _follow() -> void:
	_cam_m = _cam_m.lerp(_mid(), CAM_EASE)
	var jolt: Vector2 = Vector2.ZERO
	if _shake > 0:
		var k: float = float(_shake) / SHAKE_TICKS
		jolt = Vector2.from_angle(_shake * 2.4) * SHAKE_PX * k
		_shake -= 1
	cam = _cam_m * PX + jolt
	_frame_at(zoom)


func _mid() -> Vector2:
	var mid: Vector2 = pit.rivet_pos
	var n: float = 1.0
	for e: EnemyAgent in pit.agents:
		if e.alive() or pit.tick - e.died_tick < AFTERMATH_TICKS:
			mid += e.pos
			n += 1.0
	return mid / n


func _nearest() -> EnemyAgent:
	var best: EnemyAgent = null
	var bd: float = INF
	for e: EnemyAgent in pit.agents:
		var d: float = e.pos.distance_squared_to(pit.rivet_pos)
		if e.alive() and d < bd:
			bd = d
			best = e
	return best


func _killed_now() -> bool:
	for e: EnemyAgent in pit.agents:
		if e.died_tick > pit.tick - every and e.died_tick <= pit.tick:
			return true
	return false


func _bot_rig(e: EnemyAgent) -> CutRig:
	if not _bot_rigs.has(e.id):
		var rig: CutRig = CutRig.new()
		_bots.add_child(rig)
		var plan: BodyPlan = ThugPlan.build()  # no collar: vermilion is Rivet's only
		rig.setup(plan, RigVariant.rivet())
		rig.position = e.pos * PX
		rig.snap_facing(e.facing.angle())
		_bot_rigs[e.id] = rig
	return _bot_rigs[e.id]


func _rig_of(id: int) -> CutRig:
	return _bot_rigs[id] if _bot_rigs.has(id) else _rigs.rig_for(id)


func _save_frame() -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	_frame_no += 1
	if img == null or img.is_empty():
		return false
	return img.save_png(out_dir.path_join("f%05d.png" % _frame_no)) == OK
