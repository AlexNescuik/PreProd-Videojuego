extends Area2D

@export var velocidad: float = 100.0
var direccion: Vector2 = Vector2.LEFT
var fue_desviado: bool = false
var tiempo_vida: float = 0.0 

func _ready():
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, true) 
	
	set_collision_mask_value(1, true) # Ve Paredes
	set_collision_mask_value(2, true) # Ve Jugador
	set_collision_mask_value(3, true) # Ve Enemigos
	
	add_to_group("bala")

func _physics_process(delta):
	position += direccion * velocidad * delta
	tiempo_vida += delta
	if tiempo_vida > 3.0:
		queue_free()
	
	var cuerpos_tocando = get_overlapping_bodies()
	
	for body in cuerpos_tocando:
		
		if body.get_collision_layer_value(1):
			print("🧱 Bala destruida por una pared.")
			queue_free()
			return 
			
		if body.is_in_group("jugador") or body.has_method("morir"):
			var esta_en_barrido = false
			
			if "es_invulnerable" in body: esta_en_barrido = body.es_invulnerable
			if esta_en_barrido:
				continue
				
			if "estado_actual" in body and body.estado_actual == body.Estado.PARRY:
				if not fue_desviado:
					print("🛡️ ¡PARRY ÉPICO! La bala regresa.")
					direccion *= -1 # Invierte el vuelo
					fue_desviado = true
					modulate = Color(0, 2, 0) # Se pinta de verde aliado
				continue
				
			if not fue_desviado:
				print("💀 ¡La bala te alcanzó!")
				body.morir()
				queue_free()
				return
				
		if body.is_in_group("enemigo") and fue_desviado:
			if body.has_method("morir"):
				print("💥 ¡Enemigo destruido por su propia bala!")
				body.morir()
				queue_free()
				return
