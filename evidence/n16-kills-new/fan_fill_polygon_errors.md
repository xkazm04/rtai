# Fan-fill (80e6d139f): `Invalid polygon data, triangulation failed` per Gatling film

Command (per side): `node ../n16-tools/tools/film/film.mjs kill:gatling --victim=thug --ppm=32 --rev=<rev> --on=kill:1+40 --no-movie`,
then `grep -c 'Invalid polygon' build/film/gat_thug_<side>/film.log`. The thug has no drawn scraps, so he takes KillShredArt's coded scraps.

| side | rev | errors | from |
|---|---|---|---|
| before | e0cc756fa | 315 | 314 `kill_shred_art.gd:194` (draw_colored_polygon), 1 `rig_cast_shadows.gd:71` |
| after | 80e6d139f | 1 | 1 `rig_cast_shadows.gd:71` (not kills-new code) |

Both films ended UNVERIFIABLE only because this probe records no card rows (`--victim=thug` cannot be confirmed); the logs are complete.
