class_name KingBodyView
extends BossView
## King from straight above, after the 90-degree panel of boss_king.jpg: phase 1 the gilded
## throne-car (a long black stretch body, gold trim and grille, the hood cannon forward, the throne
## mid-car with King under a vermilion fur-trimmed cape); phases 2-3 King on foot (squat grey
## press body, two gold press plates, the jewelled crown, the cape behind). King and the gang are
## the cutout rigs (KingRigs, a child: drawn over the car and the cape); `--boss-shapes` keeps the
## first-pass drawn shapes (A/B). The car, the cape, the coins stay drawn here.

const GOLD: Color = Color("#D9A933")
const GOLD_DARK: Color = Color("#8A6418")
const CAR_BLACK: Color = Color("#231F22")
const STEEL: Color = Color("#8E8B86")
const CAR_LEN_M: float = 6.6
const CAR_W_M: float = 2.5
const WINDUP_BACK_M: float = 0.6
## it10: 48 coins (was 30) in staggered launches over the first LAUNCH_SPREAD of the window; the
## R2 sequence constants (1/g and 1/g^2, g = 1.3247, the plastic number) scatter them in 2D.
const COINS: int = 48
const LAUNCH_SPREAD: float = 0.45
const R2_A1: float = 0.7548777
const R2_A2: float = 0.5698403
const GOLD_HI: Color = Color("#F6D678")
## View lab: the hood cannon's barrel height over the roof under a tilt (m).
const BARREL_M: float = 0.45
## The cape on the throne-car spreads near the car's width (the target's fur-trimmed fan).
const CAPE_ON_CAR_K: float = 1.3

var _rigs: KingRigs = null
## The hood cannon's swivel off the car's heading (the stalled car aims only its cannon).
var _cannon_rot: float = 0.0
## View lab: the car-local screen lift per metre of height (ZERO straight down: the flat cannon).
var _car_up: Vector2 = Vector2.ZERO


func _process(_delta: float) -> void:
	super._process(0.0)
	if fight == null:
		return
	if _rigs == null and not OS.get_cmdline_user_args().has("--boss-shapes"):
		_rigs = KingRigs.new()
		add_child(_rigs)
		var accents: KingAccents = KingAccents.new()
		accents.view = self
		accents.rigs = _rigs
		accents.z_index = KingAccents.OVER_RIG_Z  # the rig's parts carry their own z
		add_child(accents)
	if _rigs != null:
		_rigs.pose(fight, adds, _windup_px())


func _draw() -> void:
	if fight == null:
		return
	var heading: Vector2 = KingBeats.car_dir(fight) if fight.phase <= 1 else fight.body.facing
	_cannon_rot = heading.angle_to(fight.aim)
	var car_at: Vector2 = Ink.px(fight.body.pos) + _windup_px()
	if fight.phase <= 1:  # view lab: the body's stack under a tilt, the roof on top of it
		var l: float = CAR_LEN_M * Ink.PX_PER_M
		KingCarStack.draw(self, car_at, heading.angle(), l, CAR_W_M * Ink.PX_PER_M)
		car_at += ViewMode.shared().lift_at(to_global(car_at), KingCarStack.ROOF_M)
		_car_up = ViewMode.shared().lift_at(to_global(car_at), 1.0).rotated(-heading.angle())
	draw_set_transform(car_at, heading.angle(), Vector2.ONE)
	var stepping: bool = KingBeats.step_k(fight) > 0.0
	if fight.phase <= 1:  # the procession, then the court on the stalled car
		_car(not stepping)
	else:
		_on_foot()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_wreck()
	if stepping:  # the cape goes down with him
		draw_set_transform(KingBeats.king_px(fight, Vector2.ZERO), fight.body.facing.angle())
		_king(Vector2.ZERO, 1.25)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_coins()
	KingShock.draw(self, fight)
	for g: BossFight in standing_adds() if _rigs == null else []:  # first pass: drawn gang
		draw_set_transform(Ink.px(g.body.pos), g.body.facing.angle(), Vector2.ONE * 1.3)
		_gangster(Vector2.ZERO)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## The tell offset KingRigs and KingAccents share.
func windup_px() -> Vector2:
	return _windup_px()


## A charge's anticipation: through the tell the body rocks back (up to WINDUP_BACK_M against the
## aim) and shakes harder as the lock nears; render only, the sim body does not move.
func _windup_px() -> Vector2:
	var a: BossAttack = fight.attack
	if a == null or fight.state != BossFight.State.WINDUP or a.shape != BossAttack.Shape.CHARGE:
		return Vector2.ZERO
	var k: float = float(fight.t) / float(maxi(a.windup, 1))
	var shake: Vector2 = fight.aim.orthogonal() * sin(float(fight.t) * 1.9) * 2.5 * k
	return Ink.px(-fight.aim * WINDUP_BACK_M * k) + shake


