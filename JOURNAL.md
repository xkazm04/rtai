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
- 11:14 NOTE briefs 02-04 written ahead (5e28bd624). Watch: `project/boot/quest1_controls_text.gd` hard-codes "Space: quick claw" / "F: car" in its English fallbacks: must follow the table (send in 01's follow-up if Astra skips it).
- 11:26 REVIEW 8ee4e085b table (Space sprint, F claw, car on 1, ghost_deploy_1..4 bits 20-23 / wire 33-36, Q/G/1-4 slots unbound, hold_sprints false): matches the contract.
- 11:46 REVIEW 974647488 number deploys (GhostNumberKeys; locked = nothing; slot-1 press near an enterable car never begins a hold; in a car holds cancel; StagePilot hashes the high word only when bit 33+ set). Check later: new in-car early stop in player_motion.drive (tape risk), header doc squeezed to one line.
- 12:22 ASTRA keys 75 accepted (timed out at the 75 min cap while mutate ran; no final message). Commits 8ee4e085b, 974647488, e75e90ce1 (chips + quest weapon hints from live bindings), c32d97d47 (gauntlet bot per-ghost deploy + decision line), 074ec2b53, 8d8bb3787 (claw prompt test). From its event log: lint 19/19, full unit 4006 passed / 0 failed / 2 skipped, scenarios 68/68 incl. the 60 s replay at its pinned hash, protected fixture dirs unchanged; gauntlet seed 7 pilot identity exact (11 deploys same forms same ticks, 9-wave result JSON byte-identical). Mutate NOT measured (killed by the cap).
- 12:24 MILESTONE keys 8d8bb3787 (merge `n26-keys` at this sha for the yard lane's prologue re-takes).
- 12:25 OPEN on keys: (a) mutate ghost_deploy.gd --max=20 changed lines (unmeasured); (b) `project/boot/quest1_controls_text.gd` English fallbacks still say "Space: quick claw" / "F: car": check e75e90ce1 covered it, else follow-up; (c) player_motion.gd header doc cut to one line in 974647488: restore; new in-car early stop in PlayerMotion.drive passed scenarios but needs a test; (d) the owner film with key overlay (sprint Space, dash Shift, claw F, ghosts 1-4, 1 into a car) after the last change; (e) car hint / prologue lesson cards: verify they render the new keys (prologue_prompts uses [melee], good). Possibly stray mutate scratch: build/mutate/ (git-ignored).
- 12:26 FRICTION brief 01 too big for one 75 min call (mutate + full suites at the tail): split verification-heavy tails into a resume next time.

NEXT (session 2): no Astra running (lock gone, astra-calls.jsonl n=1 timedOut). (1) Launch brief 02 `evidence/briefs/n26-02-hands-cadence.md` (fill HARDSTOP = start+70 min, COMMITBY = start+62) detached with PowerShell Start-Process (see 11:07). Prepend to it a 10-min item 0 covering OPEN (a)-(c) above (mutate ghost_deploy.gd, quest1_controls_text literals, player_motion doc restore + in-car stop test). (2) Then brief 03 (six p70 grids; two or three resumes), then brief 04 (p55 gloria, stop after one; gloria_vs_pistol still). (3) Keys film with overlay after the last keys change (can be a later brief item). Last new work committed by 17:10, final gate 17:25.
- 12:23 ASTRA RUNNING hands since 12:23 (pid 80188, brief `evidence/briefs/n26-02-hands-cadence.md` with item 0 = OPEN (a)-(c), hard stop 13:35, commit by 13:28). Session 2: do NOT launch brief 02 again; wait for this call (lock `C:\Users\kazda\kiro\gtai-n26\logs\keys\astra.lock`), then review its commits, LOOK at hands_before/after, log `ASTRA hands <min> <result>`, then brief 03.
