extends Area2D

func _ready():
	# Reproducimos la animación cuando está en nuestro mundo
	$ani_fragmento.play("default")

func _on_body_entered(body: Node2D):
	if body.is_in_group("jugadores"):
		##body.add_fragmento()
		queue_free()
