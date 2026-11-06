class_name ViewPitch
extends RefCounted
## Lane d8-view70: the per-pitch extras of a view row (data/tables/view.json, gtai.view/1) that
## ViewMode does not read. `art` names the folder of the card art drawn for this pitch
## (features/characters/art/view/<art>/, a card missing there falls back to the base card), so
## the 55 and 70 art live side by side and a row picks one. The combined view (`combo`) adds
## `boss_pitch_deg` (the pitch while a boss is engaged), `ease_s` (the ease between the two) and
## `swap_deg` (below it the cards draw the base art, above it the row's `art`). Render only.

const ART_DIR: String = "res://features/characters/art/view/"

var id: String = ""
var art: String = ""
var play_pitch: float = 90.0
## The pitch while a boss is engaged; equal to play_pitch for a row without one.
var boss_pitch: float = 90.0
var ease_s: float = 0.0
var swap_deg: float = 0.0


## The extras of the view row `want` (ViewMode.of reads the same table).
static func of(want: String) -> ViewPitch:
	var p: ViewPitch = ViewPitch.new()
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(ViewMode.TABLE)) != OK:
		return p
	var d: Dictionary = parser.data
	for row: Dictionary in d["views"]:
		if str(row["id"]) != want:
			continue
		p.id = want
		p.art = str(row.get("art", ""))
		p.play_pitch = row["pitch_deg"]
		var bp: float = row.get("boss_pitch_deg", p.play_pitch)
		p.boss_pitch = bp
		var e: float = row.get("ease_s", 0.0)
		p.ease_s = e
		var s: float = row.get("swap_deg", 0.0)
		p.swap_deg = s
	return p


## True when the row eases between a play and a boss pitch (the combined view).
func eases() -> bool:
	return not is_equal_approx(boss_pitch, play_pitch)


## The art folder the cards draw at `pitch`: the row's `art` at or above swap_deg, else the base.
func art_at(pitch: float) -> String:
	return art if pitch >= swap_deg else ""


## The card strip `base` (a RigHeadCard.CARDS path) drawn from the art folder `folder`, or `base`
## itself when the folder is "" or holds no such card.
static func card_path(base: String, folder: String) -> String:
	if folder.is_empty() or not base.begins_with(ART_DIR):
		return base
	var p: String = ART_DIR + folder + "/" + base.get_file()
	return p if ResourceLoader.exists(p) else base


## The pitch `t_s` seconds into an ease of `dur_s` from `from` to `to`: smoothstep, so it leaves
## and lands with zero speed (no snap at either end); `to` once the ease is over.
static func eased(from: float, to: float, t_s: float, dur_s: float) -> float:
	if dur_s <= 0.0 or t_s >= dur_s:
		return to
	var t: float = clampf(t_s / dur_s, 0.0, 1.0)
	return lerpf(from, to, t * t * (3.0 - 2.0 * t))
