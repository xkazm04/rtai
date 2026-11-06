class_name ServoRig
extends Node2D
## Servo's cutout rig, top-down (docs/bosses/servo.md section 1): parts cut from the Codex part
## sheets (tools/art/servo_parts.py, art/ at ART_PPM), posed procedurally from the fight each tick.
## Layers, low to high: legs, arms, pads, pelvis, rack wings, torso, head. Motion: a two-leg gait
## from the distance walked and a bob; every tell leans back (anticipation) and the active window
## lunges (follow-through); the head tracks the aim and its visor glows vermilion only in a tell;
## the pads spin up for a dash and vent steam in the punish window; rack bays go dark while their
## drone is out; phase 3 loses a wing; a hit flashes the body and never touches the fight's state.

const ART_PPM: float = 96.0
const ART: String = "res://features/bosses/servo/art/%s.png"
const STRIDE_M: float = 2.2
const FLASH_TICKS: int = 5
const PARTS: Array[StringName] = [
	&"head", &"pad", &"pelvis", &"torso", &"rack", &"rack3", &"thigh", &"shin", &"arm"
]
## The pads' art: pad_hazard (tools/art/servo_pad_rim.py: the sheet's ink and copper hazard rim)
## or pad (the it13 cut: copper on mid brown, one brown band at 32 px/m).
const PAD_ART: StringName = &"pad_hazard"
## A docked drone: a cream body (metres square, ink rim) in each full rack cell, the sheet's cream
## drones in the bays (the wing art alone printed them as dark cells). The flying drone's whole
## sprite there was 18 rotor crosses: noise at 32 px/m. 0 = off.
const DOCKED_M: float = 0.34
## The docked drones on the art's bays (ServoBays: a hub and rotor rings over the art's printed
## quad drone, the sheet's bays); false = the it14 cream squares on the sim's cells.
const DOCKED_ON_BAYS: bool = true
## The hover pads, out from the centre and ahead of it: the sheet's top view hangs them in front
## of the wings' outer corners (render only; it8-it9: 2.6 out, 1.2 ahead, beside the wings).
const PAD_OUT_M: float = 2.35
const PAD_AHEAD_M: float = 2.0
## The legs' stance: how far each foot steps out past its hip, and the knee's outward bow
## (metres). The sheet's top view has two parallel legs under the torso (it13: 0.9 / 0.5, splayed).
const LEG_SPLAY_M: float = 0.25
const KNEE_OUT_M: float = 0.2
## The struts' width against their art: the sheet's pad arms and legs are chunky blocks (it19:
## 1.0, the art's 0.25 m piston). Render only.
const ARM_W_K: float = 1.6
const LEG_W_K: float = 1.3

## Pixels per metre of the canvas (32 in the dev view, Ink.PX_PER_M in the arena).
var px: float = 32.0
var fight: BossFight = null
var rack: ServoRack = null
var tick: int = 0
var _tex: Dictionary[StringName, Texture2D] = {}
var _walk: float = 0.0
var _last_pos: Vector2 = Vector2.ZERO
var _spin: float = 0.0
var _seen_hurt: int = -1000000
var _flash: int = 0
var _pal: PaletteTokens = PaletteTokens.shared()
var _fall: ServoFall = ServoFall.new()
var _shift: ServoShift = ServoShift.new()
var _spine: ServoSpine = ServoSpine.new()
var _bays: ServoBays = ServoBays.new()
var _pad: ServoPad = ServoPad.new()


func _ready() -> void:
	for n: StringName in PARTS:
		_tex[n] = load(ServoArt.path(n)) as Texture2D  # d8: the view pitch's parts
	_tex[PAD_ART] = load(ServoArt.path(PAD_ART)) as Texture2D
	_pad.tex = _tex[PAD_ART]
	_spine.cap = _tex[&"head"]


## Called once per sim tick by the view: advances the gait and the pad spin, then redraws.
func pose(p_tick: int) -> void:
	tick = p_tick
	_fall.px = px
	_shift.px = px
	_spine.px = px
	_spine.gap_m = rack.spine_m()
	_shift.observe(fight)
	var moved: float = fight.body.pos.distance_to(_last_pos)
	_last_pos = fight.body.pos
	_walk = fmod(_walk + moved / STRIDE_M * TAU, TAU)
	if fight.body.hurt_tick != _seen_hurt:
		_seen_hurt = fight.body.hurt_tick
		_flash = FLASH_TICKS
	_flash = maxi(_flash - 1, 0)
	if _down() >= 0:
		_pad.rate = ServoFall.spin(_down())
	else:
		var rev: bool = fight.state == BossFight.State.TRANSITION or _stage(&"active", true)
		_pad.rate = 0.9 if rev or _stage(&"windup", true) else 0.15
	_spin += _pad.rate
	queue_redraw()


