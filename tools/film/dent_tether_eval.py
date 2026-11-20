"""Build native-scale, same-tick Dent pairs from the scratch film runner's captures."""
import argparse
import io
import json
import math
import hashlib
import shutil
import statistics
import subprocess
import tempfile
from pathlib import Path

import cv2
import numpy as np
from PIL import Image
from shapely.geometry import LineString, box

from move_call_pairs import pair


FIRST, END = 68, 368
VIEWS = ("tilt70", "top")
LOOKS = ("strap", "strings")
CROP = (255, 228, 1214, 546)  # 959 px per panel, 2 px gutter. Includes the staged 20 m car.


def jsonl(path):
    return [json.loads(line) for line in path.read_text().splitlines()]


class Panel:
    def __init__(self, root, take, view, ppm, look):
        stem = root / f"{take}_{view}_{ppm}_{look}"
        self.video = cv2.VideoCapture(str(stem.with_suffix(".avi")))
        rows = jsonl(stem.with_suffix(".jsonl"))[1:]
        self.trace = {r[0]: r for r in rows}
        self.draw = {r["frame"]: r for r in jsonl(stem.with_suffix(".jsonl.draw"))}
        if int(self.video.get(cv2.CAP_PROP_FRAME_COUNT)) < max(self.trace) + 1:
            raise ValueError(f"Truncated movie {stem}")
        for frame, row in self.trace.items():
            if not FIRST <= row[1] < END:
                continue
            if row[2] != "dent" or abs(row[21] - ppm) > 0.01:
                raise ValueError(f"Unexpected form or scale at {stem} frame {frame}")
            # Review records the next SimClock index. The visible stage stores the tick just stepped.
            draw = self.draw[frame]
            if draw["tick"] + 1 != row[1]:
                raise ValueError(f"Draw and review disagree at {stem} frame {frame}")
            if view == "tilt70" and "lines" in draw:
                col = "3" if look == "strings" else "2"
                if not row[6].startswith("dent_sp_act.png/") or row[6].split("/")[-1] != col:
                    raise ValueError(f"Wrong steering cell at {stem} frame {frame}: {row[6]}")
        measured = {r["look"] for r in self.draw.values() if "look" in r}
        if measured != {look}:
            raise ValueError(f"{stem}: measured {measured} instead of {look}")
        self.next_frame = None

    def decode(self, frame):
        if frame != self.next_frame:
            self.video.set(cv2.CAP_PROP_POS_FRAMES, frame)
        ok, pixels = self.video.read()
        if not ok:
            raise ValueError(f"Missing frame {frame}")
        self.next_frame = frame + 1
        return Image.fromarray(cv2.cvtColor(pixels, cv2.COLOR_BGR2RGB))


def same_take(panels):
    first = panels[0].trace
    for panel in panels[1:]:
        # The camera, visible art and pixel density vary. Every driveside field must match.
        if first.keys() != panel.trace.keys() or any(
            first[f][:6] + first[f][7:21] + first[f][22:24] !=
            panel.trace[f][:6] + panel.trace[f][7:21] + panel.trace[f][22:24]
            for f in first
        ):
            raise ValueError("Unsynchronised review traces")


def bitmap(image):
    buf = io.BytesIO()
    image.save(buf, format="BMP")
    buf.seek(0)
    return buf


def make_pair(panels, frame, view, ppm, crop):
    # Use the native-pixel film helper for both stills and every encoded frame.
    tick = panels[0].trace[frame][1]
    labels = [f"{look.title()}    /    {view}    /    {ppm} px/m    /    tick {tick}" for look in LOOKS]
    output = io.BytesIO()
    output.name = "pair.bmp"
    pair(*(bitmap(p.decode(frame)) for p in panels), crop, labels, output)
    output.seek(0)
    return Image.open(output).convert("RGB")


def compose_movie(groups, frames, target, ppm, poster, crop):
    width = (crop[2] - crop[0]) * 2 + 2
    height = (crop[3] - crop[1] + 34) * len(groups)
    args = ["ffmpeg", "-loglevel", "error", "-y", "-f", "rawvideo", "-pix_fmt", "rgb24",
            "-s", f"{width}x{height}", "-r", "60", "-i", "-", "-an", "-threads", "4",
            "-c:v", "libx264", "-crf", "16", "-preset", "veryfast", "-pix_fmt", "yuv420p",
            "-movflags", "+faststart", str(target)]
    with subprocess.Popen(args, stdin=subprocess.PIPE) as encoder:
        for frame in frames:
            sheet = Image.new("RGB", (width, height))
            for i, (view, panels) in enumerate(groups.items()):
                row = make_pair(panels, frame, view, ppm, crop)
                sheet.paste(row, (0, i * row.height))
            if frame == poster:
                sheet.save(target.with_suffix(".jpg"), quality=96, subsampling=0)
            encoder.stdin.write(sheet.tobytes())
        encoder.stdin.close()
        if encoder.wait():
            raise RuntimeError("ffmpeg failed")


