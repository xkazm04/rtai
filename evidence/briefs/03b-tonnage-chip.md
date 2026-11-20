# Brief 03b (follow-up, --resume of tonnage): the chip face still does not read

Hard stop: 25 minutes after you start (write it down). Last commit 5 minutes before it.

The director looked at `masters:n21/polish/tonnage/tonnage_chip_{before,after}.png`. The smoke column and the ring
are accepted. The chip is not: at HUD 1x the visor slot is only a shade darker and the face still does not read,
and a sliver of a neighbouring cell shows at the chip's right edge (both before and after).

## Do
1. Re-cut `project/features/hud/art/ghost_chips/tonnage_spectral.png` with the existing cut script
   (`tools/art/tonnage_*`), never by hand. Take the head-and-shoulders crop from a three-quarter (toward-right) cell of
   the shipped p70 sheet, so the visor is larger in the frame. Ink the visor slot near-black (the ink colour of the
   sheet's outline) and keep one thin bright teal glow line across it. Crop so that no pixel of a neighbouring cell
   is in the chip (check the alpha at all four edges). Same size and framing rules as the other chips.
2. Godot `--import`, `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`; provenance line if the
   source cell is new to this PNG. Commit "Re-cut Tonnage's chip from a three-quarter cell".
3. Stills at HUD 1x and 4x beside the other three chips: `masters:n21/polish/tonnage/tonnage_chip_after2.png`.

Environment, allowlist and repo law as in brief 03 (APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/polish; no amend,
no rebase, stage per path; fix lint and format findings in your own edit and go on). Report: commit, still path.
