extends Control

func _input(event):
	if event.is_pressed():
		Transicion.cambiar_escena("res://Escenas/UI UX HUD/PantallaDeCarga.tscn")
