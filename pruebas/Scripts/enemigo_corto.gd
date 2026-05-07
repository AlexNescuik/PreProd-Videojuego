extends CharacterBody2D

const GRAVEDAD = 980.0
enum Estado { PATRULLA, PERSEGUIR, ATACAR, MUERTO }
var estado_actual = Estado.PATRULLA

@export var vel_patrulla: float = 40.0
@export var vel_persecucion: float = 90.0
var direccion = 1
var jugador_objetivo: Node2D = null

@onready var anim = $AnimatedSprite2D
@onready var pivote = $Pivote
@onready var rayo_pared = $Pivote/RayoPared
@onready var rayo_suelo = $Pivote/RayoSuelo

func _ready():
	add_to_group("enemigo")
	anim.animation_finished.connect(_on_anim_terminada)

func _physics_process(delta):
	if estado_actual == Estado.MUERTO: return
	if not is_on_floor(): velocity.y += GRAVEDAD * delta

	match estado_actual:
		Estado.PATRULLA: 
			anim.play("Caminata")
			velocity.x = direccion * vel_patrulla
			if rayo_pared.is_colliding() or not rayo_suelo.is_colliding(): voltear()
			
		Estado.PERSEGUIR: 
			anim.play("Caminata")
			if jugador_objetivo and abs(jugador_objetivo.global_position.x - global_position.x) > 15.0:
				velocity.x = direccion * vel_persecucion
			else:
				velocity.x = 0
				
		Estado.ATACAR: 
			velocity.x = 0

	move_and_slide()

func voltear():
	direccion *= -1
	pivote.scale.x *= -1
	anim.flip_h = (direccion < 0)

# --- SEÑALES DE VISIÓN Y ATAQUE ---

func _on_zona_vision_body_entered(body):
	if estado_actual == Estado.MUERTO: return
	if body.is_in_group("jugador") and estado_actual != Estado.ATACAR:
		jugador_objetivo = body
		estado_actual = Estado.PERSEGUIR
		var dir_hacia_jugador = sign(jugador_objetivo.global_position.x - global_position.x)
		if dir_hacia_jugador != 0 and dir_hacia_jugador != direccion: voltear()

func _on_zona_vision_body_exited(body):
	if body == jugador_objetivo:
		jugador_objetivo = null
		if estado_actual != Estado.MUERTO and estado_actual != Estado.ATACAR: 
			estado_actual = Estado.PATRULLA

func _on_zona_ataque_body_entered(body):
	if estado_actual == Estado.MUERTO: return
	if body.is_in_group("jugador") and estado_actual == Estado.PERSEGUIR:
		estado_actual = Estado.ATACAR
		anim.play("Ataque")
		
		if body.has_method("morir"):
			var a_salvo = false
			if "es_invulnerable" in body and body.es_invulnerable: a_salvo = true
			if "estado_actual" in body and body.estado_actual == body.Estado.BARRIDO: a_salvo = true
			if not a_salvo:
				body.morir()

func _on_anim_terminada():
	if estado_actual == Estado.MUERTO: return
	if estado_actual == Estado.ATACAR:
		if jugador_objetivo and $Pivote/ZonaVision.overlaps_body(jugador_objetivo):
			estado_actual = Estado.PERSEGUIR
		else:
			estado_actual = Estado.PATRULLA


func morir():
	if estado_actual == Estado.MUERTO: return
	
	estado_actual = Estado.MUERTO
	velocity = Vector2.ZERO 
	
	set_collision_layer_value(3, false)
	
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		add_collision_exception_with(jugador)
	
	# Desactivamos el resto como ya lo hacíamos
	if $HurtboxEnemigo.is_in_group("hurtbox_enemigo"):
		$HurtboxEnemigo.remove_from_group("hurtbox_enemigo")
	
	$HurtboxEnemigo.set_deferred("monitorable", false)
	$Pivote/ZonaAtaque.set_deferred("monitoring", false)

	anim.play("Muerte")
	await anim.animation_finished
	queue_free()
