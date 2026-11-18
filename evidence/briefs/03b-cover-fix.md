# Brief 03b `cover-fix` (resume): four fixes, then package 04

Good work: I re-ran the 44 cover/vault unit tests and both scenarios myself (green; fuzz 800/488/360/488/312,
vault 514 landed). Four things go back before anything else; commit each separately.

1. **`project/boot/launch_args.gd` is a shared, append-only file.** You reworded three existing entries
   (`--rivet-reload`, `--device` comments) to make room. Restore those lines byte-for-byte to
   `git show c6e1ccdee:project/boot/launch_args.gd`, and append `--cover` and `--no-cover` one line each WITH a
   comment like the vault's (`# lane move n19: ...`). Other lanes append to the same list tonight: any reworded
   line is a merge conflict in the morning. The file grows by 2: take it through the debt tool with
   `node tools/debt/debt.mjs --update --accept-regression="n19 move: --cover/--no-cover appended to the shared KNOWN_FLAGS list"`
   (or whatever the tool's exact form is: read `tools/debt/README.md`).
2. **Never strip doc comments to fit a size cap** (this is the second time). Restore the doc comments removed
   from `features/player/player_motion.gd` (the class doc, updated to mention cover; the `face_aim` doc; the
   `step` doc; the `heading` doc) and the `stage_pilot.gd` doc line about vaults (add one about cover). Make room
   by moving code out instead (e.g. the delegation/flags plumbing into PlayerCover/PlayerVault, or a small
   helper), not by deleting docs. If no honest split exists, accept the debt regression with a reason.
3. **`CoverQuery.protects` calls `ArenaWalls._crosses`: a private function in the ai lane's file.** Do not call
   private functions of other lanes' classes. Use a public ArenaWalls API if one fits; otherwise carry the same
   segment-box math in CoverQuery and add a unit test that pins it equal to `ArenaWalls.blocks` (built from one
   box) over a grid of segments, so a change on their side is caught.
4. **CoverQuery is the ai lane's API.** Give `near` and `protects` proper doc comments: arguments and units,
   what `solids` is and where to get it (VaultProbe.boxes / VaultCity.collect), sort order and tie-break, what
   `protects_shots` means (only station boxes stop shots under ArenaDodges.cull), and that it has no player
   state. Mention the defaults for body radius and peek.

Then run quick gate + `run_unit.mjs --changed` + the cover/vault scenarios, and go straight on with
`evidence/briefs/04-cover-view.md` (read it now) in this same session.
