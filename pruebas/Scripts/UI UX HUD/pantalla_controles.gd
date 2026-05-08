extends Control

@export var imagen_teclado : Texture2D
@export var imagen_control : Texture2D

@onready var visualizador = $TextureRect 

func _ready():
	InputHelper.cambio_de_dispositivo.connect(_on_cambio_input)
	
	_on_cambio_input(InputHelper.usando_control)

func _on_cambio_input(es_control):
	var tween = create_tween()
	tween.tween_property(visualizador, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func(): 
		visualizador.texture = imagen_control if es_control else imagen_teclado
	)
	tween.tween_property(visualizador, "modulate:a", 1.0, 0.1) 