## The coin fan's hail in its active window: gold coins spraying down the locked cone in staggered
## launches, scattered by the R2 low-discrepancy sequence (render only, no RNG). it10: the it2-it9
## scatter took the reach from i * 0.382, which is 1 - the angle's i * 0.618, so every coin sat on
## one diagonal arc (a thin dotted line at 48 px/m); the sheet shows a dense spray.
func _coins() -> void:
	var a: BossAttack = fight.attack
	if a == null or a.shape != BossAttack.Shape.CONE or fight.state != BossFight.State.ACTIVE:
		return
	var k: float = float(fight.t) / float(maxi(a.active, 1))
	var half: float = deg_to_rad(a.arc_deg) * 0.5
	var from: Vector2 = fight.origin
	if fight.phase <= 1:  # out of the hood cannon's muzzle (see _car / _cannon), not the car's middle
		var heading: Vector2 = KingBeats.car_dir(fight)
		from = fight.body.pos + (heading * KingCarWalls.mount_k() + fight.aim * 0.22) * CAR_LEN_M
	var span: float = maxf(a.range_m - from.distance_to(fight.origin), 0.5)
	for i: int in COINS:
		var u: float = fposmod(0.5 + float(i) * R2_A1, 1.0)
		var v: float = fposmod(0.5 + float(i) * R2_A2, 1.0)
		var launch: float = LAUNCH_SPREAD * fposmod(float(i) * 0.618034, 1.0)
		var fly: float = clampf((k - launch) / (1.0 - launch), 0.0, 1.0)
		if fly <= 0.0:
			continue
		var reach: float = fly * (0.35 + 0.65 * sqrt(v))
		var dir: Vector2 = fight.aim.rotated(-half + 2.0 * half * u)
		var at: Vector2 = Ink.px(from + dir * span * reach)
		draw_circle(at, 5.0, Ink.INK)
		draw_circle(at, 3.8, GOLD)
		draw_circle(at + Vector2(-1.2, -1.2), 1.4, GOLD_HI)


## The throne-car along +x (its nose), centred on the body.
func _car(with_king: bool = true) -> void:
	var p: float = Ink.PX_PER_M
	var l: float = CAR_LEN_M * p
	var w: float = CAR_W_M * p
	var body: Rect2 = Rect2(-l * 0.5, -w * 0.5, l, w)
	if _car_up == Vector2.ZERO:  # under a tilt KingCarStack stacks them at bumper height
		KingCarTrim.bumpers(self, l, w, p)  # rounded gold bars past both ends, under the body
	if _car_up == Vector2.ZERO or not KingCarWalls.roof(self, body):  # d8: a court pitch's roof art
		KingCarTrim.roof(self, body, p)  # black lacquer, gold trim and grille, plum panels, swags
	_cannon(Vector2(l * KingCarWalls.mount_k(), 0.0), l, _cannon_rot if with_king else 0.0)
	if _rigs == null:  # first pass: the gang at the four corners, King on the throne
		for sx: float in [-0.36, 0.3]:
			for sy: float in [-1.0, 1.0]:
				_gangster(Vector2(l * sx, sy * (w * 0.5 + 0.3 * p)))
	if with_king:
		_king(Vector2(-l * 0.08, 0.0), CAPE_ON_CAR_K)  # the cape spreads wide over the car's back
	if _car_up != Vector2.ZERO:  # view lab: the back stands up behind King
		KingCarStack.throne(self, Vector2(-l * 0.08, 0.0), p, _car_up)
	else:
		KingCarTrim.throne(self, Vector2(-l * 0.08, 0.0), p)  # the gilded back, over the cape


## The car's smoke (the stall, the court) and, from phase 3, the stalled car left where it stood.
func _wreck() -> void:
	var km: KingMoves = fight.moves as KingMoves
	var at: Vector2 = fight.body.pos
	var dir: Vector2 = fight.body.facing
	if fight.phase >= 2 and km != null and km.car_at != Vector2.INF:
		at = km.car_at
		dir = km.car_facing
		var l: float = CAR_LEN_M * Ink.PX_PER_M
		KingCarStack.draw(self, Ink.px(at), dir.angle(), l, CAR_W_M * Ink.PX_PER_M)
		var roof: Vector2 = ViewMode.shared().lift_at(to_global(Ink.px(at)), KingCarStack.ROOF_M)
		draw_set_transform(Ink.px(at) + roof, dir.angle(), Vector2.ONE)
		_car_up = ViewMode.shared().lift_at(to_global(Ink.px(at)), 1.0).rotated(-dir.angle())
		_car(false)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var hood: Vector2 = Ink.px(at + dir * CAR_LEN_M * 0.36)
	var drift: Vector2 = (-dir + dir.orthogonal() * 0.35).normalized()
	KingBeats.smoke(self, hood, drift, fight.now(), KingBeats.smoke_amount(fight))


