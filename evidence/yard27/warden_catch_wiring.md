# Warden catch view: the prologue's side of the wiring (patch for the Director, after the cast merge)

Written on branch `n27-yard` (HEAD `5835bbfa0`). `FoeWardenCardView` exists only on `n27-cast`, so none of this compiles here and none of it is applied: the diff below was produced against this branch's files and is the exact change to make once `n27-cast` is merged. `git apply --check` it after the merge (line numbers may shift by a few lines if the cast lane touches these files).

## What the names are on this branch (checked in the files)

- `PrologueStage extends ArenaStage` (`project/boot/prologue/prologue_stage.gd:2`). `_move()` is at line 33; `var combat: PrologueCombat = arena as PrologueCombat` at line 35.
- `combat.catcher` is the warden currently holding Rivet (`prologue_stage.gd:36`, cleared at line 43 when `tick >= combat.pinned_until`, the catcher is dead, Rivet rolls or Rivet is mid melee). `PrologueCombat extends CombatArena` (`prologue_combat.gd:2`), so `combat.hostiles: Array[Fighter]` is `project/features/combat/combat_arena.gd:25`.
- `tick` inside `_move()` is `ArenaStage.tick` (the stage's own tick, the same one line 38 compares with `combat.pinned_until`); `CombatArena.tick` (`combat_arena.gd:43`) is the arena's. They are equal inside a stage step, so either compiles; the diff uses the stage's.
- The warden archetype id on this branch is `&"appliance_warden"` (`prologue_props.gd:31`, `:90`); `CastCards.current(&"appliance_warden")` is the card lookup (the same call the commander dress uses for `&"sergeant_mulroney"` at `prologue_command_view.gd:50`).

## 1. Drive the catch view every tick (`prologue_stage.gd`, `_move()`)

The block runs after the existing `if combat.catcher != null: ... combat.catcher = null` and before `if at_receiver or combat.catcher != null:`, so a catcher released this tick is already `null` and its view gets `false` on the same tick.

## 2. Skip the vector warden when the card is present (`prologue_props.gd`)

- Overalls dye (`_process`, line 31): the dye loop only runs for wardens that have a walk card and no cast card.
- Dress loop (`_draw`, line 90): a warden with a cast card is skipped altogether, which also removes `_warden(chest, head, h.facing)` (the bib and straps, line 112 / 158), the card-branch straps and drill rect (lines 114 to 118) and `_pole(hand, h.facing)` (line 119). Dale is unaffected (`h != patrol.dale` stays the first test).
- If the cast lane wants the pole kept (the card has no pole), change the `continue` into `if card != null: _pole(hand, h.facing)` instead: say so and it is a two-line change.

```diff
diff --git a/project/boot/prologue/prologue_stage.gd b/project/boot/prologue/prologue_stage.gd
index 40d20504a..6c2a58205 100644
--- a/project/boot/prologue/prologue_stage.gd
+++ b/project/boot/prologue/prologue_stage.gd
@@ -41,6 +41,9 @@ func _move() -> void:
 			or pilot.melee.busy()
 		):
 			combat.catcher = null
+	for h: Fighter in combat.hostiles:
+		if h.archetype == FoeWardenCardView.ID:
+			FoeWardenCardView.set_catch(h, h == combat.catcher, tick)
 	if at_receiver or combat.catcher != null:
 		intent.move_by = Vector2.ZERO
 		intent.move_to = Vector2.INF
diff --git a/project/boot/prologue/prologue_props.gd b/project/boot/prologue/prologue_props.gd
index c6403a430..77bd761fc 100644
--- a/project/boot/prologue/prologue_props.gd
+++ b/project/boot/prologue/prologue_props.gd
@@ -28,7 +28,7 @@ func _process(_dt: float) -> void:
 	var index: int = 0
 	for officer: ProloguePatrol.Officer in patrol.officers:
 		var h: Fighter = officer.body
-		if h.alive() and h.archetype == &"appliance_warden":
+		if h.alive() and h.archetype == &"appliance_warden" and not _warden_card():
 			var card: Sprite2D = walk_card(rigs, cards, h.id)
 			if card != null:
 				_dye_card(card, index)
@@ -84,11 +84,18 @@ func _dye_card(card: Sprite2D, index: int) -> void:
 	copy.show()
 
 
+## The cast lane's card draws the warden: no overalls dye, vector pole, straps or bib.
+func _warden_card() -> bool:
+	return CastCards.current(&"appliance_warden") != null
+
+
 func _draw() -> void:
 	for officer: ProloguePatrol.Officer in patrol.officers:
 		var h: Fighter = officer.body
 		if not h.alive() or (h != patrol.dale and h.archetype != &"appliance_warden"):
 			continue
+		if h.archetype == &"appliance_warden" and _warden_card():
+			continue
 		var at: Vector2 = h.pos * PP
 		var chest: Vector2 = at + Vector2.UP * 10
 		var head: Vector2 = at + Vector2.UP * 16
```

## Checks to run after applying

- `node tools/tests/run_unit.mjs --select=test_prologue_game,test_prologue_pump_tell,test_prologue_yard_props` (names the classes touched), then `just lint`.
- One film of the arrival (a warden catching Rivet) with `--cast-card` default and with `--cast-card=off` (the vector warden must come back unchanged: the `_warden_card()` guard is the only gate).
