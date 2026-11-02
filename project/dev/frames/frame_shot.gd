class_name FrameShot
extends RefCounted
## One moment the frame grabber saves: a name, when it is ready (checked every tick, in play
## order) and where the camera looks (metres; Vector2.INF follows Rivet).

var name: String = ""
var ready: Callable
var focus: Callable


static func make(p_name: String, p_ready: Callable, p_focus: Callable) -> FrameShot:
	var s: FrameShot = FrameShot.new()
	s.name = p_name
	s.ready = p_ready
	s.focus = p_focus
	return s


## Quest 1's moments, in the order they happen.
static func collect_call(p: CollectCallPlay) -> Array[FrameShot]:
	var st: CollectCallStage = p.stage
	var rivet: Callable = func() -> Vector2: return Vector2.INF
	var wave: Callable = func() -> Vector2: return _crowd(p)
	var toner: Callable = func() -> Vector2:
		return st.layout.marker("The Toner Room").at + Vector2(0, 2.5)
	var duel: Callable = func() -> Vector2: return (st.arena.rivet.pos + st.arena.boss.pos) * 0.5
	var crates: Callable = func() -> Vector2: return st.layout.crates_at + Vector2(0.0, 2.0)
	var home: Callable = func() -> Vector2: return st.layout.phones["Harbor Road"] + Vector2(0, 2)
	return [
		make("01-monologue", func() -> bool: return _line(p, "rivet-line-stopped", 260), rivet),
		make("02-collect-call", func() -> bool: return _line(p, "patch-collect-call", 300), rivet),
		make("03-toner-room", func() -> bool: return _line(p, "brass-gloria", 200), toner),
		make("04-dock-wave", func() -> bool: return _wave(p), wave),
		make("05-mertz-telegraph", func() -> bool: return _telegraph(p), duel),
		make("06-crates-burning", func() -> bool: return st.burn_ticks == 90, crates),
		make("07-payphone-refusal", func() -> bool: return _refused(p), home),
		make("08-payout-call", func() -> bool: return _line(p, "fax-confirm-receipt", 300), home),
		make("09-payout", func() -> bool: return _paid(p), home),
	]


static func _line(p: CollectCallPlay, line_id: String, after_ticks: int) -> bool:
	var lines: QuestLinePlayer = p.system.runner.lines
	return (
		lines.current != null and lines.current.id == line_id and lines.current_ticks == after_ticks
	)


## Five or more contractors standing in one screen with Rivet (gameplay zoom, HUD clear).
static func _wave(p: CollectCallPlay) -> bool:
	var beat: QuestBeat = p.system.runner.current_beat()
	if beat == null or beat.id != "b4-dock":
		return false
	var c: Vector2 = _crowd(p)
	var on_screen: int = 0
	for h: Fighter in p.stage.arena.hostiles:
		on_screen += 1 if h.alive() and _visible(h.pos - c) else 0
	return on_screen >= 5 and _visible(p.stage.arena.rivet.pos - c)


## Inside the 1920x1080 frame at gameplay zoom, below the HUD panels.
static func _visible(d: Vector2) -> bool:
	return absf(d.x) < 17.0 and d.y > -5.5 and d.y < 9.5


## Halfway between Rivet and the middle of the contractors standing.
static func _crowd(p: CollectCallPlay) -> Vector2:
	var sum: Vector2 = Vector2.ZERO
	var n: int = 0
	for h: Fighter in p.stage.arena.hostiles:
		if h.alive():
			sum += h.pos
			n += 1
	var rivet: Vector2 = p.stage.arena.rivet.pos
	var c: Vector2 = rivet if n == 0 else (rivet + sum / n) * 0.5
	return Vector2(
		clampf(c.x, rivet.x - 15.0, rivet.x + 15.0), clampf(c.y, rivet.y - 4.5, rivet.y + 4.5)
	)


static func _telegraph(p: CollectCallPlay) -> bool:
	var tazer: RoboTazer = p.stage.arena.tazer
	if tazer == null or tazer.state != RoboTazer.State.CHARGING:
		return false
	return tazer.charge_frac() >= 0.6 and not p.stage.arena.balls.is_empty()


static func _refused(p: CollectCallPlay) -> bool:
	return p.stage.refusal_left == p.stage.layout.refusal_ticks - 150


static func _paid(p: CollectCallPlay) -> bool:
	return p.system.runner.state == QuestRunner.State.SUCCEEDED and p.stage.cash_phone != ""
