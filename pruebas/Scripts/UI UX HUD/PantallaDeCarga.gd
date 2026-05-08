extends Control

func _ready():
	await get_tree().create_timer(3.0).timeout
	Transicion.cambiar_escena("res://Escenas/UI UX HUD/MenuPrincipal.tscn")
