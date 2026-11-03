# n-noir merge notes for the Director (iteration 22, 2026-11-03 07:40-07:55)

This was a read-only check with `git merge-tree --write-tree`. No branch, worktree or main was touched.
The branch tips checked were n-noir adf9afa, main 721fbbb, n-visual d1d1578, n-d4 31f8c4c and n-d5 4b61ff4. Re-checked at 07:47 in iteration 24 (n-noir 7aa4da2, main 721fbbb, n-visual 0ea52b9, n-d4 02e21c1 (journal and evidence only since 31f8c4c), n-d5 4b61ff4), with the same result.

| Into n-noir | Result |
|---|---|
| main | Clean. main has no commits past the merge base 721fbbb. |
| n-d4 | Only `JOURNAL.md` conflicts (add/add: every lane has its own root journal). The provenance jsonl auto-merges. |
| n-d5 | Only `JOURNAL.md` conflicts (add/add). `docs/decisions.md` and the provenance jsonl auto-merge. |
| n-visual | `JOURNAL.md` conflicts (add/add), and so does **`project/boot/launch_args.gd`** (a text conflict). It also has **a semantic clash in `city_view.gd`** that git does not flag. |

## n-visual: launch_args.gd (text conflict)
Both lanes added `--look` to `KNOWN_FLAGS`. n-visual's line also adds `--reduced-motion` and rewrites the doc
comment. **Resolution: take n-visual's version as it is.** It is a superset: noir only needs `--look`, and
`test_noir_look.gd` only asserts `KNOWN_FLAGS.has("--look")`.

## n-visual: city_view.gd (auto-merges, but the behaviour changes; unverified in engine)
- On n-noir, `set_noir(true)` hides the D4 world print (`_look_rect.visible = look_enabled and (not on or noir.keep_d4)`).
  `look_noir.params.json` has `keep_d4: false`, so the noir pass reads the raw art.
- On n-visual, `_update_look()` calls `set_look_enabled()` whenever a profile's `printed` flips. That call sets
  `_look_rect.visible = printed` and **re-shows the D4 print under the noir pass**.
- **Iteration 23 correction (read-only, merge-tree at n-visual 0ea52b9, which adds only a journal entry over d1d1578):**
  the clash is **latent**, not on the `--look=noir` path. The first resolve does *not* call `set_look_enabled()`
  (`was_printed` starts true). Only `LookProfiles.resolve(&"off")` returns `printed = false`; no row in
  `look_profiles.json` sets it. `--look=noir` is an unknown id, so it resolves to the printed default and never
  flips. In the merged setup, `set_look_enabled()` runs before `set_noir()`. No n-noir dev script calls
  `set_look_enabled()` or assigns `look_enabled`. So the noir frames and showcase should come out unchanged without
  the fix. The clash fires when something calls `set_look_enabled()` while noir is on: n-visual's
  `dev/selftest/pass_cost.gd` and `tests/unit/test_render_layers.gd` do, as would `--look=off` toggling or a future debug key.
  Apply the fix anyway.
- On n-visual, `--look=noir` also sets `view.look_id = &"noir"`. `LookProfiles.resolve()` does not know the id
  and falls back to the default (`auto`, the D4->D5 zoom blend). That is harmless while `_look_rect` is hidden.
  It also means `LookProfiles.has(&"noir")` is false.
- **Proposed fix in the merged `set_look_enabled`:**
  ```gdscript
  _look_rect.visible = printed and (noir == null or not noir.visible or noir.keep_d4)
  ```
  The exact two-line patch against the merged file is `evidence/merge-noir-city_view.patch`. It makes `set_noir()`
  call `set_look_enabled(look_enabled)`, so there is one source of truth and `--look=off` + noir stays unprinted.
  The patched file passes `gdformat --check` and `gdlint` (239 lines). It is not run in engine. The extra
  `crowd.apply_print(_item_mat, printed)` call from `set_noir()` re-applies the material the crowd already has (idempotent).
  That keeps n-noir's behaviour (n-noir never changed the item print either). **To verify after the merge:** re-shoot the noir_frames junction 48 and compare it with
  masters `crowdshadow-v1/before/`. The D4 world print must not be visible under the noir pass.
- Later, as a separate change: register `noir` as a row in n-visual's `look_profiles.json` (or as an overlay
  base). Then `--look=noir` is a first-class profile id instead of a side switch. That is not done here (past freeze).
- The merged `city_view.gd` is 239 lines: over the 200 soft cap, under the 300 hard stop.

## Other auto-merges into n-visual (checked by diff; independent)
- `part_materials.gd`: n-noir adds `noir`/`noir_keep` and `set_noir()`; n-visual adds `flat_below` and `world_px`.
  The changes touch disjoint lines, and the merged file is 99 lines.
- `print_part.gdshader`: n-noir adds the `noir` uniforms and the ink-mass branch; n-visual adds `world_px`
  to the FRAGCOORD. These are independent.
