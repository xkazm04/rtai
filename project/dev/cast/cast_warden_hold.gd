class_name CastWardenHold
extends Node
## Runs after the rigs' _process: holds the card on fall row 0 ("row0") or hidden ("off").

var card: Sprite2D
var mode: String = ""
var _hid: bool = false


func _init() -> void:
	process_priority = 1000


func _process(_delta: float) -> void:
	if card == null:
		return
	if _hid:
		card.visible = true
		card.self_modulate.a = 1.0
		_hid = false
	if mode == "off":
		card.visible = false
		card.self_modulate.a = 0.0
		_hid = true
		return
	if mode.is_empty():
		return
	card.visible = true
	card.self_modulate.a = 1.0
	card.frame_coords = Vector2i(card.frame_coords.x, 0)
