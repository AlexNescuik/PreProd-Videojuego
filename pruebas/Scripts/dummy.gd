extends CharacterBody2D

const GRAVEDAD = 980.0

# Asegúrate de que tu nodo Area2D se llame exactamente "HitboxDaño"
@onready var hitbox_dano = $HitboxDaño 

func _ready():
	if not is_in_group("enemigo"):
		add_to_group("enemigo")
		
	# Conectamos la señal mágicamente por código. ¡Cero bugs del editor!
	if hitbox_dano and not hitbox_dano.body_entered.is_connected(_al_tocar_jugador):
		hitbox_dano.body_entered.connect(_al_tocar_jugador)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVEDAD * delta
	move_and_slide()

func morir():
	print("¡PUM! Dummy destruido.")
	queue_free()

func _al_tocar_jugador(body):
	# Si lo que nos tocó tiene la función morir (o sea, es tu Jugador)
	if body.has_method("morir"):
		var esta_a_salvo = false
		
		# ¿Está rodando?
		if "es_invulnerable" in body and body.es_invulnerable:
			esta_a_salvo = true
			
		# ¿Está en Dash?
		if "estado_actual" in body and "Estado" in body and body.estado_actual == body.Estado.DASH:
			esta_a_salvo = true
			
		# Si caminó normal hacia nosotros...
		if not esta_a_salvo:
			print("¡Instant Kill! El Dummy tocó al jugador.")
			body.morir()
