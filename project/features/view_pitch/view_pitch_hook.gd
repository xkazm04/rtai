extends ArenaHook
## Lane d8-view70 (data/tables/arena_stations/view-pitch.json, station-only): under the combined
## view (combo) a ViewPitchEase on the dev view eases the pitch to the boss pitch while a boss
## fight is live, swaps the cards' art folder and cross-fades them (ViewPitchCards; a fixed-pitch
## row's `art` is drawn by RigHeadCard itself); live = Events.boss_engaged until the boss is
## defeated. Nothing is written to the sim or the replay hash; straight down (`top`) it
## does nothing at all.

var _pitch: ViewPitch = null
var _clock: SimClock = null
var _stage: ArenaStage = null
var _engaged: bool = false


func setup(stage: ArenaStage, ctx: WorldContext) -> void:
	var view: ViewMode = ViewMode.shared()
	if view.is_flat():
		return
	_pitch = ViewPitch.of(String(view.id))
	_stage = stage
	_clock = ctx.clock
	if _pitch.eases():
		var err: Error = ctx.events.boss_engaged.connect(_on_engaged)
		assert(err == OK)


func attach_view(view: Node) -> void:
	if _pitch == null or not (_pitch.eases() or ViewPitchCourt.dresses(_pitch.art)):
		return
	var ease: ViewPitchEase = ViewPitchEase.new()
	ease.name = &"view_pitch_ease"
	ease.pitch = _pitch
	ease.clock = _clock
	ease.boss_on = boss_on
	view.add_child(ease)


## A boss engaged and not yet defeated: a BossHook's live fight (it engages in its own setup,
## before this hook listens), else an arena boss announced on Events.boss_engaged.
func boss_on() -> bool:
	if _stage == null:
		return false
	for h: ArenaHook in _stage.hooks:
		if h is BossHook and (h as BossHook).fight != null:
			return (h as BossHook).fight.state != BossFight.State.DEFEATED
	return _engaged


func _on_engaged(_boss: StringName) -> void:
	_engaged = true
