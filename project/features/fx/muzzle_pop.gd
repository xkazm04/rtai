class_name MuzzlePop
extends Node2D
## The muzzle "lights the scene for one frame" in the D4/D5 game (lane d5-combat; noir's
## MuzzleFlash.lit, which drops noir's threshold, has no D4/D5 twin): a round fired (the `shot`
## cue) throws a soft pool of paper light, blended ADD over the world, the print and the bodies
## (the actors canvas's fx band), for exactly one sim tick. The fx.json paper star and the
## lights.json muzzle cone are untouched; this is the pop around them. Photosensitivity: at most
## one pop per lit_gap_ticks however many rounds fly, and every pop spends a light from the
## shared FlashBudget (the kill beat's), which keeps a beat's cost free and is off under reduced
## motion (no pop at all). Data: blood_fx.json game.muzzle_pop. Stepped on the sim tick. Render
## only.

var budget: FlashBudget = null
var radius_px: float = 160.0
var strength: float = 0.32
var lit_gap: int = 20
## Only a round within near_m of the camera focus pops (an off-screen pop would spend the budget).
var near_m: float = 12.0
## Pops shown, and shots that found the gap or the budget spent (evidence).
var pops: int = 0
var held: int = 0
## The ticks and places (px) of the first pops (evidence: shoot a still at one of them).
var pop_ticks: PackedInt32Array = PackedInt32Array()
var pop_at: PackedVector2Array = PackedVector2Array()
var _tex: GradientTexture2D = GradientTexture2D.new()
var _pending: Vector2 = Vector2.INF
var _triggers: FxTriggers = null
var _since: int = 1 << 20
var _tick: int = -1


func _init(row: Dictionary = {}) -> void:
	z_index = RenderLayers.z(&"fx")
	var radius_m: float = row.get("radius_m", 5.0)
	radius_px = radius_m * SimConst.PX_PER_M
	strength = row.get("strength", strength)
	lit_gap = row.get("lit_gap_ticks", lit_gap)
	near_m = row.get("near_m", near_m)
	var mat: CanvasItemMaterial = CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat
	var paper: Color = PaletteTokens.shared().color(&"paper")
	var g: Gradient = Gradient.new()  # stepped bands, like the D4 lights (lights.json steps)
	g.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	g.set_color(0, Color(paper, 1.0))
	g.set_color(1, Color(paper, 0.0))
	g.add_point(0.3, Color(paper, 0.55))
	g.add_point(0.62, Color(paper, 0.22))
	g.add_point(0.96, Color(paper, 0.0))
	_tex.gradient = g
	_tex.fill = GradientTexture2D.FILL_RADIAL
	_tex.fill_from = Vector2(0.5, 0.5)
	_tex.fill_to = Vector2(1.0, 0.5)
	_tex.width = 128
	_tex.height = 128
	visible = false


## Follows `triggers`' cues (`shot` asks for a pop).
func attach(triggers: FxTriggers) -> void:
	_triggers = triggers
	@warning_ignore("return_value_discarded")
	triggers.cued.connect(_on_cue)


## Advances to sim tick `tick` (once a frame): the lit tick ends, a waiting shot may pop.
func step(tick: int) -> void:
	var n: int = tick - _tick if _tick >= 0 else 0
	_tick = tick
	if n > 0:
		_since += n
		visible = false
	if _pending == Vector2.INF:
		return
	var at: Vector2 = _pending
	_pending = Vector2.INF
	if _since < lit_gap or (budget != null and not budget.spend_light()):
		held += 1
		return
	_since = 0
	position = at
	visible = true
	pops += 1
	if pop_ticks.size() < 32:
		@warning_ignore("return_value_discarded")
		pop_ticks.append(tick)
		@warning_ignore("return_value_discarded")
		pop_at.append(at)
	queue_redraw()


## True while the pop is lit (one tick).
func lit() -> bool:
	return visible


func _on_cue(id: StringName, pos_px: Vector2, _angle: float, _tick_at: int) -> void:
	if id != &"shot":
		return
	var focus: Vector2 = _triggers.focus_px if _triggers != null else pos_px
	if pos_px.distance_to(focus) > near_m * SimConst.PX_PER_M:
		return
	if _pending == Vector2.INF or pos_px.distance_to(focus) < _pending.distance_to(focus):
		_pending = pos_px


func _draw() -> void:
	var r: float = radius_px
	draw_texture_rect(_tex, Rect2(-r, -r, 2.0 * r, 2.0 * r), false, Color(1, 1, 1, strength))
