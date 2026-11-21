class_name GauntletPilot
extends InputSource
## For --bot the scene loads res://features/gauntlet/bot/gauntlet_bot.gd when it exists,
## otherwise GauntletWalker. Both extend this class and have a zero-argument constructor.
## configure(profile, pick_policy, seed) precedes bind(run, session), then sample(tick) drives
## the session and pick(offered) returns an index into the offer. Without --bot input is live.
## At wave close, wave_counters() supplies guard_deflects and optional rolls/form_seconds
## when the street has no measurement. reset_wave_counters() then starts a fresh interval.

var _profile: StringName = &"average"
var _pick_policy: StringName = &"random"
var _pick_rng: RandomNumberGenerator = RngRegistry.new(0).stream(&"gauntlet_picks")


func configure(p_profile: StringName, pick_policy: StringName, seed: int) -> void:
	_profile = p_profile
	_pick_policy = pick_policy
	_pick_rng = RngRegistry.new(seed).stream(&"gauntlet_picks")


func bind(_run: GauntletRun, _session: ArenaSession) -> void:
	pass


func pick(offered: Array[StringName]) -> int:
	if offered.is_empty():
		return -1
	return _pick_rng.randi_range(0, offered.size() - 1) if _pick_policy == &"random" else 0


func profile() -> StringName:
	return _profile


func wave_counters() -> Dictionary:
	return {}


func reset_wave_counters() -> void:
	pass
