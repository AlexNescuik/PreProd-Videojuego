extends Control

@onready var boton_inicial = %Jugar 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	await get_tree().process_frame
	if boton_inicial:
		boton_inicial.grab_focus()


func _on_jugar_pressed():
	print("¡Cambiando al Tutorial!")
	Transicion.cambiar_escena("res://Escenas/Tutoriel.tscn")

func _on_controles_pressed():
	print("Botón de controles presionado")

func _on_sonido_pressed():
	print("Botón de sonido presionado")

func _on_salir_pressed():
	print("Saliendo del juego...")
	get_tree().quit()
