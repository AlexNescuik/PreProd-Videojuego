extends Control

@export var imagen_teclado : Texture2D
@export var imagen_xbox : Texture2D
@export var imagen_switch : Texture2D

@onready var visualizador = $TextureRect 
@onready var boton_regresar = $Regresar

func _ready():
	boton_regresar.grab_focus()
	
	InputHelper.cambio_de_dispositivo.connect(_on_cambio_input)
	_on_cambio_input(InputHelper.usando_control)

func _on_cambio_input(es_control):
	if not es_control:
		visualizador.texture = imagen_teclado
	else:
		var nombre_mando = Input.get_joy_name(0).to_lower()
		print("Mando detectado: ", nombre_mando) 
		
		if "nintendo" in nombre_mando or "switch" in nombre_mando:
			visualizador.texture = imagen_switch
		else:
			visualizador.texture = imagen_xbox

func _on_regresar_pressed():
	Transicion.cambiar_escena("res://Escenas/UI UX HUD/MenuPrincipal.tscn")
