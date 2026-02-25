extends CharacterBody2D

const GRAVEDAD = 980.0

func _ready():
	if not is_in_group("enemigo"):
		add_to_group("enemigo")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVEDAD * delta
	move_and_slide()

func morir():
	print("¡Dummy destruido!")
	queue_free()


func _on_hitbox_daño_body_entered(body):
	if body.has_method("morir") and body.name != self.name:
		
		var a_salvo = false
		
		if "es_invulnerable" in body and body.es_invulnerable:
			a_salvo = true # El Barrido
		if "estado_actual" in body and "Estado" in body:
			if body.estado_actual == body.Estado.DASH:
				a_salvo = true # El Dash
			if body.estado_actual == body.Estado.PARRY:
				a_salvo = true # Por si te choca mientras haces parry
				
		if not a_salvo:
			print("¡El Dummy copió a la bala y te hizo Instant Kill!")
			body.morir()
