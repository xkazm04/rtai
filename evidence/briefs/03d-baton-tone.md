# Brief 03d `grids` (resume): the electro baton's tone and run row 3 (lane motion, n24)

Hard stop: 23:58 wall clock (check `date`). Commit deadline: 23:50. Whatever is not committed by then, describe in
your final report. Fix lint and format findings in your own edit and go on. No amend, no rebase, no `git stash`, no
`git add -A/./-u`, no `commit -a`, no reset --hard, never push. Stage per path. Everything from briefs 03-03c still binds
(pipeline, accept rule, allowlist, forbidden list, environment, the quick-gate note): same session, continued.

## Director's look at 1990dddbb (22:25): the baton holds and steps, but its tone jumps when he turns
Mean RGB of opaque pixels per packed row (alpha > 200):
- `rivet_walk_eq_electro_baton.png` rows 0-7: (114,86,63) (113,85,63) (124,89,63) (115,83,60) (120,92,69) (112,76,52)
  (118,74,53) (122,79,55). On grey, rows 0-4 read pale greyish beige (washed, low rust), rows 5-7 read the proper rust
  brown of the chainsaw sheet (whose rows sit at about (89-106, 64-76, 45-52)).
- `rivet_run8_eq_electro_baton.png`: row 4 (back) reads pale beige like walk rows 0-4; row 3 shrinks on a few columns
  (the head smaller in about columns 3 and 5: a scale pulse within the row).
Same-tick still `grid_electro_baton_64.png` shows it too: Front walk t190 and Back walk / Back sprint candidates are
lighter than the rows beside them.

## Do
1. Bring walk rows 0-4 and run row 4 to the rust tone of `rivet_eq_electro_baton*.png` / walk rows 5-7 (regenerate
   those rows with the eq card + a good row as the style reference; a pure colour transfer only if regeneration does not
   fit the time and the result has no banding or grey cast: say which you used). Accept rule: per-row mean within about
   8 per channel of the good rows, and a side-by-side on grey of all 8 rows showing no row stands out.
2. Fix run row 3's scale pulse (re-pack with a per-row fixed scale from the row's tallest column, as the gloria script
   did), re-measure its RUN_ROW_K.
3. Re-render `grid_electro_baton_<32|64>.png` at the same ticks; update `grid_electro_baton.md` (tone table before/after).
One commit. Then, only if 35 minutes or more remain before the hard stop: machine_pistol p70 as in 03c (committed by 23:50, else left untracked and described). No other new work: the lane freezes new code at 00:00.
