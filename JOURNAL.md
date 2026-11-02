# JOURNAL: night lane d5-close (branch n-d5)

## Iteration 1 (2026-11-02, BUILD, 21:10 -> 22:40)

- 21:10 read: AGENTS, shaders README, d4 manifest, characters README, print_part, F-09b frames, concept.
  Base: ad2078b (F-14 merged). No build/evidence in this worktree yet.
- 21:20 Codex: 4 D5 Rivet sheets queued serially (edit of the D4 parts-v2 sheets = same layout, + the concept as
  style ref). Masters: gtai-masters/night/d5-close/gen/. Prompt: gen/_prompts/rivet_base.txt + one line per sheet.
- Plan for the swap (item 1): D5 parts are installed at features/characters/art/d5/rivet/ with the SAME file names,
  sizes and parts.json as art/rivet/, and their alpha is the D4 alpha (silhouette lock) so the 64 px/m switch can
  only change the inside of a part, never its outline or the sticker halo -> no shimmer at the switch by
  construction. The swap is a texture + material swap per sprite (no new nodes).
- 21:16 MILESTONE item 1: 4/4 D5 Rivet sheets accepted (0 rejected; layout and plan view held). slice_d5.py cuts
  the D5 sheet with the D4 sheet's geometry (stretch within 2.3%) and gives each part the D4 alpha.
- FRICTION: the project's default canvas filter is linear WITHOUT mips, so the detailed D5 art aliased into speckle
  (r1-r3). Fixed by sampling the D5 parts with mipmaps. Also, an early "steel lift" edit silently failed to apply
  (string mismatch); caught at 21:33 when a measurement did not move. Lesson: verify edits by measurement.
- 21:20 a texture swap at 64 px/m popped the tone and moved the outline by 1 px (switch56_panel.png). Replaced by
  OVERLAY sprites faded 56 -> 64 px/m: 0 changed px at 32/48/54/56 (measured).
- 21:33 MILESTONE item 1 gate: D5 at 64 px/m reads closer to the concept (lavender steel, rust, ink, off-register
  vermilion), and Rivet vs street dL is 0.192 vs D4 0.174.
- 21:25 MILESTONE item 2: look_d5.gdshader world layer + look_d5.params.json. REVERTED the first tuning (r7: the
  street hatch read as rain and hurt the dark field the characters sit on); the hatch now lives only in the mid wash.
- 21:30 MILESTONE item 3: 4 D5 landmark roofs (Codex, 0 rejected). REVERTED the vermilion fist mural: at 48 px/m
  it competed with the cops (7.2% vermilion) -> re-inked to wash + thin off-register edge (0.43%).
- 21:35 MILESTONE item 4: hero junction scene (d5_hero.gd), cam on the mural corner, + hatched cast-shadow
  proposal. Gap list in evidence/README.md.
- Shared files touched (minimal): docs/decisions.md (2 DECISION lines), features/characters/character_rigs.gd
  (+4 lines: the tier hook), cut_rig.gd (+is_tinted, +on_tint call), steam/ai-provenance (append-only).
- 21:37 item 5: portraits started (Rivet accepted).
- 21:42 FRICTION: a portrait chain started with a shell `&` looked dead (ps showed no codex) but ran, in parallel
  with the tracked re-launch: each portrait was generated twice (ledger 21:37-21:40), which briefly broke "one codex
  at a time". The installed files are the last writes, reviewed in item5_portraits.png. Cost: 3 extra images. Only
  use run_in_background from now on; check with `tasklist`, not ps.
- 21:41 MILESTONE item 5: 3/3 portraits accepted (0 rejected), installed at characters/art/d5/portraits (512 px).
- 21:42 hero scene + props (h9). Gap-6 cop D5 sheets + gap-5 bold Rivet re-ink queued (7 images).
- 21:45 MILESTONE gap 6: D5 cops (3 sheets, 0 rejected). FOUND: the cop head prints with palette swap 4
  (ink->vermilion); a D5 overlay would have blacked it out at 64 px/m -> overlays skip swapped parts (+ test).
- 21:48 REVERTED: bold-hatch re-ink of the 4 Rivet sheets (gap 5 attempt). The hatch still mipped away at 64 px/m
  and the wider rust diluted the collar. Kept the fine set; instead rust prints as dried rust (VERM->INK 0.42)
  and only coarse-mip-coherent vermilion (the collar) prints pure: 1614 -> 739 pure px at 96 px/m.
- 21:52 evidence tool (--no-parity --no-bench) all PASS at f2c7654. FRICTION: it refuses a dirty tree; the
  untracked evidence/*.png have to be moved aside for the run.
- 21:56 look_d5_shadow.gdshader: hand-hatched cast shadow (world-locked wobble, pressure, broken strokes).
- 21:57 peds D5 (gap 6b) in progress.
