extends Node2D

const HeroSceneScript = preload("res://scripts/player.gd")
const ControlsScript = preload("res://scripts/touch_controls.gd")
const WorldArtScript = preload("res://scripts/world_art.gd")
const ForestFiendScript = preload("res://scripts/forest_fiend.gd")

var hero: Hero
var ui: CanvasLayer
var health_label: Label
var enemies: Array[Node2D] = []
var time := 0.0

func _ready() -> void:
    _build_world()
    hero = HeroSceneScript.new()
    hero.position = Vector2(180, 0)
    add_child(hero)
    hero.health_changed.connect(_update_health)
    _build_hud()
    add_child(ControlsScript.new())

func _process(delta: float) -> void:
    time += delta
    queue_redraw()
    for enemy in enemies:
        if is_instance_valid(enemy):
            enemy.position.x += sin(time * 1.3 + float(enemy.get_instance_id() % 9)) * 0.35

func _build_world() -> void:
    # Main path through the enchanted forest.
    _platform(0, 1100, 0)
    _platform(1190, 850, 0)
    _platform(2110, 900, 0)
    _platform(3070, 900, 0)
    _platform(4030, 1200, 0)

    # Floating ledges create vertical routes and small exploration challenges.
    _platform(540, 190, -180)
    _platform(1420, 220, -210)
    _platform(2350, 220, -190)
    _platform(3300, 240, -230)
    _platform(4470, 250, -190)
    _platform(760, 180, -350)
    _platform(2600, 180, -370)
    _platform(3750, 180, -360)

    # Tall silhouettes sit behind the playable path to give the valley depth.
    for i in range(19):
        var x := float(i) * 285.0 - 120.0
        _make_prop("tree", x, 0.0, i, -2)

    # Ruined stonework, luminous plants and mushrooms mark points of interest.
    _make_prop("ruin", 2685.0, -370.0, 1, -1)
    _make_prop("ruin", 4630.0, 0.0, 2, -1)
    for data in [
        [310.0, 0.0, 0], [690.0, -180.0, 1], [1030.0, 0.0, 2],
        [1510.0, -210.0, 3], [1900.0, 0.0, 4], [2410.0, -190.0, 5],
        [2820.0, -370.0, 6], [3400.0, -230.0, 7], [3890.0, -360.0, 8],
        [4290.0, 0.0, 9], [4540.0, -190.0, 10], [4990.0, 0.0, 11]
    ]:
        _make_prop("mushroom", float(data[0]), float(data[1]) - 2.0, int(data[2]), 1)
    for data in [
        [820.0, -350.0, 0], [1640.0, 0.0, 1], [2500.0, -190.0, 2],
        [3520.0, 0.0, 3], [4160.0, 0.0, 4], [4800.0, 0.0, 5]
    ]:
        _make_prop("crystal", float(data[0]), float(data[1]), int(data[2]), 1)
    for i in range(42):
        var x := float((i * 127) % 5200)
        _make_prop("grass", x, 0.0, i, 1)

    for x in [900.0, 1770.0, 2950.0, 4180.0, 4930.0]:
        _make_enemy(x, -2)

func _platform(x: float, platform_width: float, y: float) -> void:
    var body := StaticBody2D.new()
    body.position = Vector2(x + platform_width * 0.5, y)
    body.collision_layer = 1
    body.collision_mask = 1
    var shape_node := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = Vector2(platform_width, 70)
    shape_node.shape = shape
    shape_node.position.y = 35
    body.add_child(shape_node)
    add_child(body)
    var art: WorldArt = WorldArtScript.new()
    art.kind = "platform"
    art.width = platform_width
    art.position = Vector2(x, y)
    add_child(art)

func _make_prop(kind: String, x: float, y: float, variant: int, draw_order: int) -> void:
    var art: WorldArt = WorldArtScript.new()
    art.kind = kind
    art.variant = variant
    art.position = Vector2(x, y)
    art.z_index = draw_order
    add_child(art)

func _make_enemy(x: float, y: float) -> void:
    var enemy: ForestFiend = ForestFiendScript.new()
    enemy.position = Vector2(x, y)
    add_child(enemy)
    enemies.append(enemy)

func _build_hud() -> void:
    ui = CanvasLayer.new()
    ui.layer = 5
    add_child(ui)
    health_label = Label.new()
    health_label.position = Vector2(28, 22)
    health_label.add_theme_font_size_override("font_size", 26)
    health_label.add_theme_color_override("font_color", Color("#f3d58b"))
    health_label.text = "♥ ♥ ♥ ♥ ♥"
    ui.add_child(health_label)
    var title := Label.new()
    title.position = Vector2(28, 62)
    title.add_theme_font_size_override("font_size", 17)
    title.add_theme_color_override("font_color", Color("#d2dfdc"))
    title.text = "ENCHANTED VALE   •   MAGE AWAKENING"
    ui.add_child(title)
    var magic_label := Label.new()
    magic_label.position = Vector2(28, 88)
    magic_label.add_theme_font_size_override("font_size", 14)
    magic_label.add_theme_color_override("font_color", Color("#8bdcff"))
    magic_label.text = "J: ARCANE  •  Q: FROST  •  E: NOVA"
    ui.add_child(magic_label)

func _update_health(value: int) -> void:
    health_label.text = " ".join(PackedStringArray(["♥" if i < value else "♡" for i in range(5)]))

func _draw() -> void:
    var cam := hero.position if is_instance_valid(hero) else Vector2.ZERO
    draw_rect(Rect2(cam.x - 900, -1100, 3000, 1900), Color("#101d31"))
    # Layered mountain ridges provide a slow parallax backdrop.
    for layer in range(3):
        var parallax := cam.x * (0.12 + layer * 0.13)
        var base_y := -170 + layer * 110
        var col := [Color("#1a3041"), Color("#203d48"), Color("#294c50")][layer]
        for i in range(18):
            var px := float(i) * 190.0 - fposmod(parallax, 190.0) - 100.0
            var h := 180.0 + float((i * 37 + layer * 19) % 150)
            draw_colored_polygon(PackedVector2Array([Vector2(px, base_y), Vector2(px + 85, base_y - h), Vector2(px + 170, base_y)]), col)
    # A faint canopy glow and drifting fireflies animate the atmosphere.
    for i in range(32):
        var px := cam.x - 620 + fposmod(float(i * 137) + time * (12.0 + float(i % 4) * 4.0), 1240.0)
        var py := -430 + fposmod(float(i * 71), 410.0)
        var glow := 0.45 + 0.35 * sin(time * 2.0 + i)
        draw_circle(Vector2(px, py), 2.0 + glow * 2.0, Color(0.65, 0.86, 0.63, glow))
