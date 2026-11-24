# n28 combat 03: electro chain arcs and daze sparks in the halo look

- Code: `project/features/combat/weapons/art/weapon_fx_electro.gd` (`chain_plan`, `star_plan`, `stun_plan`), flag `--electro-cells` = before.
- Look: core `ElectricArc.CORE` 2 px alpha 1, halo `ElectricArc.HALO` 4.5 px a0.5 and 9 px a0.18; forks 3-4 per star, same widths, reach `ElectricArc.FORK_M` (chain) / 0.3 m (daze); daze stars get a faint ink under-halo (alpha 0.3, 9 px). Widths divide by the canvas screen scale.
- Not changed: fx_atlas cells 20-23 (`crackle`, melee), the in-flight bolt `ink_under` (weapon_fx_art.gd:91), `WeaponFxRay`.
- Stills/films: `C:/Users/kazda/kiro/gtai-masters/n28/combat/{stills,films}`, indexed in `frames.json`.
- Mutate: 6/15 killed on the second run (2/15 first); survivors are hash constants and the old cell path.
