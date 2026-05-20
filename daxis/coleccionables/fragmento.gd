extends Area2D

@export var portal_path : NodePath

var portal = null

func _ready():
	$ani_fragmento.play("default")

	# Obtener referencia al portal
	portal = get_node(portal_path)

func _on_body_entered(body: Node2D):
	if body.is_in_group("jugadores"):

		# Activar portal
		portal.activar_portal()

		# Eliminar coleccionable
		queue_free()
