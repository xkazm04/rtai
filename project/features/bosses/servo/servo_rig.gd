class_name ServoRig
extends Node2D
## Servo's cutout rig, top-down (docs/bosses/servo.md section 1): parts cut from the Codex part
## sheets (tools/art/servo_parts.py, art/ at ART_PPM), posed procedurally from the fight each tick.
## Layers, low to high: legs, arms, pads, pelvis, rack wings, torso, head. Motion: a two-leg gait
## from the distance walked and a bob; every tell leans back (anticipation) and the active window
## lunges (follow-through); the head tracks the aim and its visor glows vermilion only in a tell;
## the pads spin up for a dash and vent steam in the punish window; rack bays go dark while their
## drone is out; phase 3 loses a wing; a hit flashes the body and never touches the fight's state.

const PX: float = 32.0
const ART_PPM: float = 96.0
const ART: String = "res://features/bosses/servo/art/%s.png"
const STRIDE_M: float = 2.2
const FLASH_TICKS: int = 5

var fight: BossFight = null
var rack: ServoRack = null
var tick: int = 0
var _tex: Dictionary[StringName, Texture2D] = {}
var _walk: float = 0.0
var _last_pos: Vector2 = Vector2.ZERO
var _spin: float = 0.0
var _pal: PaletteTokens = PaletteTokens.shared()


func _ready() -> void:
	for n: StringName in [&"head", &"pad", &"pelvis", &"torso", &"rack", &"thigh", &"shin", &"arm"]:
		_tex[n] = load(ART % n) as Texture2D


## Called once per sim tick by the view: advances the gait and the pad spin, then redraws.
func pose(p_tick: int) -> void:
	tick = p_tick
	var moved: float = fight.body.pos.distance_to(_last_pos)
	_last_pos = fight.body.pos
	_walk = fmod(_walk + moved / STRIDE_M * TAU, TAU)
	_spin += 0.9 if _stage(&"windup", true) or _stage(&"active", true) else 0.15
	queue_redraw()


func _draw() -> void:
	var fwd: Vector2 = fight.body.facing
	var side: Vector2 = fwd.orthogonal()
	var o: Vector2 = fight.body.pos + fwd * _lean()
	var k: float = 1.0 + 0.015 * sin(_walk * 2.0)
	if fight.state == BossFight.State.DEFEATED:
		k = 0.92
	var tint: Color = _tint()
	for s: float in [-1.0, 1.0]:
		_leg(o, fwd, side, s, tint)
	for s: float in [-1.0, 1.0]:
		var pad: Vector2 = o + side * s * 2.6 + fwd * 1.2
		_strut(&"arm", o + side * s * 0.9 + fwd * 0.2, pad, tint)
		_part(&"pad", pad, fwd.angle() - PI / 2 + _spin * s * 0.1, k, tint)
		if _stage(&"recovery", false):
			_steam(pad)
	_part(&"pelvis", o + fwd * 0.5, fwd.angle() - PI / 2, k, tint)
	_wings(o, fwd, side, k, tint)
	_part(&"torso", o + fwd * 0.3, fwd.angle() - PI / 2, k, tint)
	var head_rot: float = (fight.aim if _stage(&"windup", false) else fwd).angle() - PI / 2
	_part(&"head", o + fwd * 1.2, head_rot, k, tint)
	_visor(o + fwd * 1.2, head_rot)


func _leg(o: Vector2, fwd: Vector2, side: Vector2, s: float, tint: Color) -> void:
	# The target's top view: the legs step out in front of the rack, between the pads.
	var hip: Vector2 = o + side * s * 0.6 + fwd * 0.5
	var swing: float = sin(_walk + (PI if s > 0.0 else 0.0))
	var foot: Vector2 = hip + side * s * 0.9 + fwd * (1.9 + 0.7 * swing)
	var knee: Vector2 = (hip + foot) * 0.5 + side * s * 0.5
	_strut(&"thigh", hip, knee, tint)
	_strut(&"shin", knee, foot, tint)