def stats(values):
    return dict(n=len(values), mean_us=round(statistics.mean(values), 2),
                p99_us=sorted(values)[math.ceil(0.99 * len(values)) - 1])


def overlap(row, view, grow):
    # Undo the camera's y squash before applying a constant world-space stroke radius.
    k = math.sin(math.radians(70)) if view == "tilt70" else 1
    strokes = [LineString([(x, y / k) for x, y in path]).buffer(grow / 2)
               for path in row["lines"]]
    hits = []
    for ident, x, y, end_x, end_y, live in row["boxes"]:
        bounds = box(x, y / k, end_x, end_y / k)
        if any(line.intersects(bounds) for line in strokes):
            hits.append((ident, live))
    return hits


def measures(panel, view, frames):
    all_rows = [panel.draw[f] for f in frames]
    active = [row for row in all_rows if "lines" in row]
    hits, live_hits, glow_hits = [], [], []
    for row in active:
        ink = overlap(row, view, row["width_px"])
        if ink:
            hits.append(row["frame"])
            if any(live for _, live in ink):
                live_hits.append(row["frame"])
        if row["look"] == "strings" and overlap(row, view, row["width_px"] * 4 / 1.5):
            glow_hits.append(row["frame"])
    return dict(draw_all=stats([r["draw_us"] for r in all_rows]),
                draw_tether_visible=stats([r["draw_us"] for r in active]),
                visible_frames=len(active), ink_overlap_frames=len(hits),
                living_guard_overlap_frames=len(live_hits), hit_frame_indices=hits,
                including_glow_frames=len(glow_hits) if active[0]["look"] == "strings" else len(hits))


def profiles(art_path, blank_path, lines):
    """Transverse RGB differences from lossless identical-geometry plates, isolated string spans."""
    art = np.asarray(Image.open(art_path).convert("RGB"), dtype=float)
    blank = np.asarray(Image.open(blank_path).convert("RGB"), dtype=float)
    delta = np.max(np.abs(art - blank), axis=2).astype(np.float32)
    # A different camera/pose or off-by-one frame also changes the background. Allow the
    # antialiased glow and eyelets ten pixels around each path, then check the control.
    mask = np.zeros(delta.shape, np.uint8)
    for pts in lines:
        cv2.polylines(mask, [np.rint(pts).astype(np.int32)], False, 255, 20)
    outside = np.count_nonzero((delta >= 16) & (mask == 0))
    if outside:
        raise ValueError(f"{outside} changed pixels outside the ink envelope in {art_path}")
    paths = [LineString(pts) for pts in lines]
    results = []
    for i, path in enumerate(paths):
        hits, widths, isolated = 0, [], 0
        for fraction in np.linspace(0.12, 0.88, 65):
            at = path.interpolate(fraction, normalized=True)
            if any(other.distance(at) < 5 for j, other in enumerate(paths) if j != i):
                continue
            isolated += 1
            before = path.interpolate(fraction - 0.002, normalized=True)
            after = path.interpolate(fraction + 0.002, normalized=True)
            normal = np.array([before.y-after.y, after.x-before.x])
            normal /= np.linalg.norm(normal)
            offsets = np.arange(-4, 4.05, 0.1)
            x = (at.x - 0.5 + offsets * normal[0]).astype(np.float32)
            y = (at.y - 0.5 + offsets * normal[1]).astype(np.float32)
            profile = cv2.remap(delta, x, y, cv2.INTER_LINEAR).ravel()
            centre = np.abs(offsets) < 1.6
            peak = max(profile[centre])
            if peak >= 16:
                hits += 1
                widths.append(0.1 * sum(profile >= peak / 2))
        results.append(dict(corner=["left_rear", "left_front", "right_rear", "right_front"][i],
                            isolated_samples=isolated, visible_samples=hits,
                            median_effective_px=round(float(np.median(widths)), 2) if widths else None))
    return results


def legacy_checks(root):
    checks = {}
    for tick in (160, 200):
        sides = []
        for name in ("base", "legacy"):
            directory = root / f"{name}-tilt70-64"
            row = next(r for r in jsonl(directory / "trace.jsonl")[1:] if r[1] == tick)
            path = directory / f"frame{row[0]:08}.png"
            sides.append((row[0], path.read_bytes(), np.asarray(Image.open(path).convert("RGB"))))
        a, b = sides
        if a[0] != b[0] or a[1] != b[1] or not np.array_equal(a[2], b[2]):
            raise ValueError(f"Legacy differs at tick {tick}")
        checks[tick] = dict(frame=a[0], png_byte_identical=True, rgb_identical=True,
                            sha256=hashlib.sha256(b[1]).hexdigest())
    return checks


