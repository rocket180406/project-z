extends CharacterBody2D

@export var gravity_scale = 2
@export var speed = 500
@export var acceleration = 600
@export var friction = 1500
@export var jump_force = -700
@export var air_acceleration = 2000
@export var air_friction = 700

var vida_actual = 100

@onready var ani_player = $ani_j1
@onready var vida_ui = $CanvasLayer/vida

var brain_full = preload("res://player/sprites/Health and Points Bars/Sprites/Brain Bar/Brain Stage 1.png")
var brain_mid = preload("res://player/sprites/Health and Points Bars/Sprites/Brain Bar/Brain Stage 2.png")
var brain_low = preload("res://player/sprites/Health and Points Bars/Sprites/Brain Bar/Brain Stage 3.png")

func _ready() -> void:
	add_to_group("jugadores")
	actualizar_vida_ui()

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

func recibir_dano(cantidad):
	vida_actual -=cantidad	
	if vida_actual < 0:
		vida_actual = 0		
	actualizar_vida_ui()	
	if vida_actual <= 0:
		morir()
		
func morir():
	set_physics_process(false)
	get_tree().call_deferred("reload_current_scene")
	vida_actual = 100
	actualizar_vida_ui()
