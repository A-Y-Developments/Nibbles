#!/usr/bin/env python3
import json
import sys


def walk(node):
    ident = node.get("AXUniqueId") or ""
    label = (node.get("AXLabel") or "").replace("\n", " | ")[:80]
    node_type = node.get("type", "")
    frame = node.get("frame", {})
    interesting = ident or node_type in (
        "Button",
        "TextField",
        "SecureTextField",
        "Link",
        "Switch",
        "Slider",
    )
    if interesting or (node_type == "StaticText" and label):
        cx = frame.get("x", 0) + frame.get("width", 0) / 2
        cy = frame.get("y", 0) + frame.get("height", 0) / 2
        print(f"{node_type:18} id={ident:40} label={label:80} center=({cx:.0f},{cy:.0f})")
    for child in node.get("children", []):
        walk(child)


roots = json.load(sys.stdin)
for root in roots if isinstance(roots, list) else [roots]:
    walk(root)
