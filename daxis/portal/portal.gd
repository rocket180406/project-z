extends Area2D

@export var siguiente_nivel : String = "res://niveles/nivel2.tscn"

func _ready():
	visible = false
	monitoring = false

func activar_portal():
	visible = true
	monitoring = true

	# Si tienes animación
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("appear")


func _on_body_entered(body):
	if body.is_in_group("jugadores"):
		get_tree().call_deferred("change_scene_to_file", "res://environment/envLobby.tscn")
