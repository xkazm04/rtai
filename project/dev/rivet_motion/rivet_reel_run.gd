class_name RivetReelRun
extends Node
## rivet-motion: the sample reel (owner 21:25: the full chain, in the look, in motion). Rivet on
## the D5 arena floor runs one scripted input course through the REAL state machines:
## PlayerMotion (rivet_motion.json) strafes a box around an aim mark, sprints into a ped (the
## tackle: bodies.json's rivet_base -> human rule decides it from the closing speed), rolls out,
## walks up to a patrolling cop and MeleeCombo (rivet_melee.json) claws him to death: hit-stop,
## a decaying shake, the knockback, the sprawl and CombatBlood's death spray and pool.

const PX: float = 32.0
const ARENA: String = "res://features/city/art/d5/arena/king_arena.png"
const ARENA_M: float = 12.0
const WALK_MPS: float = 6.75  # combat.json rivet walk_mps (the 2026-11-04 baseline)
const MARK: Vector2 = Vector2(-2.0, -1.5)
const PED_AT: Vector2 = Vector2(-0.6, 3.2)
const COP_A: Vector2 = Vector2(3.6, -1.8)
const COP_B: Vector2 = Vector2(3.6, 1.4)
const STAND_OFF_M: float = 1.1
const ARMS: Array[int] = [BodyPlan.L, BodyPlan.R, 2]
## Placeholders until gunplay's HitFeel lands (REQUEST 3 -> gunplay): freeze ticks, shake px.
const HITSTOP_TICKS: Array[int] = [3, 3, 7]
const SHAKE_PX: Array[float] = [2.0, 2.5, 7.0]
## [seconds (max), move or target, held actions, aim ("mark" | "cop" | "east" | ""), mash?]
## A target String ("goto:x,y" | "cop") walks to it and ends the row on arrival.
const COURSE: Array[Array] = [
	[1.0, Vector2.ZERO, "", "mark", false],
	[1.0, Vector2.RIGHT, "", "mark", false],
	[0.8, Vector2.UP, "", "mark", false],
	[1.6, Vector2.LEFT, "", "mark", false],
	[0.8, Vector2.DOWN, "", "mark", false],
	[0.4, Vector2.ZERO, "", "mark", false],
	[3.0, "goto:-5.2,3.2", "", "", false],
	[0.4, Vector2.ZERO, "", "east", false],
	[1.25, Vector2.RIGHT, "sprint", "", false],
	[0.05, Vector2.RIGHT, "sprint,roll", "", false],
	[0.9, Vector2.ZERO, "", "cop", false],
	[4.0, "cop", "", "cop", false],
	[1.6, Vector2.ZERO, "", "cop", true],
	[2.5, Vector2.ZERO, "", "cop", false],
]

var zoom: float = 1.5
## false: the shared vermilion hit flash is suppressed (red is blood only; REQUEST 1 -> gunplay).
var flash: bool = false
var _world: CanvasLayer = CanvasLayer.new()
var _post: CanvasLayer = CanvasLayer.new()
var _actors: CanvasLayer = CanvasLayer.new()
var _rig: CutRig = CutRig.new()
var _blood: CombatBlood = null
var _ped: ReelVictim = null
var _cop: ReelVictim = null
var _motion: PlayerMotion = PlayerMotion.shipped()
var _actions: PlayerActions = PlayerActions.shipped()
var _combo: MeleeCombo = MeleeCombo.new(MeleeTable.shipped())
var _bodies: BodyTable = BodyTable.load_default()
var _pos: Vector2 = Vector2(-3.0, 1.0)
var _previous: int = 0
var _tick: int = 0
var _seen_starts: int = 0
var _freeze: int = 0
var _shake: float = 0.0
var _origin: Vector2 = Vector2.ZERO
var _world_px: Vector2 = Vector2.ZERO


func _ready() -> void:
	for i: int in 3:
		var layer: CanvasLayer = [_world, _post, _actors][i]
		layer.layer = i
		add_child(layer)
	_floor()
	var look: ShaderMaterial = ShaderMaterial.new()
	look.shader = load("res://assets/shaders/look_d4.gdshader") as Shader
	look.set_shader_parameter(&"grime_tex", GrimeLattice.texture())
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.material = look
	_post.add_child(rect)
	_blood = CombatBlood.new()
	_actors.add_child(_blood)
	_ped = ReelVictim.new(HumanPlan.ped(), RigVariant.crowd(2), PED_AT, PI * 0.5, PX)
	_cop = ReelVictim.new(HumanPlan.cop(), RigVariant.crowd(5), COP_A, PI * 0.5, PX)
	_cop.patrol_b = COP_B
	_cop.patrol_mps = 1.2
	for r: CutRig in [_ped.rig, _cop.rig, _rig]:
		_actors.add_child(r)
	_rig.setup(RivetPlan.build(), RigVariant.rivet())
	_rig.snap_facing(-PI * 0.5)
	var view: Vector2 = get_viewport().get_visible_rect().size
	var xf: Transform2D = Transform2D(0.0, Vector2(zoom, zoom), 0.0, view * 0.5)
	_world.transform = xf
	_actors.transform = xf
	_origin = xf.origin
	_world_px = -view * 0.5
	look.set_shader_parameter("world_px", _world_px)
	@warning_ignore("return_value_discarded")
	RivetD5Post.attach(_post, zoom, _world_px)


