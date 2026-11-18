# n19 lane `move` JOURNAL (director: Claude Opus; builder: Astra)

- 21:51 MILESTONE session 1 start. Base 28302bd3c, tree clean, no astra.lock, no prior calls.
- 21:53 DECISION move/ownership: Rivet's pilot lives in `project/boot/collect_call/stage_pilot.gd` (boot/ is in no lane's list). The move lane edits it only for vault/cover call sites, kept small; the vault writes Rivet's position from the pilot and leaves `intent.move_by` zero, so neither `collect_call_stage.gd` nor the ai lane's `arena_stage.gd` needs an edit.
- 21:53 DECISION move/vault-trigger: the vault is the roll press when a vaultable obstacle is in reach ahead; with no vaultable obstacle the roll is unchanged. Flag `--vault` forces on, `--no-vault` forces off, default from data `vault.enabled` (false until acceptance). Unknown city props are never vaultable (safe default).
- 21:53 PLAN packages: 01 vault-core (data, probe, phase, flag, unit tests, determinism + fuzz scenario) -> 02 vault-view (pose from the rig, dev course, frames, clip) -> 03 cover-core (query API, snap/peek/move/leave, shot-stop) -> 04 cover-view -> 05 cells (image_gen) -> 06 walk slide -> 07 car enter/exit.
- 21:55 ASTRA RUNNING vault-core since 21:55 (brief evidence/briefs/01-vault-core.md)
- 22:18 ASTRA vault-core 23 accepted-with-followup (4 commits f7c866628..0347bbe36; fuzz 360 approaches, 26 vaults, 0 overlaps; flag commit blocked by debt ratchet). Bounced items: stripped doc comments, mid-vault teleport (stage line 109 re-collides), stop() mid-vault, guard_move calls private _collide.
- 22:19 ASTRA RUNNING vault-fix (resume) since 22:19 (brief evidence/briefs/01b-vault-fix.md)
