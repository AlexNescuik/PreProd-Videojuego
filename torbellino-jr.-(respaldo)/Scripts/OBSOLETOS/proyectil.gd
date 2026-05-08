extends Area2D

@export var velocidad: float = 100.0
var direccion: Vector2 = Vector2.LEFT
var fue_desviado: bool = false
var tiempo_vida: float = 0.0

func _ready():
	add_to_group("bala")

func _physics_process(delta):
	position += direccion * velocidad * delta
	
	tiempo_vida += delta
	if tiempo_vida > 2.0:
		queue_free()
		
	if fue_desviado:
		var todos_los_enemigos = get_tree().get_nodes_in_group("enemigo")
		for enemigo in todos_los_enemigos:
			if global_position.distance_to(enemigo.global_position) < 1.0:
				if enemigo.has_method("morir"):
					print("¡HOME RUN! El enemigo fue destruido.")
					enemigo.morir()
					queue_free()
					break
