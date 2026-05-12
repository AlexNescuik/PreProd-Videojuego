extends StaticBody2D

var esta_rota : bool = false

@onready var animaciones = $AnimatedSprite2D
@onready var colision = $CollisionShape2D

func _ready():
	animaciones.play("Normal")
	esta_rota = false
	colision.disabled = false

func romper():
	if esta_rota: return
	
	esta_rota = true
	animaciones.play("Roto")
	
	colision.set_deferred("disabled", true)
