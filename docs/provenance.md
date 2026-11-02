# AI provenance

The provenance log itself lives with the Steam metadata, because the build review compares the
build against the AI disclosure: [`steam/ai-provenance/`](../steam/ai-provenance/README.md)
holds the line schema (LEG-05) and one `<yyyy-mm>.jsonl` per month.

- Every shipped image and audio file has a provenance line or a `human:` line.
- Masters stay off git; [`art_src/MASTERS.md`](../art_src/MASTERS.md) says where they live.
- The disclosure text for the store (REL M16) is drafted from this log in
  `steam/content/ai-disclosure.md`.
- Pure AI output may not be copyrightable: record the human-authored layer in `human_edits` (LEG-11).
