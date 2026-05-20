extends CharacterBody2D

@onready var anim = $zombi_anim
@onready var detector_izq = $detector_izq
@onready var detector_der = $detector_der

@onready var jugador = get_tree().get_first_node_in_group("jugadores")

@export var gravity_scale = 2
@export var dano_zombi = 34
@export var fuerza_empuje = 400

# Velocidades
@export var speed = 50
@export var velocidad_persecucion = 90

# Distancia para detectar jugador
@export var rango_deteccion = 150

var direction = 1
var persiguiendo = false
var state = "appear"

const GRAVITY = 900


func _ready():

	anim.play("aparecer")

	await anim.animation_finished

	state = "move"
	anim.play("caminar")


func _physics_process(delta):

	if state != "move":
		return

	# ==================================================
	# GRAVEDAD
	# ==================================================

	if not is_on_floor():
		velocity.y += GRAVITY * gravity_scale * delta
	else:
		velocity.y = 0

	# ==================================================
	# IA
	# ==================================================

	handle_ai()

	# ==================================================
	# MOVIMIENTO
	# ==================================================

	move_and_slide()

	# ==================================================
	# FLIP SPRITE
	# ==================================================

	anim.flip_h = direction > 0


func handle_ai():

	if jugador == null:
		return

	var distancia = global_position.distance_to(jugador.global_position)

	# ==================================================
	# PERSECUCIÓN
	# ==================================================

	if distancia <= rango_deteccion:

		persiguiendo = true

		# --------------------------
		# Jugador a la derecha
		# --------------------------

		if jugador.global_position.x > global_position.x:

			direction = 1

			# SOLO perseguir si hay suelo
			if detector_der.is_colliding():

				velocity.x = velocidad_persecucion

				# Animación caminar
				if anim.animation != "caminar":
					anim.play("caminar")

			else:

				# Hay foso → detenerse
				velocity.x = 0

				# Animación idle
				if anim.animation != "idle":
					anim.play("idle")

		# --------------------------
		# Jugador a la izquierda
		# --------------------------

		else:

			direction = -1

			# SOLO perseguir si hay suelo
			if detector_izq.is_colliding():

				velocity.x = -velocidad_persecucion

				# Animación caminar
				if anim.animation != "caminar":
					anim.play("caminar")

			else:

				# Hay foso → detenerse
				velocity.x = 0

				# Animación idle
				if anim.animation != "idle":
					anim.play("idle")

		# --------------------------
		# Si se choca con pared
		# --------------------------

		if is_on_wall():

			velocity.x = 0

			if anim.animation != "idle":
				anim.play("idle")

	# ==================================================
	# PATRULLA NORMAL
	# ==================================================

	else:

		persiguiendo = false

		# --------------------------
		# Detectar bordes
		# --------------------------

		if direction == 1 and not detector_der.is_colliding():
			direction = -1

		elif direction == -1 and not detector_izq.is_colliding():
			direction = 1

		# --------------------------
		# Detectar paredes
		# --------------------------

		if is_on_wall():
			direction *= -1

		# Movimiento patrulla
		velocity.x = direction * speed

		# Animación caminar
		if anim.animation != "caminar":
			anim.play("caminar")


func _on_ene_area_body_entered(body: Node2D) -> void:

	if body.is_in_group("jugadores"):

		body.recibir_dano(dano_zombi)

		if body is CharacterBody2D:

			var direccion = (
				body.global_position - global_position
			).normalized()

			# Pequeño empuje hacia arriba
			direccion.y = -0.2

			body.velocity += direccion * fuerza_empuje
