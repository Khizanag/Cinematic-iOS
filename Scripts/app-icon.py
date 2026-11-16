"""Generates Cinematic/Resource/AppIcon.icon: a film-strip C wrapping a play triangle.

    python3 Scripts/app-icon.py Cinematic/Resource/AppIcon.icon

Writes white glyph layers for the default appearance and brand-gradient ones
for dark; Liquid Glass, tinted, and clear appearances come from the system.
Preview every appearance with Icon Composer, or headless with its `ictool`.
"""
import json, math, os, sys

OUT = sys.argv[1]
C = 512.0

# Film-strip C
R_OUT, R_IN = 384.0, 236.0
GAP = 44.0                     # half-angle of the opening, degrees, centred on east
HOLE_W, HOLE_H = 50.0, 36.0    # tangential x radial
HOLE_R = 11.0
EDGE = 22.0                    # hole inset from the strip edge
HOLE_STEP = 30.0               # degrees between holes

# Play triangle
TRI = [(-158.0, -186.0), (-158.0, 186.0), (206.0, 0.0)]
TRI_OFFSET = (22.0, 0.0)
TRI_CORNER = 52.0

def pt(r, deg):
    a = math.radians(deg)
    return C + r * math.cos(a), C - r * math.sin(a)

def f(v):
    return f"{v:.2f}"

def strip_path():
    a0, a1 = GAP, 360.0 - GAP
    cap = (R_OUT - R_IN) / 2
    rm = (R_OUT + R_IN) / 2
    # Outer arc a0 -> a1 (counter-clockwise visually), round cap, inner arc back, round cap.
    x0, y0 = pt(R_OUT, a0); x1, y1 = pt(R_OUT, a1)
    x2, y2 = pt(R_IN, a1);  x3, y3 = pt(R_IN, a0)
    d = [f"M{f(x0)},{f(y0)}",
         f"A{f(R_OUT)},{f(R_OUT)} 0 1 0 {f(x1)},{f(y1)}",
         f"A{f(cap)},{f(cap)} 0 0 0 {f(x2)},{f(y2)}",
         f"A{f(R_IN)},{f(R_IN)} 0 1 1 {f(x3)},{f(y3)}",
         f"A{f(cap)},{f(cap)} 0 0 0 {f(x0)},{f(y0)}Z"]
    holes = []
    span = (360.0 - 2 * GAP)
    n = int(span // HOLE_STEP)
    start = GAP + (span - n * HOLE_STEP) / 2
    for i in range(n + 1):
        deg = start + i * HOLE_STEP
        for r in (R_OUT - EDGE - HOLE_H / 2, R_IN + EDGE + HOLE_H / 2):
            holes.append(rounded_rect_rotated(r, deg))
    return " ".join(d + holes)

def rounded_rect_rotated(r, deg):
    cx, cy = pt(r, deg)
    a = math.radians(deg)
    # radial unit (outward) and tangential unit, in SVG coordinates (y down)
    ux, uy = math.cos(a), -math.sin(a)
    tx, ty = -uy, ux
    hw, hh, rr = HOLE_W / 2, HOLE_H / 2, HOLE_R
    def P(t, u):
        return cx + t * tx + u * ux, cy + t * ty + u * uy
    seg = []
    corners = [((hw - rr, -hh), (hw, -hh), (hw, -hh + rr)),
               ((hw, hh - rr), (hw, hh), (hw - rr, hh)),
               ((-hw + rr, hh), (-hw, hh), (-hw, hh - rr)),
               ((-hw, -hh + rr), (-hw, -hh), (-hw + rr, -hh))]
    s = P(-hw + rr, -hh)
    seg.append(f"M{f(s[0])},{f(s[1])}")
    for a_, c_, b_ in corners:
        pa, pc, pb = P(*a_), P(*c_), P(*b_)
        seg.append(f"L{f(pa[0])},{f(pa[1])} Q{f(pc[0])},{f(pc[1])} {f(pb[0])},{f(pb[1])}")
    seg.append("Z")
    return " ".join(seg)

def triangle_path():
    pts = [(C + x + TRI_OFFSET[0], C + y + TRI_OFFSET[1]) for x, y in TRI]
    d = []
    n = len(pts)
    for i in range(n):
        p0, p1, p2 = pts[i - 1], pts[i], pts[(i + 1) % n]
        def toward(a, b, dist):
            dx, dy = b[0] - a[0], b[1] - a[1]
            L = math.hypot(dx, dy)
            return a[0] + dx / L * dist, a[1] + dy / L * dist
        a = toward(p1, p0, TRI_CORNER)
        b = toward(p1, p2, TRI_CORNER)
        d.append(("L" if d else "M") + f"{f(a[0])},{f(a[1])} Q{f(p1[0])},{f(p1[1])} {f(b[0])},{f(b[1])}")
    return " ".join(d) + "Z"

GRAD = ('<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">'
        '<stop offset="0" stop-color="#8A84FB"/><stop offset="1" stop-color="#F98AD0"/>'
        '</linearGradient></defs>')

def svg(path, fill, defs=""):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">'
            f'{defs}<path fill-rule="evenodd" fill="{fill}" d="{path}"/></svg>\n')

assets = os.path.join(OUT, "Assets")
os.makedirs(assets, exist_ok=True)
for name, path in (("strip", strip_path()), ("play", triangle_path())):
    open(os.path.join(assets, f"{name}.svg"), "w").write(svg(path, "#FFFFFF"))
    open(os.path.join(assets, f"{name}-dark.svg"), "w").write(svg(path, "url(#g)", GRAD))

def p3(hexstr, a=1.0):
    r, g, b = (int(hexstr[i:i + 2], 16) / 255 for i in (0, 2, 4))
    return f"srgb:{r:.5f},{g:.5f},{b:.5f},{a:.5f}"

def layer(name, glass=True):
    return {
        "image-name-specializations": [
            {"value": f"{name}.svg"},
            {"appearance": "dark", "value": f"{name}-dark.svg"},
        ],
        "name": name,
        "glass": glass,
        # The C opens to the right, so its visual weight sits left of centre.
        "position": {"scale": 1, "translation-in-points": [12, 0]},
    }

doc = {
    "fill-specializations": [
        {"value": {"linear-gradient": [p3("5B4BF0"), p3("F166BD")],
                   "orientation": {"start": {"x": 0.0, "y": 0.0}, "stop": {"x": 1.0, "y": 1.0}}}},
        {"appearance": "dark",
         "value": {"linear-gradient": [p3("1E1A36"), p3("0B0A12")],
                   "orientation": {"start": {"x": 0.5, "y": 0.0}, "stop": {"x": 0.5, "y": 1.0}}}},
    ],
    "groups": [
        {"layers": [layer("play")],
         "shadow": {"kind": "layer-color", "opacity": 0.5},
         "translucency": {"enabled": True, "value": 0.2},
         "specular": True},
        {"layers": [layer("strip")],
         "opacity": 0.82,
         "shadow": {"kind": "layer-color", "opacity": 0.5},
         "translucency": {"enabled": True, "value": 0.5},
         "specular": True},
    ],
    "supported-platforms": {"squares": "shared"},
}
json.dump(doc, open(os.path.join(OUT, "icon.json"), "w"), indent=2)
print("ok")
