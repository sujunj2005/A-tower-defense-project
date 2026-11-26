"""Create original development textures when the local art pack is absent."""

import re
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REFERENCE = re.compile(r'''res://(images/[^"'\r\n]+\.png)["']''')


def chunk(kind, data):
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))


def placeholder(path):
    terrain = path.name == "Outside_A2.png"
    projectile = path.parent.name == "projectiles"
    width, height = (768, 576) if terrain else (32, 16) if projectile else (128, 128)
    seed = zlib.crc32(path.name.encode())
    pixels = bytearray()
    for y in range(height):
        pixels.append(0)
        for x in range(width):
            if terrain:
                tile = (x // 48 + 3 * (y // 48)) % 5
                pixels.extend((64 + 9 * tile, 94 + 9 * tile, 77 + 5 * tile, 255))
            else:
                solid = (2 * x / width - 1) ** 2 + (2 * y / height - 1) ** 2 < 0.72
                pixels.extend((100 + seed % 100, 120 + (seed >> 8) % 85, 165, 255 if solid else 0))
    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) + chunk(b"IDAT", zlib.compress(pixels)) + chunk(b"IEND", b"")


def main():
    paths = set()
    for directory in ("scenes", "scripts", "resources", "data"):
        for file in (ROOT / directory).rglob("*"):
            if file.suffix in {".gd", ".tscn", ".tres", ".json"}:
                for match in REFERENCE.findall(file.read_text(encoding="utf-8-sig")):
                    if match.count("%d") == 2:
                        paths.update(match % (row, col) for row in range(4) for col in range(4))
                    elif "%" not in match:
                        paths.add(match)
    count = 0
    image_root = (ROOT / "images").resolve()
    for path in sorted(paths):
        destination = (ROOT / path).resolve()
        if not destination.is_relative_to(image_root):
            raise ValueError(f"Texture path escapes images/: {path}")
        if destination.is_file():
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        with destination.open("xb") as file:
            file.write(placeholder(destination))
        count += 1
    print(f"Development placeholder textures created: {count}")


if __name__ == "__main__":
    main()
