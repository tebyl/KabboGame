from __future__ import annotations

import colorsys
import shutil
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Pillow is required. Install it with:")
    print("pip install pillow")
    raise SystemExit(1)


ROOT_DIR = Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT_DIR / "assets" / "sprites" / "room" / "room_wall_spritesheet.png"
OUTPUT_DIR = ROOT_DIR / "assets" / "sprites" / "room" / "walls"

MIN_WALL_LUMINANCE = 55
MAX_WALL_LUMINANCE = 245
SATURATION_LIMIT = 90
OUTLINE_DARK_LIMIT = 45

WALL_VARIANTS = {
    "default": None,
    "trim": {
        "tint": (230, 210, 175),
        "strength": 0.35,
    },
    "dark": {
        "tint": (85, 95, 120),
        "strength": 0.65,
    },
    "pastel": {
        "tint": (245, 210, 225),
        "strength": 0.45,
    },
    "blue": {
        "tint": (120, 170, 235),
        "strength": 0.55,
    },
    "green": {
        "tint": (130, 205, 155),
        "strength": 0.50,
    },
    "red": {
        "tint": (220, 125, 120),
        "strength": 0.50,
    },
    "purple": {
        "tint": (175, 135, 225),
        "strength": 0.55,
    },
}


def clamp(value: float, minimum: int = 0, maximum: int = 255) -> int:
    return max(minimum, min(maximum, int(round(value))))


def get_luminance(r: int, g: int, b: int) -> float:
    return 0.299 * r + 0.587 * g + 0.114 * b


def get_saturation(r: int, g: int, b: int) -> float:
    _, saturation, _ = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
    return saturation * 255.0


def is_wall_surface_pixel(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    if r < OUTLINE_DARK_LIMIT and g < OUTLINE_DARK_LIMIT and b < OUTLINE_DARK_LIMIT:
        return False

    luminance = get_luminance(r, g, b)
    if luminance < MIN_WALL_LUMINANCE or luminance > MAX_WALL_LUMINANCE:
        return False
    if get_saturation(r, g, b) > SATURATION_LIMIT:
        return False

    return True


def apply_tint_preserve_shading(
    r: int,
    g: int,
    b: int,
    tint: tuple[int, int, int],
    strength: float,
) -> tuple[int, int, int]:
    tint_r, tint_g, tint_b = tint
    luminance = get_luminance(r, g, b) / 255.0
    shade = 0.55 + luminance * 0.65

    shaded_r = clamp(tint_r * shade)
    shaded_g = clamp(tint_g * shade)
    shaded_b = clamp(tint_b * shade)

    new_r = clamp(r * (1.0 - strength) + shaded_r * strength)
    new_g = clamp(g * (1.0 - strength) + shaded_g * strength)
    new_b = clamp(b * (1.0 - strength) + shaded_b * strength)
    return new_r, new_g, new_b


def recolor_wall_spritesheet(
    image: Image.Image,
    tint: tuple[int, int, int],
    strength: float,
) -> Image.Image:
    source = image.convert("RGBA")
    result = Image.new("RGBA", source.size)
    source_pixels = source.load()
    result_pixels = result.load()

    for y in range(source.height):
        for x in range(source.width):
            r, g, b, a = source_pixels[x, y]
            if is_wall_surface_pixel(r, g, b, a):
                result_pixels[x, y] = (*apply_tint_preserve_shading(r, g, b, tint, strength), a)
            else:
                result_pixels[x, y] = (r, g, b, a)

    return result


def main() -> None:
    if not SOURCE_PATH.exists():
        print(f"Missing {SOURCE_PATH.relative_to(ROOT_DIR)}")
        raise SystemExit(1)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    source = Image.open(SOURCE_PATH).convert("RGBA")
    created_files: list[Path] = []

    for variant_name, config in WALL_VARIANTS.items():
        output_path = OUTPUT_DIR / f"room_wall_spritesheet_{variant_name}.png"
        if config is None:
            shutil.copyfile(SOURCE_PATH, output_path)
        else:
            recolored = recolor_wall_spritesheet(
                source,
                config["tint"],
                float(config["strength"]),
            )
            recolored.save(output_path)
        created_files.append(output_path)

    print("Wall variants generated")
    print(f"Source: {SOURCE_PATH.relative_to(ROOT_DIR)}")
    print(f"Output: {OUTPUT_DIR.relative_to(ROOT_DIR)}")
    print(f"Size: {source.width}x{source.height}")
    print(f"Variants: {', '.join(WALL_VARIANTS.keys())}")
    print("Files created:")
    for path in created_files:
        print(f"- {path.relative_to(ROOT_DIR)}")


if __name__ == "__main__":
    main()
