# Brief n29-cast-12: three decision lines (5-minute call)

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. Builder sub-agent.
**Hard stop 06:15 local.** Append exactly these three lines to the END of `docs/decisions.md` (append-only, shared file; one
line each, no other edit), then `git commit -- docs/decisions.md` with message
`docs(cast n29): decisions for the thug scale, the door walk, the live robot flash` ending with
`Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Banned: `git add -A/./-u`, `commit -a`, stash, amend, reset.
Another builder works in this worktree: commit only with the pathspec. Check the file ends with a newline before appending.

```
- [2026-11-25] DECISION n29 cast robot hit flash: ArenaRobotRigs._react lights RigClips.flash() (hit_t = HIT_S, the tint window) beside the robot's own 40 px shove, so the door carrier, robot gunner and thug cards flash on the live path (c0a1b816e); before, only cops got a HIT clip and no robot card ever flashed in a fight. Rejected: RigClips.hit (shoves 90 px). Rendering only, no digest moves. Turret and war views still have no sync_tint (outside the owner's item).
- [2026-11-25] DECISION n29 cast door carrier walk: the eight-drawing walk ships one value away (CastDoorAnchors.WALK, derived tables, 62aa13f5a) and WALK stays FOUR: measured with the re-plant (61c383438) and the redrawn p70 right drawing 7 (f867fd556) the eight's body jump is worse than the four's in every facing (p55 down-right 13.28 vs 10.43, over the 12 bar). Re-check when p55 drawing 8 and p70 down-right drawing 1 are redrawn (docs/art/cast-audit.md "Door eight with the redrawn drawing 7").
- [2026-11-25] DECISION n29 cast robot thug size: robot_thug body_scale 1.45 -> 1.42 (d9bfe36a7) so he stays under Rivet at both pitches (55: 147/150, 70: 141/154 at 64 px/m), the owner's rule that most enemies stay near Rivet's size and never taller; 1.40 was the fallback. Row still off until every checklist point passes.
```

Report: the commit sha and `tail -3 docs/decisions.md`. Then END.
