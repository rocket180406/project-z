extends CharacterBody2D

@export var gravity_scale = 2
@export var speed = 500
@export var acceleration = 600
@export var friction = 1500
@export var jump_force = -700
@export var air_acceleration = 2000
@export var air_friction = 700

var vida_actual = 100
var invulnerable := false

var checkpoint_pos = Vector2()
var last_safe_position = Vector2()

@onready var ani_player = $ani_j1
@onready var vida_ui = $CanvasLayer/vida
@onready var mensaje_ui = $CanvasLayer/mensaje

var brain_full = preload("res://player/sprites/Health and Points Bars/Sprites/Brain Bar/Brain Stage 1.png")
var brain_mid = preload("res://player/sprites/Health and Points Bars/Sprites/Brain Bar/Brain Stage 2.png")
var brain_low = preload("res://player/sprites/Health and Points Bars/Sprites/Brain Bar/Brain Stage 3.png")


func _ready() -> void:
	add_to_group("jugadores")
	actualizar_vida_ui()

	checkpoint_pos = global_position
	last_safe_position = global_position


func actualizar_vida_ui():
	if vida_actual > 66:
		vida_ui.texture = brain_full
	elif vida_actual > 33:
		vida_ui.texture = brain_mid
	else:
		vida_ui.texture = brain_low


func update_animation(input_axis):
	if not is_on_floor():
		if velocity.y < 0:
			ani_player.play("jump")
	elif input_axis != 0:
		ani_player.speed_scale = abs(velocity.x)/100
		ani_player.flip_h = (input_axis < 0)
		ani_player.play("run")
	else:
		ani_player.speed_scale = 1
		ani_player.play("idle")


func _physics_process(delta: float) -> void:
	var input_axis = Input.get_axis("mover_izq","mover_der")

	apply_gravity(delta)
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	handle_jump()
	handle_air_acceleration(input_axis, delta)
	update_animation(input_axis)

	comprobar_dano_tilemap()

	if is_on_floor():
		last_safe_position = global_position

	move_and_slide()



func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_scale


func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed * input_axis, acceleration * delta)


func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)


func handle_jump():
	if is_on_floor():
		if Input.is_action_pressed("saltar"):
			velocity.y = jump_force


func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed * input_axis, air_acceleration * delta)



func comprobar_dano_tilemap():

	if invulnerable:
		return

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.name == "peligros":

			var tilemap = collider
			var tile_pos = tilemap.local_to_map(tilemap.to_local(collision.get_position()))
			var tile_data = tilemap.get_cell_tile_data(0, tile_pos)

			if tile_data == null:
				continue

			var damage = tile_data.get_custom_data("damage")

			if damage == true:
				recibir_dano(34)
				break



func recibir_dano(cantidad):
	if invulnerable:
		return
	vida_actual -= cantidad
	if vida_actual < 0:
		vida_actual = 0

	actualizar_vida_ui()

	if vida_actual <= 0:
		morir()
	else:
		respawn_zona_segura()


func morir():
	invulnerable = true
	set_physics_process(false)

	global_position = checkpoint_pos
	velocity = Vector2.ZERO

	vida_actual = 100
	actualizar_vida_ui()

	await get_tree().process_frame

	set_physics_process(true)
	invulnerable = false


func respawn_zona_segura():
	invulnerable = true
	set_physics_process(false)

	global_position = last_safe_position
	velocity = Vector2.ZERO

	await get_tree().process_frame

	set_physics_process(true)
	invulnerable = false

func mostrar_mensaje(texto: String):
	mensaje_ui.text = texto
	mensaje_ui.visible = true

	await get_tree().create_timer(2.0).timeout
	mensaje_ui.visible = false