func _wings(o: Vector2, fwd: Vector2, side: Vector2, k: float, tint: Color) -> void:
	var rot: float = fwd.angle() - PI / 2
	var wing: Texture2D = _tex[&"rack"]
	for s: float in [-1.0, 1.0]:
		if s < 0.0 and rack.count(ServoRack.Cell.BROKEN) > 0:
			continue  # phase 3: this wing blew off
		var at: Vector2 = o + side * s * 1.305 - fwd * 0.765
		var flip: float = -1.0 if s > 0.0 else 1.0
		draw_set_transform(at * PX, rot, Vector2(flip, 1.0) * k * PX / ART_PPM)
		draw_texture(wing, -wing.get_size() * 0.5, tint)
	draw_set_transform(Vector2.ZERO)
	var bay: Color = Color(_pal.color(&"ink"), 0.85)
	for i: int in rack.state.size():
		var st: int = rack.state[i]
		if st == ServoRack.Cell.OUT or st == ServoRack.Cell.REFILL:
			draw_circle(rack.cell_pos(i) * PX, 0.3 * PX, bay)


func _part(n: StringName, at: Vector2, rot: float, k: float, tint: Color) -> void:
	var t: Texture2D = _tex[n]
	draw_set_transform(at * PX, rot, Vector2(k, k) * PX / ART_PPM)
	draw_texture(t, -t.get_size() * 0.5, tint)
	draw_set_transform(Vector2.ZERO)


## A strut part (art long axis down the page) stretched from a to b.
func _strut(n: StringName, a: Vector2, b: Vector2, tint: Color) -> void:
	var t: Texture2D = _tex[n]
	var len_px: float = a.distance_to(b) * PX
	var w: float = PX / ART_PPM
	draw_set_transform(
		(a + b) * 0.5 * PX, (b - a).angle() - PI / 2, Vector2(w, len_px / t.get_height())
	)
	draw_texture(t, -t.get_size() * 0.5, tint)
	draw_set_transform(Vector2.ZERO)


func _visor(at: Vector2, rot: float) -> void:
	if not _stage(&"windup", false):
		return
	var w: float = 6.0 if fight.locked else 3.0
	var dir: Vector2 = Vector2.from_angle(rot + PI / 2)
	var c: Vector2 = (at + dir * 0.32) * PX
	var half: Vector2 = dir.orthogonal() * 0.25 * PX
	draw_line(c - half, c + half, _pal.color(&"vermilion"), w)


func _steam(at: Vector2) -> void:
	var a: float = 0.35 + 0.15 * sin(tick * 0.4)
	for j: int in 3:
		var off: Vector2 = Vector2.from_angle(tick * 0.05 + j * TAU / 3.0) * 0.5
		draw_circle((at + off) * PX, (0.3 + 0.08 * j) * PX, Color(_pal.color(&"paper"), a))


## Anticipation and follow-through along the facing, metres.
func _lean() -> float:
	if fight.attack == null:
		return 0.0
	var a: BossAttack = fight.attack
	if fight.state == BossFight.State.WINDUP:
		return -0.25 * minf(float(fight.t) / maxi(a.windup, 1), 1.0)
	if fight.state == BossFight.State.ACTIVE:
		return 0.3
	if fight.state == BossFight.State.RECOVER:
		return 0.3 * maxf(1.0 - float(fight.t) / maxi(a.recovery, 1), 0.0)
	return 0.0


func _tint() -> Color:
	if fight.state == BossFight.State.DEFEATED:
		return Color(0.7, 0.7, 0.7)
	if fight.body.hurt_tick > 0 and tick - fight.body.hurt_tick < FLASH_TICKS:
		return Color(1.6, 1.5, 1.4)
	return Color.WHITE


## In `stage` of the current attack (windup: any tell; active: a dash, or any if `any`; recovery:
## inside the punish window).
func _stage(stage: StringName, any: bool) -> bool:
	if fight.attack == null:
		return false
	var dash: bool = any or String(fight.attack.id).begins_with("rotor_dash")
	match stage:
		&"windup":
			return fight.state == BossFight.State.WINDUP
		&"active":
			return fight.state == BossFight.State.ACTIVE and dash
		&"recovery":
			return fight.state == BossFight.State.RECOVER and fight.t <= fight.attack.punish
	return false