## Sim ticks since he went down, or -1 while he stands.
func _down() -> int:
	var m: ServoMoves = fight.moves as ServoMoves
	if m == null or m.defeated_at < 0:
		return -1
	return maxi(fight.now() - m.defeated_at, 0)


func _draw() -> void:
	var fwd: Vector2 = fight.body.facing
	var side: Vector2 = fwd.orthogonal()
	var dt: int = _down()
	var o: Vector2 = fight.body.pos + fwd * (_lean() if dt < 0 else ServoFall.slump_m(dt))
	var k: float = 1.0 + 0.015 * sin(_walk * 2.0) if dt < 0 else ServoFall.scale_k(dt)
	k *= ServoShift.lift_k(fight)
	var tint: Color = _tint() if dt < 0 else ServoFall.tint(dt)
	for s: float in [-1.0, 1.0]:
		_leg(o, fwd, side, s, tint)
	var pad_w: float = PAD_OUT_M - (ServoFall.pad_in_m(dt) if dt >= 0 else 0.0)
	var pad_k: float = k * (ServoFall.pad_k(dt) if dt >= 0 else 1.0)
	_pad.px = px
	_pad.spin = _spin
	_pad.tint = tint
	for s: float in [-1.0, 1.0]:
		var pad: Vector2 = o + side * s * pad_w + fwd * PAD_AHEAD_M
		_strut(&"arm", o + side * s * 0.9 + fwd * 0.2, pad, tint, ARM_W_K)
		_pad.draw(self, pad, fwd.angle() - PI / 2, s, pad_k)
		if _stage(&"recovery", false):
			_pad.steam(self, pad, tick)
	_part(&"pelvis", o + fwd * 0.5, fwd.angle() - PI / 2, k, tint)
	_wings(o, fwd, side, k, tint)
	_spine.draw(self, o, fwd, k, tint)
	_shift.draw(self, fight, rack)
	if dt >= 0:
		_fall.spill(self, rack, dt, _bay_points(o, fwd, k))
		_fall.crashes(self, (fight.moves as ServoMoves).crashes, dt)
	_part(&"torso", o + fwd * 0.3, fwd.angle() - PI / 2, k, tint)
	var head_rot: float = (fight.aim if _stage(&"windup", false) else fwd).angle() - PI / 2
	if dt >= 0:
		head_rot += ServoFall.head_droop(dt)
	_part(&"head", o + fwd * (1.2 if dt < 0 else 1.0), head_rot, k, tint)
	_visor(o + fwd * 1.2, head_rot)
	if dt >= 0:
		_fall.smoke(self, rack, dt)


func _leg(o: Vector2, fwd: Vector2, side: Vector2, s: float, tint: Color) -> void:
	# The target's top view: the legs step out in front of the rack, between the pads.
	var hip: Vector2 = o + side * s * 0.6 + fwd * 0.5
	var swing: float = sin(_walk + (PI if s > 0.0 else 0.0))
	var foot: Vector2 = hip + side * s * LEG_SPLAY_M + fwd * (1.9 + 0.7 * swing)
	var knee: Vector2 = (hip + foot) * 0.5 + side * s * KNEE_OUT_M
	_strut(&"thigh", hip, knee, tint, LEG_W_K)
	_strut(&"shin", knee, foot, tint, LEG_W_K)


func _wings(o: Vector2, fwd: Vector2, side: Vector2, k: float, tint: Color) -> void:
	var rot: float = fwd.angle() - PI / 2
	var wing: Texture2D = _tex[&"rack"]
	for s: float in [-1.0, 1.0]:
		if s > 0.0 and rack.count(ServoRack.Cell.BROKEN) > 0:
			continue  # phase 3: the wing of ServoRack.break_wing (its across < 0 is our side +1)
		var at: Vector2 = o + side * s * (1.305 + rack.spine_m() * 0.5) - fwd * 0.765
		at += ServoShift.shake(fight) if s > 0.0 else Vector2.ZERO
		var flip: float = -1.0 if s > 0.0 else 1.0
		draw_set_transform(at * px, rot, Vector2(flip, 1.0) * k * px / ART_PPM)
		_wing_art(wing, tint)
		ServoWingBand.draw(self, wing.get_height() * 0.5, wing.get_width() * 0.5, tint)
	draw_set_transform(Vector2.ZERO)
	_bay_cells(o, fwd, k, tint)


