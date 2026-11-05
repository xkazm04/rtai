class_name HitFeel
extends RefCounted
## The shared hit feel (README.md here): one call per landed hit, from guns, melee and powers.
## Maps a damage class (hit_feel.json) onto the camera rig's hit-stop and shake (both already
## scaled to 0 under reduced motion), a victim flash, a knockback scale and a reaction hook.

## enemy-ai plays the animation: kind is none|flinch|stagger|knockdown, for `ticks` sim ticks.
signal reaction(target_id: int, kind: StringName, dir: Vector2, ticks: int)

const TABLE: String = "res://data/tables/hit_feel.json"
const SCHEMA: String = "gtai.hit_feel/1"

var kill_hitstop: StringName = &"kill"
## A scripted kill beat holds the kill longer (d5-combat REQUEST 3: 6 -> 8 ticks).
var beat_kill_hitstop: StringName = &"boss_hit"
var beat_mode: bool = false
## `--feel=off` (before clips): no camera effect at all from a hit (no shake, kick or hit-stop);
## the victim's flash, reaction and knockback stay (they are the approved baseline, not feel).
var enabled: bool = true
## Lane n7-ranged: a lethal hit kicks the camera this much harder than its class.
var kill_kick_scale: float = 1.5
## The restraint (hit_feel.json `cap`): kicks per tick, shakes and hit-stop ticks per second.
var cap: Dictionary = {}
var _weapons: Dictionary[StringName, Dictionary] = {}
var _rows: Dictionary[StringName, Dictionary] = {}
var _flash_until: Dictionary[int, int] = {}
var _flash_len: Dictionary[int, int] = {}
var _rig: CameraRig = null
var _errors: Array[String] = []


static func shipped(rig: CameraRig = null, path: String = TABLE) -> HitFeel:
	var hf: HitFeel = HitFeel.new()
	hf._rig = rig
	var t: DataTable = DataTable.open(path, SCHEMA)
	hf.kill_hitstop = StringName(t.text(t.raw, "kill_hitstop"))
	hf.beat_kill_hitstop = StringName(t.text(t.raw, "beat_kill_hitstop"))
	for row: Variant in t.array(t.raw, "classes"):
		var r: Dictionary = row if row is Dictionary else {}
		hf._rows[StringName(t.text(r, "id"))] = {
			"hitstop": StringName(t.text(r, "hitstop")),
			"shake": StringName(t.text(r, "shake")),
			"knock": t.num(r, "knockback_scale"),
			"flash": t.integer(r, "flash_ticks"),
			"reaction": StringName(t.text(r, "reaction")),
			"stagger": t.integer(r, "stagger_ticks"),
			"kick_px": t.num(r, "kick_px"),
			"kick_ticks": t.integer(r, "kick_ticks"),
		}
	hf.kill_kick_scale = t.num(t.raw, "kill_kick_scale")
	hf.cap = t.object(t.raw, "cap")
	for row: Variant in t.array(t.raw, "weapons"):
		var w: Dictionary = row if row is Dictionary else {}
		hf._weapons[StringName(t.text(w, "id"))] = w
	hf.enabled = feel_flag() != "off"
	hf._errors = t.errors()
	if not hf.ok():
		Log.error("hit_feel", str(hf._errors))
	return hf


## The `--feel=<on|off>` launch value (OS args: the dev arena reads them raw too); "on" if absent.
static func feel_flag() -> String:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--feel="):
			return arg.substr(7)
	return "on"


func ok() -> bool:
	return _errors.is_empty()


func has_class(hit_class: StringName) -> bool:
	return _rows.has(hit_class)


## One landed hit. Returns the hit-stop ticks the caller holds the clock for (SimClock.hold);
## 0 without a rig, under reduced motion, or inside the rig's hit-stop cooldown.
func land(target_id: int, hit_class: StringName, dir: Vector2, lethal: bool, tick: int) -> int:
	var row: Dictionary = _rows.get(hit_class, _rows.get(&"light", {}))
	if row.is_empty():
		return 0
	var flash_ticks: int = row["flash"]
	_flash_until[target_id] = tick + flash_ticks
	_flash_len[target_id] = maxi(flash_ticks, 1)
	var kind: StringName = row["reaction"]
	var stagger: int = row["stagger"]
	if kind != &"none" and not lethal:
		reaction.emit(target_id, kind, dir, stagger)
	if _rig == null or not enabled:
		return 0
	var shake: StringName = row["shake"]
	if shake != &"":
		_rig.kick(shake, tick)
	var lethal_stop: StringName = beat_kill_hitstop if beat_mode else kill_hitstop
	var stop: StringName = lethal_stop if lethal else row["hitstop"]
	return _rig.hitstop(stop, tick) if stop != &"" else 0


