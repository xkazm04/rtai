# n31 ghost 26 - refusal cue strip (g26b)

Probe: `project/dev/ghost_n31/ghost_n31_refusal.gd` + `.tscn`, run windowed (project driver d3d12,
window moved to 0,1440 by the probe: `tools/dev/run.mjs` has no engine-arg pass-through) via
`node tools/dev/run.mjs ghost_n31_refusal --windowed --out=<dir> [--no-cue]`, both runs `ok exit 0;
SCRIPT ERROR 0`. The REAL `GhostFormHud`, inked with the gauntlet meter shader (the three lines of
`GauntletView.style_ghost_meter`, copied: that view needs a street), four ghosts unlocked, Tonnage
cooling at 0.6. Not a real `GhostForms` + `GhostDeploy`: the cue is fed the way `GhostFormHud.sync`
feeds it, `GhostRefusalCue.notice(refusals, refused_form, last_refusal == cooldown)`; tick 20 a
cooldown refusal on Tonnage, tick 60 a no-target refusal on Kerf. `--no-cue` never counts the
refusal (the before). Cells: HUD region at press -1, +1, +2, +4, +8, +17.

Strips: `gtai-masters/n31/ghost/refusal-cue-strip.png` (after) and `refusal-cue-strip-before.png`.

What I see:
- Before: all twelve cells of each row are identical; a press changes nothing on the HUD.
- After, Tonnage on cooldown: at +1 the cooling arc goes almost white, +2 still pale, +4 pale teal,
  +8 near teal, +17 the teal of press -1. The arc flash is the part that reads. The amber rim does
  NOT read on Tonnage at this size: the dimmed cooling avatar and the white arc cover it.
  The sideways shake (at most about 5 px here) is hard to see in stills.
- After, Kerf with no target: a clear amber/yellow outline round the Kerf avatar at +1, still strong
  at +2 and +4, fainter at +8, gone at +17; the avatar sits a few px right of its rest place at +1/+2.
  The other chips never change.

A player feels: the key was heard and said no - the refused chip winks (white arc on cooldown, amber
outline on a whiffed Kerf) for a third of a second, instead of a press that seemingly vanished.

g27 re-render (rim drawn after the face and cooling arc, same probe and flags, cells hstacked unlabelled, 2x, Tonnage row over Kerf row): the amber now reads on the dimmed Tonnage chip at +1/+2/+4 (the avatar takes an amber-green cast, fading by +8, gone at +17) where before it was hidden; it reads as a tint of the avatar's silhouette, not a clean outline. Kerf row unchanged.
