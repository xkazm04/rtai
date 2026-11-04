class_name ReactLink
extends RefCounted
## Wires one CombatArena's landed hits (CombatArena.struck) into the human reaction layer of
## the cast rigs that draw it (CharacterRigs): a wound family on a hit, the standard death by
## damage class on a kill, unless a signature kill (lane brutality) takes it through
## DeathPipe.add_signature. The host calls apply() once per frame after it filled the rig feed
## and before CharacterRigs poses (ArenaRigs does). Rivet (the arena's player) never reacts here.
## Render only: it reads the arena's signal and writes nothing back.

## A round from the front stopped on a riot shield (the `shield` family played): `victim` is
## the fighter id, `dir` the round's travel. For the hit FX (sparks off the slab, no blood).
signal blocked(victim: int, dir: Vector2)

## The arena's HitLink knockback already slides the victim (sim), so the drawn carry is scaled
## down where it would add up: wounds keep a little, deaths most of theirs (the corpse lands
## where the blow threw it). DECISION human-reactions in docs/decisions.md.
const WOUND_CARRY: float = 0.4
const DEATH_CARRY: float = 0.8
## Limp per hp lost: at 60 % of the hp gone the limp is full.
const LIMP_GAIN: float = 1.6
## gunplay's death kinds (CombatArena.kill_landed) over the weapon's hit class: a fire kill
## chars, a blast kill throws; `shot` keeps the weapon's own class.
const KILL_KIND_CLASS: Dictionary[StringName, StringName] = {&"burned": &"burn", &"blown": &"blast"}
## The lasting area states (FightAreas FighterFx) hold their family while they last: the share
## of the family the hold loops inside (start, end) and where the release resumes.
const HOLD: Dictionary[StringName, Vector3] = {
	&"stun": Vector3(0.3, 0.7, 0.7),
	&"burn": Vector3(0.3, 0.8, 0.8),
	&"knockdown": Vector3(0.3, 0.6, 0.78),
}

var pipe: DeathPipe
## Rounds that fly past a human make it duck (render only).
var near: NearMiss = NearMiss.new()
var wounds: int = 0
var blocks: int = 0
var deaths: int = 0
var signatures: int = 0
var _arena: CombatArena
var _weapons: WeaponTable
## Hits since the last apply(): [victim id, dir, lethal, hit class, in cover, weapon]. Cover is
## false here: CombatArena lands no hit on a fighter in cover (Fighter.exposed).
var _pending: Array[Array] = []
## The standard deaths played, by fighter id: [death kind, dir]. A corpse whose rig left the
## LOD bubble and came back (a fresh pooled rig) lies down again in the same final pose.
var _corpses: Dictionary[int, Array] = {}
## kill_landed's kind by victim id, read by the struck of the same landing (it fires first).
var _kill_kind: Dictionary[int, StringName] = {}
## The state family each fighter held last frame (released when its state ends).
var _held: Dictionary[int, StringName] = {}


static func make(arena: CombatArena, p_pipe: DeathPipe = null) -> ReactLink:
	var link: ReactLink = ReactLink.new()
	link._arena = arena
	link._weapons = WeaponTable.shipped()
	link.pipe = p_pipe if p_pipe != null else DeathPipe.make(ReactTable.shipped())
	@warning_ignore("return_value_discarded")
	arena.struck.connect(link._on_struck)
	@warning_ignore("return_value_discarded")
	arena.kill_landed.connect(link._on_kill)
	return link


## The damage class a weapon id hits with (weapons.json hit_class; `burn` for fire, else light).
func hit_class_of(weapon: StringName) -> StringName:
	if weapon == &"burn":
		return &"burn"
	var spec: WeaponSpec = _weapons.weapons.get(weapon, null)
	return spec.hit_class if spec != null else &"light"


## Plays every hit since the last call on its victim's rig (skipped when it has no full rig).
func apply(rigs: CharacterRigs) -> void:
	for h: Array in _pending:
		var id: int = h[0]
		var rig: CutRig = rigs.rig_for(id)
		if rig == null:
			continue
		var dir: Vector2 = h[1]
		var lethal: bool = h[2]
		var hit_class: StringName = h[3]
		var cover: bool = h[4]
		var weapon: StringName = h[5]
		var r: HumanReact = HumanReact.on(rig)
		r.carry = DEATH_CARRY if lethal else WOUND_CARRY
		if lethal:
			var kind: StringName = pipe.kill(rig, hit_class, dir, weapon)
			signatures += 1 if kind == &"signature" else 0
			deaths += 0 if kind == &"signature" else 1
			if kind != &"signature":
				_corpses[id] = [kind, dir]
		elif _held.get(id, &"") != &"knockdown":
			_wound(rig, id, hit_class, dir, cover)
	_pending.clear()
	near.apply(_arena, rigs, pipe)
	_relay(rigs)
	_hold_states(rigs)
	_limps(rigs)


