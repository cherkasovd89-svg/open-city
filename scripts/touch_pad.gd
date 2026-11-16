extends Control
class_name TouchPad

var joy_vector := Vector2.ZERO
var connected := false

func _draw() -> void:
    if connected:
        return
    var c := Vector2(112, size.y - 126)
    draw_circle(c, 73, Color(0.08,0.12,0.18,0.28))
    draw_arc(c, 73, 0, TAU, 48, Color(0.8,0.88,1,0.35), 3.0)
    var knob := c + joy_vector * 35.0
    draw_circle(knob, 29, Color(0.65,0.78,0.92,0.55))
    draw_arc(knob, 29, 0, TAU, 32, Color(1,1,1,0.5), 2.0)
