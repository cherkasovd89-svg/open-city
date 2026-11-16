extends CharacterBody2D
class_name ForestFiend

signal defeated

const GRAVITY := 1500.0
const WALK_SPEED := 78.0
const CHASE_SPEED := 125.0

var health := 3
var facing := -1
var home_x := 0.0
var patrol_phase := 0.0
var attack_cooldown := 0.0
var hurt_flash := 0.0
var freeze_timer := 0.0
var death_timer := -1.0
var anim_time := 0.0
var hero: Node2D

func _ready() -> void:
    home_x = global_position.x
    add_to_group("mage_enemies")
    collision_layer = 1
    collision_mask = 1
    var body_shape := CollisionShape2D.new()
    var capsule := CapsuleShape2D.new()
    capsule.radius = 17.0
    capsule.height = 48.0
    body_shape.shape = capsule
    body_shape.position.y = -24.0
    add_child(body_shape)
    hero = get_tree().get_first_node_in_group("hero") as Node2D

func _physics_process(delta: float) -> void:
    anim_time += delta
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    hurt_flash = maxf(0.0, hurt_flash - delta)
    freeze_timer = maxf(0.0, freeze_timer - delta)

    if death_timer >= 0.0:
        death_timer += delta
        velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
        velocity.y += GRAVITY * delta
        move_and_slide()
        queue_redraw()
        if death_timer > 0.48:
            defeated.emit()
            queue_free()
        return

    if not is_instance_valid(hero):
        hero = get_tree().get_first_node_in_group("hero") as Node2D

    var distance := 99999.0
    if is_instance_valid(hero):
        distance = global_position.distance_to(hero.global_position)

    if freeze_timer > 0.0:
        velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
    elif distance < 340.0 and is_instance_valid(hero):
        facing = 1 if hero.global_position.x > global_position.x else -1
        if distance > 48.0:
            velocity.x = move_toward(velocity.x, facing * CHASE_SPEED, 650.0 * delta)
        else:
            velocity.x = move_toward(velocity.x, 0.0, 850.0 * delta)
            if attack_cooldown <= 0.0 and hero.has_method("take_damage"):
                hero.take_damage(1)
                attack_cooldown = 1.0
    else:
        patrol_phase += delta
        var patrol_target := home_x + sin(patrol_phase * 0.8) * 72.0
        facing = 1 if patrol_target > global_position.x else -1
        velocity.x = move_toward(velocity.x, facing * WALK_SPEED, 400.0 * delta)

    if not is_on_floor():
        velocity.y += GRAVITY * delta
    move_and_slide()
    queue_redraw()

func apply_freeze(duration: float) -> void:
    if death_timer < 0.0:
        freeze_timer = maxf(freeze_timer, duration)
        hurt_flash = maxf(hurt_flash, 0.12)

func take_damage(amount: int = 1) -> void:
    if death_timer >= 0.0:
        return
    health -= amount
    hurt_flash = 0.16
    if health <= 0:
        death_timer = 0.0
        velocity.y = -180.0
        velocity.x = -facing * 120.0
    else:
        velocity.x = -facing * 150.0

func _draw() -> void:
    var fade := 1.0
    if death_timer >= 0.0:
        fade = clampf(1.0 - death_timer * 1.8, 0.0, 1.0)
    var bob := sin(anim_time * 8.0) * 2.0 if death_timer < 0.0 else 0.0
    var skin := Color("#a35d70") if hurt_flash <= 0.0 else Color("#fff0cf")
    draw_set_transform(Vector2(0,bob), 0, Vector2(float(facing),1))
    # shadow
    draw_colored_polygon(PackedVector2Array([Vector2(-20,0),Vector2(-13,-4),Vector2(13,-4),Vector2(20,0),Vector2(13,4),Vector2(-13,4)]),Color(0.01,0.02,0.04,0.35*fade))
    # ragged body and limbs
    draw_colored_polygon(PackedVector2Array([Vector2(-14,-39),Vector2(12,-40),Vector2(18,-13),Vector2(8,-6),Vector2(-12,-8),Vector2(-20,-20)]),skin * Color(1,1,1,fade))
    draw_colored_polygon(PackedVector2Array([Vector2(-12,-12),Vector2(-24,-1),Vector2(-7,-5),Vector2(0,-13)]),Color(0.27,0.13,0.22,fade))
    draw_colored_polygon(PackedVector2Array([Vector2(11,-13),Vector2(24,-1),Vector2(7,-5),Vector2(0,-13)]),Color(0.27,0.13,0.22,fade))
    draw_line(Vector2(-7,-10),Vector2(-11,0),Color("#382b38",fade),6.0,true)
    draw_line(Vector2(8,-10),Vector2(12,0),Color("#382b38",fade),6.0,true)
    # spines
    for i in range(3):
        var yy := -35.0 + float(i)*9.0
        draw_colored_polygon(PackedVector2Array([Vector2(-11,yy),Vector2(-23,yy-7),Vector2(-15,yy+4)]),Color("#59415c",fade))
    # head, horns and eyes
    draw_circle(Vector2(1,-47),13.0,Color("#bd7a82",fade) if hurt_flash <= 0.0 else Color("#fff0cf",fade))
    draw_colored_polygon(PackedVector2Array([Vector2(-9,-54),Vector2(-19,-67),Vector2(-4,-61)]),Color("#44334d",fade))
    draw_colored_polygon(PackedVector2Array([Vector2(8,-54),Vector2(18,-66),Vector2(12,-53)]),Color("#44334d",fade))
    draw_circle(Vector2(6,-48),2.8,Color("#ffd46e",fade))
    draw_circle(Vector2(-4,-48),2.2,Color("#ffd46e",fade))
    draw_line(Vector2(-5,-39),Vector2(7,-39),Color("#442638",fade),2.0,true)
    if freeze_timer > 0.0 and death_timer < 0.0:
        draw_arc(Vector2(0,-28),25.0,0.0,TAU,24,Color("#9ceeff",0.9),3.0,true)
        draw_line(Vector2(-19,-12),Vector2(19,-12),Color("#b9f6ff",0.8),2.0,true)
        draw_circle(Vector2(-17,-60),2.5,Color("#d9fbff",0.95))
        draw_circle(Vector2(18,-57),2.5,Color("#d9fbff",0.95))
    # health pip bar
    if health < 3 and death_timer < 0.0:
        for i in range(3):
            draw_circle(Vector2(-8+i*8,-76),2.2,Color("#ff7180",fade) if i < health else Color(0.2,0.16,0.2,fade))
    draw_set_transform(Vector2.ZERO)
