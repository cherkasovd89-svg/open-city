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
var cast_timer := 0.0
var cast_cooldown := 0.0
var dodge_timer := 0.0
var invulnerable := 0.0
var anim_time := 0.0
var was_airborne := false
var spell_orbs: Array[Dictionary] = []

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
    cast_timer = maxf(0.0, cast_timer - delta)
    cast_cooldown = maxf(0.0, cast_cooldown - delta)
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

    if Input.is_action_just_pressed("attack") and cast_cooldown <= 0.0:
        _cast_spell()
    if Input.is_action_just_pressed("dodge") and dodge_timer <= 0.0:
        dodge_timer = 0.30
        invulnerable = 0.38
        velocity.x = facing * 680.0
        if not is_on_floor():
            velocity.y *= 0.45

    if dodge_timer > 0.0:
        velocity.x = facing * 680.0

    for i in range(spell_orbs.size() - 1, -1, -1):
        var orb: Dictionary = spell_orbs[i]
        var orb_pos: Vector2 = orb["pos"]
        orb["pos"] = orb_pos + Vector2(float(orb["dir"]) * 760.0 * delta, 0.0)
        orb["life"] = float(orb["life"]) - delta
        spell_orbs[i] = orb
        if float(orb["life"]) <= 0.0:
            spell_orbs.remove_at(i)

    move_and_slide()
    queue_redraw()

