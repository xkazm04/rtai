"""Estimate the download size of exported .pck files (n9 perf it9).

A depot store compresses a build in fixed-size chunks, so the whole-file ratio flatters it. This
compresses every 1 MB chunk on its own with LZMA (preset 6) and zlib (level 6) and prints the sums:
the band a chunked store lands in. Lossless .ctex are WebP (already entropy-coded, ~0 % saved);
BC7 .bptc.ctex are raw blocks (they compress well), so install and download size move apart.

Usage: python -I tools/perf/pck_download.py <a.pck> [<b.pck> ...]
"""

import lzma
import sys
import zlib
from concurrent.futures import ProcessPoolExecutor

CHUNK = 1 << 20


def sizes(block: bytes) -> tuple[int, int]:
    return len(lzma.compress(block, preset=6)), len(zlib.compress(block, 6))


def main(paths: list[str]) -> None:
    for path in paths:
        with open(path, "rb") as f:
            data = f.read()
        chunks = [data[i : i + CHUNK] for i in range(0, len(data), CHUNK)]
        with ProcessPoolExecutor(4) as ex:
            res = list(ex.map(sizes, chunks, chunksize=8))
        print(
            "%s raw %.1f MB  lzma/1MB %.1f MB  zlib/1MB %.1f MB"
            % (path, len(data) / 1e6, sum(a for a, _ in res) / 1e6, sum(b for _, b in res) / 1e6)
        )


if __name__ == "__main__":
    main(sys.argv[1:])
