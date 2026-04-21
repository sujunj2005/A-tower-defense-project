from PIL import Image, ImageDraw
import math, os

os.makedirs("images/status_icons", exist_ok=True)

icons = {
    "status_slow":       ((51, 102, 230), "snow"),
    "status_dot":        ((230, 77, 26),   "fire"),
    "status_stun":       ((230, 230, 51),  "star"),
    "status_silence":    ((153, 77, 204),  "cross"),
    "status_confusion":  ((179, 102, 230), "?"),
    "status_armor_break":((204, 128, 26),  "shield"),
    "status_debuff":     ((128, 77, 77),   "down"),
}

SIZE = 20
CX = SIZE // 2
CY = SIZE // 2

for name, (rgb, shape) in icons.items():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse([1, 1, SIZE-2, SIZE-2], fill=(*rgb, 255), outline=(*[max(0,c-60) for c in rgb], 200))

    if shape == "snow":
        for i in range(6):
            a = i * math.pi / 3.0
            draw.line([CX+int(3*math.cos(a)), CY+int(3*math.sin(a)), CX+int(7*math.cos(a)), CY+int(7*math.sin(a))], fill=(255,255,255,240), width=1)
    elif shape == "fire":
        draw.rectangle([6, 4, 14, 14], fill=(255,255,50,220))
    elif shape == "star":
        pts = []
        for i in range(10):
            r = 7 if i % 2 == 0 else 3
            a = math.radians(-90 + i * 36)
            pts.append((CX + r*math.cos(a), CY + r*math.sin(a)))
        draw.polygon(pts, fill=(30,25,0,220))
    elif shape == "cross":
        draw.line([CX-4, CY, CX+4, CY], fill=(255,255,255,240), width=1)
        draw.line([CX, CY-4, CX, CY+4], fill=(255,255,255,240), width=1)
    elif shape == "?":
        draw.line([CX-3, CY-4, CX+3, CY-4], fill=(255,255,255,240), width=1)
        draw.line([CX, CY-4, CX, CY], fill=(255,255,255,240), width=1)
        draw.ellipse([CX-1, CY+2, CX+1, CY+4], fill=(255,255,255,240))
    elif shape == "shield":
        draw.arc([3, 3, SIZE-3, SIZE-3], -90, 270, fill=(*[max(0,c-80) for c in rgb], 200), width=1)
        draw.line([CX+1, CY-2, CX+3, CY], fill=(50,20,0,200), width=1)
    elif shape == "down":
        draw.polygon([(CX-5, 4), (CX+5, 4), (CX, 13)], fill=(255,255,255,240))

    path = f"images/status_icons/{name}.png"
    img.save(path)
    print(f"OK: {path}")

print("All done!")
