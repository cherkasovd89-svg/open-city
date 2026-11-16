extends CanvasLayer
class_name TouchControls

const TouchPadScript = preload("res://scripts/touch_pad.gd")
var pad: Control
var buttons: Dictionary = {}
var connected := false
var joy_id := -1
var joy_vector := Vector2.ZERO

func _ready() -> void:
    layer = 10
    _build_ui()
    Input.joy_connection_changed.connect(_on_joy_connection_changed)
    _refresh_mode()

func _build_ui() -> void:
    pad = TouchPadScript.new()
    pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    pad.mouse_filter = Control.MOUSE_FILTER_PASS
    add_child(pad)
    pad.gui_input.connect(_on_pad_input)
    _make_button("JUMP", "jump", Vector2(-205,-135), Color(0.25,0.65,0.85,0.72))
    _make_button("HIT", "attack", Vector2(-105,-85), Color(0.83,0.56,0.25,0.78))
    _make_button("DASH", "dodge", Vector2(-105,-185), Color(0.48,0.42,0.75,0.78))
    _make_button("ICE", "frost_spell", Vector2(-300,-120), Color(0.35,0.78,0.95,0.82))
    _make_button("NOVA", "nova_spell", Vector2(-300,-215), Color(0.55,0.45,0.88,0.82))

func _make_button(label_text: String, action: String, offset: Vector2, tint: Color) -> void:
    var b := Button.new()
    b.text = label_text
    b.custom_minimum_size = Vector2(82,82)
    b.anchor_left = 1.0
    b.anchor_right = 1.0
    b.anchor_top = 1.0
    b.anchor_bottom = 1.0
    b.offset_left = offset.x - 41
    b.offset_right = offset.x + 41
    b.offset_top = offset.y - 41
    b.offset_bottom = offset.y + 41
    b.add_theme_font_size_override("font_size", 15)
    b.add_theme_color_override("font_color", Color(1,1,1,1))
    b.modulate = tint
    pad.add_child(b)
    b.button_down.connect(func(): Input.action_press(action))
    b.button_up.connect(func(): Input.action_release(action))
    buttons[action] = b

func _on_pad_input(event: InputEvent) -> void:
    if connected:
        return
    var base := Vector2(112, get_viewport().get_visible_rect().size.y - 126)
    if event is InputEventScreenTouch:
        if event.pressed and event.position.x < get_viewport().get_visible_rect().size.x * 0.42:
            joy_id = event.index
            _update_joystick(event.position, base)
        elif not event.pressed and event.index == joy_id:
            joy_id = -1
            joy_vector = Vector2.ZERO
            _set_axis("move_left", false)
            _set_axis("move_right", false)
            pad.set("joy_vector", joy_vector)
            pad.queue_redraw()
    elif event is InputEventScreenDrag and event.index == joy_id:
        _update_joystick(event.position, base)

func _update_joystick(pos: Vector2, base: Vector2) -> void:
    joy_vector = ((pos - base) / 65.0).limit_length(1.0)
    _set_axis("move_left", joy_vector.x < -0.22)
    _set_axis("move_right", joy_vector.x > 0.22)
    pad.set("joy_vector", joy_vector)
    pad.queue_redraw()

func _set_axis(action: String, pressed: bool) -> void:
    if pressed and not Input.is_action_pressed(action):
        Input.action_press(action)
    elif not pressed and Input.is_action_pressed(action):
        Input.action_release(action)

func _on_joy_connection_changed(_device: int, _is_connected: bool) -> void:
    _refresh_mode()

func _refresh_mode() -> void:
    connected = Input.get_connected_joypads().size() > 0
    for b in buttons.values():
        b.visible = not connected
    pad.set("connected", connected)
    if connected:
        _set_axis("move_left", false)
        _set_axis("move_right", false)
    pad.queue_redraw()