## Each rack cell: an empty bay goes dark, a full one holds its docked drone.
func _bay_cells(o: Vector2, fwd: Vector2, k: float, tint: Color) -> void:
	var rot: float = fwd.angle() - PI / 2
	var bay: Color = Color(_pal.color(&"ink"), 0.85)
	var pts: Array[Vector2] = _bay_points(o, fwd, k)  # sets _bays.rack first
	var on: bool = DOCKED_ON_BAYS and _bays.on_art()
	for i: int in rack.state.size():
		var st: int = rack.state[i]
		var at: Vector2 = pts[i]
		if st == ServoRack.Cell.OUT or st == ServoRack.Cell.REFILL:
			draw_circle(at * px, 0.3 * px, bay)
		elif st != ServoRack.Cell.FULL or DOCKED_M <= 0.0 or _down() >= 0:  # down: ServoFall.spill
			continue
		elif on:
			_bays.docked(self, at * px, rot, k, tint)
		else:
			_docked(at, rot, k, tint)


## Where each cell's bay is drawn: on the rack art's bays (ServoBays), else the sim's cells.
func _bay_points(o: Vector2, fwd: Vector2, k: float) -> Array[Vector2]:
	_bays.rack = rack
	_bays.px = px
	_bays.wing_c_m = 1.305 + rack.spine_m() * 0.5
	return _bays.points(o, fwd, k, ServoShift.shake(fight), DOCKED_ON_BAYS)


## Three rows: rack3.png (tools/art/servo_rack3.py, one frame 3 bays deep) with its bottom on
## the 2-row wing's; other row counts keep the repeated back row (_extra_rows).
func _wing_art(wing: Texture2D, tint: Color) -> void:
	var sz: Vector2 = wing.get_size()
	if rack.rows() == 3:
		var deep: Texture2D = _tex[&"rack3"]
		draw_texture(deep, Vector2(-sz.x * 0.5, sz.y * 0.5 - deep.get_height()), tint)
		return
	draw_texture(wing, -sz * 0.5, tint)
	_extra_rows(wing, tint)


## The wing art is two bay rows deep (its +y faces forward); each further rack row repeats its
## back row (the texture's top half) one row further back, so the bays sit on rack.cell_pos.
func _extra_rows(wing: Texture2D, tint: Color) -> void:
	var sz: Vector2 = wing.get_size()
	var row_px: float = sz.y * 0.5
	for r: int in range(2, rack.rows()):
		var dst: Rect2 = Rect2(-sz.x * 0.5, -sz.y * 0.5 - row_px * (r - 1), sz.x, row_px)
		draw_texture_rect_region(wing, dst, Rect2(0.0, 0.0, sz.x, row_px), tint)


func _docked(at: Vector2, rot: float, k: float, tint: Color) -> void:
	var h: float = DOCKED_M * 0.5 * k * px
	draw_set_transform(at * px, rot)
	draw_rect(Rect2(-h - 1.5, -h - 1.5, h * 2.0 + 3.0, h * 2.0 + 3.0), _pal.color(&"ink") * tint)
	draw_rect(Rect2(-h, -h, h * 2.0, h * 2.0), _pal.color(&"paper_2") * tint)
	draw_set_transform(Vector2.ZERO)


func _part(n: StringName, at: Vector2, rot: float, k: float, tint: Color) -> void:
	var t: Texture2D = _tex[n]
	draw_set_transform(at * px, rot, Vector2(k, k) * px / ART_PPM)
	draw_texture(t, -t.get_size() * 0.5, tint)
	draw_set_transform(Vector2.ZERO)


## A strut part (art long axis down the page) stretched from a to b.
func _strut(n: StringName, a: Vector2, b: Vector2, tint: Color, wk: float) -> void:
	var t: Texture2D = _tex[n]
	var len_px: float = a.distance_to(b) * px
	var w: float = px / ART_PPM * wk
	draw_set_transform(
		(a + b) * 0.5 * px, (b - a).angle() - PI / 2, Vector2(w, len_px / t.get_height())
	)
	draw_texture(t, -t.get_size() * 0.5, tint)
	draw_set_transform(Vector2.ZERO)


func _visor(at: Vector2, rot: float) -> void:
	if _down() >= 0:  # the defeat: the visor stutters and dies (ServoFall.visor)
		_fall.visor(self, at, rot, _down())
		return
	if not _stage(&"windup", false):
		return
	var w: float = 6.0 if fight.locked else 3.0
	var dir: Vector2 = Vector2.from_angle(rot + PI / 2)
	var c: Vector2 = (at + dir * 0.32) * px
	var half: Vector2 = dir.orthogonal() * 0.25 * px
	draw_line(c - half, c + half, _pal.color(&"vermilion"), w)


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
	if _flash > 0:
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
