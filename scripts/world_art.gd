extends Node2D
class_name WorldArt

var kind := "platform"
var width := 200.0

func _draw() -> void:
    if kind == "platform":
        draw_rect(Rect2(0,0,width,70), Color("#172c36"))
        draw_rect(Rect2(0,0,width,12), Color("#52745c"))
        for i in range(int(width / 46.0)):
            var xx := float(i) * 46.0 + 8.0
            draw_line(Vector2(xx,13), Vector2(xx + 10,28), Color("#9b8b63"), 2.0)
            draw_line(Vector2(xx + 17,32), Vector2(xx + 25,53), Color("#30464a"), 2.0)
        for i in range(int(width / 90.0)):
            var xx := float(i) * 90.0 + 20.0
            draw_colored_polygon(PackedVector2Array([Vector2(xx,0),Vector2(xx+9,-15),Vector2(xx+17,0)]), Color("#6e9a68"))
    elif kind == "enemy":
        draw_circle(Vector2(0,-18), 23, Color("#8e5361"))
        draw_circle(Vector2(-8,-22), 4, Color("#f3d58b"))
        draw_circle(Vector2(8,-22), 4, Color("#f3d58b"))
        draw_arc(Vector2(0,-16), 15, 0.15, 2.95, 16, Color("#281e2a"), 3.0)
        draw_colored_polygon(PackedVector2Array([Vector2(-18,-5),Vector2(-30,8),Vector2(-10,3)]), Color("#694451"))
        draw_colored_polygon(PackedVector2Array([Vector2(18,-5),Vector2(30,8),Vector2(10,3)]), Color("#694451"))
