class_name ArenaHud
extends Control
## The arena's live telemetry, top left in screen space (dev overlay): the station Rivet stands
## in, the zoom, shots / hits / hit rate, the mean time to kill, input-to-motion latency (sim
## ticks), the peak turn rate, top speed, damage taken, the pit (wave, kills, dodges,
## deaths), and the dev keys. Reads, never writes.

const FONT_PX: int = 18
const LINE_PX: float = 22.0
const PAD: Vector2 = Vector2(16.0, 28.0)

var session: ArenaSession = null
var px_per_m: float = 32.0
var note: String = ""


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if session == null:
		return
	var lines: Array[String] = text_lines()
	var box: Rect2 = Rect2(Vector2(8, 8), Vector2(470.0, LINE_PX * lines.size() + 24.0))
	draw_rect(box, Color(Ink.CREAM, 0.88), true)
	draw_rect(box, Ink.INK, false, 2.0)
	var font: Font = ThemeDB.fallback_font
	for i: int in lines.size():
		var at: Vector2 = PAD + Vector2(0.0, LINE_PX * i)
		draw_string(font, at, lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX, Ink.INK)


func text_lines() -> Array[String]:
	var st: ArenaStage = session.stage
	var t: ArenaTelemetry = st.telemetry
	var out: Array[String] = [
		tr("ARENA  %s  |  %d px/m  |  tick %d") % [area_name(), roundi(px_per_m), st.tick],
		tr("shots %d   hits %d   hit rate %d%%") % [t.shots, t.hits, roundi(t.hit_rate() * 100)],
		tr("time to kill (mean) %s") % _ttk(),
		tr("input to motion %s ticks (sim)") % _latency(t),
		tr("turn peak %d deg/s   top speed %.1f m/s") % [roundi(t.turn_dps_peak), t.top_speed_mps],
		tr("damage taken %.1f   knockdowns %d") % [t.damage_taken, t.knockdowns],
		tr("pit wave %d   kills %d   dodges %d   deaths %d") % _pit(t),
		tr("F1 panel   T teleport   Z zoom   F6 save telemetry"),
	]
	if note != "":
		out.append(note)
	return out


## The plan area Rivet stands in ("" outside every area).
func area_name() -> String:
	var p: Vector2 = session.stage.arena.rivet.pos
	for a: ArenaPlan.Area in session.plan.areas:
		if a.rect.has_point(p):
			return a.name
	return "-"


func _ttk() -> String:
	var n: int = 0
	var sum: float = 0.0
	for id: String in session.stage.targets.ttk_s:
		for v: Variant in session.stage.targets.ttk_s[id]:
			sum += v if v is float else 0.0
			n += 1
	return "%.2f s over %d" % [sum / n, n] if n > 0 else "-"


func _latency(t: ArenaTelemetry) -> String:
	var m: float = t.latency_mean()
	return "%.1f" % m if m >= 0.0 else "-"


func _pit(t: ArenaTelemetry) -> Array[int]:
	return [t.pit_waves, t.pit_kills, t.dodges, t.deaths]
