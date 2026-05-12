from __future__ import annotations

from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Pillow is required. Install it with:")
    print("pip install pillow")
    raise SystemExit(1)


ROOT_DIR = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT_DIR / "assets" / "sprites" / "player"
OUTPUT_DIR = ROOT_DIR / "assets" / "sprites" / "npc"
OVERLAY_DIR = ROOT_DIR / "assets" / "sprites" / "npc_overlays"
ENABLE_OVERLAYS = False

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

NPC_CONFIG = {
    "mira": {
        "name": "Mira",
        "archetype": "fem",
        "shirt": (80, 200, 110),
        "pants": (45, 60, 95),
        "hair": (50, 35, 25),
        "skin": None,
        "overlays": ["hair_long"],
    },
    "pixel": {
        "name": "Pixel",
        "archetype": "neutral",
        "shirt": (160, 90, 220),
        "pants": (40, 40, 45),
        "hair": (25, 25, 30),
        "skin": None,
        "overlays": ["accessory_glasses"],
    },
    "nova": {
        "name": "Nova",
        "archetype": "fem",
        "shirt": (235, 205, 70),
        "pants": (110, 75, 45),
        "hair": (185, 150, 90),
        "skin": None,
        "overlays": ["hair_long"],
    },
    "neo": {
        "name": "Neo",
        "archetype": "masc",
        "shirt": (220, 80, 80),
        "pants": (35, 35, 35),
        "hair": (55, 35, 25),
        "skin": None,
        "overlays": [],
    },
    "luna": {
        "name": "Luna",
        "archetype": "fem",
        "shirt": (70, 130, 255),
        "pants": (60, 70, 110),
        "hair": (30, 30, 35),
        "skin": None,
        "overlays": ["hair_long"],
    },
    "axel": {
        "name": "Axel",
        "archetype": "masc",
        "shirt": (70, 180, 170),
        "pants": (50, 50, 60),
        "hair": (70, 45, 30),
        "skin": None,
        "overlays": ["jacket"],
    },
    "zara": {
        "name": "Zara",
        "archetype": "fem",
        "shirt": (210, 110, 150),
        "pants": (45, 45, 60),
        "hair": (20, 20, 25),
        "skin": None,
        "overlays": ["hair_long", "accessory_glasses"],
    },
}

# Editable mask colors sampled from assets/sprites/player/*.png.
SHIRT_BASE_COLORS = [
    (44, 86, 161),
    (47, 91, 168),
    (37, 71, 139),
    (33, 52, 100),
    (49, 85, 142),
    (63, 103, 178),
]

PANTS_BASE_COLORS = [
    (56, 72, 109),
    (34, 44, 73),
    (30, 36, 46),
    (52, 53, 59),
    (66, 64, 73),
]

HAIR_BASE_COLORS = [
    (27, 28, 30),
    (42, 39, 42),
    (52, 53, 59),
]

SKIN_BASE_COLORS = [
    (235, 191, 174),
    (238, 207, 190),
    (228, 170, 154),
    (222, 182, 166),
    (186, 123, 116),
    (169, 101, 102),
]

REGION_TOLERANCE = {
    "shirt": 34,
    "pants": 28,
    "hair": 24,
    "skin": 22,
}


def clamp(value: float, minimum: int = 0, maximum: int = 255) -> int:
    return max(minimum, min(maximum, int(round(value))))


def is_near_color(pixel_rgb: tuple[int, int, int], target_rgb: tuple[int, int, int], tolerance: int) -> bool:
    return all(abs(pixel_rgb[index] - target_rgb[index]) <= tolerance for index in range(3))


def in_vertical_band(y: int, height: int, region: str) -> bool:
    normalized_y = y / max(1, height)
    if region == "hair":
        return normalized_y <= 0.48
    if region == "shirt":
        return 0.32 <= normalized_y <= 0.72
    if region == "pants":
        return normalized_y >= 0.48
    if region == "skin":
        return 0.22 <= normalized_y <= 0.52
    return True


def is_region_pixel(
    r: int,
    g: int,
    b: int,
    a: int,
    y: int,
    height: int,
    base_colors: list[tuple[int, int, int]],
    region: str,
) -> bool:
    if a == 0:
        return False
    if max(r, g, b) < 20:
        return False
    if not in_vertical_band(y, height, region):
        return False
    tolerance = REGION_TOLERANCE.get(region, 28)
    return any(is_near_color((r, g, b), target, tolerance) for target in base_colors)


def preserve_luminance_color(r: int, g: int, b: int, tint: tuple[int, int, int], strength: float) -> tuple[int, int, int]:
    tint_r, tint_g, tint_b = tint
    lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
    shade = 0.52 + lum * 0.72
    shaded = (
        clamp(tint_r * shade),
        clamp(tint_g * shade),
        clamp(tint_b * shade),
    )
    return (
        clamp(r * (1.0 - strength) + shaded[0] * strength),
        clamp(g * (1.0 - strength) + shaded[1] * strength),
        clamp(b * (1.0 - strength) + shaded[2] * strength),
    )


def recolor_region(
    image: Image.Image,
    base_colors: list[tuple[int, int, int]],
    tint: tuple[int, int, int] | None,
    region: str,
    strength: float = 0.88,
) -> Image.Image:
    if tint is None:
        return image

    result = image.convert("RGBA")
    pixels = result.load()
    for y in range(result.height):
        for x in range(result.width):
            r, g, b, a = pixels[x, y]
            if is_region_pixel(r, g, b, a, y, result.height, base_colors, region):
                pixels[x, y] = (*preserve_luminance_color(r, g, b, tint, strength), a)
    return result


