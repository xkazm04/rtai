# features/save

Quest checkpoints (slice-play lane). Depends only on `core/` (LAY-05).

- `Checkpoint` (`gtai.checkpoint/1`, version 1, JSON via the JSON class only, SEC-02): the quest,
  the beat, the tick, the master seed, the input tape before that tick and the sim's state hash
  there. Written tmp -> rename to `user://saves/quest1_checkpoint.json`.
- `InputTape` (an `InputSource`): records the live input as changes; after a load it plays the
  saved history first. A load re-simulates the tape on a fresh world and must land on the saved
  hash, so it is exact or refused (a stale or tampered save never half-loads).

Quest 1 takes one at the start of every beat after the first (`Quest1Session.poll_checkpoint`),
offers Continue on the title card, and erases it once Rivet is paid. Respawn on death is the
stage's own (Rivet wakes in the Toner Room, Juno's tape bill comes off the payout).
The GTSV container in `core/save` (SAV-01..04) is still a stub; this is the slice's save.
