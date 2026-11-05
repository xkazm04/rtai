extends Scenario
## d7-calls ghost-powers-5 (owner, 2026-11-05): Dent is locked until his act. On the shipped quest
## 1 (the city, Quest1Session's lock, no act done) scripted input taps G round the whole cycle,
## takes the selected ghost (Q) and taps G again in the form: the selection and the forms must
## never reach Dent, and the HUD must show him locked. With his act done (ghost_forms.json
## `unlock` act_dent) the same input must select him. TST-05: the planted fault (the lock ignored,
## GhostLocks.plant_ignore) must let Dent through, and this check must see it.

const EVIDENCE_FILE: String = "quest1-dent-lock.json"
const DENT: StringName = &"dent"
const WARM: int = 30
const TICKS: int = 140
## G taps in base (one full cycle of four), Q, then G in the form (a switch).
const PICKS: Array[int] = [10, 16, 22, 28]
const TAKE_AT: int = 40
const SWITCH_AT: int = 100


func run(_tree: SceneTree) -> String:
	var locked: Dictionary = _run([], false)
	var out: Dictionary = {"locked": locked}
	if _reached(locked, "seen") or _reached(locked, "formed"):
		return "quest 1 let Dent through the lock: %s" % JSON.stringify(out)
	var seen: Array = locked["seen"]
	if locked["hud_locked"] != true or seen.size() < 3:
		return "quest 1's lock showed wrong (HUD or the cycle): %s" % JSON.stringify(out)
	var freed: Dictionary = _run([&"act_dent"], false)
	out["after_act"] = freed
	if not _reached(freed, "seen") or freed["hud_locked"] == true:
		return "Dent stayed locked after his act: %s" % JSON.stringify(out)
	var planted: Dictionary = _run([], true)
	out["planted_lock_ignored"] = planted
	if not _reached(planted, "seen"):
		return "the planted ignored lock went unseen: %s" % JSON.stringify(out)
	return write_evidence(EVIDENCE_FILE, out)


## True when the run's `key` list (the selections seen, the forms taken) names Dent.
func _reached(result: Dictionary, key: String) -> bool:
	var ids: Array = result[key]
	return ids.has(String(DENT))


func _run(acts: Array[StringName], fault: bool) -> Dictionary:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	Quest1Session.on_city = true
	Quest1Session.acts_done = acts
	var s: Quest1Session = Quest1Session.open(bus, data)
	Quest1Session.acts_done = []
	var out: Dictionary = {"seen": [], "formed": [], "hud_locked": false}
	if s != null:
		var forms: GhostForms = s.pilot.ghosts.forms
		forms.locks.plant_ignore = fault
		for i: int in WARM:
			s.step()
		s.world.loop().set_input(Press.new(s.actions, s.tick()))
		var seen: Array = []
		for t: int in TICKS:
			s.step()
			if not seen.has(String(forms.selected)):
				seen.append(String(forms.selected))
		var formed: Array = []
		for h: Array in forms.history:
			var to: StringName = h[2]
			formed.append(String(to))
		var hud: GhostFormHud = GhostFormHud.new()
		hud.sync(forms)
		out = {"seen": seen, "formed": formed, "hud_locked": hud.locked.get(DENT, false)}
		hud.free()
		s.world.free()
	bus.free()
	data.free()
	return out


## The scripted pad: G round the cycle, Q, then G in the form.
class Press:
	extends InputSource

	var actions: PlayerActions
	var start: int

	func _init(p_actions: PlayerActions, p_start: int) -> void:
		actions = p_actions
		start = p_start

	func sample(tick: int) -> TickInput:
		var t: int = tick - start
		var buttons: int = 0
		if t in PICKS or t == SWITCH_AT:
			buttons |= 1 << actions.bit(&"power_gearbox")
		if t == TAKE_AT:
			buttons |= 1 << actions.bit(&"power_hauler")
		return TickInput.new(buttons)
