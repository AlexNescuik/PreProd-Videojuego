extends CanvasLayer

func _ready():
	hide() 

func _input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("start"):
		toggle_pausa()

func toggle_pausa():
	var nuevo_estado = !get_tree().paused
	get_tree().paused = nuevo_estado
	visible = nuevo_estado
	
	if nuevo_estado:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$VBoxContainer/Reanudar.grab_focus()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_reanudar_pressed():
	toggle_pausa()

func _on_menu_pressed():
	get_tree().paused = false 
	Transicion.cambiar_escena("res://Escenas/UI UX HUD/MenuPrincipal.tscn")

func _on_salir_pressed():
	get_tree().quit()
