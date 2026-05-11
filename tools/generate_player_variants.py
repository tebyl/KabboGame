from __future__ import annotations

import shutil
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Pillow is required. Install it with:")
    print("pip install pillow")
    raise SystemExit(1)


ROOT_DIR = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT_DIR / "assets" / "sprites" / "player"
OUTPUT_DIR = ROOT_DIR / "assets" / "sprites" / "player_variants"

DIRECTIONS = [
    "east",
    "west",
    "north",
    "south",
    "north-east",
    "north-west",
    "south-east",
    "south-west",
]

TINTS = {
    "default": None,
    "blue": (80, 150, 255),
    "green": (80, 220, 130),
    "red": (240, 90, 90),
    "yellow": (245, 210, 80),
    "purple": (170, 100, 255),
}


def recolor_image(image: Image.Image, tint: tuple[int, int, int]) -> Image.Image:
    source = image.convert("RGBA")
    result = Image.new("RGBA", source.size)
    source_pixels = source.load()
    result_pixels = result.load()

    tint_r, tint_g, tint_b = tint
    for y in range(source.height):
        for x in range(source.width):
            r, g, b, a = source_pixels[x, y]
            if a == 0:
                result_pixels[x, y] = (r, g, b, a)
                continue
            new_r = int(r * 0.65 + tint_r * 0.35)
            new_g = int(g * 0.65 + tint_g * 0.35)
            new_b = int(b * 0.65 + tint_b * 0.35)
            result_pixels[x, y] = (new_r, new_g, new_b, a)
    return result


def main() -> None:
    created_files: list[Path] = []
    missing_files: list[Path] = []

    for variant, tint in TINTS.items():
        variant_dir = OUTPUT_DIR / variant
        variant_dir.mkdir(parents=True, exist_ok=True)

        for direction in DIRECTIONS:
            source_path = SOURCE_DIR / f"{direction}.png"
            output_path = variant_dir / f"{direction}.png"

            if not source_path.exists():
                print(f"WARNING: missing base sprite: {source_path}")
                missing_files.append(source_path)
                continue

            if tint is None:
                shutil.copyfile(source_path, output_path)
            else:
                with Image.open(source_path) as image:
                    recolored = recolor_image(image, tint)
                    recolored.save(output_path)

            created_files.append(output_path)

    print("Player variant generation complete.")
    print(f"Variants generated: {', '.join(TINTS.keys())}")
    print(f"Files created: {len(created_files)}")
    print(f"Missing base files: {len(missing_files)}")
    if missing_files:
        for path in missing_files:
            print(f" - {path.relative_to(ROOT_DIR)}")


if __name__ == "__main__":
    main()
