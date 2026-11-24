extends "res://dev/test_player/gauntlet_bot_film.gd"
## The bond and the mastery card, drawn. The gauntlet film scene with every owned ghost's bond
## filled to master_at - N before the first wave, the rest screen drawn long enough to read, and
## a read-only log of the bond edges. Run through the movie writer at 60 fps; always the film view.

const KNOWN: PackedStringArray = [
	"--seed",
	"--bot",
	"--pick",
	"--waves",
	"--result",
	"--controls",
	"--pick-view",
	"--bot-salt",
	"--pick-filter",
	"--wave-timeout",
	"--bond-prefill",
]

var _prefill: int = 0
var _capture: BondFilmCapture = BondFilmCapture.new()


## --bond-prefill=<points short of master_at>. The parent's list does not know it.
func _invalid_arg(args: ArenaArgs) -> String:
	if args.has("--bond-prefill"):
		var text: String = args.text("--bond-prefill")
		@warning_ignore("return_value_discarded")
		args.values.erase("--bond-prefill")
		if not text.is_valid_int() or text.to_int() < 0:
			return "--bond-prefill=" + text
		_prefill = text.to_int()
	return super._invalid_arg(args)


func _open_street(args: ArenaArgs) -> GauntletSession:
	var opened: GauntletSession = super._open_street(args)
	if opened != null:
		_fill(opened.pilot.ghosts.forms)
		opened.stage.hooks.append(BondFilmLog.new())
	return opened


func _open_view(_film: bool) -> void:
	super._open_view(true)
	if pick_view == null:
		return
	var plain: GauntletPickView = pick_view
	pick_view = BondFilmPick.new()
	pick_view.waves = waves
	pick_view.pilot = pilot
	hud.remove_child(plain)
	plain.queue_free()
	hud.add_child(pick_view)
	hud.move_child(hud.get_node(^"Status"), -1)
	if _capture.enabled():
		_capture.attach(get_tree(), get_viewport(), _tick)


func _tick() -> int:
	return session.tick() if session != null else 0


## Records kills (then stuns) through the bond's own record(): its values stay private. The
## gauntlet starts with no ghost owned, so every ghost's bond is filled: each is near master the
## moment a card hands it over.
func _fill(forms: GhostForms) -> void:
	var points: float = forms.table.master_at - float(_prefill)
	var kills: int = floori(points / forms.table.per_kill)
	var stuns: int = floori((points - kills * forms.table.per_kill) / forms.table.per_stun)
	for id: StringName in forms.table.order:
		if _prefill > 0:
			forms.bond.record(id, kills, stuns)
			Log.info("bond-film", "prefill %s %.0f" % [id, forms.bond.value(id)])
