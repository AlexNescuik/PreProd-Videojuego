extends RichTextLabel

# 1. ESCRIBE TU MENSAJE AQUÍ EN EL INSPECTOR
@export_multiline var mensaje_base = "Presiona [ACCION] para atacar"


var iconos = {
	"teclado": {
		"[ACCION]": "res://Assets/UI UX HUD/Teclas/Teclado/boton c.png",
		"[ABAJO]": "res://Assets/UI UX HUD/Teclas/Teclado/boton abajo.png"
	},
	"control": {
		"[ACCION]": "res://Assets/UI UX HUD/Teclas/Control/gatillo der.png", 
		"[ABAJO]": "res://Assets/UI UX HUD/Teclas/Control/Control abajo.pngs"        
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
	var modo = "control" if es_control else "teclado"
	var texto_procesado = mensaje_base
	
	for etiqueta in iconos[modo]:
		var ruta = iconos[modo][etiqueta]
		var formato_img = "[img]" + ruta + "[/img]"
		texto_procesado = texto_procesado.replace(etiqueta, formato_img)
	
	text = "[center]" + texto_procesado + "[/center]"
