extends CharacterBody2D

enum Estado { IDLE, PERSEGUIR, ATACAR, MUERTO }
var estado_actual = Estado.IDLE

const VELOCIDAD = 120.0
const GRAVEDAD = 980.0

@onready var anim = $AnimatedSprite2D
@onready var zona_deteccion = $ZonaDeteccion
@onready var zona_ataque = $ZonaAtaque
@onready var hitbox_punetazo = $ZonaAtaque/CollisionShape2D

var jugador: Node2D = null

func _ready():
	hitbox_punetazo.disabled = true
	
	zona_deteccion.body_entered.connect(_on_ver_jugador)
	zona_deteccion.body_exited.connect(_on_perder_jugador)
	zona_ataque.body_entered.connect(_on_rango_ataque)
	anim.animation_finished.connect(_on_anim_terminada)

func _physics_process(delta):
	if estado_actual == Estado.MUERTO: return
	
	if not is_on_floor():
		velocity.y += GRAVEDAD * delta

	match estado_actual:
		Estado.IDLE:
			velocity.x = 0
			anim.play("Idle")
			
		Estado.PERSEGUIR:
			if jugador:
				var direccion = sign(jugador.global_position.x - global_position.x)
				velocity.x = direccion * VELOCIDAD
				anim.play("Caminata")
				
				if direccion != 0:
					anim.flip_h = (direccion < 0)
					zona_ataque.scale.x = -1 if direccion < 0 else 1
					
		Estado.ATACAR:
			velocity.x = 0 
			
	move_and_slide()


func morir():
	if estado_actual == Estado.MUERTO: return
	
	estado_actual = Estado.MUERTO
	velocity = Vector2.ZERO
	hitbox_punetazo.set_deferred("disabled", true)
	
	anim.play("Muerte")
	await anim.animation_finished
	queue_free()


func _on_ver_jugador(body):
	if body.is_in_group("jugador") and estado_actual == Estado.IDLE:
		jugador = body
		estado_actual = Estado.PERSEGUIR

func _on_perder_jugador(body):
	if body == jugador and estado_actual != Estado.ATACAR:
		jugador = null
		estado_actual = Estado.IDLE

func _on_rango_ataque(body):
	if body.is_in_group("jugador") and estado_actual == Estado.PERSEGUIR:
		estado_actual = Estado.ATACAR
		anim.play("Ataque")
		hitbox_punetazo.set_deferred("disabled", false)

func _on_anim_terminada():
	if estado_actual == Estado.ATACAR:
		hitbox_punetazo.set_deferred("disabled", true)
		
		if jugador and zona_deteccion.overlaps_body(jugador):
			estado_actual = Estado.PERSEGUIR
		else:
			estado_actual = Estado.IDLE