## Knockback multiplier for the class (weapons.json knockback_mps times this).
func knock_scale(hit_class: StringName) -> float:
	var row: Dictionary = _rows.get(hit_class, {})
	return row.get("knock", 1.0)


## The victim's hit flash at `tick`, 1 on the hit fading to 0 (views tint the sprite with it).
func flash(target_id: int, tick: int) -> float:
	var until: int = _flash_until.get(target_id, -1)
	if tick >= until:
		return 0.0
	return float(until - tick) / float(_flash_len[target_id])


## The camera side of one hit (lane n7-ranged): the class row with the weapon's override on top
## (hit_feel.json `weapons`): hitstop and shake ids, kick_px (screen px along the hit) and
## kick_ticks. A lethal hit adds kill_hitstop (beat_kill_hitstop in a beat; the caller holds the
## longer of the two, so a rocket kill keeps its blast stop) and a harder kick.
func camera_row(weapon: StringName, hit_class: StringName, lethal: bool) -> Dictionary:
	var row: Dictionary = _rows.get(hit_class, _rows.get(&"light", {}))
	var out: Dictionary = {
		"hitstop": row.get("hitstop", &""),
		"shake": row.get("shake", &""),
		"kick_px": row.get("kick_px", 0.0),
		"kick_ticks": row.get("kick_ticks", 1),
	}
	var over: Dictionary = _weapons.get(weapon, {})
	for key: String in ["hitstop", "shake"]:
		if over.has(key):
			out[key] = StringName(str(over[key]))
	if over.has("kick_px"):
		var px: float = over["kick_px"]
		out["kick_px"] = px
	if over.has("kick_ticks"):
		var ticks: float = over["kick_ticks"]
		out["kick_ticks"] = roundi(ticks)
	out["kill_hitstop"] = &""
	if lethal:
		var kpx: float = out["kick_px"]
		out["kill_hitstop"] = beat_kill_hitstop if beat_mode else kill_hitstop
		out["kick_px"] = kpx * kill_kick_scale
	return out


## The class a `weapons` row routes its hits to (n7-melee REQUEST 2: ghost attacks that land
## through CombatArena.damage, with no `struck`); &"" when the row has none.
func weapon_class(weapon: StringName) -> StringName:
	var over: Dictionary = _weapons.get(weapon, {})
	return StringName(str(over.get("class", "")))


## The fire side of `weapon` (hit_feel.json `weapons` fire_kick_px / fire_kick_ticks): a camera
## kick against the aim on each round Rivet fires (recoil, a Gatling's steady rumble). Zero = none.
func fire_row(weapon: StringName) -> Vector2:
	var over: Dictionary = _weapons.get(weapon, {})
	var px: float = over.get("fire_kick_px", 0.0)
	var ticks: float = over.get("fire_kick_ticks", 1.0)
	return Vector2(px, ticks)


## The ignition kick of `weapon` (hit_feel.json `weapons` ignite_kick_px): screen px on the first
## round after the trigger rested (FeelCam), over the fire kick. Zero = none.
func ignite_px(weapon: StringName) -> float:
	var over: Dictionary = _weapons.get(weapon, {})
	return over.get("ignite_kick_px", 0.0)


## The ignition flare of `weapon` (hit_feel.json `weapons` ignite_flare_k / ignite_flare_ticks):
## the muzzle cell's scale on the round that lights the stream, easing back (WeaponFxIgnite).
## Zero = none, and none under --feel=off.
func ignite_flare(weapon: StringName) -> Vector2:
	var over: Dictionary = _weapons.get(weapon, {})
	if not enabled:
		return Vector2.ZERO
	var k: float = over.get("ignite_flare_k", 0.0)
	var ticks: float = over.get("ignite_flare_ticks", 1.0)
	return Vector2(k, ticks)


## The spin-up tremor of `weapon` (hit_feel.json `weapons` spin_rumble_px, screen px at full spin
## below firing speed; FeelCam.spin_tremor). Zero = none.
func spin_row(weapon: StringName) -> float:
	var over: Dictionary = _weapons.get(weapon, {})
	return over.get("spin_rumble_px", 0.0)


## The muzzle flash scale of `weapon` (hit_feel.json `weapons` muzzle_k, over the weapon-art cell
## size; WeaponFxArt.muzzle). 1 = the art's size, and 1 under --feel=off.
func muzzle_k(weapon: StringName) -> float:
	var over: Dictionary = _weapons.get(weapon, {})
	var k: float = over.get("muzzle_k", 1.0)
	return k if enabled else 1.0
