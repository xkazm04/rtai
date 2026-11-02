# AI provenance log (LEG-05, REL M16)

One JSON object per line in `<yyyy-mm>.jsonl`, one line per AI-made or AI-assisted asset that
ships. Append only; a correction is a new line for the same `file` with a later `date`.

| Field | Type | Meaning |
|---|---|---|
| `file` | string | repo path of the game-ready file (`project/...`) |
| `sha256` | string | hex SHA-256 of that file as committed |
| `tool` | string | the pipeline or app (e.g. `nano-banana`, `codex-image`, `tts`) |
| `model` | string | model id and version |
| `date` | string | ISO date of generation |
| `prompt_ref` | string | where the prompt lives (path in `art_src/` manifests, or a PoF id) |
| `references` | string[] | inputs used as references (own masters only; never franchise or real-artist refs, LEG-04) |
| `seed` | integer or null | generation seed when the tool exposes one |
| `human_edits` | string | what a human changed after generation (LEG-11), or `"none"` |
| `accepted_by` | string | who accepted it into the game |
| `ships_in` | string | PCK or build that carries it (e.g. `core.pck`) |

A purely human-made file gets a line with `"tool": "human:<name>"` instead. CI (TODO, the
lint job) checks that every shipped image and audio file has a line.

Example (not a real asset):

```json
{"accepted_by":"owner","date":"2026-11-02","file":"project/features/characters/art/rivet_head.png","human_edits":"none","model":"<model id>","prompt_ref":"art_src/rivet.manifest.json#head","references":[],"seed":1234,"sha256":"<64 hex>","ships_in":"core.pck","tool":"nano-banana"}
```