func _cast_spell() -> void:
    cast_timer = 0.34
    cast_cooldown = 0.48
    var origin := Vector2(35.0 * facing, -48.0)
    spell_orbs.append({"pos": origin, "dir": facing, "life": 1.15, "phase": randf() * TAU})

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
    var running := absf(velocity.x) > 35.0 and is_on_floor()
    var airborne := not is_on_floor()
    var stride := sin(anim_time * 13.0) if running else 0.0
    var bob := absf(stride) * 2.0 if running else sin(anim_time * 2.1) * 1.8
    var robe := Color("#172b55")
    var robe_light := Color("#294c83")
    var gold := Color("#e6bd68")
    var skin := Color("#e9bd9c")
    var flicker := invulnerable > 0.0 and int(anim_time * 18.0) % 2 == 0
    var a := 0.35 if flicker else 1.0

    draw_set_transform(Vector2(0, bob), 0, Vector2(float(facing), 1))
    # soft magical ground shadow
    draw_set_transform(Vector2(0, 2), 0, Vector2(float(facing), 1))
    draw_colored_polygon(PackedVector2Array([Vector2(-24,0),Vector2(-18,-3),Vector2(-9,-5),Vector2(9,-5),Vector2(18,-3),Vector2(24,0),Vector2(18,3),Vector2(9,5),Vector2(-9,5),Vector2(-18,3)]), Color(0.01,0.02,0.06,0.36))
    draw_set_transform(Vector2(0, bob), 0, Vector2(float(facing), 1))

    # flowing split cloak, with animated hem
    var hem := sin(anim_time * 8.0) * 4.0 if running else sin(anim_time * 2.0) * 2.0
    draw_colored_polygon(PackedVector2Array([Vector2(-12,-55),Vector2(11,-57),Vector2(19,-23),Vector2(12,-8),Vector2(2,-18),Vector2(-9,-8),Vector2(-19,-25)]), Color(0.035,0.07,0.15,a))
    draw_colored_polygon(PackedVector2Array([Vector2(-12,-54),Vector2(-3,-50),Vector2(-8,-18),Vector2(-18,-22+hem),Vector2(-16,-38)]), Color(0.12,0.22,0.43,a))
    draw_colored_polygon(PackedVector2Array([Vector2(3,-53),Vector2(12,-54),Vector2(19,-23),Vector2(11,-11+hem),Vector2(5,-27)]), Color(0.10,0.18,0.36,a))
    # gold trim and star sigil
    draw_line(Vector2(-15,-25),Vector2(-10,-12+hem),gold,a * 2.0,true)
    draw_line(Vector2(14,-25),Vector2(10,-12+hem),gold,a * 2.0,true)
    draw_colored_polygon(PackedVector2Array([Vector2(-8,-53),Vector2(8,-53),Vector2(12,-23),Vector2(0,-17),Vector2(-12,-23)]), Color(0.10,0.16,0.29,a))
    draw_line(Vector2(0,-47),Vector2(0,-32),gold,a * 1.7,true)
    draw_line(Vector2(-6,-40),Vector2(6,-40),gold,a * 1.7,true)
    draw_circle(Vector2(0,-40),3.2,Color("#75dfff",a))
    # legs and boots
    var leg_a := stride * 7.0 if running else (3.0 if airborne else 0.0)
    draw_line(Vector2(-6,-18),Vector2(-8+leg_a,-4),Color("#172035",a),7.5,true)
    draw_line(Vector2(6,-18),Vector2(8-leg_a,-4),Color("#172035",a),7.5,true)
    draw_line(Vector2(-8+leg_a,-4),Vector2(1+leg_a,-3),gold,a * 6.0,true)
    draw_line(Vector2(8-leg_a,-4),Vector2(17-leg_a,-3),gold,a * 6.0,true)
    # left arm and hand
    draw_line(Vector2(-10,-48),Vector2(-18,-34),skin * Color(1,1,1,a),6.0,true)
    draw_circle(Vector2(-18,-33),4.0,skin * Color(1,1,1,a))
    # staff held in right hand
    draw_line(Vector2(13,-27),Vector2(24,-83),Color("#76502f",a),5.0,true)
    draw_line(Vector2(14,-29),Vector2(25,-82),gold,a * 1.1,true)
    draw_circle(Vector2(25,-87),8.0,Color(0.18,0.55,0.95,a))
    draw_circle(Vector2(25,-87),5.0,Color(0.55,0.91,1.0,a))
    draw_arc(Vector2(25,-87),12.0,anim_time*1.5,anim_time*1.5+4.6,24,Color(0.43,0.78,1.0,a),1.8,true)
    # casting arm extends forward
    if cast_timer > 0.0:
        draw_line(Vector2(10,-49),Vector2(28,-46),skin * Color(1,1,1,a),7.0,true)
        draw_circle(Vector2(31,-45),4.5,Color("#b9f2ff",a))
        draw_circle(Vector2(31,-45),10.0,Color(0.18,0.65,1.0,0.25*a))
    else:
        draw_line(Vector2(10,-49),Vector2(16,-34),skin * Color(1,1,1,a),7.0,true)
    # face, hair and hood
    draw_circle(Vector2(0,-69),13.0,Color("#101a32",a))
    draw_circle(Vector2(2,-69),9.2,skin * Color(1,1,1,a))
    draw_colored_polygon(PackedVector2Array([Vector2(-13,-72),Vector2(-12,-83),Vector2(-4,-90),Vector2(8,-87),Vector2(15,-75),Vector2(7,-79),Vector2(0,-82),Vector2(-5,-77)]),Color("#101a2e",a))
    draw_colored_polygon(PackedVector2Array([Vector2(-12,-78),Vector2(-18,-67),Vector2(-13,-53),Vector2(-7,-58),Vector2(-8,-73)]),robe_light * Color(1,1,1,a))
    draw_circle(Vector2(6,-69),1.6,Color("#18243a",a))
    draw_line(Vector2(3,-63),Vector2(8,-63),Color("#a75f55",a),1.2,true)

    # orbiting particles around the crystal
    for i in range(3):
        var angle := anim_time * 2.2 + float(i) * TAU / 3.0
        var particle := Vector2(25,-87) + Vector2(cos(angle),sin(angle)) * 15.0
        draw_circle(particle,1.7,Color(0.55,0.88,1.0,0.8*a))

    # traveling arcane bolts, with a bright core and trailing runes
    for orb in spell_orbs:
        var p: Vector2 = orb["pos"]
        var phase := float(orb["phase"]) + anim_time * 10.0
        draw_line(p - Vector2(27,0),p,Color(0.15,0.58,1.0,0.42*a),9.0,true)
        draw_circle(p,10.0,Color(0.13,0.55,1.0,0.22*a))
        draw_circle(p,5.5,Color(0.38,0.83,1.0,a))
        draw_circle(p,2.3,Color(0.94,1.0,1.0,a))
        draw_arc(p,13.0,phase,phase+4.0,16,Color(0.55,0.84,1.0,0.9*a),1.8,true)

    # brief cast flash and ground rune
    if cast_timer > 0.0:
        var glow := 0.5 + 0.5 * sin(anim_time * 35.0)
        draw_arc(Vector2(30,-45),17.0,0.0,TAU,28,Color(0.42,0.83,1.0,glow*a),2.0,true)
    draw_set_transform(Vector2.ZERO)
