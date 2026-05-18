extends Area2D

var mostrar_mensaje_interactuar = false
var jugador_actual = null
var usado = false

func _process(delta: float) -> void:
	$msg_interaccion.visible = mostrar_mensaje_interactuar
	
	if mostrar_mensaje_interactuar && Input.is_action_just_pressed("interactuar"):
		
		if jugador_actual == null:
			return
		
		jugador_actual.checkpoint_pos = global_position
		
		if not usado:
			jugador_actual.vida_actual = 100
			jugador_actual.actualizar_vida_ui()
			
			usado = true
			jugador_actual.mostrar_mensaje("Checkpoint actualizado\nVida restaurada")
		else:
			jugador_actual.mostrar_mensaje("Checkpoint actualizado")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugadores"):
		mostrar_mensaje_interactuar = true
		jugador_actual = body


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("jugadores"):
		mostrar_mensaje_interactuar = false
		jugador_actual = null
