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
	for row: Variant in t.array(t.raw, "classes"):
		var r: Dictionary = row if row is Dictionary else {}
		hf._rows[StringName(t.text(r, "id"))] = {
			"hitstop": StringName(t.text(r, "hitstop")),
			"shake": StringName(t.text(r, "shake")),
			"knock": t.num(r, "knockback_scale"),
			"flash": t.integer(r, "flash_ticks"),
			"reaction": StringName(t.text(r, "reaction")),
			"stagger": t.integer(r, "stagger_ticks"),
		}
	hf._errors = t.errors()
	if not hf.ok():
		Log.error("hit_feel", str(hf._errors))
	return hf


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
	if _rig == null:
		return 0
	var shake: StringName = row["shake"]
	if shake != &"":
		_rig.kick(shake, tick)
	var stop: StringName = kill_hitstop if lethal else row["hitstop"]
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
