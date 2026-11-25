# Builder n31-melee-04a (sonnet, ~20 min, Godot-FREE): the impact audit table from code and data

Read `evidence/briefs/n31-common.md` (binding). Tag `04a`. Do NOT launch Godot in this call (other builders hold
the lane's Godot). Commit by 25 min into the call, report and END by 30 min (session dies at 00:57 local).
Write ONLY `evidence/n31-melee/04-impacts/audit.md` and `audit.json`. Commit with `git commit -- <paths>`.

## The owner
"Animations from weapons/projectiles and impact on enemies are inconsistent - some of them detailed and well
thought, some on surface done without care."

## Task
For every Rivet weapon the gauntlet wheel offers (find the list: gauntlet loadout / `weapons.json` /
`melee_weapons.json` / `rivet_melee.json`; melee: claw (hands), chainsaw, electro_baton, katana, plasma_sword;
guns: every gun row incl. shotgun) and four cases - **hit on a human, hit on a robot, hit on a shield, kill** -
write what is drawn and felt, by reading the code paths and data that fire on that case:
cells/sheets (which file), marks (`melee_marks.json`, rake/saw/scorch marks), sparks, blood (which set), decal,
hitstop ticks, shake, kick (`hit_feel.json` row), gun_fx row (`features/combat/weapons/gun_fx.json`), scorch,
the kill path in the GAUNTLET (no signature feed there today: generic `death_*` from `human_reactions.json`,
`foe_cast_view.gd`), and the signature row that exists in `signature_kills.json` (for item 3's feed).
Cite file:line for each claim. Score each cell 0-3 against the references: 3 = claw rake marks (melee), plasma
rifle scorch (guns), the saw grind (kills); 0 = nothing distinct is drawn. Then a ranked "lift list": the worst
cells in the order a player meets them in the gauntlet (wave 1 enemies first), naming the smallest change that
would lift each (a cell cut from an existing sheet, a mark row, a hitstop value) and its owner file.
Known from the director (verify): katana and plasma sword have no impact mark; the chainsaw has no hitstop/shake
and its SawMarks live only in the brutality-only KillSplitFx; the shotgun has no signature row; blood is one
weapon-agnostic set.
Final report: the table (markdown), the lift list, the commit sha.
