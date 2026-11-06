class_name ViewPitchEase
extends Node
## Lane d8-view70, the combined view (view.json `combo`): each frame the camera's pitch eases
## between the row's play pitch (70) and its boss pitch (55) while `boss_on` says a boss is
## engaged, written into the shared ViewMode, so the camera zoom, the lifts, the cards and the
## mouse's ground point (ViewMode.ground_of) all follow the live pitch. The ease runs on sim
## ticks: a hit-stop holds the clock, so it holds the ease too. The cards swap their art folder at
## the row's swap_deg (ViewPitchCards). View only: it reads the sim and never writes to it.

var pitch: ViewPitch = null
var clock: SimClock = null
## () -> bool: a boss is engaged now.
var boss_on: Callable = Callable()
var _boss: bool = false
var _from: float = 0.0
var _since: int = 0


func _ready() -> void:
	_from = pitch.play_pitch


func _process(_delta: float) -> void:
	if pitch == null or clock == null:
		return
	var boss: bool = boss_on.is_valid() and boss_on.call() == true
	ViewMode.shared().pitch_deg = step(clock.tick(), boss)
	var art: String = pitch.art_at(ViewMode.shared().pitch_deg)
	if art != ViewPitchCards.current():
		Log.info("view", "cards -> '%s' at tick %d" % [art, clock.tick()])
	ViewPitchCards.apply(get_parent(), art)


## The pitch at `tick` with the boss engaged or not: a change of target starts a new ease from
## wherever the pitch is now (a boss down mid-ease turns back without a jump).
func step(tick: int, boss: bool) -> float:
	var now: float = ViewMode.shared().pitch_deg
	if boss != _boss:
		_boss = boss
		_from = now
		_since = tick
		Log.info(
			"view", "pitch ease %.1f -> %s at tick %d" % [now, "boss" if boss else "play", tick]
		)
	var to: float = pitch.boss_pitch if _boss else pitch.play_pitch
	return ViewPitch.eased(_from, to, float(tick - _since) * SimClock.TICK_DT, pitch.ease_s)
