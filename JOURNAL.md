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
