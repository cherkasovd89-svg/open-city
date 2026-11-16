extends Node2D
class_name WorldArt

var kind := "platform"
var width := 200.0
var variant := 0

func _draw() -> void:
    match kind:
        "platform":
            _draw_platform()
        "tree":
            _draw_tree()
        "mushroom":
            _draw_mushroom()
        "crystal":
            _draw_crystal()
        "ruin":
            _draw_ruin()
        "grass":
            _draw_grass()

func _draw_platform() -> void:
    draw_rect(Rect2(0, 0, width, 70), Color("#172c36"))
    draw_rect(Rect2(0, 0, width, 12), Color("#52745c"))
    draw_rect(Rect2(0, 12, width, 5), Color("#344c43"))
    for i in range(int(width / 46.0)):
        var xx := float(i) * 46.0 + 8.0
        draw_line(Vector2(xx, 18), Vector2(xx + 10, 34), Color("#9b8b63"), 2.0)
        draw_line(Vector2(xx + 17, 39), Vector2(xx + 25, 59), Color("#30464a"), 2.0)
    for i in range(int(width / 90.0)):
        var xx := float(i) * 90.0 + 20.0
        draw_colored_polygon(PackedVector2Array([Vector2(xx, 2), Vector2(xx + 9, -15), Vector2(xx + 17, 2)]), Color("#6e9a68"))

func _draw_tree() -> void:
    var scale_factor := 0.82 + float(variant % 4) * 0.12
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(scale_factor, scale_factor))
    draw_colored_polygon(PackedVector2Array([Vector2(-18, 12), Vector2(-12, -100), Vector2(-24, -190), Vector2(-9, -285), Vector2(10, -300), Vector2(15, -205), Vector2(28, -125), Vector2(18, 12)]), Color("#263b39"))
    draw_line(Vector2(0, -30), Vector2(-72, -132), Color("#3b5145"), 13.0, true)
    draw_line(Vector2(5, -75), Vector2(80, -170), Color("#3b5145"), 10.0, true)
    for i in range(7):
        var x := float((i * 47 + variant * 29) % 150) - 75.0
        var y := -170.0 - float((i * 31 + variant * 17) % 125)
        var radius := 35.0 + float((i * 13 + variant) % 22)
        var leaf: Color = [Color("#294b47"), Color("#31584b"), Color("#3c624d"), Color("#456b53")][i % 4]
        draw_circle(Vector2(x, y), radius, leaf)
        draw_circle(Vector2(x - radius * 0.25, y - radius * 0.24), radius * 0.42, leaf.lightened(0.12))
    draw_set_transform(Vector2.ZERO)

func _draw_mushroom() -> void:
    var stem_height := 17.0 + float(variant % 3) * 4.0
    draw_colored_polygon(PackedVector2Array([Vector2(-5, 0), Vector2(-4, -stem_height), Vector2(5, -stem_height), Vector2(7, 0)]), Color("#d8c9a5"))
    draw_colored_polygon(PackedVector2Array([Vector2(-19, -stem_height + 2), Vector2(-14, -stem_height - 12), Vector2(0, -stem_height - 19), Vector2(15, -stem_height - 12), Vector2(20, -stem_height + 2)]), Color("#b65d70") if variant % 2 == 0 else Color("#d39a57"))
    for i in range(4):
        draw_circle(Vector2(float(i * 8 - 12), -stem_height - 8.0 - float(i % 2) * 4.0), 2.2, Color("#f4dfb4"))

func _draw_crystal() -> void:
    var h := 34.0 + float(variant % 3) * 13.0
    draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(-13, -h * 0.55), Vector2(-5, -h), Vector2(10, -h * 0.78), Vector2(15, -h * 0.22)]), Color("#327d91"))
    draw_colored_polygon(PackedVector2Array([Vector2(-5, -h * 0.15), Vector2(-5, -h), Vector2(4, -h * 0.72), Vector2(8, -h * 0.3)]), Color("#a4f1f1"))
    draw_line(Vector2(-17, 0), Vector2(18, 0), Color("#6e9d87"), 3.0)
    draw_circle(Vector2(0, -h * 0.55), h * 0.58, Color(0.25, 0.8, 1.0, 0.10))

func _draw_ruin() -> void:
    draw_rect(Rect2(-24, -100, 48, 100), Color("#53605a"))
    draw_rect(Rect2(-31, -106, 62, 12), Color("#788174"))
    draw_rect(Rect2(-17, -82, 8, 58), Color("#354b49"))
    draw_rect(Rect2(8, -82, 8, 58), Color("#354b49"))
    draw_line(Vector2(-24, -50), Vector2(24, -50), Color("#89917b"), 3.0)
    draw_colored_polygon(PackedVector2Array([Vector2(-24, -100), Vector2(-10, -118), Vector2(4, -103), Vector2(18, -119), Vector2(24, -100)]), Color("#53605a"))
    draw_circle(Vector2(0, -61), 8.0, Color("#203b43"))

func _draw_grass() -> void:
    for i in range(5):
        var x := float(i - 2) * 7.0
        var height := 12.0 + float((i * 11 + variant * 7) % 15)
        draw_line(Vector2(x, 0), Vector2(x - 4.0 + float(i % 3) * 4.0, -height), Color("#78a66c"), 2.2, true)
