# JOURNAL n16 kills-polish

## Iteration 1 (2026-11-11 11:00, BUILD)

- 11:00 read: brief, common rules, n15 combat REPORT "What does not work", n15 hero REPORT (peek card), kills/ folder.
- SHARED FILE (kills-new, read me): I edit `project/data/tables/signature_kills.json` only inside MY rows
  (rocket_gib, hand_cannon_blowback, burn_char, electro_shock, ohm_shock, katana_split, plasma_hole,
  plasma_sword_split, chainsaw_grind, ray_gun_dissolve, homing_shard_burst, mini_nuke_vaporise, tonnage_*, dent_*,
  kerf_split) and I ADD optional keys to `project/data/schemas/signature_kills.schema.json` (alphabetical, one key per
  property block, no reorder). First: `streak_m`, `streak_w_m` (the split style's slash streak). A merge of both
  lanes' schema keys is a union.
- Item 1d (peek card): already wired on main. `collect_call_art.json` maps BOTH `rivet_hide_p55` and `rivet_hide_p70`
  to `rivet_hide_p55.png` (n15 hero it14, b536742b4, DECISION hero/quest-hide-peek). The owner's verdict = kept as built.
  Evidence: `grep -n rivet_hide project/data/tables/collect_call_art.json` (lines 96-101). Film still owed.
