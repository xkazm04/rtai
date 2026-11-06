class_name PickupsView
extends Node2D
## rivet-arsenal: the guns on the ground (RivetCarry.ground) in the print: weapon-art's pickup
## side view on a paper disc with an ink ring, slowly turning so it reads as loot, not decor.
## Render only: reads the sim each frame, writes nothing back.
## n5-look (r2_w8): the loot ring is a dashed paper ring over a faint paper wash, the gun on the
## ground inside it, instead of an opaque paper disc. d7-calls look-7 (owner, 2026-11-05): the
## opaque paper disc is the default again; `--pickup-disc=off` = the dashed ring.

const DISC_M: float = 0.55
const RING_PX: float = 2.0
const TURN_RAD_S: float = 0.6
const DASHES: int = 14
## The dash's share of its step round the ring, and the wash's alpha under the gun.
const DASH_K: float = 0.6
const WASH_A: float = 0.2
## d8-weapons: under a tilt the gun hovers over its disc (HOVER_M up, bobbing BOB_M), stood up for
## the raised camera (its side view un-squashed), with an ink shadow on the disc: loot at a
## glance under the angle. Straight down nothing moves (the flat path). `--shot-lift=off` = before.
const HOVER_M: float = 0.35
const BOB_M: float = 0.05
const BOB_RAD_S: float = 2.4
const SHADOW_A: float = 0.3
static var disc: bool = not OS.get_cmdline_user_args().has("--pickup-disc=off")

var carry: RivetCarry = null
## n8-hud: a showcase drawing (WeaponShowcase, keyed by the view's art) is drawn for its camera:
## stood up, never spun; `--pickup-hover=off` lays it on the disc (the owner's open hover call).
var hover: bool = LaunchArgs.value("--pickup-hover") != "off"
var art: WeaponArt = WeaponArt.new()
var showcase: WeaponShowcase = WeaponShowcase.new()
var _sprites: Array[Sprite2D] = []
var _shown: Array[StringName] = []
var _form: String = ""
var _drawn: Array[bool] = []
var _paper: Color = PaletteTokens.shared().color(&"paper")
var _ink: Color = PaletteTokens.shared().color(&"ink")
var _t: float = 0.0
var _outline: float = PickupLook.outline_px(art.pickup_outline_px)


func _process(_delta: float) -> void:
	_t += SimClock.TICK_DT  # a render frame's turn step (the view runs at the sim's 60 Hz)
	var items: Array[WeaponPickups.Item] = carry.ground.items if carry != null else []
	var ids: Array[StringName] = []
	for it: WeaponPickups.Item in items:
		ids.append(it.id)
	var form: String = WeaponShowcase.form_of(ViewMode.shared())
	if ids != _shown or form != _form:
		_form = form
		_rebuild(ids)
	var stand: bool = ShotLift.up_m() != Vector2.ZERO
	for i: int in items.size():
		_sprites[i].position = items[i].pos * SimConst.PX_PER_M
		_sprites[i].rotation = sin(_t * TURN_RAD_S + i) * 0.5
		if stand:
			_stand(_sprites[i], i)
	queue_redraw()


## Under a tilt: lift the gun HOVER_M (+ a bob) and stand its side view up (screen y undone).
func _stand(s: Sprite2D, i: int) -> void:
	var v: ViewMode = ViewMode.shared()
	if _drawn[i]:  # n8-hud: the showcase drawing already faces this camera
		s.rotation = 0.0
		if hover:
			s.position += v.lift_px(hover_m(_t, i))
		s.scale.y = s.scale.x / v.ground_k()
		return
	s.position += v.lift_px(hover_m(_t, i))
	s.rotation *= 0.5  # the sway, not a spin: a standing card turned far reads as a shear
	s.scale.y = s.scale.x / v.ground_k()


## The gun's height over its disc at view time `t` (s) for item `i` (render only, no RNG).
static func hover_m(t: float, i: int) -> float:
	return HOVER_M + BOB_M * sin(t * BOB_RAD_S + float(i) * 1.7)


func _draw() -> void:
	if carry == null:
		return
	var r: float = DISC_M * SimConst.PX_PER_M
	for it: WeaponPickups.Item in carry.ground.items:
		var at: Vector2 = it.pos * SimConst.PX_PER_M
		if disc:
			draw_circle(at, r, _paper)
			draw_arc(at, r, 0.0, TAU, 32, _ink, RING_PX, true)
		else:
			_dashed(at, r)
		if ShotLift.up_m() != Vector2.ZERO:  # d8-weapons: the hovering gun's shadow on the disc
			draw_circle(at, r * 0.45, Color(_ink, SHADOW_A))


## r2_w8's loot ring: a faint paper wash and a ring of paper dashes.
func _dashed(at: Vector2, r: float) -> void:
	draw_circle(at, r, Color(_paper, WASH_A))
	var step: float = TAU / float(DASHES)
	for k: int in DASHES:
		var a0: float = step * float(k)
		draw_arc(at, r, a0, a0 + step * DASH_K, 4, _paper, RING_PX, true)


func _rebuild(ids: Array[StringName]) -> void:
	for s: Sprite2D in _sprites:
		s.queue_free()
	_sprites.clear()
	_drawn.clear()
	for id: StringName in ids:
		var s: Sprite2D = Sprite2D.new()
		s.texture = showcase.texture(id, _form)
		_drawn.append(s.texture != null)
		if s.texture == null:
			s.texture = art.pickup_texture(id) if art.has(id) else null
		var w: float = s.texture.get_width() if s.texture != null else 1.0
		var span_m: float = maxf(art.length_m(id), art.pickup_min_span_m)  # r2_w8: fills the ring
		s.scale = Vector2.ONE * span_m * SimConst.PX_PER_M / maxf(w, 1.0)
		PickupLook.dress(s, _outline)  # flat fills in ink (--pickup-print=on = before)
		add_child(s)
		_sprites.append(s)
	_shown = ids
