# Brief 02b (follow-up, --resume): ship the eight-facing HOVER sheet; keep the mirrored act sheet

Hard stop: 50 minutes after you start (write it down). Last commit 10 minutes before it.

The director looked at your four boards and agrees with your verdict for the **act** columns: recovery reads as idle,
struck as drift, and their heights drift +10 to +20%. But the **hover** columns (idle, drift: pair A, p70 t2 / p55 t3)
are as good as the shipped cells at 32 and 64 px/m, their heights are within about 10%, and in the left-facing
cells the staff stays in his right hand. Hover is what the player sees nearly all the time, and it is what the owner
asked for ("Ohm turning left with the staff in the same hand"). So: ship hover with eight facings, keep the act sheet
as it is (5 rows, mirrored). No new image generation in this follow-up.

## Do
1. Cut pair A per tilt into the eight-facing hover sheet `ohm_spec_hover.png` + `ohm_spec_hover_jars.png` (rows
   `toward, toward_right, right, away_right, away, away_left, left, toward_left`; columns idle, drift), with the
   jar masks and `forks_row_major` for the hover sheet, using `tools/art/ohm_n21_eight_cut.py` (extend it; import the
   shared steps from `ohm_spectral_cut.py`). **Calibrate each new cell's coat height to its shipped partner's**
   (the right cell for right/toward/away facings, the same shipped cell for its mirrored left twin) so every hover
   cell lands within 5% of the shipped height; report the per-cell residual. Leave `ohm_spec_act*.png` untouched.
2. Meta: `ohm_spec_cells.json` gets per-sheet rows (the hover sheet lists 8 rows, the act sheet keeps its 5). If the
   meta format has one global `rows`, add a per-sheet `rows` under `sheets.hover` / `sheets.act`, and keep the loader
   reading the old global one as the fallback.
3. Wiring: a facing uses its own row with `flip_h == false` when **that sheet** has 8 rows; else the existing mirror.
   So under the spectral look, hovering/drifting left never flips, a strike to the left still mirrors. The jar
   overlay (`ohm_jars.gd`) and the fork tip (`ohm_fork.gd`) follow the same cell and flip. Pin with unit tests:
   (a) the shipped p70 and p55 hover metas have 8 rows; (b) for all 8 facing directions in idle and drift,
   `flip_h == false` and the row index matches the facing; (c) in an act cell facing left, `flip_h == true` as today;
   (d) the jar overlay and fork follow the sprite's flip in both cases.
4. Import (`"$GODOT_BIN" --headless --path project --import`), `node tools/tests/run_unit.mjs --changed`,
   `node tools/gate/quick.mjs`, provenance lines for the shipped PNGs (`steam/ai-provenance/2026-11.jsonl`), the
   manifest entry, and one `docs/decisions.md` line:
   `- [2026-11-20] DECISION ohm art: spectral Ohm hovers and drifts with eight drawn facings (left and right drawn in one image by pose pair), so his staff stays in his right hand when he turns left; the act sheet keeps its 5 rows and the mirror because the generated charged/recovery/struck cells lost their poses (boards masters:n21/polish/ohm/). Switch: per-sheet row count in ohm_spec_cells.json. Re-check: when the act sheet is redrawn.`
   Commit: "Hover Ohm in eight drawn facings; keep the act mirror".
5. Stills, same tick before/after: Ohm drifting left and right in tilt 70 and 55 at 32 and 64 px/m. Use
   `tools/film/ghost_films.mjs --ghost=ohm --look=spectral --takes=move --stills=<ticks where he faces left / right>`
   (read `ghost_films_plan.mjs` for the drive), "before" from the commit before yours (`git worktree`-free: the film
   tool has a `--rev` or use `tools/film/film.mjs` same-tick before/after if it exists; otherwise film before you
   commit). Into `C:/Users/kazda/kiro/gtai-masters/n21/polish/ohm/ohm_left_{p70,p55}_{32,64}_{before,after}.png`.
6. `node tools/mutate/mutate.mjs --file=<the file holding the row/flip choice> --max=20 --lines=<changed lines>`; quote it.

Repo law, environment and the owned-file allowlist are as in brief 02 (also `ohm_spec_cells.json` for both tilts).
Report: commits, per-cell height residuals, test results, still paths, mutate line, anything not done.
