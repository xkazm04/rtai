class_name BlastLead
extends RefCounted
## n7-ranged: the camera leads toward a blast weapon's round (hit_feel.json `weapons` blast_lead_k,
## blast_lead_max_m, blast_lead_hold_ticks): while Rivet's shell flies, the view drifts a share of
## the way toward it, holds on where it landed while the blast plays, then eases back to Rivet.
## The mini-nuke's ring is 12 m in radius, 384 px at 32 px/m on an 800 px tall screen: centred
## on Rivet it is always cut. View only: reads the arena's rounds, steps on the sim tick (a
## hit-stop freezes it), writes nothing back; FeelCam adds it outside the kick cap.

## Per tick, the share of the way to the lead (in) and back to Rivet (out).
const EASE_IN: float = 0.08
const EASE_OUT: float = 0.04

## The lead's cap in screen px (blast_lead_max_px): Rivet stays on screen at 48 or 64 px/m too.
var max_px: float = 0.0

var _lead_m: Vector2 = Vector2.ZERO
var _at_m: Vector2 = Vector2.ZERO
var _k: float = 0.0
var _max_m: float = 0.0
var _hold_until: int = -1
var _tick: int = -1


## The lead (metres from Rivet's framing) at sim tick `tick`; zero when no blast round leads.
func step(arena: CombatArena, feel: HitFeel, tick: int) -> Vector2:
	var steps: int = clampi(tick - _tick, 0, 8) if _tick >= 0 else 1
	_tick = tick
	if arena == null or arena.rivet == null:
		return Vector2.ZERO
	var shell: Shot = _shell(arena, feel)
	if shell != null:
		_at_m = shell.pos
		_k = feel.weapon_num(shell.weapon, "blast_lead_k", 0.0)
		_max_m = feel.weapon_num(shell.weapon, "blast_lead_max_m", 0.0)
		max_px = feel.weapon_num(shell.weapon, "blast_lead_max_px", 0.0)
		_hold_until = tick + int(feel.weapon_num(shell.weapon, "blast_lead_hold_ticks", 0.0))
	var live: bool = shell != null or tick <= _hold_until
	var want: Vector2 = (
		((_at_m - arena.rivet.pos) * _k).limit_length(_max_m) if live else Vector2.ZERO
	)
	var rate: float = EASE_IN if live else EASE_OUT
	for i: int in steps:
		_lead_m = _lead_m.lerp(want, rate)
	return _lead_m


## Rivet's first round in flight whose weapon leads the camera, or null.
func _shell(arena: CombatArena, feel: HitFeel) -> Shot:
	for s: Shot in arena.shots:
		if s.from_rivet and feel.weapon_num(s.weapon, "blast_lead_k", 0.0) > 0.0:
			return s
	return null
