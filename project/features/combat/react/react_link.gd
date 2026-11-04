class_name ReactLink
extends RefCounted
## Wires one CombatArena's landed hits (CombatArena.struck) into the human reaction layer of
## the cast rigs that draw it (CharacterRigs): a wound family on a hit, the standard death by
## damage class on a kill, unless a signature kill (lane brutality) takes it through
## DeathPipe.add_signature. The host calls apply() once per frame after it filled the rig feed
## and before CharacterRigs poses (ArenaRigs does). Rivet (the arena's player) never reacts here.
## Render only: it reads the arena's signal and writes nothing back.

## The arena's HitLink knockback already slides the victim (sim), so the drawn carry is scaled
## down where it would add up: wounds keep a little, deaths most of theirs (the corpse lands
## where the blow threw it). DECISION human-reactions in docs/decisions.md.
const WOUND_CARRY: float = 0.4
const DEATH_CARRY: float = 0.8

var pipe: DeathPipe
var wounds: int = 0
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


static func make(arena: CombatArena, p_pipe: DeathPipe = null) -> ReactLink:
	var link: ReactLink = ReactLink.new()
	link._arena = arena
	link._weapons = WeaponTable.shipped()
	link.pipe = p_pipe if p_pipe != null else DeathPipe.make(ReactTable.shipped())
	@warning_ignore("return_value_discarded")
	arena.struck.connect(link._on_struck)
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
		else:
			@warning_ignore("return_value_discarded")
			pipe.wound(rig, hit_class, dir, false, cover)
			wounds += 1
	_pending.clear()
	_relay(rigs)


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


func _on_struck(victim: Fighter, dir: Vector2, lethal: bool, weapon: StringName) -> void:
	if victim == _arena.rivet:
		return
	var d: Vector2 = dir if dir != Vector2.ZERO else -victim.facing
	_pending.append([victim.id, d, lethal, hit_class_of(weapon), false, weapon])
