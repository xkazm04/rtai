class_name ReelArsenal
extends RefCounted
## The showcase reel's weapon switch: with rivet-arsenal's carry (`--loadout=a,b,c,d`) the gun
## beat walks the carried slots in order, the next one every SWITCH_KILLS pit kills, so each
## weapon lands its kill (and the advanced ones their signature kill) on camera. It presses the
## slot's own action bit (weapon_slot_N) until RivetCarry has drawn it: one press edge, the same
## input a player gives, so the reel still records and replays. Without a carry it does nothing.

const SWITCH_KILLS: int = 2
## The gun beat's length with a carry (every weapon needs its turn): 60 s.
const GUN_TICKS: int = 3600


## The carry on the live pilot, or null (no --loadout).
static func carry_of(stage: ArenaStage) -> RivetCarry:
	return stage.pilot.carry if stage.pilot != null else null


## The slot bit to press this tick (0: none), after `kills` pit kills in the gun beat.
static func press(stage: ArenaStage, actions: PlayerActions, kills: int) -> int:
	var carry: RivetCarry = carry_of(stage)
	if carry == null:
		return 0
	var filled: Array[int] = []
	for i: int in RivetCarry.SLOTS:
		if carry.slots[i] != &"":
			filled.append(i)
	if filled.size() < 2:
		return 0
	var want: int = filled[(kills / SWITCH_KILLS) % filled.size()]
	if want == carry.current:
		return 0
	return 1 << actions.bit(RivetCarry.SLOT_ACTIONS[want])
