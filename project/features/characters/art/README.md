# features/characters/art: D4 cutout parts (F-09)

Cutout-rig parts in the slice look (D4 hybrid): flat light values, a bold hand-inked outline, no hatching on the
characters. The cream sticker rim is NOT painted into the parts: the rig draws it as a halo under the body, so parts
can overlap without cream seams. Every file has a line in `steam/ai-provenance/2026-11.jsonl`; the raw sheets and
prompts are masters (`art_src/d4.manifest.json`).

| Folder | Character | Parts |
|---|---|---|
| `rivet/` | Rivet, the hero | helmet, collar, torso, pelvis, thigh, shin, foot (+ toe-off), upper arm and forearm (+ end-on cells), torch forearm, claw open / closed / with pistol, pistol, hose |
| `cop/` | cop, patrol and riot | torso, `head_cap` (patrol), `head_helmet` + `shield` (riot), pelvis, limbs, `forearm_pistol`, baton |
| `ped/` | pedestrian | `torso` (coat, cream) and `torso_jacket` (ink) are the two variants; heads `head_hat`, `head_hair`, `head_hood`; `torso_vest` spare; limbs |

- **Units:** part pixels, the spike rig's scale (1 part px = 0.1 world px; Rivet's torso is 297 px shoulder to
  shoulder). `parts.json` holds each part's size and joint pivots as measured by the slicer.
- **Orientation:** limbs face +x with the joint on the left; body parts are rotated so their front is +x.
- **Import:** Lossless with mipmaps (drawn far below 1:1).
- **Colour doctrine:** Rivet's only vermilion is the hazard collar, his only teal the torch tip. A cop carries one
  vermilion armour plate and shoulder pads. Civilians carry no colour.
- **Gameplay scale:** at 32 px/m the rig's sticker LOD prints each part as one flat value with an ink outline
  (the D1 `print_part` rule, ported with the rig); the D4 art shows from about 48 px/m up.
