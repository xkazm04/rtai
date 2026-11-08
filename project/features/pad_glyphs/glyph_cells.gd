class_name GlyphCells
extends RefCounted
## n9-handheld: the two drawn glyph sets PadGlyphArt can draw, each an atlas + its ink-box json +
## the prompt label -> cell map. `pad` (ui_pad_glyphs_v1) on the handheld rows; `kb`
## (ui_kb_glyphs_v1, the keyboard and mouse twin) only on a row with `glyphs: kb` (a desktop study
## row: the shipped desktop keeps its bracketed text).

const PAD: StringName = &"pad"
const KB: StringName = &"kb"
const ATLAS_PNG: Dictionary[StringName, String] = {
	&"pad": "res://features/pad_glyphs/ui_pad_glyphs_v1.png",
	&"kb": "res://features/pad_glyphs/ui_kb_glyphs_v1.png",
}
const ATLAS_JSON: Dictionary[StringName, String] = {
	&"pad": "res://features/pad_glyphs/ui_pad_glyphs_v1.json",
	&"kb": "res://features/pad_glyphs/ui_kb_glyphs_v1.json",
}
## The prompt's pad label (PadGlyphs.label: Xbox, PlayStation or Nintendo names) -> its cell.
const PAD_CELL: Dictionary[String, String] = {
	"A": "face_a",
	"B": "face_b",
	"X": "face_x",
	"Y": "face_y",
	"Cross": "face_cross",
	"Circle": "face_circle",
	"Square": "face_square",
	"Triangle": "face_triangle",
	"LB": "lb",
	"RB": "rb",
	"LT": "lt",
	"RT": "rt",
	"L1": "l1",
	"R1": "r1",
	"L2": "l2",
	"R2": "r2",
	"L": "l",
	"R": "r",
	"ZL": "zl",
	"ZR": "zr",
	"Back": "select",
	"Create": "select",
	"-": "select",
	"Start": "start",
	"Options": "start",
	"+": "start",
	"L3": "stick_l3",
	"R3": "stick_r3",
	"L-stick": "move_stick_l",
	"R-stick": "aim_stick_r",
}
## The prompt's key label (ObjectiveHint.key_name: OS.get_keycode_string, LMB / RMB; with_keys'
## "W A S D" and "mouse") -> its cell.
const KB_CELL: Dictionary[String, String] = {
	"W A S D": "move_keys",
	"Up Left Down Right": "move_arrows",
	"mouse": "aim_mouse",
	"LMB": "mouse_left",
	"RMB": "mouse_right",
	"A": "key_a",
	"D": "key_d",
	"E": "key_e",
	"F": "key_f",
	"G": "key_g",
	"P": "key_p",
	"Q": "key_q",
	"R": "key_r",
	"S": "key_s",
	"W": "key_w",
	"1": "key_1",
	"2": "key_2",
	"3": "key_3",
	"4": "key_4",
	"Up": "key_up",
	"Down": "key_down",
	"Left": "key_left",
	"Right": "key_right",
	"Escape": "key_esc",
	"Esc": "key_esc",
	"Space": "key_space",
	"Shift": "key_shift",
	"Ctrl": "key_ctrl",
	"Tab": "key_tab",
}


static func cell_map(glyph_set: StringName) -> Dictionary[String, String]:
	return KB_CELL if glyph_set == KB else PAD_CELL
