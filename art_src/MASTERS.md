# Masters (GIT-06 tier 1)

Raw generations, layered files, contact sheets and `work/` folders never enter git. This folder
holds only manifests that record them.

- **Where the masters live:** a local disk plus a backup (spark gtai-phase-2, Wave 3). Path: TODO
  (owner to fill in, e.g. `D:\rtai-masters\`), and the backup target.
- **Manifest format:** one `<set>.manifest.json` per art set: `{file, sha256, tool, model, date,
  prompt_ref, seed}` per master, so a game-ready file in `project/` can be traced to its master.
- Game-ready exports go to `project/` through LFS; provenance lines go to `steam/ai-provenance/`.
