extends RichTextLabel

@export_multiline var mensaje_base = "Presiona [MOVER] para moverte y [SALTAR] para saltar"

var iconos = {
	"teclado": {
		"[MOVER]": "res://UI/HUD Tuto/mov teclado.png",
		"[SALTAR]": "res://UI/HUD Tuto/Espacio.png"
	},
	"xbox": {
		"[MOVER]": "res://UI/HUD Tuto/Joystick.png", 
		"[SALTAR]": "res://UI/HUD Tuto/xbox bot.png" 
	},
	"switch": {
		"[MOVER]": "res://UI/HUD Tuto/Joystick.png", 
		"[SALTAR]": "res://UI/HUD Tuto/SWITCH CONTROLES CHIDO.png" # 
	}
}

# 3. VARIABLES DE FLOTE
var tiempo_flote = 0.0
var velocidad_flote = 2.0
var amplitud_flote = 5.0
@onready var posicion_inicial_y = position.y

func _ready():
	InputHelper.cambio_de_dispositivo.connect(_actualizar_icono)
	_actualizar_icono(InputHelper.usando_control)

func _process(delta):
	tiempo_flote += delta
	position.y = posicion_inicial_y + sin(tiempo_flote * velocidad_flote) * amplitud_flote

func _actualizar_icono(es_control):
	var modo = "teclado"
	
	if es_control:
		modo = "xbox"
		
		var controles_conectados = Input.get_connected_joypads()
		if controles_conectados.size() > 0:
			var nombre_control = Input.get_joy_name(controles_conectados[0]).to_lower()
			
			if "nintendo" in nombre_control or "switch" in nombre_control or "pro controller" in nombre_control or "joy-con" in nombre_control:
				modo = "switch"
	
	var texto_procesado = mensaje_base
	
	for etiqueta in iconos[modo]:
		var ruta = iconos[modo][etiqueta]
		var formato_img = "[img]" + ruta + "[/img]"
		texto_procesado = texto_procesado.replace(etiqueta, formato_img)
	
	text = "[center]" + texto_procesado + "[/center]"
