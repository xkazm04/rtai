class_name BotForms
extends RefCounted
## GhostPilot decodes press edges. In base G cycles, Q enters the selected form.
## Exit to base before selecting a different form to avoid activating intervening powers.

const HEAVY_M: float = 4.0
const KERF_M: float = 9.0
const OHM_M: float = 11.0
const CLUSTER_M: float = 3.0
const DENT_M: float = 7.0

var _rng: RandomNumberGenerator
var _last_candidate: StringName = &""
var _last_target: int = -1
var _accepted: bool = false
var _seeking_tonnage: bool = false


func _init(registry: RngRegistry) -> void:
	_rng = registry.stream(&"test_player_forms")


func desired(
	view: BotView, target: BotView.Hostile, chance: float, emergency: StringName
) -> StringName:
	var me: BotView.Player = view.player()
	if me.form == &"tonnage" or not me.forms.has(&"tonnage"):
		_seeking_tonnage = false
	elif emergency == &"tonnage" or _heavy_near(view):
		_seeking_tonnage = true
	if _seeking_tonnage:
		return &"tonnage"
	var candidate: StringName = _offensive(view, target)
	var id: int = target.id if target != null else -1
	if candidate != _last_candidate or id != _last_target:
		_last_candidate = candidate
		_last_target = id
		_accepted = candidate != &"" and _rng.randf() < chance
	return candidate if _accepted else &""


static func transform(me: BotView.Player, want: StringName) -> StringName:
	if want == &"base" and me.form != &"base" and me.settled:
		return &"power_hauler"
	if want == &"" or not me.settled or me.form == want or not me.forms.has(want):
		return &""
	if me.form != &"base" or me.selected == want:
		return &"power_hauler"
	return &"power_gearbox"


static func _heavy_near(view: BotView) -> bool:
	for foe: BotView.Hostile in view.hostiles():
		if foe.stomp_m > 0.0 or foe.archetype == &"sentry_turret":
			continue
		if foe.alive and foe.pos.distance_to(view.player().pos) <= HEAVY_M:
			if foe.tier >= 5 or foe.archetype == &"war_machine" or (foe.robot and foe.hp >= 6.0):
				return true
	return false


static func _offensive(view: BotView, target: BotView.Hostile) -> StringName:
	var me: BotView.Player = view.player()
	if target == null or me.form != &"base" or me.forms.is_empty():
		return &""
	var distance: float = me.pos.distance_to(target.pos)
	var neighbors: int = 0
	for other: BotView.Hostile in view.hostiles():
		if other.alive and target.pos.distance_to(other.pos) <= CLUSTER_M:
			neighbors += 1
	if (neighbors >= 3 or target.stomp_m > 0.0) and distance <= OHM_M and me.forms.has(&"ohm"):
		return &"ohm"
	if me.pos.distance_to(me.car_pos) <= DENT_M and me.forms.has(&"dent"):
		return &"dent"
	if target.shooter and neighbors == 1 and distance <= KERF_M and me.forms.has(&"kerf"):
		return &"kerf"
	return &""


static func reach(form: StringName) -> float:
	match form:
		&"kerf":
			return KERF_M
		&"ohm":
			return OHM_M
		&"tonnage":
			return HEAVY_M
		_:
			return 0.0