def apply_external_overlay(image: Image.Image, overlay_name: str, direction: str) -> tuple[Image.Image, bool]:
    overlay_path = OVERLAY_DIR / overlay_name / f"{direction}.png"
    if not overlay_path.exists():
        return image, False
    with Image.open(overlay_path) as overlay:
        overlay_rgba = overlay.convert("RGBA")
        if overlay_rgba.size != image.size:
            print(f"WARNING: overlay size mismatch: {overlay_path.relative_to(ROOT_DIR)}")
            return image, False
        composed = image.copy()
        composed.alpha_composite(overlay_rgba)
        return composed, True


def make_procedural_overlay(size: tuple[int, int], overlay_name: str, direction: str, config: dict) -> Image.Image:
    overlay = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    w, h = size
    hair = tuple(config.get("hair", (35, 30, 30)))
    shirt = tuple(config.get("shirt", (80, 120, 220)))

    if overlay_name == "hair_long":
        side = {
            "east": "right",
            "north-east": "right",
            "south-east": "right",
            "west": "left",
            "north-west": "left",
            "south-west": "left",
        }.get(direction, "both")
        if side in ("left", "both"):
            draw.rectangle((int(w * 0.30), int(h * 0.30), int(w * 0.36), int(h * 0.61)), fill=(*hair, 230))
        if side in ("right", "both"):
            draw.rectangle((int(w * 0.64), int(h * 0.30), int(w * 0.70), int(h * 0.61)), fill=(*hair, 230))
        draw.rectangle((int(w * 0.38), int(h * 0.22), int(w * 0.62), int(h * 0.30)), fill=(*hair, 225))

    elif overlay_name == "accessory_glasses" and direction not in ("north", "north-east", "north-west"):
        y = int(h * 0.37)
        draw.rectangle((int(w * 0.40), y, int(w * 0.46), y + 2), fill=(18, 20, 24, 230))
        draw.rectangle((int(w * 0.54), y, int(w * 0.60), y + 2), fill=(18, 20, 24, 230))
        draw.line((int(w * 0.47), y + 1, int(w * 0.53), y + 1), fill=(18, 20, 24, 230))

    elif overlay_name == "jacket":
        y0 = int(h * 0.47)
        y1 = int(h * 0.67)
        draw.line((int(w * 0.38), y0, int(w * 0.48), y1), fill=(24, 28, 34, 210), width=2)
        draw.line((int(w * 0.62), y0, int(w * 0.52), y1), fill=(24, 28, 34, 210), width=2)
        draw.line((int(w * 0.50), y0 + 2, int(w * 0.50), y1), fill=(*shirt, 180), width=1)

    return overlay


def apply_overlays(image: Image.Image, config: dict, direction: str, missing_overlays: set[str]) -> Image.Image:
    if not ENABLE_OVERLAYS:
        return image
    result = image
    for overlay_name in config.get("overlays", []):
        result, applied_external = apply_external_overlay(result, overlay_name, direction)
        if applied_external:
            continue
        missing_overlays.add(overlay_name)
        procedural = make_procedural_overlay(result.size, overlay_name, direction, config)
        result.alpha_composite(procedural)
    return result


def generate_npc_sprite(base_image: Image.Image, config: dict, direction: str, missing_overlays: set[str]) -> Image.Image:
    result = base_image.convert("RGBA")
    result = recolor_region(result, HAIR_BASE_COLORS, config.get("hair"), "hair", 0.92)
    result = recolor_region(result, SHIRT_BASE_COLORS, config.get("shirt"), "shirt", 0.90)
    result = recolor_region(result, PANTS_BASE_COLORS, config.get("pants"), "pants", 0.86)
    result = recolor_region(result, SKIN_BASE_COLORS, config.get("skin"), "skin", 0.35)
    result = apply_overlays(result, config, direction, missing_overlays)
    return result


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    OVERLAY_DIR.mkdir(parents=True, exist_ok=True)

    created_files: list[Path] = []
    missing_files: list[Path] = []
    missing_overlays: set[str] = set()

    for npc_id, config in NPC_CONFIG.items():
        npc_dir = OUTPUT_DIR / npc_id
        npc_dir.mkdir(parents=True, exist_ok=True)

        for direction in DIRECTIONS:
            source_path = SOURCE_DIR / f"{direction}.png"
            output_path = npc_dir / f"{direction}.png"

            if not source_path.exists():
                print(f"WARNING: missing base sprite: {source_path}")
                missing_files.append(source_path)
                continue

            with Image.open(source_path) as image:
                generated = generate_npc_sprite(image, config, direction, missing_overlays)
                generated.save(output_path)

            created_files.append(output_path)

    print("NPC variant generation complete.")
    print(f"NPCs generated: {', '.join(NPC_CONFIG.keys())}")
    print(f"Files created: {len(created_files)}")
    print(f"Missing base files: {len(missing_files)}")
    print(f"Output path: {OUTPUT_DIR.relative_to(ROOT_DIR)}")
    if missing_files:
        for path in missing_files:
            print(f" - {path.relative_to(ROOT_DIR)}")
    if missing_overlays:
        print("Optional overlays not found on disk; procedural fallbacks were used:")
        for overlay_name in sorted(missing_overlays):
            print(f" - {overlay_name}")
    print("Tune masks in SHIRT_BASE_COLORS, PANTS_BASE_COLORS, HAIR_BASE_COLORS and REGION_TOLERANCE.")


if __name__ == "__main__":
    main()
