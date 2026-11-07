class_name HudPaper
extends RefCounted
## n8-hud: the HUD's torn memo paper (HudArt's 9-slice memo frame, the dialogue box's paper) for a
## widget drawn outside HudView (the ghost-form card). One HudArt shared by every caller.

static var _art: HudArt = null


static func draw(ci: CanvasItem, r: Rect2) -> void:
	if _art == null:
		_art = HudArt.new()
	HudView.nine(ci, _art.texture(_art.memo_art), r, _art.memo_margin_px, _art.memo_scale)
