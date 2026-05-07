extends CharacterBody2D

const GRAVEDAD = 980.0
enum Estado { PATRULLA, PERSEGUIR, ATACAR, MUERTO }
var estado_actual = Estado.PATRULLA

@export_group("Movimiento Rana")
@export var fuerza_salto_rana: float = -250.0 
@export var impulso_horizontal: float = 140.0 
@export var tiempo_espera_salto: float = 0.4  
@export var vel_persecucion: float = 200.0    
@export var vel_patrulla: float = 120.0

var direccion = 1
var jugador_objetivo: Node2D = null
var puede_saltar: bool = true
var ultima_posicion_jugador: Vector2 = Vector2.ZERO

@onready var anim = $AnimatedSprite2D
@onready var pivote = $Pivote
@onready var rayo_pared = $Pivote/RayoPared
@onready var rayo_suelo = $Pivote/RayoSuelo

func _ready():
	add_to_group("enemigo")
	if not anim.animation_finished.is_connected(_on_anim_terminada):
		anim.animation_finished.connect(_on_anim_terminada)

func _physics_process(delta):
	if estado_actual == Estado.MUERTO: return
	
	if not is_on_floor(): 
		velocity.y += GRAVEDAD * delta
	else:
		velocity.x = move_toward(velocity.x, 0, 15)

	match estado_actual:
		Estado.PATRULLA: 
			if is_on_floor() and puede_saltar:
				anim.play("Caminata") 
				if rayo_pared.is_colliding() or not rayo_suelo.is_colliding(): 
					voltear()
				ejecutar_brinco(vel_patrulla)
			
		Estado.PERSEGUIR: 
			if jugador_objetivo:
				ultima_posicion_jugador = jugador_objetivo.global_position
				if puede_saltar and is_on_floor():
					cambiar_a_ataque()
				
		Estado.ATACAR: 
			pass

	move_and_slide()

func ejecutar_brinco(impulso_x: float):
	puede_saltar = false
	velocity.x = direccion * impulso_x
	velocity.y = fuerza_salto_rana
	
	await get_tree().create_timer(tiempo_espera_salto).timeout
	puede_saltar = true

func cambiar_a_ataque():
	estado_actual = Estado.ATACAR
	puede_saltar = false
	
	var dir_hacia = sign(ultima_posicion_jugador.x - global_position.x)
	if dir_hacia != 0 and dir_hacia != direccion: 
		voltear()
	
	anim.play("Ataque")
	velocity.x = direccion * vel_persecucion
	velocity.y = fuerza_salto_rana * 1.2 
	
	await get_tree().create_timer(tiempo_espera_salto * 2).timeout
	puede_saltar = true
	if estado_actual != Estado.MUERTO:
		estado_actual = Estado.PERSEGUIR

func voltear():
	direccion *= -1
	pivote.scale.x *= -1
	anim.flip_h = (direccion < 0)

# --- SEÑALES DE VISIÓN Y ATAQUE ---

func _on_zona_vision_body_entered(body):
	if estado_actual == Estado.MUERTO: return
	if body.is_in_group("jugador"):
		jugador_objetivo = body
		estado_actual = Estado.PERSEGUIR

func _on_zona_vision_body_exited(body):
	if body == jugador_objetivo:
		jugador_objetivo = null
		await get_tree().create_timer(1.0).timeout
		if not jugador_objetivo and estado_actual != Estado.MUERTO:
			estado_actual = Estado.PATRULLA

func _on_zona_ataque_body_entered(body):
	if estado_actual == Estado.MUERTO: return
	if body.is_in_group("jugador"):
		if body.has_method("morir"):
			var a_salvo = false
			if "es_invulnerable" in body and body.es_invulnerable: a_salvo = true
			if "estado_actual" in body and body.estado_actual == body.Estado.BARRIDO: a_salvo = true
			
			if not a_salvo:
				print("Rana Aplastó")
				body.morir()

func _on_anim_terminada():
	if estado_actual == Estado.MUERTO: return
	if estado_actual == Estado.ATACAR:
		if is_on_floor():
			estado_actual = Estado.PERSEGUIR

func morir():
	if estado_actual == Estado.MUERTO: return
	estado_actual = Estado.MUERTO
	velocity = Vector2.ZERO 
	
	set_collision_layer_value(3, false)
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador: add_collision_exception_with(jugador)
	
	if $HurtboxEnemigo.is_in_group("hurtbox_enemigo"):
		$HurtboxEnemigo.remove_from_group("hurtbox_enemigo")
	
	$HurtboxEnemigo.set_deferred("monitorable", false)
	$Pivote/ZonaAtaque.set_deferred("monitoring", false)
	$Pivote/ZonaVision.set_deferred("monitoring", false)

	anim.play("Muerte")
	await anim.animation_finished
	queue_free()
