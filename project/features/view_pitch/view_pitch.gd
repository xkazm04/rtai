class_name ViewPitch
extends RefCounted
## Lane d8-view70: the per-pitch extras of a view row (data/tables/view.json, gtai.view/1) that
## ViewMode does not read (ViewMode reads `art`, the cards' folder: RigHeadCard.rows_of). The
## combined view (`combo`) adds `boss_pitch_deg` (the pitch while a boss is engaged), `boss_art`
## (the cards' folder at that pitch, p55), `ease_s` (the ease between the two), `swap_deg` (below
## it the cards draw boss_art, above it the row's `art`) and `fade_deg` (the cards cross-fade over
## this many degrees centred on swap_deg; 0 = a hard swap). Render only.

var id: String = ""
var art: String = ""
## The cards' art folder below swap_deg (combo: "p55"); "" = the base cards.
var boss_art: String = ""
var play_pitch: float = 90.0
## The pitch while a boss is engaged; equal to play_pitch for a row without one.
var boss_pitch: float = 90.0
var ease_s: float = 0.0
var swap_deg: float = 0.0
var fade_deg: float = 0.0


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
		p.boss_art = str(row.get("boss_art", ""))
		p.play_pitch = row["pitch_deg"]
		var bp: float = row.get("boss_pitch_deg", p.play_pitch)
		p.boss_pitch = bp
		var e: float = row.get("ease_s", 0.0)
		p.ease_s = e
		var s: float = row.get("swap_deg", 0.0)
		p.swap_deg = s
		var f: float = row.get("fade_deg", 0.0)
		p.fade_deg = f
	return p


## True when the row eases between a play and a boss pitch (the combined view).
func eases() -> bool:
	return not is_equal_approx(boss_pitch, play_pitch)


## How much of the row's `art` the cards draw at `pitch` (0 = boss_art's card, 1 = the art):
## 1 at or above swap_deg (a hard swap), or a smoothstep over fade_deg centred on it.
func mix_at(pitch: float) -> float:
	if art == boss_art:
		return 1.0
	if fade_deg <= 0.0:
		return 1.0 if pitch >= swap_deg else 0.0
	var t: float = clampf((pitch - swap_deg) / fade_deg + 0.5, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)


## The art folder the cards are built from at `mix` (ViewMode.art): the row's `art` from half way.
func art_at(mix: float) -> String:
	return art if mix >= 0.5 else boss_art


## The pitch `t_s` seconds into an ease of `dur_s` from `from` to `to`: smoothstep, so it leaves
## and lands with zero speed (no snap at either end); `to` once the ease is over.
static func eased(from: float, to: float, t_s: float, dur_s: float) -> float:
	if dur_s <= 0.0 or t_s >= dur_s:
		return to
	var t: float = clampf(t_s / dur_s, 0.0, 1.0)
	return lerpf(from, to, t * t * (3.0 - 2.0 * t))