## The hood cannon about its mount `p` (car px), swivelled `rot` off the car's nose.
func _cannon(p: Vector2, l: float, rot: float) -> void:
	var a: Vector2 = Vector2.from_angle(rot)
	var tail: Vector2 = p - a * l * 0.08
	var tip: Vector2 = p + a * l * 0.22
	if _car_up != Vector2.ZERO:  # view lab: a barrel on a mount, BARREL_M above the roof
		_cannon_raised(p, tail, tip, a.orthogonal() * 10.0)
		return
	KingCarTrim.cannon(self, tail, tip)


## Under a tilt: the barrel's shadow on the roof, the mount post, then KingCarTrim's barrel lifted.
func _cannon_raised(p: Vector2, tail: Vector2, tip: Vector2, n: Vector2) -> void:
	var up: Vector2 = _car_up * BARREL_M
	var quad: PackedVector2Array = PackedVector2Array([tail - n, tip - n, tip + n, tail + n])
	draw_colored_polygon(quad, Ink.INK)  # its shadow on the roof
	draw_circle(p, 12.0, Ink.INK)
	draw_circle(p + up * 0.5, 10.0, GOLD_DARK)  # the mount post
	KingCarWalls.cannon(self, tail + up, tip + up)  # lifted: the art barrel, else KingCarTrim's


## King on foot: the squat press body, plates out to the sides, cape behind.
func _on_foot() -> void:
	var lunge: float = 0.0
	if fight.state == BossFight.State.WINDUP:
		lunge = -0.25 * (1.0 - float(fight.tell_left()) / float(maxi(fight.attack.windup, 1)))
	var b: Fighter = fight.body
	var up: Vector2 = ViewMode.shared().lift_at(to_global(Ink.px(b.pos)), 1.0)
	_king(Vector2(lunge * Ink.PX_PER_M, 0.0), 1.25, up.rotated(-b.facing.angle()))


## `up` = the local lift per metre of height (ZERO straight down: the cape lies flat).
func _king(at: Vector2, k: float, up: Vector2 = Vector2.ZERO) -> void:
	var p: float = Ink.PX_PER_M * k
	KingCape.draw(self, at, p, fight, up)  # vermilion, folded, ermine; drapes under a tilt
	if _rigs != null:  # the rig is King's body; the cape spreads under it
		return
	draw_circle(at, 0.62 * p, Ink.INK)
	draw_circle(at, 0.56 * p, STEEL)
	for sy: float in [-1.0, 1.0]:  # the gold press plates
		var plate: Rect2 = Rect2(at + Vector2(-0.1, sy * 0.62 - 0.22) * p, Vector2(0.62, 0.44) * p)
		draw_rect(plate.grow(3.0), Ink.INK)
		draw_rect(plate, GOLD)
	draw_arc(at, 0.4 * p, -2.4, 2.4, 16, GOLD, 0.1 * p)  # the gold chains
	_crown(at, 0.3 * p)


func _crown(at: Vector2, r: float) -> void:
	var pts: Array[Vector2] = []
	for i: int in 10:
		var rr: float = r if i % 2 == 0 else r * 0.62
		pts.append(at + Vector2.from_angle(TAU * float(i) / 10.0) * rr)
	var poly: PackedVector2Array = PackedVector2Array(pts)
	draw_colored_polygon(poly, GOLD)
	draw_polyline(poly + PackedVector2Array([pts[0]]), Ink.INK, 2.0)
	draw_circle(at, r * 0.3, Ink.VERMILION.darkened(0.15))


func _gangster(at: Vector2) -> void:
	var p: float = Ink.PX_PER_M
	draw_circle(at, 0.36 * p, Ink.INK)
	draw_circle(at, 0.31 * p, STEEL)
	draw_rect(Rect2(at + Vector2(0.06, -0.2) * p, Vector2(0.12, 0.4) * p), Ink.INK)  # shades
	draw_arc(at, 0.22 * p, 1.2, 5.1, 10, GOLD, 4.0)  # gold chain
