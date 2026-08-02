from PIL import Image, ImageDraw
from pathlib import Path

src = Path(r"assets/images/logo.png")
base = Path(r"android/app/src/main/res")

img = Image.open(src).convert("RGBA")
w, h = img.size
pixels = img.load()
bg = pixels[0, 0][:3]

out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
op = out.load()
for y in range(h):
    for x in range(w):
        r, g, b, a = pixels[x, y]
        if a < 20:
            continue
        if abs(r - bg[0]) < 28 and abs(g - bg[1]) < 28 and abs(b - bg[2]) < 28:
            continue
        op[x, y] = (255, 255, 255, max(a, 220))

bbox = out.getbbox()
if bbox:
    out = out.crop(bbox)

pad = int(max(out.size) * 0.12)
side = max(out.size) + pad * 2
canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
ox = (side - out.size[0]) // 2
oy = (side - out.size[1]) // 2
canvas.paste(out, (ox, oy), out)

sizes = {
    "drawable-mdpi": 48,
    "drawable-hdpi": 72,
    "drawable-xhdpi": 96,
    "drawable-xxhdpi": 144,
    "drawable-xxxhdpi": 192,
}
for folder, size in sizes.items():
    dest_dir = base / folder
    dest_dir.mkdir(parents=True, exist_ok=True)
    resized = canvas.resize((size, size), Image.Resampling.LANCZOS)
    path = dest_dir / "ic_stat_onee.png"
    resized.save(path)
    print("wrote", path, size)

# Colorful large icon
color = Image.open(src).convert("RGBA")
cp = color.load()
color_out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
cop = color_out.load()
for y in range(h):
    for x in range(w):
        r, g, b, a = cp[x, y]
        if a < 20:
            continue
        if abs(r - bg[0]) < 28 and abs(g - bg[1]) < 28 and abs(b - bg[2]) < 28:
            continue
        cop[x, y] = (r, g, b, a)

bbox = color_out.getbbox()
if bbox:
    color_out = color_out.crop(bbox)

pad = int(max(color_out.size) * 0.12)
side = max(color_out.size) + pad * 2
large_canvas = Image.new("RGBA", (side, side), (251, 236, 179, 255))
ox = (side - color_out.size[0]) // 2
oy = (side - color_out.size[1]) // 2
large_canvas.paste(color_out, (ox, oy), color_out)

mask = Image.new("L", (side, side), 0)
draw = ImageDraw.Draw(mask)
radius = int(side * 0.18)
draw.rounded_rectangle((0, 0, side - 1, side - 1), radius=radius, fill=255)
rounded = Image.new("RGBA", (side, side), (0, 0, 0, 0))
rounded.paste(large_canvas, (0, 0))
rounded.putalpha(mask)

large_sizes = {
    "drawable-mdpi": 64,
    "drawable-hdpi": 96,
    "drawable-xhdpi": 128,
    "drawable-xxhdpi": 192,
    "drawable-xxxhdpi": 256,
}
for folder, size in large_sizes.items():
    dest_dir = base / folder
    resized = rounded.resize((size, size), Image.Resampling.LANCZOS)
    path = dest_dir / "ic_notification_large.png"
    resized.save(path)
    print("wrote", path, size)

print("done")
