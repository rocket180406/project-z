extends Area2D

@onready var cartel = $spr_cartel
@onready var label_interact = $msg_interaccion
@onready var label_info = $texto

var jugador_dentro = false
var abierto = false
var tween: Tween

func _on_body_entered(body):
	if body.is_in_group("jugadores"):
		jugador_dentro = true
		label_interact.visible = true

func _on_body_exited(body):
	if body.is_in_group("jugadores"):
		jugador_dentro = false
		label_interact.visible = false
		cerrar()

func _process(delta):
	if jugador_dentro and Input.is_action_just_pressed("interactuar"):
		if not abierto:
			abrir()
		else:
			cerrar()

func abrir():
	abierto = true

	label_interact.visible = false
	zoom(true)
	
	await get_tree().create_timer(0.15).timeout
	
	label_info.visible = true

	
func cerrar():
	abierto = false

	label_info.visible = false

	if jugador_dentro:
		label_interact.visible = true

	zoom(false)

func zoom(activar: bool):
	if tween:
		tween.kill()

	tween = create_tween()

	if activar:
		tween.tween_property(cartel, "scale", Vector2(2.0, 2.0), 0.2)
	else:
		tween.tween_property(cartel, "scale", Vector2(1, 1), 0.2)