func play() -> int:
	for row: Array in COURSE:
		Log.info(
			"reel", "row at tick %d pos %s v %.2f" % [_tick, _pos, _motion.velocity().length()]
		)
		var secs: float = row[0]
		for _t: int in maxi(roundi(secs / SimClock.TICK_DT), 1):
			if _freeze > 0:
				_freeze -= 1
			elif not _step(row):
				break
			_apply_shake()
			_blood.step(_tick, _world_px)
			await get_tree().process_frame
	Log.info("reel", "ticks %d, ped down %s, cop dead %s" % [_tick, _ped.down > 0, _cop.dead])
	return 0 if _cop.dead else 1


## One sim tick of the row; false when a walk-to row has arrived (the row ends).
func _step(row: Array) -> bool:
	_tick += 1
	var c: PlayerCommand = PlayerCommand.new()
	var target: String = row[1] if row[1] is String else ""
	c.move = _toward(target) if target != "" else row[1]
	if target != "" and c.move == Vector2.ZERO:
		return false
	var aim: String = row[3]
	var at: Vector2 = MARK if aim == "mark" else _cop.pos_m()
	at = _pos + Vector2.RIGHT if aim == "east" else at
	c.aim = (at - _pos).normalized() if aim != "" else Vector2.ZERO
	var held: String = row[2]
	for n: String in held.split(",", false):
		c.held |= 1 << _actions.bit(StringName(n))
	c.pressed = c.held & ~_previous
	_previous = c.held
	var rolls: int = _motion.rolls
	_pos += _motion.step(c, WALK_MPS, _actions)
	if _motion.rolls != rolls:
		_rig.clips.roll(_motion.roll_ticks * SimClock.TICK_DT)
	var mash: bool = row[4]
	_melee(mash and _tick % 4 == 0)
	_tackle()
	_rig.position = _pos * PX
	_rig.vel_in = _motion.velocity() * PX
	_rig.face_to = _motion.facing().angle()
	_rig.drive(SimClock.TICK_DT)
	_cop.alert = _pos.distance_to(_cop.pos_m()) < 4.0
	_cop.look_at = _pos
	_ped.step(SimClock.TICK_DT, flash)
	_cop.step(SimClock.TICK_DT, flash)
	return true


func _toward(target: String) -> Vector2:
	var goal: Vector2 = _cop.pos_m()
	var stop: float = STAND_OFF_M
	if target.begins_with("goto:"):
		var xy: PackedStringArray = target.substr(5).split(",")
		goal = Vector2(xy[0].to_float(), xy[1].to_float())
		stop = 0.12
	var d: Vector2 = goal - _pos
	return Vector2.ZERO if d.length() < stop else d.normalized()


## bodies.json decides the contact: above rivet_base's run_mps a human is knocked down.
func _tackle() -> void:
	var d: Vector2 = _ped.pos_m() - _pos
	var reach: float = _bodies.radius(&"rivet_base") + _bodies.radius(&"human")
	if _ped.down > 0 or d.length() > reach:
		return
	var rule: BodyRule = _bodies.rule(&"rivet_base", &"human")
	var closing: float = _motion.velocity().dot(d.normalized())
	var res: StringName = rule.result(closing, _bodies.run_mps(&"rivet_base"))
	Log.info("reel", "tick %d: contact at %.2f m/s -> %s" % [_tick, closing, res])
	if res == &"knockdown":
		_ped.knock(d.normalized(), rule.knockback_m, roundi(rule.down_s / SimClock.TICK_DT))
		_freeze = HITSTOP_TICKS[0]
		_shake = SHAKE_PX[1]


func _melee(press: bool) -> void:
	if press:
		_combo.press()
	_combo.step()
	var h: MeleeHit = _combo.current()
	if _combo.starts != _seen_starts and _combo.hit_index != 0:
		_seen_starts = _combo.starts
		var arm: int = ARMS[mini(_combo.hit_index - 1, ARMS.size() - 1)]
		var dt: float = SimClock.TICK_DT
		_rig.clips.strike(_rig, h.windup * dt, h.active * dt, h.recovery * dt, arm)
	if not _combo.lands() or _cop.dead:
		return
	var to: Vector2 = _cop.pos_m() - _pos
	if to.length() > h.reach_m + 0.45 or to.normalized().dot(_motion.facing()) < h.cone_dot:
		Log.info("reel", "tick %d: %s whiffs" % [_tick, h.id])
		return
	var k: int = mini(_combo.hit_index - 1, HITSTOP_TICKS.size() - 1)
	_freeze = HITSTOP_TICKS[k]
	_shake = SHAKE_PX[k]
	Log.info("reel", "tick %d: %s lands" % [_tick, h.id])
	if h.knockback_m > 1.0:
		_cop.kill(to.normalized(), h.knockback_m)
		_blood.kill_human(_cop.rig.position, to.normalized())
	else:
		_cop.knock(to.normalized(), h.knockback_m, 0)


func _apply_shake() -> void:
	var off: Vector2 = Vector2(sin(_tick * 7.3), cos(_tick * 5.1)) * _shake
	_world.transform.origin = _origin + off
	_actors.transform.origin = _origin + off
	_shake = _shake * 0.72 if _shake > 0.2 else 0.0


func _floor() -> void:
	var field: Polygon2D = Polygon2D.new()
	var e: float = 30.0 * PX
	field.polygon = PackedVector2Array(
		[Vector2(-e, -e), Vector2(e, -e), Vector2(e, e), Vector2(-e, e)]
	)
	field.color = D5HeroKerbs.ASPHALT
	_world.add_child(field)
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(ARENA) as Texture2D
	s.scale = Vector2.ONE * ARENA_M * PX / s.texture.get_width()
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)
