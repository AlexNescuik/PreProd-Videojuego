extends Control

func _ready():
	$SndVictoria.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$VBoxContainer/VolverAJugar.grab_focus()

func _on_volver_a_jugar_pressed():
	Transicion.cambiar_escena("res://Escenas/Tutoriel.tscn")

func _on_menu_pressed():
	Transicion.cambiar_escena("res://Escenas/UI UX HUD/MenuPrincipal.tscn")

func _on_salir_pressed():
	get_tree().quit()
