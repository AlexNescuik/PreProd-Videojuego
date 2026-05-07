extends CharacterBody2D

const GRAVEDAD = 980.0
enum Estado { IDLE, ACTIVADO, EXPLOTANDO, MUERTO }
var estado_actual = Estado.IDLE

@export var tiempo_detonacion: float = 1.5
var jugador_objetivo: Node2D = null

@onready var anim = $AnimatedSprite2D
@onready var pivote = $Pivote

func _ready():
	add_to_group("enemigo")
	estado_actual = Estado.IDLE
	anim.play("IDLE")
	if not anim.animation_finished.is_connected(_on_anim_terminada):
		anim.animation_finished.connect(_on_anim_terminada)

func _physics_process(delta):
	if estado_actual == Estado.MUERTO: return
	if not is_on_floor(): velocity.y += GRAVEDAD * delta

	match estado_actual:
		Estado.IDLE, Estado.ACTIVADO:
			if jugador_objetivo:
				mirar_al_jugador()
			velocity.x = 0 

	move_and_slide()

func mirar_al_jugador():
	var dir = sign(jugador_objetivo.global_position.x - global_position.x)
	if dir != 0:
		anim.flip_h = (dir < 0)
		if pivote:
			pivote.scale.x = dir

# --- LÓGICA DE BOMBA ---

func _on_zona_vision_body_entered(body):
	if estado_actual == Estado.MUERTO: return
	if body.is_in_group("jugador"):
		jugador_objetivo = body
		if estado_actual == Estado.IDLE:
			activar_bomba()

func activar_bomba():
	estado_actual = Estado.ACTIVADO
	anim.play("Encender")
	
	await get_tree().create_timer(tiempo_detonacion).timeout
	
	if estado_actual == Estado.ACTIVADO:
		explotar()

func explotar():
	if estado_actual == Estado.MUERTO or estado_actual == Estado.EXPLOTANDO: return
	
	estado_actual = Estado.EXPLOTANDO
	anim.play("Explotar")
	
	var cuerpos = $Pivote/ZonaAtaque.get_overlapping_bodies()
	for c in cuerpos:
		if c.is_in_group("jugador"):
			aplicar_daño(c)

func _on_zona_ataque_body_entered(body):
	if estado_actual == Estado.EXPLOTANDO and body.is_in_group("jugador"):
		aplicar_daño(body)

func aplicar_daño(body):
	if body.has_method("morir"):
		body.morir()

# --- MORIR ---

func morir():
	if estado_actual == Estado.MUERTO or estado_actual == Estado.EXPLOTANDO: return
	
	print("¡Cabrón suicida desactivado a tiempo!")
	estado_actual = Estado.MUERTO
	velocity = Vector2.ZERO 
	
	set_collision_layer_value(3, false)
	
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		add_collision_exception_with(jugador)
	
	if $HurtboxEnemigo.is_in_group("hurtbox_enemigo"):
		$HurtboxEnemigo.remove_from_group("hurtbox_enemigo")
	
	$HurtboxEnemigo.set_deferred("monitorable", false)
	$Pivote/ZonaAtaque.set_deferred("monitoring", false)
	$Pivote/ZonaVision.set_deferred("monitoring", false)

	if anim.sprite_frames.has_animation("Muerte"):
		anim.play("Muerte")
		await anim.animation_finished
	else:
		anim.modulate = Color(1, 1, 1, 0.5)
		await get_tree().create_timer(0.2).timeout
	
	queue_free()

func _on_anim_terminada():
	if estado_actual == Estado.EXPLOTANDO:
		queue_free()
