extends CharacterBody2D

@onready var anim = $zombi_anim 
@export var gravity_scale = 2
@export var dano_zombi = 34
@export var fuerza_empuje = 400

var speed = 50
var direction = 1  
var state = "appear"

const GRAVITY = 900

func _ready():
	anim.play("aparecer")
	await anim.animation_finished
	
	state = "move"
	anim.play("caminar")
	behavior_loop()

func behavior_loop():
	while state == "move":
		direction = [-1, 1][randi() % 2]
		await get_tree().create_timer(randf_range(0.8, 2.5)).timeout

func _physics_process(delta):
	if state != "move":
		return
	if not is_on_floor():
		velocity.y += GRAVITY * gravity_scale * delta
	else:
		velocity.y = 0
	velocity.x = direction * speed
	move_and_slide()
	if anim.animation != "caminar":
		anim.play("caminar")
	anim.flip_h = direction > 0
	
func _on_ene_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugadores"):
		
		body.recibir_dano(dano_zombi)
		
		if body is CharacterBody2D:
			var direccion = (body.global_position - global_position).normalized()
			direccion.y = -0.2 

			body.velocity += direccion * fuerza_empuje
