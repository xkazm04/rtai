# JOURNAL lane melee (n26, 2026-11-23), branch `n26-melee`, worktree `n23-street`

Order: 1 hands one-shot humans, 2 electric finishers on robots, 3 Kerf boss cap, 4 earning the transformation.

- 11:05 session 1 start. JOURNAL created. Read n24-melee and n24-ghost REPORTs, owner verdict line (decisions.md 1517).
- 11:07 Godot `--import` on 0779185ac: exit 0, 27 s, 0 ERROR (`build/import-n26.log`).
- 11:09 ASTRA RUNNING m1-hands since 11:09 (pid 42352, brief `evidence/briefs/n26-melee-01-hands.md`, hard stop 12:28).
- 11:12 FRICTION m1 asked mid-run whether it may change existing tests asserting the old claw rule; it went on by itself. Answer ready in `evidence/briefs/n26-melee-01b-answer.md` (yes, keep intent on an exempt target) for a resume if needed.
- 11:14 briefs 02 (electric), 03 (Kerf cap), 04 (bond) drafted under `evidence/briefs/`; HARDSTOP/COMMITBY placeholders to fill at launch.
- 11:15 m1 reports a NEED yard: Dale Winnick (named) spawns as plain `patrol_cop`; only `prologue_patrol.gd` knows his role.
- 11:15 keys lane slot order: 1 Dent, 2 Kerf, 3 Ohm, 4 Tonnage (their JOURNAL 11:06).
- 11:47 FRICTION m1 spent ~25 min on a BEFORE scenario run on main (60/68 then its own limit). Later briefs: main 0779185ac is gate-green (Director's merge gate), run scenarios only AFTER, and use `--only=<names>` for the touched ones first.
- 12:06 MILESTONE m1 commit `21f4fd10c` claw lethal to ordinary humans (never_finish list: mulroney, appliance_warden; named meta `melee_named_human`).
- 12:10 m1: prologue pilot seeds 1..5 after == before on every seed (patrol 30.9-31.3 s, squad 35-58 s, lowest HP 0 on seeds 1,3,5: one death each, on main too). Likely cause: prologue humans have hp 1 (warden hp 1), the claw already killed them; to confirm in m1's report.
- 12:12 DECISION (to verify in m2 item 0): the appliance warden is a grunt type (hp 1, three in the prologue), not named; he loses the exemption and plays the rake kill. Mulroney stays exempt.
- 12:17 m1 commits `912cf4552` (a drawn claw rake death per archetype), `0d47d809e` (stills). Review sheet `evidence/n26/hands/frames/review-32.jpg`: five different deaths with blood; read OK at 32 px/m.
- 12:24 ASTRA m1-hands 75 accepted (hit the 75 min cap while running mutate, no final message; 5 commits 21f4fd10c..9ee5e9cf0, tree clean). Results: claw one-shots patrol/riot/SWAT/contractor/trooper + plain guard; own rake death per archetype (`kill_rake_art.gd`, `signature_kills.json`); prologue pilot seeds 1..5 identical before/after (`evidence/n26/hands/prologue.md`: prologue humans already died to one claw contact; wardens exempt, hp 1); 60 s replay pinned digest held, parity 1200 exact, quest 1 checkpoints reached; `rivet_claw` scenario re-pinned (decision line, arena mash tape now 5 kills); 4 unit fixtures updated. Mutate not reported (owed, added to m2).
- 12:24 NEED yard (from m1): Dale Winnick spawns as plain `patrol_cop`; to exempt him as named, the yard spawner sets `set_meta(MeleeLethal.NAMED, true)` on that fighter. The prologue does not mount the arena's signature-death renderer, so the hand deaths do not show in the prologue: yard's composition code (one hook) if they want them.
- 12:25 ASTRA RUNNING m2-electric since 12:25 (pid 80024, brief `evidence/briefs/n26-melee-02-electric.md`, hard stop 13:42; item 0 drops the warden's exemption; owes m1's mutate).

NEXT: (session 2) wait for m2-electric (lock `C:/Users/kazda/kiro/gtai-n26/logs/melee/astra.lock`, events `astra-02-m2-electric.jsonl`); review its diff + `evidence/n26/electric/frames/`; then fill HARDSTOP/COMMITBY in `evidence/briefs/n26-melee-03-kerf-cap.md` and launch m3; then `n26-melee-04-bond.md` (check keys lane's chip files first). Owner films after the last behaviour change (masters dir `C:/Users/kazda/kiro/gtai-masters/n26/melee/`). Commit last new work by 17:10, final gate start by 17:25.

## Session 2 (12:26 to 13:56)

- 12:26 start. ASTRA m2-electric alive (pid 80024 node, lock 12:25). No `NEED melee` in the four journals; pressure's stall lead (n23-loop JOURNAL 12:26/12:40: test player stuck in Ohm/Tonnage form in frozen waves, hidden while `transform_unlocked` false) bears on item 4: appended to brief 04.
- 12:27 REVIEW m1 64 px/m sheet `evidence/n26/hands/frames/review-64.jpg`: five rake deaths read distinct, blood red only, Rivet's collar rigid. Accepted.
- 12:28 DECISION merge keys `MILESTONE 8d8bb3787` into n26-melee after m2 and before m3 (overlap with this branch: only `docs/decisions.md` + `JOURNAL.md`); briefs 03/04 build on number-key deploys and the per-ghost test player. Addenda written to both briefs.
