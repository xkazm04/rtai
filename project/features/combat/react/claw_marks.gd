class_name ClawMarks
extends RefCounted
## n7-melee: the claw's jab, made to read at 32 px/m (the audit: "the jab is small at 32, the arm
## over the cop"). On the claw's hit frame (CombatArena.wounded or kill_landed, weapon claw) three
## short parallel rakes print across the victim, square to Rivet -> victim, cream edged in ink;
## they print at full length on the hit frame (the hit-stop holds that frame, so a draw-in
## would freeze at nothing) and thin and fade over flash_ticks. The look is data
## (melee_marks.json `claw`); flash_ticks 0 or --feel=off = none (the before). Render only:
## never read by the sim. n31-melee 04b: every other row of the table with a `style` is a
## weapon's own mark keyed by its id (BladeMarks: katana, plasma_sword, chainsaw), drawn on the
## victim at gun height (ShotLift) as it moves; a repeat hit of one weapon on one victim
## refreshes its mark.

const TABLE: String = "res://data/tables/melee_marks.json"
const SCHEMA: String = "gtai.melee_marks/1"
const WEAPON: StringName = &"claw"
const RAKES: int = 3
const KEEP: int = 8
## The blade mark rides the torso: the gun-height lift times this, so the line crosses his body.
const TORSO_K: float = 3.0

var arena: CombatArena
var enabled: bool = true
var flash_ticks: int = 0
var rake_m: float = 0.0
var gap_m: float = 0.0
## The weapon rows beside the claw's, by weapon id.
var blades: Dictionary[StringName, BladeMarks] = {}
## (at.x, at.y, blow angle, tick) per marked hit, oldest first; _who and _weapon run beside it.
var marks: Array[Vector4] = []
var _who: Array[Fighter] = []
var _weapon: Array[StringName] = []


static func attach(p_arena: CombatArena, path: String = TABLE) -> ClawMarks:
	var m: ClawMarks = ClawMarks.new()
	m.arena = p_arena
	var t: DataTable = DataTable.open(path, SCHEMA)
	var row: Dictionary = t.object(t.raw, "claw")
	m.flash_ticks = t.integer(row, "flash_ticks")
	m.rake_m = t.num(row, "rake_m")
	m.gap_m = t.num(row, "gap_m")
	for key: String in t.raw:
		if t.raw[key] is Dictionary:
			var r: Dictionary = t.object(t.raw, key)
			if r.has("style"):
				m.blades[StringName(key)] = BladeMarks.from_row(t, r)
	m.enabled = HitFeel.feel_flag() != "off" and t.ok()
	if not t.ok():
		Log.error("melee_marks", str(t.errors()))
	@warning_ignore("return_value_discarded")
	p_arena.wounded.connect(m._on_wounded)
	@warning_ignore("return_value_discarded")
	p_arena.kill_landed.connect(m._on_kill)
	return m


func _on_wounded(victim: Fighter, weapon: StringName) -> void:
	_add(victim, weapon)


func _on_kill(
	victim: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName
) -> void:
	_add(victim, weapon)


func ticks_of(weapon: StringName) -> int:
	if weapon == WEAPON:
		return flash_ticks
	var b: BladeMarks = blades.get(weapon, null)
	return b.flash_ticks if b != null else 0


func _add(victim: Fighter, weapon: StringName) -> void:
	if not enabled or ticks_of(weapon) <= 0:
		return
	var d: Vector2 = victim.pos - arena.rivet.pos
	var a: float = d.angle() if d.length() > 0.001 else victim.facing.angle() + PI
	var i: int = _repeat(victim, weapon)
	if i >= 0:
		marks.remove_at(i)
		_who.remove_at(i)
		_weapon.remove_at(i)
	marks.append(Vector4(victim.pos.x, victim.pos.y, a, arena.tick))
	_who.append(victim)
	_weapon.append(weapon)
	if marks.size() > KEEP:
		marks.remove_at(0)
		_who.remove_at(0)
		_weapon.remove_at(0)


## A blade's mark still showing on this victim (its repeat refreshes it); the claw stacks.
func _repeat(victim: Fighter, weapon: StringName) -> int:
	if weapon == WEAPON:
		return -1
	for i: int in marks.size():
		if _who[i] == victim and _weapon[i] == weapon:
			return i
	return -1


func draw(ci: CanvasItem, tick: int) -> void:
	for i: int in marks.size():
		var m: Vector4 = marks[i]
		var w: StringName = _weapon[i]
		var age: int = tick - int(m.w)
		var life: int = ticks_of(w)
		if age < 0 or age >= life:
			continue
		if w == WEAPON:
			_rakes(ci, Vector2(m.x, m.y), m.z, float(age) / float(life))
		else:
			var f: Fighter = _who[i]
			(blades[w] as BladeMarks).draw(
				ci, f.pos + ShotLift.up_m() * TORSO_K, m.z, age, not f.machine
			)


## Three rakes square to the blow, the middle one longest, full on the hit frame.
func _rakes(ci: CanvasItem, at: Vector2, blow: float, t: float) -> void:
	var along: Vector2 = Vector2.from_angle(blow)
	var across: Vector2 = along.orthogonal()
	var alpha: float = 1.0 - t * t
	var w: float = 1.0 - 0.5 * t
	for i: int in RAKES:
		var off: float = (i - (RAKES - 1) * 0.5) * gap_m
		var half: float = rake_m * 0.5 * (1.0 if i == 1 else 0.75)
		var mid: Vector2 = at + along * off
		var p0: Vector2 = Ink.px(mid - across * half)
		var p1: Vector2 = Ink.px(mid + across * half)
		ci.draw_line(p0, p1, Color(Ink.INK, alpha), 8.0 * w, true)
		ci.draw_line(p0, p1, Color(Ink.CREAM, alpha), 3.5 * w, true)
