# Brief n28-09b-collar-now: run brief n28-09 now, with these times

Read `evidence/briefs/n28-09-collar-p55-sheet.md` whole, and the brief it builds on, `evidence/briefs/n28-05-collar-p55.md`
(why, bars, evidence, allowlist, forbidden list). Both hold. Only these values are set or changed:

- `{COMMIT}` = **22:36** (run `date +%H:%M` first and often). `{END}` = **22:52**: report and END by then.
- Images: at most 2 (lane count is 19/60 before this call).
- **Godot is busy until `build/scen_n28.exit` exists**: the director's scenario run (`build/scen_n28.log`). Do not launch
  any Godot (no `--import`, no render) before that file exists. Start the image job and the neck audit first; they need no
  Godot. If the file still does not exist at 22:28, tell me in your report and do not launch Godot; leave the round
  resumable (state file under `C:/Users/kazda/kiro/gtai-art/rivet-n28/collar_p55/`).
- Fix lint and format findings in your own edit and go on. Never amend, never rebase, never `git stash`, never `git add -A`/`.`/`-u`.
  Stage per path and commit with a pathspec (`git commit -m ... -- <paths>`). If the pre-commit hook fails only on
  `tools/merge/clash.test.mjs` or `tools/film/kill_reel_*.break.test.mjs`, rerun the commit once (load/stale cache); never skip the hook.
- Mutate is not needed: this is art only.
- If the edit fails the bars (rope still reads twisted, a seam at the mask edge, a pixel outside the masks moves, red or teal in
  the collar): commit nothing and report what you saw; do not try a third image.
- Evidence after the commit only if time is left before 22:52; otherwise STATE "Next" with the exact commands.
- Other lanes' files (combat: `ghost_forms.json`, `souls/**`, kills, `fx_atlas.png`, `weapon_fx_electro.gd`, deflect VFX,
  `enemies.json`, `weapons.json`, `combat.json`; cast: cast art, `cast_cards.json`; yard: `project/boot/prologue/**`,
  scenery art) are forbidden. Any path not in n28-05's allowlist: stop and report a NEED.

Report (short), as in n28-09.
