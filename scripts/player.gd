extends CharacterBody2D
class_name Hero

signal health_changed(value: int)
signal landed

const SPEED := 310.0
const ACCEL := 1800.0
const FRICTION := 2100.0
const JUMP_VELOCITY := -650.0
const GRAVITY := 1650.0

var facing := 1
var health := 5
var attack_timer := 0.0
var dodge_timer := 0.0
var invulnerable := 0.0
var anim_time := 0.0
var was_airborne := false

func _ready() -> void:
    collision_layer = 1
    collision_mask = 1
    floor_snap_length = 12.0
    add_to_group("hero")
    var shape := CollisionShape2D.new()
    var capsule := CapsuleShape2D.new()
    capsule.radius = 18.0
    capsule.height = 76.0
    shape.shape = capsule
    shape.position.y = -38.0
    add_child(shape)
    var camera := Camera2D.new()
    camera.position = Vector2(0, -150)
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 5.0
    camera.limit_left = 0
    camera.limit_top = -1200
    camera.limit_bottom = 1600
    camera.limit_right = 5200
    add_child(camera)

func _physics_process(delta: float) -> void:
    anim_time += delta
    attack_timer = maxf(0.0, attack_timer - delta)
    dodge_timer = maxf(0.0, dodge_timer - delta)
    invulnerable = maxf(0.0, invulnerable - delta)

    var axis := Input.get_axis("move_left", "move_right")
    if absf(axis) > 0.12:
        facing = 1 if axis > 0 else -1
        if dodge_timer <= 0.0:
            velocity.x = move_toward(velocity.x, axis * SPEED, ACCEL * delta)
    elif dodge_timer <= 0.0:
        velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

    if not is_on_floor():
        velocity.y += GRAVITY * delta
        was_airborne = true
    else:
        if was_airborne:
            landed.emit()
        was_airborne = false
        if Input.is_action_just_pressed("jump"):
            velocity.y = JUMP_VELOCITY

    if Input.is_action_just_pressed("attack"):
        attack_timer = 0.24
    if Input.is_action_just_pressed("dodge") and dodge_timer <= 0.0:
        dodge_timer = 0.30
        invulnerable = 0.38
        velocity.x = facing * 680.0
        if not is_on_floor():
            velocity.y *= 0.45

    if dodge_timer > 0.0:
        velocity.x = facing * 680.0
    move_and_slide()
    queue_redraw()

func take_damage(amount: int = 1) -> void:
    if invulnerable > 0.0:
        return
    health = maxi(0, health - amount)
    invulnerable = 1.0
    health_changed.emit(health)

func heal(amount: int = 1) -> void:
    health = mini(5, health + amount)
    health_changed.emit(health)

func _draw() -> void:
    var run := absf(velocity.x) > 35.0 and is_on_floor()
    var swing := sin(anim_time * (13.0 if run else 3.0))
    var bob := absf(swing) * 2.5 if run else sin(anim_time * 2.0) * 1.2
    var alpha := 1.0
    if invulnerable > 0.0 and int(anim_time * 18.0) % 2 == 0:
        alpha = 0.35
    draw_set_transform(Vector2(0, bob), 0, Vector2(float(facing), 1))
    var cloth := Color(0.12, 0.22, 0.34, alpha)
    var gold := Color(0.88, 0.62, 0.25, alpha)
    var skin := Color(0.91, 0.69, 0.53, alpha)
    # cloak and torso
    draw_colored_polygon(PackedVector2Array([Vector2(-14,-58),Vector2(12,-58),Vector2(19,-20),Vector2(0,-12),Vector2(-20,-20)]), cloth)
    draw_rect(Rect2(-11,-55,22,29), Color(0.24,0.34,0.42,alpha))
    # legs
    var leg := swing * 5.0 if run else 0.0
    draw_line(Vector2(-6,-19), Vector2(-8+leg,-3), Color(0.12,0.14,0.19,alpha), 8.0, true)
    draw_line(Vector2(6,-19), Vector2(8-leg,-3), Color(0.12,0.14,0.19,alpha), 8.0, true)
    draw_line(Vector2(-8+leg,-4), Vector2(0+leg,-2), gold, 7.0, true)
    draw_line(Vector2(8-leg,-4), Vector2(16-leg,-2), gold, 7.0, true)
    # arm and sword
    draw_line(Vector2(10,-49), Vector2(19,-31), skin, 7.0, true)
    if attack_timer > 0.0:
        draw_line(Vector2(18,-34), Vector2(65,-62), Color(0.78,0.91,1.0,alpha), 5.0, true)
        draw_arc(Vector2(12,-43), 54, -1.0, 0.8, 24, Color(0.65,0.88,1.0,0.8), 4.0, true)
    else:
        draw_line(Vector2(18,-31), Vector2(27,-52), Color(0.72,0.82,0.9,alpha), 4.0, true)
        draw_line(Vector2(27,-52), Vector2(34,-62), Color(0.86,0.92,1.0,alpha), 3.0, true)
    # head, hood and face
    draw_circle(Vector2(0,-69), 13, Color(0.09,0.15,0.22,alpha))
    draw_circle(Vector2(2,-69), 9, skin)
    draw_colored_polygon(PackedVector2Array([Vector2(-13,-72),Vector2(-8,-87),Vector2(7,-88),Vector2(15,-73),Vector2(6,-79),Vector2(-4,-80)]), cloth)
    draw_circle(Vector2(6,-69), 1.8, Color(0.12,0.16,0.2,alpha))
    draw_set_transform(Vector2.ZERO)
