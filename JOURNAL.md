# JOURNAL - lane keys (n26, 2026-11-23)

Branch `n26-keys`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`, cut from `main` `0779185ac`.
Continues `docs/day/2026-11-23/n24-motion/`.

## Session 1 (11:04 - 12:34)

- 11:05 START read n24-motion REPORT, decisions tail, input_actions rows. No NEED keys lines yet (lanes just started).
- 11:06 DECISION slot order (owner asked): key 1 Dent, 2 Kerf, 3 Ohm, 4 Tonnage = `ghost_forms.json` `forms` order.
- 11:06 DECISION pad: the pad keeps what it had: LB (joy 9) holds/releases the SELECTED ghost (`ghost_deploy` bit 19), RB (joy 10) cycles (`power_gearbox` bit 8). The four number actions get no pad button by default; the d-pad as 1-4 is the alternative (one table edit, but it takes the d-pad off movement). Recorded for the owner.
- 11:06 DECISION key 1 beside a car: `car` (bit 0) binds key "1" as well as `ghost_deploy_1`; a slot-1 hold that starts on a tick where the car use is taken (enter or leave) is consumed by the car and never deploys Dent. Old tapes press bit 0 only: unchanged.
- 11:06 DECISION `rivet_motion.json` `dash.hold_sprints` -> false (owner: Shift is the dash burst only).
- 11:07 ASTRA RUNNING keys since 11:07 (pid 77272, brief `evidence/briefs/n26-01-keys.md`, hard stop 12:25)
