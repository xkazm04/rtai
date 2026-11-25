# n30 combat call 06: three decision lines (docs only, no Godot)

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Hard stop: commit by 12:27, END by 12:29.

Append exactly these three lines at the END of `docs/decisions.md` (append-only; one line each; do not edit other lines),
then `git add docs/decisions.md` and commit `docs: n30 combat decisions (thin hop, card fall, round band)` ending with
`Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. The pre-commit hook may run; never skip it. Never `git add -A/./-u`,
no stash, no amend. Stage only `docs/decisions.md` (another builder has files in the tree: do not stage them).

```
- [2026-11-25] DECISION n30 combat thin hop: the chain hop and the daze stars go back to the thin look (owner verdict on n29), `WeaponFxElectro.THIN_BODY_PX` 3 / `THIN_CORE_PX` 1.5, opaque amber body, cream core, no ink outline, the n28 `ElectricArc` kink (no `JAG_K` on the hop); the in-flight bolt keeps the bold 10 / 4 px with a 13 px ink outline and `JAG_K` 3.0 (tick 114 whole frame 0 px diff); hop box red 0 / teal 0 (a0f9c8bed, evidence/n30/electric/thin.md). Rejected: 4 px (more amber, heavier than the owner's n29 thin reference). Re-check: the owner's view of the stun stars, which read cream/tan at 3 px.
- [2026-11-25] DECISION n30 combat card fall: a whole-body kill on a card foe (`CastCardPose`) with no cells drawn for any victim (`*`) draws his own `CastCards.Sheets.fall` in the fall grid (`KillCardFall`, 480268dcf), at his card scale, in the geometry his living death uses; the style's cells keyed to his pooled rig's street row (`cop/head_swat`, the patrol cop) are another kind's drawn death and no longer show on him; `--kill-card-fall=grid` = the before. All enabled card rows have a usable sheet (evidence/n30/kills/card_fall.md). Rejected: keeping the street-row stitch cells (Mulroney and the warden fell as a patrol cop). Re-check: the warden's fall sheet pops ~1.4x on the head at the switch (cast art; his living death does the same).
- [2026-11-25] DECISION n30 combat round band: Rivet's `fx/rocket.png` and `fx/nuke_shell.png` nose band amber #EDAB42 hue by a masked recolour (the n29 `is_red` gate plus its red-hue 8-neighbours; value and alpha kept, 0 px changed outside; 42e7af756, 201763968); in game at 64 px/m the rocket band's reddish px 91 -> 0, the nuke's 1048 -> 39 (single px on the amber/ink stripe edges, where the item print snaps the blend to vermilion) (evidence/n30/rounds/band.md). Rejected: keeping the red band (n29 call: amber reads as heat, the owner's pick). Re-check: the nuke's last 39 px.
```

Report: the commit hash and END.