## A wound family on `rig` (fighter `id`); a round stopped on the shield is announced (blocked).
func _wound(rig: CutRig, id: int, hit_class: StringName, dir: Vector2, cover: bool) -> void:
	var kind: StringName = pipe.wound(rig, hit_class, dir, shielded(rig), cover)
	wounds += 1
	if kind == &"shield":
		blocks += 1
		blocked.emit(id, dir)


## True when the rig carries the riot shield (its look): a round from the front then recoils
## behind the shield (ReactTable decides by the hit's side; render only, the sim's hp is untouched).
static func shielded(rig: CutRig) -> bool:
	return rig.variant != null and rig.variant.shield


## The family a fighter's lasting area state holds (&"" when none): stun over burn over down.
func state_family(h: Fighter) -> StringName:
	if _arena.areas == null:
		return &""
	var e: FighterFx = _arena.areas.effect(h)
	if e == null:
		return &""
	if e.stun_ticks > 0:
		return &"stun"
	if e.burn_ticks > 0:
		return &"burn"
	return &"knockdown" if e.down_ticks > 0 else &""


func _hold_states(rigs: CharacterRigs) -> void:
	for h: Fighter in _arena.hostiles:
		var fam: StringName = state_family(h) if h.alive() else &""
		var rig: CutRig = rigs.rig_for(h.id)
		var was: StringName = _held.get(h.id, &"")
		if rig == null or (rig.react != null and rig.react.dying):
			@warning_ignore("return_value_discarded")
			_held.erase(h.id)
			continue
		if fam != &"":
			_held[h.id] = fam
		else:
			@warning_ignore("return_value_discarded")
			_held.erase(h.id)
		hold(rig, fam, was, -h.facing)


## Holds `fam` on `rig` while its state lasts (looping inside HOLD's span), and lets the family
## run out from the release point once the state `was` ended (fam = &""). `away` is the fall
## direction when nothing is playing yet.
func hold(rig: CutRig, fam: StringName, was: StringName, away: Vector2) -> void:
	if fam == &"" and was == &"":
		return
	var r: HumanReact = HumanReact.on(rig)
	if fam != &"":
		if r.kind != fam:
			r.carry = WOUND_CARRY
			r.play(rig, fam, away if r.kind == &"" else r.dir.rotated(rig.facing), pipe.table)
		var span: Vector3 = HOLD[fam]
		if r.progress() > span.y:
			r.t = r.length * span.x
	elif was != &"" and r.kind == was:
		r.t = maxf(r.t, r.length * HOLD[was].z)


## A human that took a hit and lives (gunplay's armored hp) limps by how hurt it is.
func _limps(rigs: CharacterRigs) -> void:
	for h: Fighter in _arena.hostiles:
		var rig: CutRig = rigs.rig_for(h.id)
		if rig == null:
			continue
		var hurt: float = 1.0 - h.hp / h.max_hp if h.alive() and h.max_hp > 0.0 else 0.0
		if hurt > 0.0 or rig.react != null:
			HumanReact.on(rig).limp = clampf(hurt * LIMP_GAIN, 0.0, 1.0)


func _relay(rigs: CharacterRigs) -> void:
	for id: int in _corpses:
		var rig: CutRig = rigs.rig_for(id)
		if rig == null or (rig.react != null and rig.react.dying):
			continue
		var c: Array = _corpses[id]
		var kind: StringName = c[0]
		var dir: Vector2 = c[1]
		var r: HumanReact = HumanReact.on(rig)
		r.carry = DEATH_CARRY
		r.play(rig, kind, dir, pipe.table)
		r.settle()


func _on_kill(
	victim: Fighter, _weapon: StringName, _dir: Vector2, _at: Vector2, kind: StringName
) -> void:
	_kill_kind[victim.id] = kind


func _on_struck(victim: Fighter, dir: Vector2, lethal: bool, weapon: StringName) -> void:
	if victim == _arena.rivet:
		return
	var d: Vector2 = dir if dir != Vector2.ZERO else -victim.facing
	var hit_class: StringName = hit_class_of(weapon)
	if lethal and _kill_kind.has(victim.id):
		hit_class = KILL_KIND_CLASS.get(_kill_kind[victim.id], hit_class)
		@warning_ignore("return_value_discarded")
		_kill_kind.erase(victim.id)
	_pending.append([victim.id, d, lethal, hit_class, false, weapon])
