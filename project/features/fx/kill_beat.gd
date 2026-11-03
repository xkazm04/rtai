class_name KillBeat
extends Node
## The comic kill beat in the D4/D5 game (lane d5-combat), an owner A/B behind
## `-- --kill-beat=off|panel|flash|both` (blood_fx.json game.kill_beat, default off): noir's
## ImpactFrame on the `beat` canvas (above the world UI, under the HUD) when Rivet kills (the
## `rivet_kill` cue). flash = the silhouette-on-speed-lines frames (look_noir.params.json
## impact.sequence: the world and its print hidden, every actor solid ink, blood red); panel =
## the kill held in a comic panel with paper gutters (impact.panel_ticks); both = flash, then
## panel. Photosensitivity: every beat spends from noir's shared FlashBudget (at most 3 flashes
## a second, BEAT_COST 2) and turns calm (a thin border, no flash) when it is spent; reduced
## motion (`-- --reduced-motion`) disables the budget, so no beat ever flashes. Stepped on the
## sim tick (the silhouette holds through the kill hit-stop as one flash); a cue fired between
## steps waits for the next step (ImpactFrame wants step_ticks before fire). Render only.

const MODES: PackedStringArray = ["off", "panel", "flash", "both"]

var mode: String = "off"
var impact: ImpactFrame = ImpactFrame.new()
## Beats fired and how many of them were calm (budget spent or reduced motion).
var beats: int = 0
var calm_beats: int = 0
## Callable(px: Vector2) -> Vector2: world px to screen uv (the burst centre); none = centre.
var to_uv: Callable = Callable()
var _pending: Vector2 = Vector2.INF
var _tick: int = -1


func _init(fallback: String = "off") -> void:
	var want: String = LaunchArgs.value("--kill-beat")
	mode = want if MODES.has(want) else fallback
	impact.layer = RenderLayers.canvas(&"beat")
	if mode == "panel":
		impact.sequence = PackedInt32Array()
	elif mode == "flash":
		impact.panel_ticks = 0
	impact.budget.enabled = not LaunchArgs.has("--reduced-motion")
	add_child(impact)


## Follows `triggers`' cues (rivet_kill starts a beat).
func attach(triggers: FxTriggers) -> void:
	@warning_ignore("return_value_discarded")
	triggers.cued.connect(_on_cue)


## The nodes the silhouette frames hide (the world canvas and its print pass).
func hide_on_flash(nodes: Array[Node]) -> void:
	impact.hide_on_flash = nodes


## No flash at all (the accessibility setting): every beat is the calm one.
func set_reduced_motion(on: bool) -> void:
	impact.budget.enabled = not on


## Advances the beat to sim tick `tick` (once a frame), then starts a waiting one.
func step(tick: int) -> void:
	var n: int = tick - _tick if _tick >= 0 else 0
	_tick = tick
	if n > 0:
		impact.step_ticks(n)
	if _pending == Vector2.INF:
		return
	var at: Vector2 = _pending
	_pending = Vector2.INF
	if mode == "off" or not impact.can_fire():
		return
	var uv: Vector2 = Vector2(0.5, 0.5)
	if to_uv.is_valid():
		uv = to_uv.call(at)
	impact.fire(uv)
	beats += 1
	calm_beats += 1 if impact.calm() else 0


func _on_cue(id: StringName, pos_px: Vector2, _angle: float, _tick_at: int) -> void:
	if id == &"rivet_kill" and mode != "off":
		_pending = pos_px
