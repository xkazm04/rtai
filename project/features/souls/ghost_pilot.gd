class_name GhostPilot
extends RefCounted
## The four ghost forms for the bound player (StagePilot): one SoulPowers (one form at a time, one
## Madness meter) behind GhostForms, in front of the attack stages of lane ghost-powers (HaulerStage
## = Tonnage, DentStage = Dent, KerfStage, OhmStage). Q / LB (power_hauler) transforms into the
## selected ghost or back to base; G / RB (power_gearbox) selects the next ghost in base, or
## switches straight to it in a form (JOURNAL DECISION input). The attacks fire only while the form
## is settled (never mid-transformation); a transformation roots Rivet to morph_move_k of his walk.

## Rivet's walk while a transformation plays (the body is rebuilding; data-free on purpose: one
## value, judged in the clip).
const MORPH_MOVE_K: float = 0.25

var powers: SoulPowers
var forms: GhostForms
var hauler: HaulerStage
var dent: DentStage
var kerf: KerfStage
var ohm: OhmStage
var transforms: int = 0


func _init(table: PowerTable, form_table: GhostFormTable) -> void:
	powers = SoulPowers.new(table)
	forms = GhostForms.new(form_table, powers)
	hauler = HaulerStage.new(table)
	hauler.share(powers)
	dent = DentStage.new(table)
	dent.share(powers)
	kerf = KerfStage.new(table)
	kerf.share(powers)
	ohm = OhmStage.new(table)
	ohm.share(powers)
	var ohm_form: GhostFormDef = form_table.forms.get(OhmStage.GHOST)
	if ohm_form != null:
		ohm.set_electrodes(ohm_form.anchor(&"electrode_l"), ohm_form.anchor(&"electrode_r"))


static func shipped() -> GhostPilot:
	return GhostPilot.new(PowerTable.load_default(), GhostFormTable.load_default())


## True while `id` is the settled form (its attacks may fire).
func settled_in(id: StringName) -> bool:
	return forms.settled() and forms.current() == id


## One tick. Returns the move to use instead of `move_by` (metres this tick).
func drive(
	stage: CollectCallStage, c: PlayerCommand, actions: PlayerActions, press: bool
) -> Vector2:
	var move_by: Vector2 = stage.intent.move_by
	if stage.arena.rivet.alive():
		if c.was_pressed(actions, &"power_hauler") and forms.press_transform() == SoulPowers.OK:
			transforms += 1
		elif c.was_pressed(actions, &"power_gearbox"):
			@warning_ignore("return_value_discarded")
			forms.press_next()
	powers.tick()
	forms.tick()
	var tonnage: bool = settled_in(HaulerStage.GHOST)
	move_by = hauler.drive(stage, false, press and tonnage, move_by)
	var in_dent: bool = settled_in(DentStage.GHOST)
	var seize: bool = in_dent and c.was_pressed(actions, &"fire")
	dent.drive(stage, seize, press and in_dent, stage.arena.rivet.facing)
	if in_dent:
		stage.intent.fire_at = Vector2.INF  # Dent's hands are on the car, not on the gun
	move_by = kerf.drive(stage, false, press and settled_in(KerfStage.GHOST), c.aim, move_by)
	ohm.drive(stage, false, press and settled_in(OhmStage.GHOST), c.aim)
	var walk: float = stage.arena.tuning.rivet["walk_mps"]
	return move_by * _move_k(walk)


## True when a form's attacks own the melee press this tick (the pilot skips the claw): Tonnage,
## Dent, Kerf (the blink), Ohm (the bolt), or a transformation (no claw mid-morph).
func owns_melee() -> bool:
	if not forms.settled() or hauler.owns_melee() or settled_in(DentStage.GHOST):
		return true
	return settled_in(KerfStage.GHOST) or settled_in(OhmStage.GHOST)


## The settled light form's speed against Rivet's walk (Tonnage drives its own momentum).
func _move_k(walk_mps: float) -> float:
	if not forms.settled():
		return MORPH_MOVE_K
	var f: GhostFormDef = forms.def()
	if f == null or f.id == HaulerStage.GHOST:
		return 1.0
	return f.top_mps / maxf(0.1, walk_mps)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(hash(String(forms.from_id) + ">" + String(forms.to_id) + ":" + String(forms.phase)))
	out.put_32(forms.history.size())
	out.put_float(powers.madness)
	hauler.write_state(out)
	dent.write_state(out)
	kerf.write_state(out)
	ohm.write_state(out)