def run(root, out, legacy=None):
    scratch = out / "scratch" / "a4"
    scratch.mkdir(parents=True, exist_ok=True)
    def load(take, view, ppm):
        return [Panel(root, take, view, ppm, look) for look in LOOKS]
    stock = {v: load("attack", v, 32) for v in VIEWS}
    close = {"tilt70": load("attack", "tilt70", 64)}
    far = {v: load("range", v, 32) for v in VIEWS}
    same_take([p for group in [*stock.values(), *close.values()] for p in group])
    same_take([p for group in far.values() for p in group])
    sample = stock["top"][0]
    frames = [f for f, row in sample.trace.items() if FIRST <= row[1] < END]
    if {sample.trace[f][1] for f in frames} != set(range(FIRST, END)):
        raise ValueError("Incomplete arena tick range")
    result = dict(schema="gtai.dent-tether-eval/1", seed=20261103, tick_range=[FIRST, END-1],
                  movie_frames=len(frames), render_scope="The fourth tilt act cell supplies both hands. "
                  "The turn moves the inside roof attachments toward the centre and lifts them in projection. "
                  "The car uses its normal chassis drawing.",
                  timing="CONTENDED; CPU wall time around DentView._draw, "
                  "including the active tether, excluding the probe, body posing and GPU. Nearest-rank p99.",
                  clutter="Frames counted once including repeated held ticks. Ink band vs on-screen "
                  "axis-aligned boxes of nontransparent, visible guard rig sprites, including fallen guards. "
                  "excluding shadows, corner rings and strap buckle. Glow counted separately.",
                  widths="At 32 px/m: 1 px coloured core, 1.5 px total ink band, 4 px glow; strap 15.36 px. " +
                  "Effective width: median full width at half maximum RGB change vs same-frame lossless " +
                  "no-strings plate, samples at least 5 px from other strands, peak >=16/255.",
                  stock_max_distance_m=max(r.get("distance_m", 0) for r in sample.draw.values()),
                  stats={}, stills={})
    for ppm, group in [(32, stock), (64, close)]:
        for view, panels in group.items():
            result["stats"][f"{view}_{ppm}"] = {
                look: measures(panel, view, frames) for look, panel in zip(LOOKS, panels)}
    poster = min((f for f in frames if "distance_m" in sample.draw[f]),
                 key=lambda f: abs(sample.draw[f]["distance_m"] - 12))
    result["poster_tick"] = sample.trace[poster][1]
    for target, group in [(5, stock), (20, far)]:
        ref = group["top"][0]
        frame = min((f for f, r in ref.draw.items() if "distance_m" in r),
                    key=lambda f: abs(ref.draw[f]["distance_m"] - target))
        row = ref.draw[frame]
        tick = ref.trace[frame][1]
        if abs(row["distance_m"] - target) > 0.4:
            raise ValueError(f"Missing {target} m mark: nearest {row['distance_m']}")
        result["stills"][target] = dict(tick=tick, stage_tick=row["tick"], frame=frame, actual_m=row["distance_m"],
            staging="stock" if target == 5 else "same seed, actions and aim headings from the farther mark; parked at (14, -1.8) m, cursor reach 18 m")
        for view, panels in group.items():
            name = f"dent_{target}m_{view}_32_t{tick}"
            base = "attack" if target == 5 else "range"
            def still(arm):
                return root / f"{base}_{view}_32_{arm}.jsonl.png"
            for look in LOOKS:
                shutil.copyfile(still(look), scratch / f"{name}_{look}.png")
            pair(still("strap"), still("strings"), CROP,
                 [f"{look.title()}    /    {view}    /    {row['distance_m']:.2f} m    /    tick {tick}"
                  for look in LOOKS], scratch / f"{name}_pair.png")
            blank_rows = jsonl(root / f"{base}_{view}_32_blank.jsonl.draw")
            blank = min((r for r in blank_rows if "distance_m" in r),
                        key=lambda r: abs(r["distance_m"] - target))
            lines = panels[1].draw[frame]["lines"]
            if blank["frame"] != frame or blank["lines"] != lines:
                raise ValueError("No-ink plate differs in geometry or timing")
            strand_stats = profiles(still("strings"), still("blank"), lines)
            result["stills"][target][view] = dict(
                grip_separation_px=round(math.dist(lines[0][0], lines[2][0]), 2),
                all_four_detectable=all(s["visible_samples"] > 0 for s in strand_stats),
                strands=strand_stats)
    compose_movie(stock, frames, out / "dent_tether_strap_vs_strings_32.mp4", 32, poster, CROP)
    compose_movie(close, frames, scratch / "dent_tether_strap_vs_strings_64.mp4", 64, poster, (0, 170, 1279, 594))
    if legacy:
        result["legacy"] = legacy_checks(legacy)
    (scratch / "strings_eval.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("captures", type=Path)
    parser.add_argument("masters", type=Path)
    parser.add_argument("--legacy", type=Path, help="a3b-film reference and fresh legacy captures")
    args = parser.parse_args()
    args.masters.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=args.masters, prefix=".dent-tether-") as tmp:
        staged = Path(tmp)
        run(args.captures, staged, args.legacy)
        # Validate and encode the complete set before replacing earlier review copies.
        files = sorted(staged.rglob("*"), key=lambda f: f.name == "strings_eval.json")
        for src in files:
            if src.is_file():
                dest = args.masters / src.relative_to(staged)
                dest.parent.mkdir(parents=True, exist_ok=True)
                src.replace(dest)
