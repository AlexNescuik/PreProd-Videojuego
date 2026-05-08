extends Area2D

func _on_meta_body_entered(body):
	if body.name == "Player":
		print("Nivel Completado!")
		
		body.set_physics_process(false)
		Transicion.cambiar_escena("res://Escenas/UI UX HUD/CONGRATULATIONS.tscn")
