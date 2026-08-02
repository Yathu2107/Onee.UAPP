"""Regenerate notification large icon from assets/images/logo.png."""
from PIL import Image, ImageDraw
from pathlib import Path

src = Path(r"assets/images/logo.png")
base = Path(r"android/app/src/main/res")
img = Image.open(src).convert("RGBA")

# Keep logo as-is (cream bg), make rounded square for tray large-icon.
w, h = img.size
side = max(w, h)
canvas = Image.new("RGBA", (side, side), (251, 236, 179, 255))
canvas.paste(img, ((side - w) // 2, (side - h) // 2), img)

mask = Image.new("L", (side, side), 0)
draw = ImageDraw.Draw(mask)
r = int(side * 0.18)
draw.rounded_rectangle((0, 0, side - 1, side - 1), radius=r, fill=255)
out = Image.new("RGBA", (side, side), (0, 0, 0, 0))
out.paste(canvas, (0, 0))
out.putalpha(mask)

sizes = {
    "drawable-mdpi": 96,
    "drawable-hdpi": 144,
    "drawable-xhdpi": 192,
    "drawable-xxhdpi": 288,
    "drawable-xxxhdpi": 384,
}
for folder, size in sizes.items():
    dest = base / folder
    dest.mkdir(parents=True, exist_ok=True)
    out.resize((size, size), Image.Resampling.LANCZOS).save(
        dest / "ic_notification_large.png"
    )
    print("wrote", dest / "ic_notification_large.png", size)
print("done")
