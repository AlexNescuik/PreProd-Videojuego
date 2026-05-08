extends Node2D

var sala_actual: Node2D = null

func _ready():
	for cuarto in get_children():
		var area = cuarto.get_node_or_null("Area2D")
		if area:
			# El bind() manda qué sala específica estamos pisando
			area.body_entered.connect(_on_jugador_entra.bind(cuarto))

func _on_jugador_entra(body: Node2D, cuarto: Node2D):
	# Si es el jugador y NO es la misma sala en la que ya estamos...
	if body.is_in_group("jugador") and cuarto != sala_actual:
		sala_actual = cuarto 
		print("--- Transición activada hacia: ", cuarto.name, " ---")
		
		var camara = body.get_node_or_null("Camera2D")
		if camara:
			hacer_transicion_camara(camara, cuarto)

func hacer_transicion_camara(camara: Camera2D, cuarto: Node2D):
	# 1. FORZAMOS la configuración correcta en la cámara para evitar bugs
	camara.limit_smoothed = true
	camara.position_smoothing_enabled = true
	
	# 2. Medimos la nueva sala
	var colision = cuarto.get_node("Area2D/CollisionShape2D")
	var forma = colision.shape as RectangleShape2D
	var centro = colision.global_position
	var tamano = forma.size
	
	# 3. Calculamos los muros invisibles de la cámara
	var lim_izq = int(centro.x - (tamano.x / 2.0))
	var lim_der = int(centro.x + (tamano.x / 2.0))
	var lim_sup = int(centro.y - (tamano.y / 2.0))
	var lim_inf = int(centro.y + (tamano.y / 2.0))
	
	# 4. Hacemos el paneo (El swoosh de Celeste)
	var tween = get_tree().create_tween().set_parallel(true)
	var tiempo = 0.6 # Segundos del viaje
	
	# Le decimos a los límites que viajen suavemente (TRANS_SINE) hacia sus nuevos valores
	tween.tween_property(camara, "limit_left", lim_izq, tiempo).set_trans(Tween.TRANS_SINE)
	tween.tween_property(camara, "limit_right", lim_der, tiempo).set_trans(Tween.TRANS_SINE)
	tween.tween_property(camara, "limit_top", lim_sup, tiempo).set_trans(Tween.TRANS_SINE)
	tween.tween_property(camara, "limit_bottom", lim_inf, tiempo).set_trans(Tween.TRANS_SINE)
