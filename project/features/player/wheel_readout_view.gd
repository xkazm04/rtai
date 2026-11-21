class_name WheelReadoutView
extends Node2D
## The current wheel beside the weapon ticket for one simulation second after a switch.

const PAD: float = 8.0
const FONT_PX: int = 20
const ROW_H: float = 28.0
const HOLD_TICKS: int = roundi(0.6 * SimClock.TICK_RATE)
const FADE_TICKS: int = SimClock.TICK_RATE - HOLD_TICKS

var _hud: HudView
var _arena: CombatArena
var _wheel: RivetWheel
var _text: QuestText = QuestText.new()


static func attach(hud: HudView, stage: CollectCallStage) -> void:
	if stage == null or stage.pilot == null or stage.pilot.wheel == null:
		return
	var view: WheelReadoutView = WheelReadoutView.new()
	view._hud = hud
	view._arena = stage.arena
	view._wheel = stage.pilot.wheel
	view.visible = false
	hud.add_sibling(view)


func _process(_delta: float) -> void:
	var age: int = _arena.tick - _wheel.switched_tick
	modulate.a = clampf(1.0 - float(age - HOLD_TICKS) / FADE_TICKS, 0.0, 1.0)
	visible = _wheel.switched_tick >= 0 and age >= 0 and modulate.a > 0.0
	if visible:
		queue_redraw()


func _draw() -> void:
	var screen: Vector2 = get_viewport_rect().size
	var ticket: Rect2 = HudWeaponSlot.box_of(screen, _hud.dialogue.showing())
	var ids: Array[StringName] = _wheel.order()
	var names: PackedStringArray = PackedStringArray()
	var font: Font = ThemeDB.fallback_font
	var width: float = 0.0
	for id: StringName in ids:
		var key: StringName = StringName("WEAPON__%s" % QuestText.symbol(id))
		var label: String = _text.resolve(key, String(id).replace("-", " ").capitalize())
		@warning_ignore("return_value_discarded")
		names.append(label)
		width = maxf(width, font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX).x)
	var size: Vector2 = Vector2(width + PAD * 4.0, ROW_H * ids.size() + PAD * 2.0)
	var at: Vector2 = Vector2(ticket.position.x - PAD * 3.0 - size.x, ticket.end.y - size.y)
	if not HudWeaponSlot.on():
		at.y = HudView.MARGIN
	at = at.max(Vector2.ONE * PAD)
	draw_rect(Rect2(at, size), HudArt.INK)
	for i: int in ids.size():
		var row: Vector2 = at + Vector2(PAD, PAD + i * ROW_H)
		var active: bool = ids[i] == _wheel.selected()
		if active:
			draw_rect(
				Rect2(row, Vector2(size.x - 2.0 * PAD, ROW_H)), HudArt.INK.lerp(Ink.CREAM, 0.2)
			)
			draw_rect(Rect2(row, Vector2(4.0, ROW_H)), Ink.CREAM)
		draw_string(
			font,
			row + Vector2(PAD, FONT_PX),
			names[i],
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			FONT_PX,
			Color.WHITE if active else Ink.CREAM
		)
