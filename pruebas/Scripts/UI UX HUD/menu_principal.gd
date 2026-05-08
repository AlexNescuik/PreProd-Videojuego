extends Control

@onready var boton_inicial = %Jugar 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	for boton in get_tree().get_nodes_in_group("botones_menu"):
		boton.focus_entered.connect(_on_boton_hover)
		boton.mouse_entered.connect(_on_boton_hover)
	
	await get_tree().process_frame
	if boton_inicial:
		boton_inicial.grab_focus()

func _on_boton_hover():
	$SndHover.play()

func _on_jugar_pressed():
	$SndClick.play()
	await $SndClick.finished
	Transicion.cambiar_escena("res://Escenas/Tutoriel.tscn")

func _on_controles_pressed():
	$SndClick.play()

func _on_sonido_pressed():
	$SndClick.play()

func _on_salir_pressed():
	$SndClick.play()
	await $SndClick.finished
	get_tree().quit()
